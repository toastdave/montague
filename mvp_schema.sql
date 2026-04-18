-- MVP core relational schema
-- Production-oriented Postgres draft for the first working version of the product.
-- The focus is on core workflow tables only.

create extension if not exists pgcrypto;
create extension if not exists citext;

-- ---------------------------------------------------------------------------
-- Shared types and helpers
-- ---------------------------------------------------------------------------

create type tenant_status as enum ('active', 'inactive');
create type user_role as enum ('admin', 'operations_manager', 'foreman', 'worker', 'driver', 'mechanic', 'payroll');
create type user_status as enum ('active', 'inactive', 'invited');
create type employment_status as enum ('active', 'inactive', 'terminated', 'leave');
create type worker_type as enum ('worker', 'foreman', 'driver', 'mechanic', 'manager', 'office');
create type job_status as enum ('draft', 'active', 'on_hold', 'completed', 'cancelled');
create type work_item_type as enum ('standard', 'change_order', 'time_and_material', 'rework', 'internal');
create type work_item_status as enum ('active', 'completed', 'cancelled');
create type simple_active_status as enum ('active', 'inactive');
create type crew_member_role as enum ('foreman', 'driver', 'operator', 'member');
create type assignment_status as enum ('planned', 'in_progress', 'completed', 'cancelled');
create type daily_report_status as enum ('draft', 'submitted', 'reviewed');
create type time_entry_status as enum ('draft', 'submitted', 'approved', 'exported');
create type related_entity_type as enum ('daily_report', 'asset_move', 'maintenance_work_order');
create type asset_status as enum ('available', 'assigned', 'in_transit', 'down', 'maintenance', 'retired');
create type asset_move_location_type as enum ('yard', 'job', 'shop', 'vendor', 'other');
create type asset_move_status as enum ('requested', 'assigned', 'in_transit', 'completed', 'cancelled');
create type priority_level as enum ('low', 'medium', 'high', 'critical');
create type work_order_status as enum ('open', 'assigned', 'in_progress', 'completed', 'cancelled');

create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Platform boundary
-- ---------------------------------------------------------------------------

create table tenants (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    slug text not null unique,
    status tenant_status not null default 'active',
    timezone text not null default 'America/Chicago',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create trigger tenants_set_updated_at
before update on tenants
for each row execute function set_updated_at();

-- Users are app accounts. They log in and perform system actions.
create table users (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    employee_id uuid null,
    email citext not null,
    password_hash text not null,
    role user_role not null,
    status user_status not null default 'active',
    last_login_at timestamptz null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, email)
);

create trigger users_set_updated_at
before update on users
for each row execute function set_updated_at();

-- Employees are labor resources whether or not they have app access.
create table employees (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    first_name text not null,
    last_name text not null,
    display_name text not null,
    phone text null,
    employee_number text not null,
    employment_status employment_status not null default 'active',
    worker_type worker_type not null default 'worker',
    hire_date date null,
    terminated_at timestamptz null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, employee_number)
);

create trigger employees_set_updated_at
before update on employees
for each row execute function set_updated_at();

alter table users
    add constraint users_employee_id_fkey
    foreign key (employee_id) references employees(id) on delete set null;

create unique index users_employee_id_unique
    on users(employee_id)
    where employee_id is not null;

-- ---------------------------------------------------------------------------
-- Work planning
-- ---------------------------------------------------------------------------

create table jobs (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    job_number text not null,
    name text not null,
    status job_status not null default 'active',
    start_date date null,
    end_date date null,
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, job_number),
    check (end_date is null or start_date is null or end_date >= start_date)
);

create trigger jobs_set_updated_at
before update on jobs
for each row execute function set_updated_at();

create table work_items (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    job_id uuid not null references jobs(id),
    code text null,
    name text not null,
    type work_item_type not null default 'standard',
    status work_item_status not null default 'active',
    is_billable boolean not null default true,
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index work_items_job_id_idx on work_items(job_id);

create trigger work_items_set_updated_at
before update on work_items
for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- Crew scheduling
-- ---------------------------------------------------------------------------

create table crews (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    name text not null,
    foreman_employee_id uuid null references employees(id) on delete set null,
    status simple_active_status not null default 'active',
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, name)
);

create trigger crews_set_updated_at
before update on crews
for each row execute function set_updated_at();

create table crew_members (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    crew_id uuid not null references crews(id),
    employee_id uuid not null references employees(id),
    role_in_crew crew_member_role not null default 'member',
    start_date date not null,
    end_date date null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, crew_id, employee_id, start_date),
    check (end_date is null or end_date >= start_date)
);

create index crew_members_crew_id_idx on crew_members(crew_id);
create index crew_members_employee_id_idx on crew_members(employee_id);

create trigger crew_members_set_updated_at
before update on crew_members
for each row execute function set_updated_at();

