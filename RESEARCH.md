# Montague Field Management Platform Research

## Executive Summary

This document analyzes the provided Montague Development Field Management Platform reference document as a business system and data-integration problem, not a frontend or hosting problem.

The central conclusion is:

- The company is trying to build an operations system that unifies planning, field execution, payroll, equipment, moves, maintenance, and billing.
- The hard part is not screens. The hard part is data ownership, workflow state transitions, auditability, and integration reliability.
- Google Sheets should not be the live runtime datastore for the application.
- Google Sheets should be treated as an integration and business-input layer that syncs into a canonical backend data model.
- External integrations, approvals, and operational workflows should run from the application backend, not directly from spreadsheet tabs.

This approach preserves the business's comfort with spreadsheets while avoiding the fragility of building the system directly on top of live sheet reads and writes.

## Scope Of This Research

This research intentionally ignores the document's frontend and hosting preferences except where they affect data, authentication, or integration design.

The focus here is:

- What business system this document defines
- What entities and workflows actually exist beneath the UI descriptions
- Where the document is clear versus where it is incomplete or contradictory
- How Google Sheets should be integrated effectively
- How external integrations should be structured
- What implementation order makes the most sense

## What The Company Is Actually Trying To Build

At a business level, this is not a generic field app. It is a construction operations control system.

The document describes a single operational platform spanning:

- Job planning
- Crew scheduling
- Foreman daily reporting
- Payroll preparation and approval
- Equipment location and engine-hour tracking
- Equipment move planning and execution
- Maintenance work order management
- Billing review for completed and change-order work

In practical terms, the platform is trying to replace fragmented operational coordination currently spread across multiple tools, likely including:

- Shared spreadsheets
- Manual payroll reports
- Ad hoc equipment tracking
- External planning tools like Fieldwire
- CSV-based accounting handoffs

The intended end state is a single operational source of truth with enough control to support payroll, job costing, and equipment visibility.

## Core Operational Domains

The platform can be broken into six primary domains.

### 1. Planning And Master Data

This includes:

- Jobs
- Tasks
- Change-order designation
- Crews
- Users and permissions
- Plans/links
- Settings
- Vendors

These records define the company structure and current work universe.

### 2. Scheduling And Daily Work Assignment

This includes:

- Weekly scheduling grid
- Crew-to-job assignment by day
- Task linkage to assignments
- Change-order distinction at planning time
- Pre-population of foreman daily sheets from assignments

This is the bridge between planning and execution.

### 3. Field Execution And Labor Capture

This includes:

- Foreman daily sheet
- Crew hours
- Worker-level overrides
- Task allocation
- Notes
- Photos
- Injury and incident reporting
- Equipment hours confirmation or override

This is where the company captures what actually happened in the field.

### 4. Payroll Control

This includes:

- Grouping of payroll entries by job
- Editable hours, jobs, and cost codes
- Dual approval workflow
- Approval reset when data changes
- CSV output for Foundation import
- Audit logging

This is a financial-control workflow, not just a report.

### 5. Equipment Operations

This includes:

- Equipment master
- Current location/job assignment
- Tracker/manual status
- Engine-hour updates
- Move planning
- Driver move execution
- Maintenance threshold logic

This is the company's equipment dispatch and status layer.

### 6. Maintenance And Billing

This includes:

- Maintenance work orders
- Mechanic assignment/vendor assignment
- Mechanic timesheet and costing export
- Billing queue for completed work and change-order labor

These are downstream monetization and asset-care workflows fed by upstream operational data.

## The Real Product Is Workflow Logic

The most important part of the document is not the module list. It is the workflow logic connecting modules.

The document defines several critical state transitions:

1. A schedule assignment becomes foreman daily sheet input.
2. A foreman submission becomes payroll rows.
3. A payroll edit invalidates prior approvals.
4. A completed driver move updates equipment location immediately.
5. A field equipment issue becomes a maintenance work order immediately.
6. A completed task or change-order effort becomes billing review input.

