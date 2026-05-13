# IronOps Vision

## Purpose

IronOps is a blue-collar operations platform for companies that coordinate field work, crews, equipment, materials, documents, maintenance, and time-sensitive logistics across many jobs.

The first customer is Montague Development, a construction business with long-running jobs, scheduled production tasks, foreman-led crews, heavy equipment, subcontractor crews, job plans, field documentation, and maintenance needs.

The long-term product should be designed as a multi-tenant SaaS platform, but the early product should stay anchored in Montague's real operating model. The goal is not to build a generic project management tool. The goal is to build a clear operational system for field-heavy companies where work is planned in the office, executed in the field, and reviewed through structured process data.

## How To Use This Document

This document is the product north star. It should guide what IronOps is, what it is not, and which product decisions should shape the first build.

Separate documents should cover implementation detail:

- technical stack and application architecture
- database schema and migrations
- API and integration design
- UX flows and screen maps
- UI design system and visual direction
- customer-specific implementation notes

## Product Thesis

Most blue-collar companies run operations through a mix of spreadsheets, calls, texts, paper forms, photos, GPS tools, accounting systems, and individual memory.

IronOps should become the operational source of truth that connects:

- what work is planned
- who is doing it
- where people and equipment are expected to be
- what actually happened
- what needs to move
- what broke or needs maintenance
- what documents support the work
- what data should be reviewed, approved, exported, or analyzed

The system should collect process data at the point of work, preserve it in a structured model, and make it useful at different levels of the company through role-based views, dashboards, workflows, and integrations.

## Core Product Shape

The central operating chain is:

```text
Job -> Task -> Assignment -> Crew/Worker -> Field Activity -> Review/Reporting
```

Around that chain sit several parallel but connected systems:

- equipment and asset state
- logistics planning for equipment, materials, tools, and other physical resources
- maintenance work orders
- document management
- time and labor review
- subcontractor coordination
- material planning and tracking
- audit history and process analytics
- billing-ready operational support data, without becoming accounting software

This structure should support Montague's crew-based construction work first, while leaving room for companies that schedule smaller crews or individual workers.

## Current Working Position

These are the product assumptions to carry forward unless future discovery disproves them:

- Montague is the design anchor; broader SaaS flexibility should not weaken the crew-based construction workflow.
- Crews are first-class, and a one-person crew is the simplest early path for solo-worker support.
- Tasks are the flexible work unit under a job; billing, cost codes, change orders, and production metrics can grow around them later.
- Moves are real workflow records, not notes on equipment. Equipment moves come first, and the model should allow material moves later. Workers may be responsible for moves, but they are not the moved resource.
- Maintenance is a parallel stream, not a subtype of production tasks.
- Subcontractors, materials, and documents should be part of the long-term domain model even if their first implementation is lightweight.
- SaaS flexibility should come from modules, roles, constrained settings, and durable entities, not from open-ended customization.

## Guiding Decisions

These decisions should guide the first build and future product calls.

### Work And Scheduling

- Production scheduling is crew-first. One-person crews are the early bridge for solo-worker support.
- Worker/employee records are independent from login accounts. Workers do not need user accounts unless they need app access.
- Crew membership is temporal and dynamic for planning views; submitted reports, reviewed time, approvals, exports, and financial records snapshot the facts that mattered at the time.
- `assignments` is the production labor scheduling concept. It requires a job, allows an optional task, belongs to one crew, and should not be confused with assignee fields on moves or maintenance work orders.
- Tasks are job-scoped production work. They may have parent/child hierarchy, lightweight billing/change-order flags, dependencies, planned dates, and production quantities, but phase and cost code remain separate classification fields.
- PM/Gantt planning should operate primarily on task dates and dependencies. Crew execution scheduling should operate on assignment dates and time windows.
- A crew can have multiple assignments in one day, and a task can have many assignments. The system should detect conflicts and overbooking rather than prohibit these cases.

### Field Execution And Time

- Field reports are execution records. Montague production work should default to crew-day reports, with reporting policy configurable by job or assignment.
- Daily reports can capture time, task allocation, photos, notes, equipment usage, issues, incidents, weather/site conditions, and optional production quantities.
- Time entries can originate from daily reports, worker self-submission, admin entry, or imports. Original field reports remain immutable; time entries are correctable with audit history.
- Phase 1 should use review statuses and audit history before formal approval workflows. Formal approvals can come later for payroll, billing, exports, and other locked workflows.
- Payroll export/sync is a target capability. Payroll integration should push reviewed time out of IronOps while external payroll/accounting systems provide controlled reference mappings only.

### Equipment, Logistics, And Maintenance

- Assets need a robust state model. Lifecycle, availability, maintenance state, current location, current job, relationships to other assets, and telemetry should be separate concepts.
- Asset job assignment and physical location are separate facts. Moves represent intended relocation; telemetry represents observed evidence.
- Equipment usage should become structured data, but Phase 1 usage is for visibility and issue capture, not costing, utilization analytics, or strict telemetry reconciliation.
- Equipment issues reported from the field enter a review flow first. They do not automatically become maintenance work orders by default.
- Maintenance work orders require an asset in the core equipment maintenance model and remain separate from tasks.
- The logistics module should expose `Move Queue` and `Move Schedule` surfaces. Moves are for physical items such as equipment and materials, can contain multiple line items, can be unscheduled or scheduled, and should prefer a named responsible person for accountability.
- Completing an asset move should update the asset's operational current location, create history/audit records, and surface exceptions if telemetry disagrees.

