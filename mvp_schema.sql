-- MVP core relational schema
-- Postgres-oriented draft for the first working version of the product.
-- The focus is on core workflow tables only.

-- ---------------------------------------------------------------------------
-- Platform boundary
-- ---------------------------------------------------------------------------

create table tenants (
    id uuid primary key,
    name text not null,
    slug text not null unique,
    status text not null default 'active',
    timezone text not null default 'America/Chicago',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (status in ('active', 'inactive'))
);

-- Users are app accounts. They log in and perform system actions.
create table users (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    employee_id uuid null,
    email text not null,
    password_hash text not null,
    role text not null,
    status text not null default 'active',
    last_login_at timestamptz null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, email),
    check (role in ('admin', 'operations_manager', 'foreman', 'worker', 'driver', 'mechanic', 'payroll')),
    check (status in ('active', 'inactive', 'invited'))
);

-- Employees are labor resources whether or not they have app access.
create table employees (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    first_name text not null,
    last_name text not null,
    display_name text not null,
    phone text null,
    employee_number text not null,
    employment_status text not null default 'active',
    worker_type text not null default 'worker',
    hire_date date null,
    terminated_at timestamptz null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, employee_number),
    check (employment_status in ('active', 'inactive', 'terminated', 'leave')),
    check (worker_type in ('worker', 'foreman', 'driver', 'mechanic', 'manager', 'office'))
);

alter table users
    add constraint users_employee_id_fkey
    foreign key (employee_id) references employees(id);

create unique index users_employee_id_unique
    on users(employee_id)
    where employee_id is not null;

-- ---------------------------------------------------------------------------
-- Work planning
-- ---------------------------------------------------------------------------

create table jobs (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    job_number text not null,
    name text not null,
    status text not null default 'active',
    start_date date null,
    end_date date null,
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, job_number),
    check (status in ('draft', 'active', 'on_hold', 'completed', 'cancelled'))
);

create table work_items (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    job_id uuid not null references jobs(id),
    code text null,
    name text not null,
    type text not null default 'standard',
    status text not null default 'active',
    is_billable boolean not null default true,
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (type in ('standard', 'change_order', 'time_and_material', 'rework', 'internal')),
    check (status in ('active', 'completed', 'cancelled'))
);

create index work_items_job_id_idx on work_items(job_id);

-- ---------------------------------------------------------------------------
-- Crew scheduling
-- ---------------------------------------------------------------------------

create table crews (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    name text not null,
    foreman_employee_id uuid null references employees(id),
    status text not null default 'active',
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, name),
    check (status in ('active', 'inactive'))
);

create table crew_members (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    crew_id uuid not null references crews(id),
    employee_id uuid not null references employees(id),
    role_in_crew text not null default 'member',
    start_date date not null,
    end_date date null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, crew_id, employee_id, start_date),
    check (role_in_crew in ('foreman', 'driver', 'operator', 'member'))
);

create index crew_members_crew_id_idx on crew_members(crew_id);
create index crew_members_employee_id_idx on crew_members(employee_id);

-- Assignments are the planning-to-execution bridge.
create table assignments (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    assignment_date date not null,
    crew_id uuid not null references crews(id),
    job_id uuid not null references jobs(id),
    work_item_id uuid null references work_items(id),
    status text not null default 'planned',
    shift_start time null,
    shift_end time null,
    notes text null,
    created_by_user_id uuid not null references users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (status in ('planned', 'in_progress', 'completed', 'cancelled'))
);

create index assignments_assignment_date_idx on assignments(assignment_date);
create index assignments_crew_id_idx on assignments(crew_id);
create index assignments_job_id_idx on assignments(job_id);

-- ---------------------------------------------------------------------------
-- Field execution
-- ---------------------------------------------------------------------------

-- Daily reports capture what actually happened for an assignment.
create table daily_reports (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    assignment_id uuid not null references assignments(id),
    crew_id uuid not null references crews(id),
    job_id uuid not null references jobs(id),
    report_date date not null,
    submitted_by_user_id uuid not null references users(id),
    status text not null default 'draft',
    notes text null,
    submitted_at timestamptz null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (assignment_id, report_date),
    check (status in ('draft', 'submitted', 'reviewed'))
);

create index daily_reports_job_id_idx on daily_reports(job_id);
create index daily_reports_crew_id_idx on daily_reports(crew_id);
create index daily_reports_report_date_idx on daily_reports(report_date);