These are system events with business consequences. They must be modeled explicitly in backend logic.

That is why this system should be treated as a workflow application with integrations, not a spreadsheet-driven website.

## High-Value Requirements Hidden In The Document

Several requirements are especially important because they imply nontrivial backend behavior.

### Schedule Pre-Population

When a crew is assigned to a job on a given day, the foreman's daily sheet is pre-populated automatically.

Implications:

- Schedule assignments need stable identities.
- Foreman access needs to resolve against crew ownership and date.
- Daily work context is derived from schedule state.
- The daily sheet is not freeform entry only; it is a workflow continuation step.

### Labor Explosion On Submission

The document says submission creates an entry in the `PayrollEntries` tab for each worker/task combination.

Implications:

- The submitted form is not the same shape as payroll output.
- One submission can produce many normalized transaction rows.
- Allocation correctness matters at the worker level.
- Payroll is a derived transactional record, not a direct spreadsheet form capture.

### Approval Reset On Edit

The document says if data changes after either approver has approved, approvals reset automatically.

Implications:

- Approval is tied to a specific version of payroll data.
- Payroll data must support revision tracking or at least change fingerprinting.
- Approval reset must be enforced by backend rules, not by UI convention.

### Equipment Location As Shared Operational State

Move completion updates the equipment location instantly across the platform.

Implications:

- Equipment current location is a shared state consumed by multiple modules.
- There must be a clear owner of `current_job_id`.
- Driver move execution and manual edits can conflict unless ownership rules exist.

### Maintenance As A Side Effect Of Field Events

The foreman equipment section can flag an issue and immediately create a maintenance work order.

Implications:

- Work orders are not isolated records entered only by managers.
- Field events can create operational maintenance state.
- Notification and assignment rules matter.

### Change Orders As Distinct Operational And Financial Work

The document repeatedly emphasizes separate visual treatment for change-order tasks and labor.

Implications:

- Change-order work is not merely a label for UI color.
- It affects scheduling visibility, labor review, billing readiness, and dashboard metrics.
- It likely needs explicit reporting and lineage.

## Assessment Of The Document Quality

The document is useful and unusually detailed for a business reference, but it is still incomplete as a true implementation spec.

It is strongest in:

- Describing modules and user intent
- Defining workflow expectations
- Outlining core fields at a business level
- Explaining approval and review behavior
- Showing which external systems matter

It is weaker in:

- Defining stable identifiers
- Clarifying ownership of shared fields
- Separating reference data from transactions
- Resolving duplicate concepts across tabs
- Formalizing validation rules and source-of-truth boundaries

In short: it is a good product/operations reference, but not yet a production-ready systems design.

## Gaps, Contradictions, And Ambiguities

These are the most important implementation risks in the document.

### Roles Are Inconsistent

The document says the platform has four roles:

- Owner
- Field Manager
- Office Manager
- Administrator

However, the permission matrix also includes `Foremen/Driver` as a distinct access profile.

Additionally, the move bank repeatedly refers to an `Operations Manager` without formally defining that role.

Implications:

- The actual role model is underspecified.
- User authorization cannot be implemented cleanly until the role taxonomy is finalized.
- The app may need role plus capability mapping rather than a single flat role enum.

### Workbook Tabs Are Incomplete Relative To The Module Descriptions

The tab list includes:

- Jobs
- Tasks
- ChangeOrders
- Crews
- ScheduleAssignments
- PayrollEntries
- PayrollApprovals
- AuditLog
- Equipment
- Moves
- WorkOrders
- Vendors
- IncidentReports
- Users
- Settings

But the document also references data that would need separate storage or lookup structures:

- Plans tab for Fieldwire links
- Cost code list
- Historical 237-job list used by payroll editing
- Photo metadata and Drive linkage
- Mechanic timesheet entries

Implications:

- The tab design is incomplete.
- Several features currently lack explicit persistence models.

### ChangeOrders Duplicates Tasks Conceptually