### Documents, Materials, And External Parties

- Documents use a generic document/attachment model, with versioning and early planning for markup.
- Markups are annotations by default and can later link to or create operational records such as tasks, maintenance work orders, moves, material requests, or issues.
- Photos live in the document system with photo-specific metadata. Plans should eventually support plan sets and individual sheets, but Montague's plan workflow needs more discovery.
- Materials start as a simple catalog/reference list, not a full inventory system.
- Subcontractors, vendors, suppliers, and customers/clients are organizations. Subcontractor crews are schedulable crews linked to subcontractor organizations.
- External access should be designed for later through scoped users and short-lived secure action links, but not built before internal workflows are stable.

### Platform Boundaries

- IronOps database owns operational data. Spreadsheets are controlled import, export, or reporting surfaces, not live workflow sources of truth.
- IronOps should produce billing-ready operational data before considering invoicing or accounting features.
- Accounting export and accounting platform API sync are target capabilities, but accounting systems remain the system of record for invoices, ledger, payments, and financial close.
- IronOps should avoid customer-defined custom fields in the core product. Product-led schema additions, tags, comments, attachments, notes, saved views, and dashboards are the preferred flexibility mechanisms.
- Core workflow statuses and job types should be product-defined canonical values, not tenant-defined workflows.
- Tenant-level module toggles and policy-based required fields are acceptable when they apply to product-defined modules and workflows.
- RBAC should evolve from simple tenant roles into role plus scope. Device type shapes interface and risk controls, not core authorization.
- IronOps should plan shared integration infrastructure, outbound webhooks, and a public API, but only after concrete integrations and internal domain events are stable.
- Tenant model should stay flat for a long time. Core records need internal IDs, tenant-scoped human-readable business codes, archive/void semantics, focused audit history, and preserved external IDs for integrations.

## Design Principles

### 1. Build For Montague First, But Avoid Dead Ends

Montague's real workflow should drive the early design. They have long-running jobs, task-level scheduling, stable and semi-stable crews, foremen, heavy equipment, plans, subcontractors, and maintenance.

The platform should not distort this workflow to chase every possible trade business on day one. A single electrician assigned to many short jobs per day is a valid future customer, but the first product should not sacrifice construction crew operations to cover that case prematurely.

The right stance is:

- model crews as first-class scheduling units
- allow a crew to have one member
- allow direct worker scheduling later if a real customer workflow requires it
- keep production scheduling crew-first in the first product
- avoid hard-coding assumptions that every company has large permanent crews

### 2. Flexibility Over Full Customization

The product should support different operating styles without becoming a configuration-heavy platform that is hard to understand, support, or implement.

Preferred flexibility:

- optional modules
- reusable workflow states with constrained options
- policy-based required fields for product-defined workflows
- tenant-level feature flags
- tenant-level module toggles
- clear entity relationships
- role-based views
- product-led schema additions where repeated customer needs emerge
- tags, comments, attachments, and notes for lightweight flexibility

Avoid:

- arbitrary custom tables as a core product feature
- per-tenant workflow builders for every process
- tenant-defined canonical workflow statuses
- customer-defined custom fields that become the real product model
- customer-specific forks of business logic
- interfaces that require heavy setup before they are useful

The platform should feel opinionated. It should adapt to field operations, but it should not ask each customer to invent their own operating system.

Customer-defined custom fields should not be a core product feature early. They often create hidden per-tenant schemas, inconsistent reporting, support burden, messy mobile UI, and future migration problems. IronOps should prefer customer feedback, repeated-pattern discovery, and first-class product fields or entities once a need proves durable. Internal metadata can still exist for integrations, imports, source payloads, and debugging, but should not become customer workflow modeling.

Core workflow statuses should be product-defined canonical enums. Tenant-defined statuses can break dashboards, alerts, reporting, and integrations. If needed later, tenants may get display labels or views that adapt how statuses are shown without changing the underlying workflow states.

Policy-based required fields are acceptable when the fields and workflows are product-defined. For example, a tenant can require equipment usage on certain reports, completion photos for certain moves, weather conditions for certain jobs, or production quantities for measurable task types. This gives operational flexibility without creating custom schema.

Tenant-level module toggles should allow IronOps to enable or disable major product areas such as equipment, logistics, maintenance, materials, subcontractor access, payroll sync, telemetry, or documents. These toggles are for packaging, rollout, and product complexity management. They should not become per-tenant workflow builders.

Generic tags or labels are acceptable as lightweight organization. They can help users filter and group jobs, tasks, documents, assets, moves, or work orders. Tags should not become required payroll, billing, maintenance, or approval logic.

Saved views and configurable filters should be part of the long-term product direction. Users or tenant admins can save views such as overdue moves, open down-equipment work orders, unreviewed time by job, missing subcontractor documents, or this week's crew schedule. This is a better flexibility mechanism than custom fields because it adapts presentation and workflow surfaces without changing core entities.

Dashboards should start with clear role-based defaults: admin/operations, foreman, mechanic/equipment, payroll/time review, and other major roles as needed. Later, dashboards can support configurable widgets, saved views, tenant defaults, and personal filters.

### 3. Separate Planning From Execution

Planned work and actual field activity are different records.

Planning answers:

- what should happen
- who is assigned
- when it should happen
- what task, job, equipment, materials, or documents are expected

Execution answers:

- what actually happened
- who actually worked
- what equipment was used
- what moved
- what broke
- what changed
- what needs review

This separation is important for accountability, audit history, payroll review, job costing, billing, and operational learning.

### 4. Capture Process Data Once, Use It Many Ways

Field data should not be trapped in flat forms. A foreman's report, worker time entry, equipment move, maintenance note, GPS runtime reading, material delivery, photo, or approval should become structured process data.

That data should later support:

- daily dashboards
- payroll review
- job progress reporting
- equipment utilization
- asset depreciation and operating cost analysis
- maintenance history
- subcontractor performance
- billing support
- audit trails
- management analytics

The early app can expose only a small slice of this, but the data model should preserve enough structure to grow.

### 5. Multi-Tenant From The Start

Every business record should belong to a tenant. Tenant isolation is not a later feature.

The SaaS design should support:

- tenant-owned users, employees, jobs, crews, assets, documents, and workflows
- tenant-level roles and permissions
- tenant-level integrations
- tenant-level feature availability
- consistent shared product concepts across tenants

The product can start with one customer, but the data boundary should be correct immediately.

The tenant model should stay flat for a long time: one tenant represents one company account. Parent-child tenants, divisions, regions, branches, or business units may become useful later, but they should not complicate the early platform model.

### 6. Database-Owned Operational Truth

IronOps should own operational data in its application database. Spreadsheets can help with onboarding, imports, exports, reports, or customer-visible outputs, but they should not remain the live workflow engine for assignments, time entries, moves, maintenance, asset state, approvals, or other operational records.

Onboarding imports and controlled reference-data sync can be repeatable where useful. Main operational records should become app-owned after launch so customers are not constantly importing their core workflow data.

### 7. Human-Readable Business References

Every core record should have a stable internal system ID. Important operational records should also support human-readable business references where users or integrations expect them, such as job numbers, employee numbers, asset numbers, work order numbers, move numbers, task codes, document sheet numbers, material SKUs, or external system codes.

Human-readable business references should generally be unique within a tenant, not globally across all IronOps customers. Internal system IDs remain globally safe for application use.

### 8. Preserve Operational History

Core operational records should generally be archived, cancelled, voided, or marked inactive rather than hard-deleted. Jobs, tasks, crews, workers, assets, moves, maintenance work orders, reports, time entries, and documents all carry history that may matter for audit, payroll, accounting support, legal support, or operational review. Hard delete should be rare and reserved for controlled cleanup or mistakes.

## Primary Users

### Owner / Executive

Needs broad visibility into operations, resource use, risk, productivity, cost, exceptions, and long-term trends.

### Admin / Operations Manager

Owns the operational system: jobs, tasks, schedules, crews, workers, equipment, moves, documents, maintenance, time review, user access, and corrected records.

### Foreman / Field Lead

Leads execution in the field: assigned work, crew context, daily reports, time allocation, photos, notes, equipment issues, and move or maintenance requests.

### Worker

May only need a minimal mobile surface: assigned work, time entry or confirmation, simple notes, photos, and status updates where allowed.

### Mechanic / Equipment Manager

Owns maintenance execution and equipment readiness: work orders, asset history, repair notes, status updates, documents, and closeout.

### Dispatcher / Move Coordinator

Owns logistics across job sites: scheduled moves, resource conflicts, drivers or responsible people, blocked items, and late or urgent moves.

### Subcontractor Contact

Represents an outside company or crew with scoped access to assigned work, limited documents, reporting, uploads, and confirmations.

## Core Domain Model

### Tenant

The company account and data boundary.

Long-term SaaS requirement:

- every operational record belongs to one tenant
- tenant data must be isolated by design

### User

A login account with permissions.

Users are actors. They submit reports, approve records, request moves, update work orders, upload files, and leave audit history.

### Worker / Employee

An operational person record.

Workers can exist without login accounts. This supports field labor, subcontractor labor, mechanics, drivers, former employees, and people whose time is tracked by a foreman.

### Organization / Vendor / Subcontractor

A company or outside party that participates in work.

This should eventually support:

- subcontractor companies
- vendor contacts
- material suppliers
- customers or clients
- outside crews
- insurance or compliance documents
- scoped access for external users

Subcontractors should not be modeled only as text fields. They are core to the business and should become first-class entities, even if the first build only tracks them lightly.

External subcontractor access should be planned for, but not built before internal workflows are stable. Long-term access can include external users tied to an organization and short-lived secure action links for scoped uploads, confirmations, document requests, or report submissions.

Secure scoped links can support limited external actions without full account setup. Examples include subcontractor document uploads, vendor delivery confirmation, move receiver confirmation, or viewing a specific shared document. These links should be short-lived, token-scoped, audited, and avoid broad tenant access.

Customers or clients can be represented as organizations so jobs, documents, reports, billing context, or future sharing can relate back to them. CRM, sales pipeline, and broad customer portal features should stay out of early scope.

### Job

The top-level container for customer, development, or project work.

A job should collect:

- optional customer/client organization
- tasks
- assignments
- crews and workers
- equipment
- documents
- photos
- reports
- materials
- subcontractors
- time entries
- maintenance context where relevant

Jobs may be long-running and should support rich history.

