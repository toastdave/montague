# MVP Core Schema

This document defines the smallest relational model that can support a real working version of the product.

The goal of this schema is not to model every future concept. The goal is to support the core operating loop:

1. Define work
2. Assign labor
3. Record what happened
4. Review labor
5. Track equipment state
6. Handle exceptions

## Design Principles

- Keep one table per real business concept.
- Separate planning records from execution records.
- Separate login/access from labor/resource identity.
- Prefer a simple direct model over polymorphic workflow tables in MVP.
- Defer accounting, billing, and advanced permission tables until the core loop is solid.

## Postgres Implementation Notes

The SQL companion file, `mvp_schema.sql`, is written specifically for Postgres and adds a few production-oriented choices beyond the conceptual model in this document.

- UUID primary keys default with `gen_random_uuid()`.
- Case-insensitive emails use `citext`.
- Status and role columns use Postgres enum types instead of freeform text.
- `updated_at` is maintained with a trigger instead of relying on application code.
- Date and workflow sanity checks are enforced at the database layer where practical.
- Foreign keys use `on delete set null` only where preserving historical records matters more than strict parent deletion.

These choices keep the schema simple enough for MVP while making it harder for bad data or inconsistent status values to leak in.

## Why `users` And `employees` Are Separate

These two tables look similar at first, but they serve different purposes.

- `users` are application accounts. They log in, perform approvals, submit reports, and appear in audit history.
- `employees` are labor resources. They appear on crews, time entries, asset moves, and work orders whether or not they ever log in.

That separation matters because an MVP still needs to support:

- field workers whose foreman submits time for them
- mechanics and drivers who may not need full app access
- former employees who must remain on historical records
- employee setup before login credentials are issued

## Table Groups

### Platform Boundary

#### `tenants`
Purpose:
- Defines the SaaS account boundary.
- Every core business record belongs to exactly one tenant.

Why it is a separate table:
- Multi-tenant isolation is a first-class product requirement.

Key fields:
- `id`
- `name`
- `slug`
- `status`
- `timezone`

Parent entities:
- none

Child entities:
- all other core tables

#### `users`
Purpose:
- Stores login accounts and app roles.
- Represents actors who perform actions in the system.

Why it is a separate table:
- Authentication and authorization are not the same thing as labor identity.

Key fields:
- `id`
- `tenant_id`
- `employee_id` nullable
- `email`
- `password_hash`
- `role`
- `status`
- `last_login_at`

Parent entities:
- `tenants`

Child entities:
- `assignments.created_by_user_id`
- `daily_reports.submitted_by_user_id`
- `asset_moves.requested_by_user_id`
- `maintenance_work_orders.opened_by_user_id`
- `files.uploaded_by_user_id`
- `audit_events.actor_user_id`

#### `employees`
Purpose:
- Stores the business-side identity of workers and staff.
- Provides the labor/resource records used by crews, time, moves, and maintenance.

Why it is a separate table:
- The business must track people who do work even if they do not have a login.

Key fields:
- `id`
- `tenant_id`
- `first_name`
- `last_name`
- `display_name`
- `employee_number`
- `employment_status`
- `worker_type`
- `hire_date`
- `terminated_at`

Parent entities:
- `tenants`

Child entities:
- `users.employee_id`
- `crews.foreman_employee_id`
- `crew_members.employee_id`
- `time_entries.employee_id`
- `asset_moves.assigned_driver_employee_id`
- `maintenance_work_orders.assigned_employee_id`

### Work Planning

#### `jobs`
Purpose:
- Top-level unit of planned work.
- Main operational container for scheduling, execution, labor, and equipment usage.

Why it is a separate table:
- Jobs are the primary thing the business plans and measures work against.

Key fields:
- `id`
- `tenant_id`
- `job_number`
- `name`
- `status`
- `start_date`
- `end_date`

Parent entities:
- `tenants`

Child entities:
- `work_items.job_id`
- `assignments.job_id`
- `daily_reports.job_id`
- `time_entries.job_id`
- `assets.current_job_id`
- `asset_moves.from_job_id`
- `asset_moves.to_job_id`

#### `work_items`
Purpose:
- Breaks a job into smaller operational or billable buckets of work.
- Supports regular work and change/extra work without needing separate tables.

Why it is a separate table:
- Job-level tracking alone is too coarse once the business needs task-level labor visibility.

Key fields:
- `id`
- `tenant_id`
- `job_id`
- `code`
- `name`
- `type`
- `status`
- `is_billable`

Parent entities:
- `tenants`
- `jobs`

Child entities:
- `assignments.work_item_id`
- `time_entries.work_item_id`

### Crew Scheduling

#### `crews`
Purpose:
- Represents the labor unit that is usually scheduled together.
- Gives the business a stable object for planning and field accountability.

Why it is a separate table:
- Blue collar scheduling is usually crew-first, not only employee-first.

Key fields:
- `id`
- `tenant_id`
- `name`
- `foreman_employee_id`
- `status`

Parent entities:
- `tenants`
- `employees`

Child entities:
- `crew_members.crew_id`
- `assignments.crew_id`
- `daily_reports.crew_id`

#### `crew_members`
Purpose:
- Tracks which employees belong to which crew over time.

Why it is a separate table:
- Crew membership is many-to-many and changes over time.

Key fields:
- `id`
- `tenant_id`
- `crew_id`
- `employee_id`
- `role_in_crew`
- `start_date`
- `end_date`

Parent entities:
- `tenants`
- `crews`
- `employees`

Child entities:
- none

#### `assignments`
Purpose:
- Connects planning to execution.
- Defines which crew is expected to do which work on which date.