The document says change-order items are a subset of tasks with `type = change-order`, but it also defines a separate `ChangeOrders` tab.

This is a classic duplication risk.

If `ChangeOrders` is a separate editable source, then:

- It can diverge from `Tasks`.
- One logical concept now has two sources of truth.
- Billing, reporting, and dashboards can disagree.

Best interpretation:

- There should be one task model.
- Change-order status should be a task attribute.
- Any `ChangeOrders` view should be derived, not independently authored.

### Billing Queue Logic Is Self-Conflicting

The document states:

- Nothing moves to the billing queue automatically.
- Field Manager or Administrator marks completed tasks as billable.
- All change-order tasks appear in the billing queue regardless of billable flag.

These statements cannot all mean the same thing operationally.

The most coherent interpretation is:

- Standard tasks require a manager action to become billing candidates.
- Change-order items are always billing candidates by rule.
- The queue itself is therefore a derived business view, not a manually maintained table.

### Mechanic Timesheet Storage Is Underspecified

The mechanic workflow is described in detail, but its persistence layer is not.

Unknowns include:

- Is mechanic time stored in `PayrollEntries`?
- Is there a separate `MechanicEntries` structure?
- Are mechanic entries included in approval flow or just exported weekly?
- Is there any relationship between work orders and mechanic entry rows?

This needs explicit design before implementation.

### Photos Exist Operationally But Not Structurally

The daily sheet supports photo capture and Drive storage, but there is no explicit model for:

- Photo ID
- Job/date linkage
- Submission linkage
- Uploader identity
- File URL or Drive file ID
- Retention or permissions

That is fine for a prototype but not for a system expected to support audit and operational review.

### Job Reference Model Is Incomplete

Payroll editing references a full 237-job list. The jobs module is described as active and completed jobs. It is not clear whether the same tab covers:

- Current active jobs
- Historical jobs
- Payroll-valid but operationally inactive jobs

This matters because payroll corrections often need broader job references than daily planning views.

### Identity Is Too Email-Centric

The document uses Google account email as the primary identity mechanism.

That works for authentication, but not for internal operations. The system also needs stable internal identifiers for:

- Users
- Employees
- Drivers
- Foremen
- Approvers
- Mechanic
- Crew members

Email should be a login attribute, not the sole identity key across workflows.

## Recommended System Interpretation

The right way to interpret this project is:

- Google Sheets is a business-facing operational data source.
- The application backend owns canonical business logic and runtime workflow state.
- The backend syncs selected spreadsheet data into normalized application tables.
- The backend may push selected outputs back to Sheets for visibility or compatibility.

This is the most stable approach because it lets the company keep spreadsheet familiarity without forcing the application to use a spreadsheet as its transactional engine.

## Why Google Sheets Should Be An Integration Layer, Not The Runtime Datastore

### Operational Reasons

The document contains multiple workflows that depend on correctness, consistency, and auditability:

- Dual payroll approval
- Reset-on-edit controls
- Per-worker task allocation
- Equipment move status transitions
- Immediate maintenance ticket creation
- Billing readiness logic

These are easier to implement and defend in a real backend datastore than in live spreadsheet logic.

### Concurrency Reasons

Spreadsheets are user-editable and flexible, which makes them good business tools but weak as application databases.

Problems include:

- No strong record-level locking model for app workflows
- Fragility if columns move or users alter structure
- Limited transaction semantics for multi-step business operations
- Difficulty enforcing relational constraints
- Ambiguity when humans and app logic both edit the same data

### Performance And API Reasons

Google Sheets API is strong enough for integration but not ideal for serving as the live query path for operational screens.

Relevant Google Sheets API constraints:

- Requests have quota limits per minute per project and per user.
- Heavy service-account traffic effectively concentrates usage into one identity.
- Large or slow requests can time out.
- API best practice is to batch reads and writes, not continuously query cell-by-cell.

This is acceptable for sync pipelines. It is not ideal for every screen load, filter, or mobile interaction in the field.