-- Time entries are normalized labor rows derived from daily reports.
create table time_entries (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    daily_report_id uuid not null references daily_reports(id),
    employee_id uuid not null references employees(id),
    job_id uuid not null references jobs(id),
    work_item_id uuid null references work_items(id),
    work_date date not null,
    hours numeric(6,2) not null,
    status text not null default 'draft',
    version integer not null default 1,
    edit_reason text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (hours > 0),
    check (status in ('draft', 'submitted', 'approved', 'exported')),
    check (version > 0)
);

create index time_entries_daily_report_id_idx on time_entries(daily_report_id);
create index time_entries_employee_id_idx on time_entries(employee_id);
create index time_entries_job_id_idx on time_entries(job_id);
create index time_entries_work_date_idx on time_entries(work_date);

-- Files hold attachment metadata for reports, moves, and work orders.
create table files (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    uploaded_by_user_id uuid not null references users(id),
    storage_key text not null,
    file_name text not null,
    mime_type text not null,
    size_bytes bigint null,
    related_entity_type text not null,
    related_entity_id uuid not null,
    created_at timestamptz not null default now(),
    check (related_entity_type in ('daily_report', 'asset_move', 'maintenance_work_order'))
);

create index files_related_entity_idx on files(related_entity_type, related_entity_id);

-- ---------------------------------------------------------------------------
-- Equipment operations
-- ---------------------------------------------------------------------------

-- Assets keep the current operational state directly on the row for MVP simplicity.
create table assets (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    asset_number text not null,
    name text not null,
    asset_type text not null,
    status text not null default 'available',
    current_job_id uuid null references jobs(id),
    current_location_label text not null,
    current_meter_hours numeric(10,2) null,
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, asset_number),
    check (status in ('available', 'assigned', 'in_transit', 'down', 'maintenance', 'retired')),
    check (current_meter_hours is null or current_meter_hours >= 0)
);

-- Asset moves are the event records that update asset location and assignment state.
create table asset_moves (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    asset_id uuid not null references assets(id),
    from_type text not null,
    from_job_id uuid null references jobs(id),
    from_label text not null,
    to_type text not null,
    to_job_id uuid null references jobs(id),
    to_label text not null,
    status text not null default 'requested',
    requested_by_user_id uuid not null references users(id),
    assigned_driver_employee_id uuid null references employees(id),
    scheduled_for timestamptz null,
    completed_at timestamptz null,
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (from_type in ('yard', 'job', 'shop', 'vendor', 'other')),
    check (to_type in ('yard', 'job', 'shop', 'vendor', 'other')),
    check (status in ('requested', 'assigned', 'in_transit', 'completed', 'cancelled'))
);

create index asset_moves_asset_id_idx on asset_moves(asset_id);
create index asset_moves_status_idx on asset_moves(status);

-- ---------------------------------------------------------------------------
-- Exceptions and control
-- ---------------------------------------------------------------------------

-- Work orders turn equipment issues into actionable tracked maintenance work.
create table maintenance_work_orders (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    asset_id uuid not null references assets(id),
    source_daily_report_id uuid null references daily_reports(id),
    title text not null,
    description text null,
    priority text not null default 'medium',
    status text not null default 'open',
    opened_by_user_id uuid not null references users(id),
    assigned_employee_id uuid null references employees(id),
    opened_at timestamptz not null default now(),
    closed_at timestamptz null,
    resolution_notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (priority in ('low', 'medium', 'high', 'critical')),
    check (status in ('open', 'assigned', 'in_progress', 'completed', 'cancelled'))
);

create index maintenance_work_orders_asset_id_idx on maintenance_work_orders(asset_id);
create index maintenance_work_orders_status_idx on maintenance_work_orders(status);

-- Audit events provide immutable traceability for meaningful actions.
create table audit_events (
    id uuid primary key,
    tenant_id uuid not null references tenants(id),
    actor_user_id uuid null references users(id),
    event_type text not null,
    entity_type text not null,
    entity_id uuid not null,
    summary text not null,
    payload_json jsonb null,
    occurred_at timestamptz not null default now()
);

create index audit_events_entity_idx on audit_events(entity_type, entity_id);
create index audit_events_occurred_at_idx on audit_events(occurred_at);
