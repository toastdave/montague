# MVP Screen Map

This document maps the core MVP workflow to application screens.

The point is not to design final UI. The point is to define the minimum navigable product surface needed to operate the system end to end.

## Navigation Structure

Primary nav for MVP:

- Dashboard
- Work
- Schedule
- Field
- Time
- Assets
- Maintenance
- Admin

## Screen Inventory

### 1. Dashboard

Purpose:
- Gives operations staff a live summary of what needs attention today.

Main users:
- admin
- operations manager
- foreman

Reads from:
- `assignments`
- `daily_reports`
- `time_entries`
- `assets`
- `asset_moves`
- `maintenance_work_orders`

Key widgets:
- crews scheduled today
- reports not submitted
- time entries awaiting review
- assets in transit or down
- open maintenance work orders

### 2. Jobs List

Purpose:
- Browse and filter the current work portfolio.

Reads from:
- `jobs`

Actions:
- create job
- edit job
- archive/cancel job

### 3. Job Detail

Purpose:
- View one job as the parent record for planning and execution.

Reads from:
- `jobs`
- `work_items`
- `assignments`
- `daily_reports`
- `time_entries`
- `assets`

Actions:
- add work item
- review scheduled assignments
- review submitted reports and labor

### 4. Work Item Editor

Purpose:
- Create and manage the smaller work buckets under a job.

Reads from:
- `jobs`
- `work_items`

Actions:
- create work item
- mark work item complete
- flag work item billable/non-billable

### 5. Schedule Board

Purpose:
- Plan daily crew assignments.

Main users:
- operations manager
- dispatcher

Reads from:
- `crews`
- `crew_members`
- `jobs`
- `work_items`
- `assignments`

Actions:
- create assignment
- reassign crew
- move assignment date
- mark assignment cancelled/completed

### 6. Crew Detail

Purpose:
- Manage a crew as an operational scheduling unit.

Reads from:
- `crews`
- `crew_members`
- `employees`

Actions:
- edit crew
- assign foreman
- add/remove crew members

### 7. Employee Directory

Purpose:
- Manage labor/resource records, regardless of login access.

Reads from:
- `employees`
- `users`

Actions:
- create employee
- link employee to user account
- deactivate employee

### 8. User Admin

Purpose:
- Manage app access separately from labor records.

Reads from:
- `users`
- `employees`

Actions:
- invite user
- reset access
- assign role
- link/unlink employee

### 9. My Assignments

Purpose:
- Gives a foreman or field lead a focused list of their current work.

Reads from:
- `assignments`
- `crews`
- `jobs`
- `work_items`

Filters:
- today
- this week
- by assigned crew

Actions:
- open daily report

### 10. Daily Report Form

Purpose:
- Capture what actually happened for an assignment.

Reads from:
- `assignments`
- `crews`
- `crew_members`
- `employees`
- `jobs`
- `work_items`
- `daily_reports`
- `files`

Writes to:
- `daily_reports`
- `time_entries`
- `files`
- optionally `maintenance_work_orders`
- `audit_events`

Sections:
- assignment context
- crew roster
- hours by employee
- work item allocation
- notes
- photos and attachments
- equipment issue flag

### 11. Daily Report History

Purpose:
- Review past field submissions.

Reads from:
- `daily_reports`
- `time_entries`
- `files`

Actions:
- open report detail
- compare submitted labor to reviewed labor

### 12. Time Review Queue

Purpose:
- Review and correct normalized time entries before payroll/export workflows are added.

Main users:
- operations manager
- payroll reviewer

Reads from:
- `time_entries`
- `daily_reports`
- `employees`
- `jobs`
- `work_items`

Writes to:
- `time_entries`
- `audit_events`

Actions:
- filter by date/job/employee/status
- edit hours
- change work item
- mark reviewed or approved

### 13. Asset List

Purpose:
- View current equipment state in one place.

Reads from:
- `assets`
- `jobs`

Actions:
- create asset
- update baseline asset details

### 14. Asset Detail

Purpose:
- View the current status and history of one asset.

Reads from:
- `assets`
- `asset_moves`
- `maintenance_work_orders`
- `files`

Actions:
- request move
- create maintenance work order

### 15. Asset Move Board

Purpose:
- Manage planned and in-flight asset relocations.

Reads from:
- `asset_moves`
- `assets`
- `employees`
- `jobs`

Writes to:
- `asset_moves`
- `assets`
- `audit_events`

Actions:
- request move
- assign driver
- complete move
- cancel move

### 16. Maintenance Queue

Purpose:
- Manage open equipment issues.

Reads from:
- `maintenance_work_orders`
- `assets`
- `employees`
- `daily_reports`

Actions:
- assign work order
- update priority
- mark in progress
- close work order

### 17. Maintenance Work Order Detail

Purpose:
- Work the full lifecycle of one maintenance issue.

Reads from:
- `maintenance_work_orders`
- `assets`
- `files`
- `daily_reports`

Writes to:
- `maintenance_work_orders`
- `files`
- `audit_events`

### 18. File Viewer

Purpose:
- Show attached photos and documents from core workflows.

Reads from:
- `files`

Context entry points:
- daily report detail
- asset move detail
- maintenance work order detail

### 19. Audit Explorer

Purpose:
- View important system changes in one place.

Reads from:
- `audit_events`

Filters:
- entity type
- event type
- actor
- date range

## Workflow To Screen Mapping

### Define Work
- Jobs List
- Job Detail
- Work Item Editor

### Assign Labor
- Crew Detail
- Employee Directory
- Schedule Board

### Record What Happened
- My Assignments
- Daily Report Form
- Daily Report History

### Review Labor
- Time Review Queue

### Track Equipment State
- Asset List
- Asset Detail
- Asset Move Board

### Handle Exceptions
- Maintenance Queue
- Maintenance Work Order Detail
- Audit Explorer

## Recommended MVP Navigation By Role

### Admin
- Dashboard
- Jobs
- Schedule
- Assets
- Maintenance
- Admin

### Operations Manager
- Dashboard
- Jobs
- Schedule
- Time
- Assets
- Maintenance

### Foreman
- Dashboard
- Field
- My Assignments
- Daily Report History

### Payroll Reviewer
- Dashboard
- Time

### Mechanic or Driver
- Assets
- Maintenance

## Notes On Scope

These screens intentionally avoid:

- customer CRM
- accounting export management
- billing workflows
- advanced approvals
- mobile offline sync

Those can be added after the core operating loop works reliably.