Jobs should support multiple locations. The first UI can default to one primary location, but the model should allow staging areas, entrances, phases, stockpile areas, dump sites, or other job-specific places.

Jobs should support an optional customer/client organization. Some job types may require a client, while internal, development, overhead, warranty, yard, or other job types may not.

Job types should start as a small product-defined enum such as customer, internal, development, overhead, warranty, and other. Fully tenant-defined job types should be avoided until a clear product need emerges.

### Task / Work Item

A unit of work under a job.

Tasks should start simple, but be designed to grow. They can function initially as work items for scheduling and time allocation, then later support billing, change orders, production tracking, cost codes, dependencies, estimates, and progress.

Tasks should support:

- parent/child hierarchy for operational grouping
- regular work
- change-order or extra work
- billable and non-billable flags
- schedule status
- assignment status
- progress status
- cost code or phase references where needed
- dependencies and blockers
- estimated and actual production quantities later

Important design stance:

- tasks are job-scoped production work
- use `task` or `work_item` as the same core concept
- do not create separate entities for every billing or production variant too early
- add financial and production attributes around the task model as the product matures
- keep phase and cost code as separate classification fields rather than encoding them only through task hierarchy
- allow operational scheduling before every classification field is complete
- keep manual task progress/status as the official operational state while using reports, time entries, equipment usage, and production quantities as context
- plan for task dependencies and Gantt/PM-style views as important scheduling capabilities
- separate task-level planning dates from assignment-level crew schedule windows
- plan for estimated quantities and report-based actual production quantities

### Crew

A scheduling and execution unit.

For Montague, crews are central. They often have a foreman and a working set of members. Some crews are stable over time; others may move frequently between jobs.

The model should support:

- named crews
- foreman-led crews
- changing crew membership over time
- subcontractor crews
- one-person crews
- temporary or ad hoc crews if needed

The UI can remain crew-first for Montague while the underlying model leaves room for worker-level scheduling.

Foreman or lead assignment should be policy-driven by crew type. Montague internal production crews may require a foreman, while subcontractor, temporary, or solo crews may use different leadership/contact rules.

Crew membership should be tracked historically with effective start and end dates. Planning views can read the roster for a work date, while submitted field reports and time entries snapshot the actual workers present.

### Assignment

A planned commitment of production labor to job work.

An assignment connects:

- date or time window
- job
- optional task
- crew
- expected equipment or materials
- status
- responsible user or foreman

Assignments are the bridge between office planning and field execution for production work. Moves and maintenance work orders can have their own responsible assignees and schedules without being forced into this table.

Long-term flexibility:

- crew assignment should be first-class
- direct worker assignment can be added later if needed
- one-person crews may be the simplest way to support solo operators without complicating the early model

### Daily Report / Field Report

The record of what actually happened.

A field report should capture:

- assignment context
- actual workers present
- time worked
- task allocation
- notes
- photos
- incidents
- equipment usage
- equipment problems
- material events where relevant
- weather or site conditions if needed later

The report is an execution envelope. It should generate normalized downstream records instead of acting as the only source of truth.

For measurable tasks, daily reports may capture actual production quantities such as linear feet, structures, loads, acres, or other units. This should be policy-driven by task or report type rather than required for every task.

Weather and site conditions should be optional report fields. They can explain delays, productivity, safety conditions, or equipment issues. Later, weather can be auto-filled from job location and report date.

Daily reports should capture incident and safety signals because the foreman report is the first field account. Serious incidents should be promoted into separate formal incident records with deeper investigation, follow-up, attachments, approvals, and compliance fields as needed.

### Time Entry

A normalized labor record.

Time entries may be created from foreman reports, individual worker input, admin edits, or integrations. The original field report should remain immutable as the field account of what was submitted. Time entries are the reviewable and correctable labor records derived from or related to that submission.

They should support:

- employee or worker
- job
- task
- crew context
- date
- hours
- status
- review state
- approval state
- versioning or edit history

Corrections should be audited. Approved or exported time should require a stricter reopen or correction workflow later.

Phase 1 can rely on review statuses rather than formal approval workflows. Formal approvals, approval locks, and approval reset-on-edit behavior should come later when payroll, billing, exports, or other consequential workflows require them.

Payroll export and payroll sync should be planned as target capabilities. Reviewed time entries should be structured so they can later feed CSV exports or API integrations with popular payroll platforms. Pay periods, payroll batches, export history, integration mappings, approval locks, and correction/reopen flows can layer on after core time review is reliable.

Payroll integration should start as a controlled outbound sync from IronOps to payroll systems. Reviewed or approved time entries are pushed out. External payroll or accounting systems may provide reference data such as employee identifiers, pay codes, job codes, or cost codes through controlled imports and mappings, but they should not directly own or mutate IronOps operational records.

Billing support should focus on billing-ready operational data rather than full invoicing or accounting. IronOps can collect billable task flags, change-order classifications, reviewed labor, equipment usage, materials context, photos, documents, production quantities, and supporting proof. Invoice generation, receivables, payment tracking, and ledger behavior should remain outside early scope.

Accounting export and accounting platform API sync should be planned as boundary integrations. IronOps can send reviewed operational data, billing support, approved time, cost-code/job-code mappings, equipment/material support, and documents to accounting systems. Accounting platforms remain the system of record for invoices, ledger, payments, and financial close.