Why it is a separate table:
- An assignment is a scheduled commitment, not just a job or a report.

Key fields:
- `id`
- `tenant_id`
- `assignment_date`
- `crew_id`
- `job_id`
- `work_item_id` nullable
- `status`
- `shift_start`
- `shift_end`
- `created_by_user_id`

Parent entities:
- `tenants`
- `crews`
- `jobs`
- `work_items` optional
- `users`

Child entities:
- `daily_reports.assignment_id`

### Field Execution

#### `daily_reports`
Purpose:
- Captures the foreman or field lead submission for what actually happened.
- Holds context, notes, and exceptions at the report level.

Why it is a separate table:
- A field report is broader than labor rows and acts as the execution envelope.

Key fields:
- `id`
- `tenant_id`
- `assignment_id`
- `crew_id`
- `job_id`
- `report_date`
- `submitted_by_user_id`
- `status`
- `notes`
- `submitted_at`

Parent entities:
- `tenants`
- `assignments`
- `crews`
- `jobs`
- `users`

Child entities:
- `time_entries.daily_report_id`
- `files` via `related_entity_type = daily_report`
- `maintenance_work_orders.source_daily_report_id`

#### `time_entries`
Purpose:
- Stores normalized labor rows used for review and downstream payroll preparation.

Why it is a separate table:
- The labor transaction is not the same thing as the report that produced it.

Key fields:
- `id`
- `tenant_id`
- `daily_report_id`
- `employee_id`
- `job_id`
- `work_item_id` nullable
- `work_date`
- `hours`
- `status`
- `version`
- `edit_reason`

Parent entities:
- `tenants`
- `daily_reports`
- `employees`
- `jobs`
- `work_items` optional

Child entities:
- none

#### `files`
Purpose:
- Stores uploaded file metadata for photos and documents.
- Allows the same attachment system to be reused across reports and work orders.

Why it is a separate table:
- File metadata should not be embedded directly into workflow rows.

Key fields:
- `id`
- `tenant_id`
- `uploaded_by_user_id`
- `storage_key`
- `file_name`
- `mime_type`
- `related_entity_type`
- `related_entity_id`

Parent entities:
- `tenants`
- `users`

Child entities:
- none

### Equipment Operations

#### `assets`
Purpose:
- Represents equipment, vehicles, and other tracked units.
- Stores current operational state in the simplest possible MVP shape.

Why it is a separate table:
- Equipment has its own operational lifecycle and shared state.

Key fields:
- `id`
- `tenant_id`
- `asset_number`
- `name`
- `asset_type`
- `status`
- `current_job_id` nullable
- `current_location_label`
- `current_meter_hours`

Parent entities:
- `tenants`
- `jobs` optional

Child entities:
- `asset_moves.asset_id`
- `maintenance_work_orders.asset_id`

#### `asset_moves`
Purpose:
- Tracks planned and completed asset relocations.
- Provides the event history that updates asset state.

Why it is a separate table:
- A move is a workflow record with its own status, timestamps, and assignee.

Key fields:
- `id`
- `tenant_id`
- `asset_id`
- `from_type`
- `from_job_id` nullable
- `from_label`
- `to_type`
- `to_job_id` nullable
- `to_label`
- `status`
- `requested_by_user_id`
- `assigned_driver_employee_id` nullable
- `scheduled_for`
- `completed_at`

Parent entities:
- `tenants`
- `assets`
- `jobs` optional
- `users`
- `employees` optional

Child entities:
- `files` via `related_entity_type = asset_move`

### Exceptions And Control

#### `maintenance_work_orders`
Purpose:
- Turns asset issues into actionable work.
- Tracks maintenance lifecycle from open to close.

Why it is a separate table:
- Maintenance is not just a note on an asset. It has assignment, priority, and resolution state.

Key fields:
- `id`
- `tenant_id`
- `asset_id`
- `source_daily_report_id` nullable
- `title`
- `description`
- `priority`
- `status`
- `opened_by_user_id`
- `assigned_employee_id` nullable
- `opened_at`
- `closed_at`

Parent entities:
- `tenants`
- `assets`
- `daily_reports` optional
- `users`
- `employees` optional

Child entities:
- `files` via `related_entity_type = maintenance_work_order`

#### `audit_events`
Purpose:
- Stores important system and user actions for traceability.
- Supports review of edits, submissions, moves, and maintenance actions.

Why it is a separate table:
- Audit history should not be mixed into workflow tables.

Key fields:
- `id`
- `tenant_id`
- `actor_user_id` nullable
- `event_type`
- `entity_type`
- `entity_id`
- `summary`
- `payload_json`
- `occurred_at`

Parent entities:
- `tenants`
- `users` optional

Child entities:
- none

## Core Relationship Summary

- A `tenant` owns every other record.
- An `employee` may optionally have a linked `user` account.
- A `job` can have many `work_items`.
- A `crew` is made up of many `crew_members`.
- An `assignment` links one crew to one job for one date.
- A `daily_report` is the execution record for an assignment.
- A `daily_report` creates many `time_entries`.
- An `asset_move` changes the operational state of an `asset`.
- A `maintenance_work_order` belongs to one `asset` and may come from one `daily_report`.
- `files` can attach to multiple core workflow records.
- `audit_events` record meaningful actions across the entire model.

## Intentionally Deferred From MVP Core

These concepts are useful, but they are not required for the first working version of the product:

- customers
- sites
- cost codes
- approval batches and approval actions
- billing candidates
- inspections
- maintenance labor entries
- vendors
- notifications
- export runs

Those can be added later once the core operating loop is stable.