### Modeling Reasons

The system needs:

- Stable identifiers
- Derived state
- audit logs
- versioned approvals
- side effects across modules
- search/filter behavior across multiple related entities

Those are normal backend concerns and should be implemented in a database designed for them.

## Recommended Google Sheets Strategy

The recommended approach is a sync-based architecture.

### Principle

Use Google Sheets as an editable business input layer and reporting surface, while the application database becomes the canonical runtime model.

### Practical Model

1. Import reference and planning data from Google Sheets.
2. Normalize that data into internal application entities.
3. Run operational workflows against the internal model.
4. Push selected outputs back to Google Sheets when required for compatibility or visibility.

### What Should Stay Sheets-Owned

These are good candidates for business-owned spreadsheet maintenance:

- Users
- Jobs
- Plans links
- Vendors
- Settings
- Cost codes
- Possibly crews and equipment baseline details

These are relatively stable or administrative records.

### What Should Become App-Owned

These should be treated as backend transactional records:

- Payroll entries
- Payroll approval records
- Audit log
- Move execution timestamps and status changes
- Incident reports
- Work order lifecycle transitions
- Photo metadata
- Mechanic time entries

These are operational transactions that need reliable workflow rules.

### Hybrid Areas Requiring Explicit Ownership Rules

Some data crosses planning and execution boundaries and must have field-level ownership defined.

Examples:

- Tasks
- Schedule assignments
- Equipment current location
- Equipment engine hours
- Billing readiness state

Each of these needs a decision about whether Sheets edits remain authoritative or whether the app becomes the runtime owner after import.

## How To Effectively Get Their Data From Google Sheets

This is the key implementation question.

### 1. Use A Service Account For Backend Sync

Recommended pattern:

- Create a service account for server-side access.
- Share the workbook with that service account.
- Use that account for scheduled imports and optional controlled writes.

Why:

- It decouples app sync from any individual employee account.
- It simplifies server-side automation.
- It makes permission scope easier to manage.

### 2. Perform Full Initial Import By Tab

Use the Google Sheets API to read the workbook in structured batches.

Recommended read strategy:

- Read whole logical tab ranges with headers.
- Use `batchGet` where practical to reduce request count.
- Parse each tab into a typed import pipeline.

Do not:

- Build logic around row numbers
- Hardcode fragile cell-level assumptions without validation
- Continuously fetch one small range per screen interaction

### 3. Normalize Each Tab Into Canonical Entities

Each sheet row should be mapped into an internal entity with:

- Stable primary key
- Business key if applicable
- Source metadata
- Validation state
- Last synced timestamp

For example, a job imported from `Jobs` should not remain "just a spreadsheet row" in the app. It should become a real internal `job` record.

### 4. Store Source Metadata On Imported Records

Every imported record should track provenance such as:

- Spreadsheet ID
- Tab name
- Imported row key or row hash
- Import timestamp
- Sync batch ID
- Last seen checksum/version

Why this matters:

- Easier debugging
- Easier re-sync and reconciliation
- Better traceability when business users ask where a value came from

### 5. Validate Aggressively On Import

Import should not silently coerce bad data if the data affects operations.

Examples of validation:

- Required job number present
- Unique unit number
- Valid status enum
- Valid date format
- Known crew reference
- Known task/job relationship
- Known cost code

Malformed rows should be:

- Rejected into an import error queue, or
- Imported with explicit warning status for admin review

Silent guessing will create payroll and equipment problems later.

### 6. Use Incremental Sync After Initial Load

Once the initial load is complete, move to incremental refresh.

Recommended pattern:

- Poll key tabs on a schedule
- Re-import tabs whose source changed
- Compare row hashes/business keys to detect inserts, updates, removals
- Update internal records accordingly

### 7. Treat Drive Notifications As Invalidators, Not Business Events

Google Drive provides push notifications for changes to files. That can be useful for the spreadsheet.

However:

- Drive notifications tell you a file changed, not exactly which rows changed.
- Watch channels expire and must be renewed.
- Notifications should trigger a re-sync process, not direct business logic.

Best use:

- Spreadsheet changed -> queue tab re-import -> reconcile differences.

### 8. Keep A Polling Fallback

Do not rely exclusively on push notifications.

Use both:

- Scheduled polling for reliability
- Push-triggered sync for freshness

This gives you resilience when webhooks expire or fail.

### 9. Write Back Selectively To Sheets

If the business still wants certain outputs visible in Google Sheets, use controlled writes.

Good write-back candidates:

- Read-only reporting tabs
- Approval snapshots
- Audit exports
- Billing review outputs
- Derived operational summaries

Bad write-back candidates:

- Any tab that staff actively edits while the app also treats it as transactional truth

### 10. Avoid Live App Reads From Sheets For Operational UI

The application should serve screens from its own database.

That includes:

- Dashboard
- Schedule views
- Foreman daily sheet context
- Payroll approval tables
- Equipment lists
- Driver queue
- Maintenance queue

The sync layer should refresh backend state. The UI should query backend state.

## Recommended Data Ownership Model

The single most important implementation artifact after this research should be a source-of-truth matrix.

At minimum, every entity and critical field should answer:

- Who can edit it?
- Where is it authored first?
- Which system is authoritative?
- Can it be overwritten by sync?
- Is it derived?

Below is the recommended direction.

### Users

- Business source: Google Sheet `Users`
- Canonical runtime: App database copy
- Notes: Email is for login mapping; internal user ID should drive workflows.

### Jobs

- Business source: Google Sheet `Jobs`
- Canonical runtime: App database copy
- Notes: Need stable internal `job_id` plus business `job_number`.

### Tasks

- Business source: Google Sheet `Tasks`
- Canonical runtime: App database copy
- Notes: `type = change-order` should remain on the task model itself.

### Crews And Crew Membership

- Business source: Sheets
- Canonical runtime: App database copy
- Notes: Crew membership and foreman linkage need formal structure.

### Schedule Assignments

- Preferred source: App-owned after initial setup
- Reason: Assignments feed time entry and should behave transactionally.

### Payroll Entries

- Source: App-owned
- Reason: These are produced by submissions and edits, then approved and exported.

### Payroll Approvals

- Source: App-owned
- Reason: Approval records are version-sensitive workflow data.

### Audit Log

- Source: App-owned
- Reason: It must be tamper-resistant relative to ordinary sheet editing.

### Equipment Master

- Baseline source: Sheet import
- Runtime source: App database
- Notes: Location, last move date, maintenance status, and tracker-derived values should become operational app state.

### Moves

- Source: App-owned
- Reason: These have status transitions, timestamps, and immediate downstream effects.

### Work Orders

- Source: App-owned
- Reason: They are transactional lifecycle records created by system actions and users.

### Incident Reports

- Source: App-owned
- Reason: They originate from submissions and may carry compliance implications.

### Photos

- File storage: Google Drive
- Metadata source: App-owned
- Reason: Need structured linkage independent of folder naming alone.

### Billing Queue

- Best modeled as: Derived app view
- Reason: It is computed from tasks, completion, billable flags, and CO rules.

## Recommended Canonical Entity Set

The document describes many tabs, but the application needs a normalized entity model underneath them.

Recommended core entities:

- `user`
- `role_assignment`
- `employee`
- `crew`
- `crew_member`
- `job`
- `task`
- `schedule_assignment`
- `daily_submission`
- `daily_submission_worker`
- `daily_submission_task_allocation`
- `payroll_entry`
- `payroll_approval`
- `equipment_unit`
- `equipment_telemetry_snapshot`
- `equipment_move`
- `work_order`
- `vendor`
- `incident_report`
- `photo_asset`
- `billing_candidate`
- `audit_event`
- `settings_entry`

This normalized model will be easier to reason about than trying to make every business concept map 1:1 to a sheet tab.