Integrations should share common infrastructure where practical: provider connections, credentials, external references, mapping tables, sync runs, logs, errors, and retry behavior. IronOps should not build a large abstract integration platform before the first real APIs are known, but the architecture should avoid one-off integration code that cannot be extended.

Synced and imported records should preserve external system identifiers where relevant, including provider, external ID, external URL when available, last sync time, sync status, and enough source reference information to reconcile and debug. This prevents duplicates and supports idempotent sync behavior.

Outbound webhooks and event delivery should be a long-term integration capability. Candidate events include time reviewed, move completed, work order closed, asset location changed, document uploaded, and task completed. Internal domain events and activity feed should mature before exposing external webhooks.

A public API should be part of the long-term platform vision. It should come after stable internal API boundaries, concrete integrations, and webhook/event infrastructure because public APIs require durable contracts, auth scopes, versioning, rate limits, documentation, and support.

### Asset / Equipment

A tracked physical asset.

Equipment should have both current state and history.

Current state may include:

- location
- assigned job
- lifecycle status
- availability status
- maintenance state
- current meter or runtime
- tracker status

History may include:

- moves
- job assignments
- usage
- GPS readings
- runtime readings
- maintenance work orders
- documents
- photos
- inspections

The long-term goal is to connect equipment activity to operating cost, depreciation, utilization, job allocation, and overhead.

Asset state should not be collapsed into one generic status. A robust asset model should separate:

- lifecycle status: active, retired, sold, lost, or similar
- availability status: available, assigned, unavailable, or similar
- maintenance status: ok, needs review, down, in repair, or similar
- current operational location
- current job assignment where applicable
- telemetry state such as last seen, runtime, tracker health, and observed GPS

This matters because an asset can be assigned to a job, physically observed somewhere else, unavailable for use, and under maintenance review at the same time.

Job assignment and physical location should remain separate. Job assignment represents intended operational ownership or allocation. Location represents where the app currently believes the asset is. Telemetry represents observed evidence. Moves represent intended relocation.

Assets should also support relationships to other assets. Attachments, trailers, mounted GPS trackers, components, and paired equipment may need their own history while still being associated with a parent asset. This also helps moves represent bundled equipment accurately without assuming every asset is standalone.

### Equipment Telemetry

External equipment data, especially from GoAardvark.

Desired data:

- GPS location
- runtime or engine hours
- tracker health
- last seen time
- movement history

Telemetry should not replace operational workflow state. It should enrich and validate it.

For example:

- a scheduled move says where equipment is expected to go
- GPS says where it appears to be
- runtime says how much it was used
- maintenance says whether it is available

The product should reconcile these into useful operational signals.

Field reports should also be able to capture manual equipment usage and equipment issues. Admins should be able to decide whether equipment usage reporting is required for a job, assignment, crew, or report policy. Manual reporting provides business context; telemetry provides observed signals.

Equipment usage should become structured data, even if the first foreman UI is simple. A usage record can later connect an asset to a report, job, task, operator, reported hours, telemetry runtime, notes, and issues.

Phase 1 equipment usage should be visibility-first. Foremen can report equipment used and flag issues; admins can review that context and optionally open maintenance work orders. Costing, utilization analytics, and strict reported-versus-telemetry reconciliation should wait until the core scheduling, reporting, and time loop is stable.

Equipment issues from field reports should create reviewable issue records before becoming maintenance work orders. This preserves field signal without flooding the maintenance queue. Admins or mechanics can convert issues into work orders when action is needed; severe issue categories can support automatic work-order creation later through policy.

Technical exploration needed:

- determine what GoAardvark data is available through API, export, webhook, or reporting access
- evaluate reliability, latency, cost, and integration constraints
- understand whether runtime, GPS, tracker health, and historical readings are available cleanly
- compare long-term integration value against building a native lightweight tracker offering
- consider whether owned trackers could become a product add-on with simpler onboarding, tighter API integration, and automatic asset linking

### Move

A planned or completed movement of physical resources between locations.

The logistics surface is a queue and schedule for equipment, materials, and other physical resources that need to move between job sites, the yard, vendors, suppliers, shops, or storage locations during a given day or time period.

Moves should eventually support:

- resource type: equipment, material, tool, attachment, document/package, or other physical item
- source location
- destination location
- needed-by date or time
- scheduled date or time window
- priority
- status
- assigned driver or responsible person
- requested by and received by actors where needed
- linked job and task
- notes, photos, and attachments
- multiple move items in one move
- conflicts or dependency warnings

The move queue should be designed as a dispatch surface, not just a list. It should help answer:

- what needs to move today
- what is waiting
- what is blocked
- who is responsible
- what is late
- what conflicts with another schedule
- what equipment or materials are needed before a crew can work

### Maintenance Work Order

A parallel workflow for equipment issues and repairs.

Maintenance should stay separate from production tasks because it has a different lifecycle, responsible people, priorities, and operational impact.

Work orders should support:

- asset
- issue source
- priority
- status
- assigned mechanic or vendor
- reported by
- opened from field report where applicable
- parts or materials later
- photos and documents
- resolution notes
- downtime tracking

Core maintenance work orders should require an asset because they represent equipment repair or service. If the product later needs shop, yard, or facility maintenance, that should be modeled deliberately instead of weakening the equipment maintenance concept.

Maintenance work orders should affect asset state through rules. A severe or downing issue can make an asset unavailable. A lower-severity issue can mark the asset as needing review while leaving it usable. Closing a work order can restore the asset only if no other open severe work orders still affect it.

