# MVP Entity Diagram

This view is intentionally simplified so a business user can understand the main parent/child relationships without reading SQL.

## Business View

```mermaid
flowchart TD
    T[Tenant]

    T --> U[Users]
    T --> E[Employees]
    T --> J[Jobs]
    T --> C[Crews]
    T --> A[Assets]
    T --> AE[Audit Events]

    E --> U
    J --> WI[Work Items]
    E --> CM[Crew Members]
    C --> CM

    C --> ASG[Assignments]
    J --> ASG
    WI --> ASG
    U --> ASG

    ASG --> DR[Daily Reports]
    C --> DR
    J --> DR
    U --> DR

    DR --> TE[Time Entries]
    E --> TE
    J --> TE
    WI --> TE

    U --> F[Files]
    DR --> F

    A --> AM[Asset Moves]
    U --> AM
    E --> AM
    J --> AM
    AM --> F

    A --> MWO[Maintenance Work Orders]
    DR --> MWO
    U --> MWO
    E --> MWO
    MWO --> F
```

## Parent And Child Summary

### Tenant
- Parent of every operational record.

### Users
- Optional child of `Employees`.
- Parent of created assignments, submitted reports, requested asset moves, opened work orders, uploaded files, and audit events.

### Employees
- Parent of crew memberships, time entries, assigned drivers on asset moves, assigned workers on work orders, and optional linked users.

### Jobs
- Parent of work items, assignments, daily reports, time entries, and some asset state and move references.

### Work Items
- Child of jobs.
- Optional child reference for assignments and time entries.

### Crews
- Parent of crew memberships, assignments, and daily reports.

### Assignments
- Child of crews and jobs.
- Parent of daily reports.

### Daily Reports
- Child of assignments.
- Parent of time entries.
- Optional parent of maintenance work orders and attached files.

### Assets
- Parent of asset moves and maintenance work orders.

### Asset Moves
- Child of assets.
- Can also reference jobs and employees.
- Can have attached files.

### Maintenance Work Orders
- Child of assets.
- May also be created from a daily report.
- Can have attached files.

### Files
- Generic attachment records used across daily reports, asset moves, and maintenance work orders.

### Audit Events
- Standalone trace records that point back to the entity that changed.

## Technical ER View

```mermaid
erDiagram
    TENANTS ||--o{ USERS : owns
    TENANTS ||--o{ EMPLOYEES : owns
    TENANTS ||--o{ JOBS : owns
    TENANTS ||--o{ WORK_ITEMS : owns
    TENANTS ||--o{ CREWS : owns
    TENANTS ||--o{ CREW_MEMBERS : owns
    TENANTS ||--o{ ASSIGNMENTS : owns
    TENANTS ||--o{ DAILY_REPORTS : owns
    TENANTS ||--o{ TIME_ENTRIES : owns
    TENANTS ||--o{ ASSETS : owns
    TENANTS ||--o{ ASSET_MOVES : owns
    TENANTS ||--o{ MAINTENANCE_WORK_ORDERS : owns
    TENANTS ||--o{ FILES : owns
    TENANTS ||--o{ AUDIT_EVENTS : owns

    EMPLOYEES o|--|| USERS : linked_account
    EMPLOYEES ||--o{ CREW_MEMBERS : serves_on
    EMPLOYEES ||--o{ TIME_ENTRIES : logs_time
    EMPLOYEES o|--o{ ASSET_MOVES : drives
    EMPLOYEES o|--o{ MAINTENANCE_WORK_ORDERS : assigned_to

    JOBS ||--o{ WORK_ITEMS : contains
    JOBS ||--o{ ASSIGNMENTS : planned_for
    JOBS ||--o{ DAILY_REPORTS : reported_against
    JOBS ||--o{ TIME_ENTRIES : costed_to

    CREWS ||--o{ CREW_MEMBERS : includes
    CREWS ||--o{ ASSIGNMENTS : scheduled_to
    CREWS ||--o{ DAILY_REPORTS : reports_for

    ASSIGNMENTS ||--o{ DAILY_REPORTS : executed_by
    DAILY_REPORTS ||--o{ TIME_ENTRIES : generates

    ASSETS ||--o{ ASSET_MOVES : moved_by
    ASSETS ||--o{ MAINTENANCE_WORK_ORDERS : serviced_by
    DAILY_REPORTS o|--o{ MAINTENANCE_WORK_ORDERS : may_create
```