## Workbook Improvements Recommended Before Or During Build

If the company continues maintaining a master workbook, it should be improved to be machine-friendly.

### Add Missing Tabs Or Equivalent Structures

Recommended additions:

- `Plans`
- `CostCodes`
- `Employees`
- `Photos`
- `MechanicEntries`
- Possibly `ImportErrors` or `SyncStatus`

### Add Stable Primary Keys Everywhere

Each tab should have a dedicated primary key column.

Examples:

- `job_id`
- `task_id`
- `crew_id`
- `employee_id`
- `assignment_id`
- `unit_id`
- `move_id`
- `work_order_id`
- `incident_id`
- `vendor_id`
- `user_id`

Do not rely on row numbers or only on human-readable fields.

### Standardize Dates And Enums

Recommended standards:

- Dates as ISO `YYYY-MM-DD`
- Times as 24-hour or clearly normalized values
- Enum columns restricted to known values
- Boolean columns standardized consistently

This reduces sync complexity and locale-related issues.

### Separate Human Labels From Keys

Store both machine identifiers and user-facing display values where needed.

Example:

- `job_id`
- `job_number`
- `job_name`

This keeps relational joins stable even when labels change.

## Module-By-Module Research Findings

### Dashboard

This is a derived analytics surface, not a source module.

It depends on:

- Jobs
- Tasks
- Change-order classification
- Payroll entries

Recommendation:

- Compute dashboard metrics in the app from normalized data.
- Do not query multiple sheet tabs live to render dashboard cards.

### Schedule

This is one of the most important upstream modules because it drives field execution.

Key design insight:

- Schedule assignments should be treated as business records with stable IDs.
- Past weeks being read-only implies version/freeze behavior.
- Multiple crews per job/day means the assignment model is one-to-many, not one cell = one assignment.

Recommended implementation concept:

- Each visual chip in the schedule corresponds to a concrete `schedule_assignment` record.

### Foreman Daily Sheet

This is the most operationally dense module in the system.

It combines:

- Preloaded context
- Time capture
- Task allocation
- Equipment review
- Incident capture
- Photos
- Notes
- Language support

Important backend interpretation:

- The submitted form should persist as a submission envelope plus normalized transaction rows.
- Balance logic should be calculated server-side as well as client-side.
- Submission should create linked artifacts, not just dump a flat sheet row.

### Payroll Approval

This is a control module with legal/financial importance.

Key requirements:

- Only named approvers can approve their own slot.
- Edits invalidate approvals.
- All actions are logged.
- CSV export must match Foundation's import format.

This should be treated as a controlled state machine, not just an editable table.

### Jobs And Tasks

This is the planning model for actual work.

Key recommendation:

- Keep one task model.
- Use task attributes for status, type, billable, billed, estimated hours, assigned crew, and dates.
- Derive change-order views from tasks rather than creating a separate editable change-order table.

### Equipment Tracking

This is both a master-data and runtime-status module.

Important distinction:

- Baseline equipment attributes can originate from business-maintained records.
- Runtime fields such as current job, tracker health, imported hours, maintenance flags, and last moved date should become app-managed operational state.

The `force manual` field is especially important because it reflects conflict resolution between live telemetry and field reality.

### Move Bank And Driver Timesheet

This module is effectively dispatch plus execution tracking.

Important implications:

- Driver sees filtered assignment queue by identity.
- Move transitions affect equipment records immediately.
- Unplanned moves introduce operational exceptions that require visibility and audit.

This is a transactional module and should be app-owned.

### Maintenance Management

This module links equipment condition, work execution, and costing.

Important design requirement:

- Work orders need structured lifecycle management.
- Work queue ordering by priority is business logic, not merely sorting.
- Mechanic timesheet and work orders should likely be linkable, even though the document does not say so explicitly.

### Billing Queue

This should not be treated as a manually maintained source unless there is a compelling business reason.

Best interpretation:

- It is a staging view derived from completed tasks, CO status, billable flags, labor totals, and billing state.

This will make consistency much easier than trying to maintain it separately.

## External Integration Research Findings

### Google Sheets API

Google Sheets API is appropriate for:

- Initial import
- Periodic sync
- Controlled write-back
- Reading reference data in batches

It is not ideal as a real-time application datastore for all operational UI.

Relevant capabilities:

- `spreadsheets.values.batchGet` for batch reads
- `spreadsheets.values.batchUpdate` for batched writes
- `spreadsheets.batchUpdate` for structural or formatting operations if ever needed

Relevant usage considerations from Google documentation:

- Quotas apply per minute per project and per user.
- Batching is recommended.
- Processing timeouts can occur for long-running requests.
- Sheets updates are atomic per request batch.

### Google Drive

Google Drive matters for two reasons:

1. Spreadsheet file change notification
2. Photo storage

Drive push notifications are useful for signaling that a spreadsheet file changed, but they should not be treated as row-level change events.

Recommended use:

- Drive change notification -> enqueue workbook re-sync -> reconcile updates

### GoAardvark

The document explicitly says API availability is pending. Therefore, this integration should be treated as uncertain.

Recommended design:

- Build an adapter interface that supports both API ingestion and CSV ingestion.
- Store raw imported telemetry separately from operational equipment state.
- Reconcile telemetry into the equipment model after validation.

That way, if the vendor offers only CSV or inconsistent API coverage, the rest of the system remains stable.

### Foundation / Intuit Enterprise

This is currently a file-based downstream integration.

The document's current operational reality is:

- Payroll export CSV after dual approval
- Mechanic CSV weekly or on payroll approval
- Manual import by office staff

Recommendation:

- Treat Foundation as an export boundary first.
- Make file generation exact and testable.
- Do not prioritize automated API push until the upstream payroll and mechanic models are stable.

## Recommended Architecture Shape

The recommended architecture is straightforward conceptually even if the implementation details will vary.

### Layer 1: Canonical Backend Model

Purpose:

- Hold normalized entities
- Support operational queries
- Enforce workflow rules
- Maintain audit trail

### Layer 2: Google Sheets Sync Layer

Purpose:

- Import staff-maintained spreadsheet data
- Validate and reconcile sheet changes
- Optionally publish selected outputs back to Sheets

### Layer 3: Workflow Services

Purpose:

- Submission handling
- Payroll entry generation
- Approval reset logic
- Equipment move completion side effects
- Work order creation
- Billing candidate derivation

### Layer 4: External Integration Adapters

Purpose:

- Sheets API adapter
- Drive adapter
- GoAardvark adapter
- Foundation export adapter
- Fieldwire link resolution if needed

### Layer 5: Audit And Notification Layer

Purpose:

- Track significant state changes
- Record approvals, edits, downloads, and operational events
- Notify management when incidents, moves, or maintenance events occur

## Recommended Sync Design

### Sync Categories

Not all tabs should sync the same way.

Recommended categories:

#### Category A: Reference/Admin Data

Examples:

- Users
- Vendors
- Settings
- Cost codes

Characteristics:

- Lower change frequency
- Usually admin-maintained
- Good fit for scheduled polling or manual refresh

#### Category B: Planning Data

Examples:

- Jobs
- Tasks
- Crews
- Plans

Characteristics:

- Medium change frequency
- Business-owned but operationally significant
- Good fit for frequent polling plus import validation

#### Category C: Runtime Transactional Data

Examples:

- Payroll entries
- Approvals
- Moves
- Work orders
- Incident reports
- Photos

Characteristics:

- High integrity requirements
- Should be app-owned
- Write-back to Sheets only if business visibility requires it

### Import Pipeline Pattern

Recommended import sequence for each tab:

1. Read source range
2. Parse header row
3. Validate schema version/required columns
4. Transform rows into typed records
5. Validate business rules
6. Upsert canonical records
7. Mark missing/removed records where appropriate
8. Record sync result and import errors