Maintenance assignment should support internal workers and users first. Long term, a work order may also be assigned to an outside vendor, repair shop, or subcontractor organization.

Maintenance can capture parts or materials in notes early. Structured parts usage should come later, likely linked to the material catalog, quantities, units, and optional costs.

Inspections should eventually become their own concept, especially for recurring equipment checks, safety checks, job/site inspections, or structured checklists. Failed inspection items can create equipment issues or maintenance work orders.

### Material

Materials are core to Montague's business, but do not need to be fully built on day one.

The first material model should be a simple catalog: a structured list of material names, categories, and default units that can be referenced by moves or later job requirements. It should not try to be full inventory in the first product.

Simple catalog fields may include:

- name
- category
- default unit
- optional SKU or code
- status

Deferred inventory capabilities may include:

- job material requirements
- scheduled deliveries
- received quantities
- material moves between jobs or yard
- supplier/vendor relationships
- photos and delivery tickets
- task-level material usage
- cost allocation

Materials should connect naturally to jobs, tasks, moves, vendors, documents, and reports.

### Document / File

Documents should become a robust system, not just attachments.

The technical model should separate documents from attachments:

- `documents` store the file or document metadata
- `attachments` link documents to business records such as jobs, tasks, assets, moves, maintenance work orders, reports, organizations, and materials

This generic attachment model is appropriate because documents are supporting context that can validly relate to many entity types.

The product should support:

- job plans
- plan sets and individual sheets later
- plan versions
- photos
- PDFs
- delivery tickets
- inspection documents
- subcontractor documents
- maintenance documents
- annotations or markups
- document relationships to jobs, tasks, assets, moves, work orders, reports, and vendors

Every job should be able to hold plans and supporting documents. Other entities should also be able to attach documents where the business workflow needs evidence or context.

Long-term document management should include:

- versioning
- markup/annotation
- access control
- mobile capture
- document type
- tags
- upload source
- linked entity
- audit history
- folders or collections later if needed

The document model should separate the logical document from specific uploaded versions. Plans and other important files change over time, and historical reports or markups may need to reference the exact version used at the time.

Photos should be treated as documents/files with photo-specific metadata such as captured time, location, upload source, and related entity attachments. They should not require a separate photo system.

Markups should be planned early. A markup is an annotation by default, but it should be able to link to or create operational records later. For example, a plan markup could link to a task, maintenance work order, move, material request, issue, or photo. Markup coordinates should attach to the specific document version because plan revisions can shift content.

Document organization should start with document type, tags, and entity attachments. Folders or collections can be added later if users need a more familiar browsing model, but the core model should not depend on a file living in only one folder.

Plans need more discovery. The long-term model should likely support plan sets as parent records and individual sheets as children so users can work with both a full issued set and specific sheets such as grading, utilities, or erosion control. V1 can be simpler, but markups and versioning should not block this future shape.

### Audit Event

A structured record of important changes.

Audit history should be built into workflows that affect payroll, equipment location, maintenance state, assignment changes, approvals, documents, and administrative permissions.

Audit coverage should start with high-consequence actions: time entry edits, report submissions or corrections, assignment schedule changes, asset location/status changes, move completion or correction, maintenance state changes, document version changes, permission changes, and payroll/accounting export or sync events later. Audit depth can expand as workflows mature.

Audit events and activity feed items should be related but distinct. Audit events are compliance and change-history records. Activity feed items are user-facing operational timeline entries such as reports submitted, moves completed, documents uploaded, task status changes, issues flagged, and work orders closed.

Notifications should grow out of the workflow and activity model, but do not need to be overbuilt before the core operational surfaces are stable. Long term, notifications will need user preferences, channels, read state, retries, and escalation.

Comments should be a shared cross-entity feature. Jobs, tasks, assignments, reports, moves, work orders, assets, documents, and markups may all need discussion. Later, comments can support mentions, threads, resolved states, activity feed entries, and notification triggers.

## Scheduling Philosophy

Montague's early scheduling model should be crew-first.

The system should make it natural to:

- create jobs
- break jobs into tasks
- schedule tasks to crews
- let foremen execute assigned work
- record actual labor and activity

At the same time, the model should leave room for:

- a crew with one worker
- a worker temporarily assigned outside their usual crew
- a subcontractor crew
- equipment or material requirements tied to an assignment
- multiple crews on the same task
- one crew moving across multiple tasks or jobs in a day

The product should not initially optimize for high-volume service dispatch where one technician completes many short appointments per day. That is a future expansion path, not the primary design target.

Job and schedule management should support PM-style planning over time, including task dependencies, timeline/Gantt views, blockers, and schedule impact visibility. The first implementation can stay operationally simple, but the data model should not block these views.

Task-level planning and assignment-level scheduling are related but different. Task dates and dependencies represent the project plan. Assignment dates and time windows represent crew execution scheduling. A long-running task may have many crew assignments over time.

Crew membership should be dynamic in planning views. A scheduled crew assignment should pull the relevant crew roster for the work date. Once a field report is submitted, the actual workers present should be stored on the report and downstream time entries so history does not change when crew membership changes later.

Reporting requirements should be policy-driven. Montague production work should default to a crew-day field report, but jobs or assignments can override the policy where needed. Possible report policies include no report, crew-day report, per-assignment report, and later per-task report.