-- Assignments are the planning-to-execution bridge.
create table assignments (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    assignment_date date not null,
    crew_id uuid not null references crews(id),
    job_id uuid not null references jobs(id),
    work_item_id uuid null references work_items(id),
    status assignment_status not null default 'planned',
    shift_start time null,
    shift_end time null,
    notes text null,
    created_by_user_id uuid not null references users(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (shift_end is null or shift_start is null or shift_end > shift_start)
);

create index assignments_assignment_date_idx on assignments(assignment_date);
create index assignments_crew_id_idx on assignments(crew_id);
create index assignments_job_id_idx on assignments(job_id);
create unique index assignments_unique_active_slot_idx
    on assignments(tenant_id, assignment_date, crew_id, job_id, coalesce(work_item_id, '00000000-0000-0000-0000-000000000000'::uuid));

create trigger assignments_set_updated_at
before update on assignments
for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- Field execution
-- ---------------------------------------------------------------------------

-- Daily reports capture what actually happened for an assignment.
create table daily_reports (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    assignment_id uuid not null references assignments(id),
    crew_id uuid not null references crews(id),
    job_id uuid not null references jobs(id),
    report_date date not null,
    submitted_by_user_id uuid not null references users(id),
    status daily_report_status not null default 'draft',
    notes text null,
    submitted_at timestamptz null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (assignment_id, report_date),
    check (submitted_at is null or submitted_at >= created_at)
);

create index daily_reports_job_id_idx on daily_reports(job_id);
create index daily_reports_crew_id_idx on daily_reports(crew_id);
create index daily_reports_report_date_idx on daily_reports(report_date);

create trigger daily_reports_set_updated_at
before update on daily_reports
for each row execute function set_updated_at();

-- Time entries are normalized labor rows derived from daily reports.
create table time_entries (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    daily_report_id uuid not null references daily_reports(id),
    employee_id uuid not null references employees(id),
    job_id uuid not null references jobs(id),
    work_item_id uuid null references work_items(id),
    work_date date not null,
    hours numeric(6,2) not null,
    status time_entry_status not null default 'draft',
    version integer not null default 1,
    edit_reason text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (hours > 0),
    check (version > 0)
);

create index time_entries_daily_report_id_idx on time_entries(daily_report_id);
create index time_entries_employee_id_idx on time_entries(employee_id);
create index time_entries_job_id_idx on time_entries(job_id);
create index time_entries_work_date_idx on time_entries(work_date);
create index time_entries_status_idx on time_entries(status);

create trigger time_entries_set_updated_at
before update on time_entries
for each row execute function set_updated_at();

-- Files hold attachment metadata for reports, moves, and work orders.
create table files (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    uploaded_by_user_id uuid not null references users(id),
    storage_key text not null,
    file_name text not null,
    mime_type text not null,
    size_bytes bigint null,
    related_entity_type related_entity_type not null,
    related_entity_id uuid not null,
    created_at timestamptz not null default now(),
    check (size_bytes is null or size_bytes >= 0)
);

create index files_related_entity_idx on files(related_entity_type, related_entity_id);

-- ---------------------------------------------------------------------------
-- Equipment operations
-- ---------------------------------------------------------------------------

-- Assets keep the current operational state directly on the row for MVP simplicity.
create table assets (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    asset_number text not null,
    name text not null,
    asset_type text not null,
    status asset_status not null default 'available',
    current_job_id uuid null references jobs(id),
    current_location_label text not null,
    current_meter_hours numeric(10,2) null,
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (tenant_id, asset_number),
    check (current_meter_hours is null or current_meter_hours >= 0)
);

create index assets_current_job_id_idx on assets(current_job_id);

create trigger assets_set_updated_at
before update on assets
for each row execute function set_updated_at();

-- Asset moves are the event records that update asset location and assignment state.
create table asset_moves (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    asset_id uuid not null references assets(id),
    from_type asset_move_location_type not null,
    from_job_id uuid null references jobs(id),
    from_label text not null,
    to_type asset_move_location_type not null,
    to_job_id uuid null references jobs(id),
    to_label text not null,
    status asset_move_status not null default 'requested',
    requested_by_user_id uuid not null references users(id),
    assigned_driver_employee_id uuid null references employees(id) on delete set null,
    scheduled_for timestamptz null,
    completed_at timestamptz null,
    notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check ((from_type = 'job' and from_job_id is not null) or (from_type <> 'job' and from_job_id is null)),
    check ((to_type = 'job' and to_job_id is not null) or (to_type <> 'job' and to_job_id is null)),
    check (completed_at is null or completed_at >= created_at)
);

create index asset_moves_asset_id_idx on asset_moves(asset_id);
create index asset_moves_status_idx on asset_moves(status);
create index asset_moves_scheduled_for_idx on asset_moves(scheduled_for);

create trigger asset_moves_set_updated_at
before update on asset_moves
for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- Exceptions and control
-- ---------------------------------------------------------------------------

-- Work orders turn equipment issues into actionable tracked maintenance work.
create table maintenance_work_orders (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    asset_id uuid not null references assets(id),
    source_daily_report_id uuid null references daily_reports(id),
    title text not null,
    description text null,
    priority priority_level not null default 'medium',
    status work_order_status not null default 'open',
    opened_by_user_id uuid not null references users(id),
    assigned_employee_id uuid null references employees(id) on delete set null,
    opened_at timestamptz not null default now(),
    closed_at timestamptz null,
    resolution_notes text null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (closed_at is null or closed_at >= opened_at)
);

create index maintenance_work_orders_asset_id_idx on maintenance_work_orders(asset_id);
create index maintenance_work_orders_status_idx on maintenance_work_orders(status);
create index maintenance_work_orders_opened_at_idx on maintenance_work_orders(opened_at);

create trigger maintenance_work_orders_set_updated_at
before update on maintenance_work_orders
for each row execute function set_updated_at();

-- Audit events provide immutable traceability for meaningful actions.
create table audit_events (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references tenants(id),
    actor_user_id uuid null references users(id) on delete set null,
    event_type text not null,
    entity_type text not null,
    entity_id uuid not null,
    summary text not null,
    payload_json jsonb null,
    occurred_at timestamptz not null default now()
);

create index audit_events_entity_idx on audit_events(entity_type, entity_id);
create index audit_events_occurred_at_idx on audit_events(occurred_at);
create index audit_events_event_type_idx on audit_events(event_type);