### Conflict Handling

For hybrid domains, define conflict strategy explicitly.

Examples:

- If a sheet user edits equipment location after a driver completes a move, which wins?
- If payroll rows were exported and someone edits a source submission later, what happens?
- If a task changes type from regular to CO after hours are logged, how is billing affected?

Without explicit conflict policy, sync becomes unpredictable.

## Biggest Risks If The Project Follows The Original Document Too Literally

### 1. Treating Google Sheets As A Real Application Database

This will cause:

- Runtime fragility
- Sync confusion
- Performance bottlenecks
- Difficult audit control

### 2. Duplicating Concepts Across Tabs Without A Canonical Model

Examples:

- Tasks vs ChangeOrders
- Jobs vs historical payroll job list
- Equipment baseline vs tracker-imported state

### 3. Not Defining Field Ownership

The company needs to know exactly which system owns each critical field.

### 4. Building Approval Logic Only In UI

If approval reset is enforced only visually, data integrity will fail.

### 5. Letting Human Sheet Edits Compete With App Transactions

This is especially dangerous for:

- Payroll
- Equipment location
- Maintenance state
- Billing status

### 6. Not Formalizing Stable IDs Early

Without IDs, integrations and reconciliation become much harder later.

## Recommended MVP Build Order

This project should be built in dependency order, not document order.

### Phase 1: Data Foundations

- Finalize entity model
- Define source-of-truth matrix
- Define workbook schema expectations
- Build Sheets import pipeline
- Import users, jobs, tasks, crews, equipment, vendors, settings, plans, cost codes

### Phase 2: Scheduling And Foreman Daily Workflow

- Schedule assignments
- Foreman daily sheet context generation
- Submission capture
- Worker/task allocation logic
- Incident and photo linkage

### Phase 3: Payroll Workflow

- Payroll entry generation
- Payroll review grouping
- Direct edits
- Dual approval
- Approval reset on edit
- Audit logging
- Foundation CSV export

### Phase 4: Equipment Moves And Maintenance

- Equipment master operational state
- Move planning and driver execution
- Equipment location updates
- Work order generation
- Mechanic workflow and exports

### Phase 5: Billing And Reporting

- Billing candidate derivation
- Change-order reporting
- Dashboard metrics
- Export/report surfaces as needed

### Phase 6: GoAardvark Integration Hardening

- Add API or CSV ingestion path
- Reconcile telemetry into equipment state
- Add monitoring for tracker data quality

## Decisions That Should Be Locked Before Development Starts

These are the most important unresolved product decisions.

1. Is `ChangeOrders` a true source table or a derived subset of tasks?
2. What is the authoritative employee/crew membership source?
3. Which tabs are staff-editable versus app-managed?
4. Which fields on equipment are sheet-owned versus runtime-owned?
5. Is billing queue persisted or derived?
6. How are mechanic entries stored and related to work orders?
7. What is the formal role model, including foremen, drivers, and operations manager?
8. What spreadsheet schema governance exists to prevent accidental structural edits?

## Final Recommendation

The company's document is a strong business reference, but it should be translated into a backend-first workflow system with a controlled Google Sheets integration boundary.

The clearest implementation stance is:

- Keep Google Sheets because the business already thinks in spreadsheets.
- Do not let Google Sheets remain the live operational engine.
- Import spreadsheet data into a canonical application model.
- Run workflows, approvals, audit, and integrations from the application backend.
- Push only selected outputs back to Sheets where the business still benefits from spreadsheet visibility.

That gives the project the best balance of:

- Business familiarity
- Operational correctness
- Integration reliability
- Auditability
- Long-term maintainability

## Recommended Next Artifact

The next useful document after this one should be a build-oriented implementation blueprint containing:

- Canonical entity schema
- Sheet-to-entity mapping table
- Source-of-truth ownership matrix
- Sync strategy by tab
- Open questions register
- MVP delivery phases

That would turn this research into an execution-ready technical foundation.