Individual workers may submit direct time entries in minimal mobile workflows. That is a separate capture mode from foreman-led field reporting.

A task can have many assignments. If multiple crews work the same task, each crew should receive its own assignment rather than one assignment pointing to many crews. This keeps accountability, reporting, time capture, and crew scheduling clear.

A crew can have multiple assignments in a single day. The schedule should allow this while surfacing conflicts, overbooking, travel/logistics concerns, and reporting expectations. A crew-day field report can cover multiple assignment/task sections.

Production assignments should require a job and allow a nullable task. Task-linked assignments are preferred for production reporting and billing, but job-only assignments avoid forcing fake tasks for general support, mobilization, cleanup, or early planning.

## Logistics And Move Vision

The logistics module is a central dispatch layer for physical movement.

It should cover operational movement across:

- equipment
- materials
- tools, attachments, or job packets if needed

The first practical version can focus on equipment moves because that is the clearest operational need. The model should not prevent materials from being added later.

Core move states may include:

- requested
- scheduled
- assigned
- in transit
- completed
- cancelled
- blocked

Important move concepts:

- needed-by time and scheduled time are different
- a move can exist before it has a scheduled time window
- current location and planned destination are different
- assignment to a driver or responsible person is its own step
- a crew can be associated with a move, but a named responsible person is preferred for accountability
- completion should update operational state
- completed asset moves should update asset current location
- completion requirements should be policy-driven, including optional photo, receiver confirmation, condition check, GPS capture, or admin review
- telemetry can confirm or contradict expected location
- move history is part of the resource's history
- a move can contain multiple line items

The move queue and move schedule should become main daily coordination surfaces for operations.

## Equipment And Cost Vision

Equipment should start as operational state tracking, then grow into financial and utilization intelligence.

Near-term:

- asset registry
- current job or location
- status and availability
- move workflow
- maintenance work orders
- file attachments
- basic GoAardvark sync
- optional or required equipment usage capture on field reports for visibility and issue capture

Medium-term:

- GPS location history
- runtime history
- usage by job
- usage by task where possible
- downtime tracking
- maintenance cost history
- utilization dashboards

Long-term:

- depreciation support
- asset operating overhead
- job-level equipment cost allocation
- owned versus rented equipment analysis
- equipment productivity metrics
- alerts when actual location or runtime conflicts with planned work

Important stance:

- operational workflow should remain authoritative for intent and responsibility
- telemetry should be authoritative for observed signals
- financial allocation should be derived from reviewed operational and telemetry data
- cost allocation should use assignment, reported usage, telemetry runtime, moves, and admin corrections as inputs rather than trusting any single raw signal

## Location And Geospatial Vision

Locations are first-class business places. They should not be stored only as freeform text.

The model should support:

- job sites
- yards
- shops
- vendors and suppliers
- storage areas
- staging areas
- entrances and access points
- other tenant-defined operational places

Jobs should support multiple locations, with one primary location by default. Assets should have an operational current location. Moves should have source and destination locations. Vendors, suppliers, shops, and subcontractor organizations may also have locations.

GPS readings are different from locations:

- `locations` are business-defined places
- telemetry readings are observed GPS points
- asset current location is the app's operational belief
- moves express intended relocation

Long-term geospatial capabilities may include geofences, map-based dispatch, expected-versus-observed location alerts, route and distance estimates, tracker health monitoring, and historical location playback.

## Role-Based Product Depth

The same process data should power very different experiences.

Field mobile workflows should plan for poor connectivity. Phase 1 should provide durable drafts, upload retry, and clear submission state. Full offline sync for reports, time, photos, and field updates should remain in the long-term vision once the core data model and field workflow are stable.

Admin users need broad dashboards and control:

- manage jobs
- manage tasks
- schedule crews
- manage users and roles
- manage equipment
- manage moves
- manage documents
- review payroll/time
- inspect reports and audit history

Foremen need focused execution tools:

- today's assignments
- crew roster
- daily report
- time allocation
- equipment issues
- photos and notes
- durable drafts and retry behavior in weak connectivity

Workers may need minimal mobile flows:

- clock or time entry
- assignment visibility
- simple confirmations
- photo or note submission
- offline-capable capture later if field conditions require it

Mechanics need maintenance workflows:

- work order queue
- asset history
- status updates
- repair notes and files

Subcontractors need scoped access:

- assigned work
- limited documents
- limited reporting
- upload and confirmation flows

RBAC should control actions and visibility. It should also shape the interface so each role sees the amount of product they can actually use.

Permissions should eventually combine role and scope. A role defines what actions a user can perform. Scope defines where those actions apply: tenant-wide, module-specific, job-specific, crew-specific, organization-specific, assignment-specific, or document-specific. Phase 1 can use simpler tenant-wide internal roles, but external users and field users will require scoped access over time.

Device type should primarily affect user experience, navigation, and risk controls. Core authorization should come from user, role, scope, and tenant. Mobile screens may hide bulk admin tools or require re-authentication for sensitive actions, but a user's fundamental permissions should not depend on screen size alone.

## Long-Term Modules

### Work Management

- jobs
- tasks
- schedule assignments
- field reports
- production status
- task progress

### Labor

- employees/workers
- crews
- foremen
- time entries
- review and approval
- payroll export and payroll platform sync

### Equipment

