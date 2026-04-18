# MVP Feature To Table Walkthrough

This document shows how each core MVP feature uses the schema.

The goal is to answer a practical question:

"If we build feature X, which tables does it really depend on?"

## 1. Tenant Setup

Feature goal:
- Create a new company account and isolate its data.

Primary tables:
- `tenants`

Why these tables matter:
- `tenants` is the root boundary for every operational record.

What working software can do:
- provision a new tenant
- separate one company from another

## 2. User Access

Feature goal:
- Let staff log in and act in the system.

Primary tables:
- `users`
- `employees` optional link

Why these tables matter:
- `users` controls auth, role, and actor identity.
- `employees` lets an app account connect to an operational worker record.

What working software can do:
- invite a foreman or manager
- assign an app role
- track who submitted or edited records

## 3. Employee Management

Feature goal:
- Track labor resources even if they do not log in.

Primary tables:
- `employees`
- `users` optional link

Why these tables matter:
- field labor and historical payroll-facing records cannot depend on login accounts existing.

What working software can do:
- create an employee roster
- keep former employees in history
- assign employees to crews and time entries

## 4. Job Setup

Feature goal:
- Define the main unit of work the business performs.

Primary tables:
- `jobs`
- `work_items`

Why these tables matter:
- `jobs` is the top-level operational container.
- `work_items` lets a job be broken into meaningful units for assignment and labor capture.

What working software can do:
- create and manage jobs
- define standard work versus change work

## 5. Crew Management

Feature goal:
- Create reusable labor groupings for scheduling.

Primary tables:
- `crews`
- `crew_members`
- `employees`

Why these tables matter:
- crews are the main scheduling unit
- crew membership changes over time and needs history

What working software can do:
- assign a foreman
- add/remove workers from crews
- see who belonged to a crew on a given date

## 6. Scheduling

Feature goal:
- Plan who is expected to work where and on what.

Primary tables:
- `assignments`
- `crews`
- `jobs`
- `work_items`
- `users`

Why these tables matter:
- `assignments` is the planning-to-execution bridge
- `created_by_user_id` preserves who scheduled the work

What working software can do:
- schedule a crew to a job for a date
- optionally target a specific work item
- give field users a concrete record to execute against

## 7. Daily Report Submission

Feature goal:
- Record what actually happened in the field.

Primary tables:
- `daily_reports`
- `assignments`
- `crews`
- `jobs`
- `users`
- `files`

Why these tables matter:
- `daily_reports` is the execution envelope
- `files` supports photos and attachments without bloating report rows

What working software can do:
- submit a foreman report for an assignment
- capture notes and attachments
- connect the report back to planned work

## 8. Time Capture And Review

Feature goal:
- Turn field reporting into normalized labor records the office can review.

Primary tables:
- `time_entries`
- `daily_reports`
- `employees`
- `jobs`
- `work_items`

Why these tables matter:
- `time_entries` is the labor transaction table
- it stays separate from `daily_reports` so review can happen without destroying the original field submission

What working software can do:
- create one row per employee per work bucket
- edit hours during office review
- preserve a version number for later approval logic

## 9. Asset Registry

Feature goal:
- Track the current state of equipment and vehicles.

Primary tables:
- `assets`
- `jobs` optional current reference

Why these tables matter:
- `assets` is the shared state record for operations

What working software can do:
- know what equipment exists
- see where it is now
- see whether it is available, assigned, down, or under maintenance

## 10. Asset Move Workflow

Feature goal:
- Request, assign, and complete equipment relocations.

Primary tables:
- `asset_moves`
- `assets`
- `users`
- `employees`
- `jobs`

Why these tables matter:
- `asset_moves` gives movement its own workflow state
- `assets` holds the resulting current state after completion

What working software can do:
- request a move
- assign a driver
- complete the move and update current location

## 11. Maintenance Workflow

Feature goal:
- Convert equipment issues into actionable tracked work.

Primary tables:
- `maintenance_work_orders`
- `assets`
- `daily_reports` optional source
- `users`
- `employees`
- `files`

Why these tables matter:
- the issue needs a record with lifecycle, assignee, and resolution status
- the source daily report link preserves origin context

What working software can do:
- open a maintenance issue from the field
- assign it to a mechanic
- attach supporting photos
- close it with resolution notes

## 12. Audit Trail

Feature goal:
- Trace meaningful business actions across the system.

Primary tables:
- `audit_events`
- `users`

Why these tables matter:
- operations software needs more than row timestamps
- key actions need a structured event record for investigation and trust

What working software can do:
- track who changed time entries
- record who submitted reports
- record move completion and work order status changes

## End-To-End Workflow Chain

This is the main chain that proves the MVP schema is functional:

1. `jobs` and `work_items` define the work.
2. `crews` and `crew_members` define the labor group.
3. `assignments` schedules that crew to that work.
4. `daily_reports` records what actually happened.
5. `time_entries` normalizes labor from the report.
6. `asset_moves` updates equipment state when units are relocated.
7. `maintenance_work_orders` captures exceptions that need follow-up.
8. `files` stores supporting attachments.
9. `audit_events` records significant actions across the chain.

## Features Deliberately Not In Core MVP

These are useful later, but they are not required for the first real operating version:

- customer records
- site/location master tables
- billing candidates
- payroll approval batches
- accounting exports
- inspections
- vendor management
- notifications

The current schema is intentionally sized to make the main operating loop work first.