- asset registry
- move history
- telemetry
- utilization
- maintenance state
- cost allocation later

### Moves And Dispatch

- move queue
- move schedule
- equipment moves
- material moves
- driver assignment
- time-window coordination

### Maintenance

- work orders
- mechanic workflow
- downtime
- maintenance documents
- repair history

### Materials

- catalog
- job requirements
- deliveries
- movement
- supplier relationships
- cost and quantity tracking later

### Documents

- plans
- photos
- tickets
- versions
- annotations
- entity attachments
- document permissions

### Subcontractors And Vendors

- subcontractor companies
- subcontractor crews
- external contacts
- scoped access
- compliance documents
- work confirmations

### Analytics

- operational dashboards
- process data aggregation
- activity feed and operational timelines
- notifications and alerting later
- job performance
- labor trends
- equipment utilization
- move bottlenecks
- maintenance patterns
- overhead and cost allocation

## First Build Focus

The first build should prove the core operating loop:

1. Create jobs and tasks.
2. Manage employees and crews.
3. Schedule crews to tasks.
4. Let foremen submit daily reports.
5. Generate and review time entries.
6. Track equipment state.
7. Manage equipment moves.
8. Open and resolve maintenance work orders.
9. Attach photos and documents to key records.
10. Maintain audit history for important changes.

The first build should include enough structure to grow into the long-term vision, but it should not attempt to build every module fully.

Day-one defer candidates:

- full material inventory
- full subcontractor portal
- document annotation
- billing automation
- depreciation and cost allocation
- advanced telemetry analytics
- configurable workflow builders
- high-volume single-technician dispatch optimization

## Implementation Priority Ladder

The vision is broad, but the build should move in dependency order.

1. Core operational truth: tenants, users, workers, crews, jobs, tasks, assignments, locations, and core status models.
2. Field execution: crew-day reports, worker/time capture, photos/documents, notes, equipment usage visibility, and issue capture.
3. Review loop: time review, corrections, report history, focused audit events, and operational dashboards.
4. Equipment, logistics, and maintenance: robust assets, move queue/schedule, move items, equipment issue review, and maintenance work orders.
5. Documents and plans: versioning, generic attachments, tags, plan workflow discovery, markup foundations, and later plan sets/sheets.
6. Integrations: GoAardvark exploration, payroll export/sync, accounting export/sync, external IDs, sync runs, and integration logs.
7. Expansion modules: material workflows, subcontractor scoped access, secure action links, inspections, notifications, configurable saved views, and role/scoped permissions.
8. Advanced intelligence and platform capabilities: equipment cost allocation, utilization analytics, geofencing, public API, outbound webhooks, external portals, and native tracker hardware exploration.

## Product Risks

### Over-Generalizing Too Early

Trying to support every blue-collar workflow immediately could weaken the product for Montague's actual needs.

Mitigation:

- design around Montague's field construction workflow first
- use one-person crews for future flexibility
- add direct worker scheduling only if a real customer workflow requires it
- avoid building a service-dispatch product before the construction workflow is solid

### Under-Modeling Key Concepts

Treating subcontractors, materials, documents, or moves as text fields could make future features harder.

Mitigation:

- define long-term entities now
- implement lightweight versions first
- avoid overbuilding UI before workflows are confirmed

### Excessive Customization

A platform that allows every tenant to define everything differently becomes hard to operate and hard to improve.

Mitigation:

- keep shared core entities
- use constrained configuration
- add feature flags and modules before custom schema
- prefer product decisions over per-customer setup

### Confusing Operational Intent With Observed Data

Scheduled assignments, moves, and equipment locations represent what the company intends. GPS and runtime data represent what was observed.

Mitigation:

- keep planned workflow records separate from telemetry records
- reconcile them into signals instead of replacing one with the other

## Open Design Questions

1. Should the product use `task` or `work_item` as the user-facing term?
2. How often does Montague assign one crew to multiple jobs or tasks in the same day?
3. Which crew types should exist in the first implementation: internal, subcontractor, temporary, solo?
4. What exact statuses does the move queue need for equipment moves first?
5. Are material moves part of the first move queue workflow, or a later extension?
6. Which GoAardvark fields are available, and how reliable are location and runtime readings?
7. Which equipment cost questions matter first: utilization, downtime, depreciation, job allocation, or overhead?
8. What subcontractor workflows are required early: scheduling only, document collection, reporting, time capture, or scoped portal access?
9. What document types matter first: plans, photos, tickets, subcontractor docs, maintenance docs, or all job files?
10. For Montague's first rollout, does worker self-submitted time need to ship or can foreman reports remain the only field capture path?
11. Which actions require audit history in the first release?
12. Which data should remain editable in spreadsheets, and which data becomes app-owned immediately?

## Strategic Summary

IronOps should become an opinionated operating system for field-heavy companies.

The product should start with Montague Development's construction workflow: jobs, tasks, crews, foremen, daily reports, time review, equipment, moves, maintenance, documents, and subcontractors.

The architecture should support multi-tenant SaaS from the beginning, with clear shared entities and constrained flexibility. The platform should be flexible enough to handle smaller crews, solo workers, subcontractors, materials, and richer asset intelligence over time, but it should not become a fully custom workflow builder.

The long-term advantage is not just digitizing forms. It is collecting structured operational process data across the company and turning it into coordination, accountability, cost insight, and better field execution.
