# IronOps Architecture

## Purpose

This document is the technical north star for IronOps. It captures foundational architecture decisions for a greenfield, long-lived, multi-tenant SaaS platform for blue-collar field operations.

The current repository shape is not a constraint. IronOps should be built on a quality foundation that is easy to grow, scale, observe, secure, and operate without prematurely becoming a distributed platform.

## Product Context

IronOps owns operational truth for field companies. The platform will manage jobs, tasks, crews, assignments, reports, time entries, equipment/assets, logistics moves, maintenance, documents/plans, materials, subcontractors, integrations, analytics, and exports.

The architecture must support:

- structured operational data
- transactional workflows
- mobile field usage
- documents, plans, photos, and markup
- background jobs and integrations
- audit/activity history
- geospatial data and future telemetry
- role/scope based access
- future public APIs, webhooks, and SaaS packaging

## Core Principles

- Start with a modular monolith, not microservices.
- Use one primary Postgres database as the system of record.
- Keep domain boundaries clean enough to extract services later if real pressure appears.
- Prefer containers, open standards, and provider portability.
- Prefer open-source infrastructure when mature and operationally reasonable.
- Build for multi-tenancy, auditability, observability, and security from day one.
- Avoid low-code/custom-field sprawl and operationally dangerous customer customization.
- Keep Phase 1 pragmatic enough to ship a strong Montague-focused product.

## Initial System Shape

```text
Web Client / Mobile Web / Future Mobile Shell
        |
Core API
        |
Postgres / PostGIS
        |
Object Storage
        |
Workers / Queues / Scheduled Jobs
        |
External Integrations
```

Initial deployable units:

- `apps/web`: Astro web app
- `apps/api`: Hono API
- `apps/worker`: background workers and scheduled job runner
- shared packages for domain, database, config, queues, observability, API contracts, and UI

Additional worker/container splits are allowed later for document processing, telemetry, integrations, or exports when isolation or scale justifies them.

## Non-Goals For Phase 1

- Microservices by default
- Event sourcing as primary persistence
- Kubernetes before orchestration complexity justifies it
- A full workflow engine
- A low-code/custom-fields platform
- Spreadsheets as operational storage
- A data warehouse or BI stack before reporting load demands it
- Full local-first sync
- Billing/pricing engine
- Broad public API/webhook product

## Monorepo, Runtime, And Tooling

- Use a monorepo with separate apps/packages for web, API, workers, shared code, and infrastructure.
- Use TypeScript as the core platform language.
- Use Hono for the core API, running as a containerized long-lived server.
- Use Node LTS as the production runtime for API/workers initially.
- Use Bun for package management and script running.
- Validate Bun runtime separately before using it for production API/workers.
- Use Turborepo for task orchestration, caching, and build coordination.
- Keep business logic outside Hono route handlers in domain/application services.
- Keep Effect out of the core architecture for now; evaluate later for integrations/workers where typed errors, retries, concurrency, resource management, or dependency injection become high-value.

## API Architecture

- Keep the frontend and API as separate apps. The API is authoritative for web, mobile, workers, and future integrations.
- Use REST-ish resource endpoints for normal CRUD.
- Use explicit action endpoints for workflow transitions such as `submit_report`, `approve_time_entry`, `complete_move`, `close_work_order`, `create_document_version`, and `reopen_exported_time`.
- Do not hide meaningful workflow side effects behind generic `PATCH status` calls.
- Use OpenAPI as the API contract format.
- Generate TypeScript clients for web/mobile/internal consumers.
- Prefer OpenAPI over tRPC because IronOps needs durable boundaries for mobile, future public API, docs, testing, and non-TypeScript integrations.
- Use Zod for request/response validation, DTO schemas, and config validation.
- Keep transport schemas, domain rules, and database constraints conceptually separate.
- Use `/api/v1` from day one, even while private.
- Prefer additive API changes and avoid casual breaking changes to response shapes, enum meanings, IDs, pagination, and error codes.
- Treat generated clients and OpenAPI contract checks as compatibility tests.
- Do not build heavy multi-version support until external customers or integrations depend on older contracts.

Response conventions:

- Return direct resource payloads for simple success responses.
- Use `{ data, meta }` for lists, pagination, search, and metadata-heavy responses.
- Use structured error envelopes with stable error codes, human-readable messages, and optional details.
- Use cursor pagination by default for lists, timelines, audit/activity, documents, reports, time entries, moves, and telemetry.
- Allow offset pagination only for small reference/admin tables when clearly safe.

API docs:

- Serve an internal API reference from generated OpenAPI.
- Use Scalar as the first API reference UI because it integrates cleanly with Hono, provides an interactive client, and keeps OpenAPI as source of truth.
- Keep the renderer swappable. Redoc/Redocly, Swagger UI, or hosted docs can be evaluated later for public developer docs.

## Frontend And Mobile

- Use Astro for `apps/web`.
- Use Svelte as the default product UI framework.
- Allow React islands only by exception for specialized high-value components or libraries.
- Keep auth, state, API clients, routing, and design-system conventions coherent so Astro does not become a mixed-framework free-for-all.
- Use Astro static/SSR where useful for marketing, docs, auth pages, lightweight settings/admin pages, and initial protected app shell loading.
- Use client-rendered Svelte islands for highly interactive surfaces such as schedule boards, move queues, tables, dashboards, document viewers/markup, maps, and drag/drop workflows.
- Use route/layout/middleware checks for protected Astro routes where server-side checks are available.
- Client-side route guards are UX helpers only. API authorization remains the security boundary.

Mobile strategy:

- Start with responsive web/mobile web for field workflows.
- Prefer Capacitor as the near-term native shell if app-store packaging, push notifications, camera/file/location access, or mobile install behavior require it.
- Reserve Expo/React Native for a later dedicated native app if WebView/PWA/Capacitor constraints become limiting for deep offline, high-fidelity native UX, or device-heavy field workflows.
- Support current evergreen desktop browsers and modern iOS/Android browsers.
- Do not optimize for legacy browsers unless a specific customer requirement justifies it.

Offline readiness:

- Treat offline support as a planned field-workflow constraint, not a full Phase 1 local-first system.
- Use durable IDs, idempotency keys, retry-safe mutation endpoints, server-side conflict rules, and clear submission states.
- Allow client-side drafts for reports, time entries, photos, notes, and simple task updates.
- Keep the server authoritative for accepted records, timestamps affecting payroll/billing, permission checks, and conflict resolution.
- Do not adopt Zero/local-first sync in Phase 1.

## UI Foundation

- Use Tailwind CSS as the styling foundation.
- Use shadcn-svelte as the starting component distribution layer for common product UI.
- Treat shadcn-svelte components as owned source code that IronOps can modify.
- Use Bits UI directly when lower-level accessible Svelte primitives are needed.
- Do not treat React shadcn/Base UI as the default UI foundation; that only applies to exceptional React islands.
- Build IronOps-specific product components instead of adopting a generic admin template wholesale.
- Use Superforms + Zod for Svelte/Astro form handling where standard forms and progressive enhancement fit.
- Use TanStack Query for server-state fetching, caching, mutations, invalidation, polling, retries, and stale data management.
- Use local Svelte state/stores for UI-only state.
- Use TanStack Table for data-heavy tables.
- Build IronOps table patterns for filtering, column visibility, sorting, bulk actions, row actions, saved views, and export behavior.
- Do not prematurely standardize on one calendar, scheduler, or Gantt library. Start with first-party schedule/queue/timeline views and evaluate specialized libraries once requirements harden.

Accessibility:

- Treat accessibility as an engineering requirement from the beginning.
- Use semantic HTML, accessible primitives, keyboard navigation, visible focus states, labels/descriptions/errors, color contrast, and screen-reader-friendly dialogs/forms/tables.
- Include accessibility checks in design review and critical workflow testing.
- Defer VPAT/compliance paperwork until enterprise contracts require it.

## Database And Data Model

- Use Postgres as the primary operational database.
- Enable PostGIS from the beginning.
- Use Drizzle for schema, migrations, query building, and TypeScript database typing.
- Do not use libSQL/Turso as the primary database.
- Do not adopt Zero Sync in Phase 1.
- Treat libSQL/Turso, Zero, or similar sync/local-first tools as future specialty options for scoped offline/edge/realtime needs.
- Use UUIDv7 as the default primary ID for tenant-owned and platform-owned records where supported.
- Keep human-readable business codes separate from primary keys for job numbers, asset tags, move numbers, work order numbers, report numbers, invoice/export refs, and external integration refs.
- Do not make business codes the database primary key.
- Keep database schema definitions close to Drizzle schema and domain modules.
- Treat schema/migrations as the technical source of truth.
- Generate ERD/entity docs periodically for human review and onboarding.

Search:

- Use Postgres as the first search layer.
- Prefer normalized filters, targeted indexes, `pg_trgm`, and Postgres full-text search for jobs, assets, workers, document metadata, tasks, reports, moves, and work orders.
- Do not add Elasticsearch/OpenSearch/Meilisearch/Typesense in Phase 1 unless forced.
- Keep API search contracts abstract enough to add a dedicated search service later.

Reporting:

- Use Postgres as the first customer-facing business reporting layer.
- Phase 1 reports should focus on job status, open/overdue tasks, schedules, crew utilization, worker hours, time approvals, equipment assignments/usage, maintenance due, move history, report completion, missing reports, unresolved issues, and payroll/accounting exports.
- Use indexes, scoped queries, summary tables, or materialized views when reporting gets expensive.
- Do not add a warehouse/ClickHouse/BigQuery/DuckDB pipeline in Phase 1.
- Keep business reporting separate from app observability.

Lifecycle:

- Use soft deletes for major tenant-owned operational entities where history, auditability, references, or reporting matter.
- Use `deleted_at` and `deleted_by` where deletion is supported.
- Add `archived_at` or archive status where records should leave active workflows but remain valid history.
- Jobs, tasks, workers, crews, assets, documents, moves, work orders, reports, and time entries should generally not be casually hard-deleted.
- Hard deletes or expiration are acceptable for disposable records such as sessions, tokens, temporary upload state, queue internals, cache rows, and some join rows where history does not matter.

## Tenancy, Identity, And Authorization

- Every tenant-owned table should include `tenant_id`.
- Every application query should run through tenant/user/security context.
- Start with strict app-layer tenant scoping, tenant-aware schema conventions, and tests.
- Design for later Postgres row-level security as defense-in-depth after patterns stabilize.
- Use stable internal `tenant_id` as source of truth.
- Use tenant slugs for URLs, admin UX, support workflows, and human-readable references.
- Do not depend on email domains as tenant identity.
- Use verified domains for allowlisting, invite routing, login hints, and tenant discovery.
- Phase 1 can use explicit tenant selection after login or path-based tenant context.
- Leave room for custom domains/subdomains later.

Authentication:

- Use Better Auth for Phase 1.
- Support Google OAuth/OIDC and tenant/domain allowlisting for Montague's Google Workspace.
- Keep IronOps-owned users, workers, roles, scopes, and policy logic in the application domain.
- Treat WorkOS, SAML, SCIM, and enterprise SSO as later enterprise features if demand justifies them.
- Model authenticated users as global identities that can belong to multiple tenants.
- Store tenant membership separately from user accounts, with role/scope/status attached to membership.
- Ensure every request has explicit active tenant context after login.
- Do not assume one email maps to exactly one tenant.

Users, workers, and external access:

- Model authenticated users separately from operational workers/personnel.
- A user is a global login identity.
- A worker is an operational person/resource within a tenant.
- Allow workers to link to users when they have app access.
- Allow workers without user accounts for imports, historical records, payroll references, subcontractors, and rosters.
- Reuse the same global user and tenant membership model for subcontractor/external access.
- Do not create a second auth system for external users.
- Represent external access through membership type, role/scope, invitation, expiration, and entity-specific grants.
- Use tightly scoped invitation links for short-term or limited access.

Authorization:

- Use auth middleware to establish user, tenant, role, and scope context.
- Use an explicit policy layer shaped around actor, action, resource, and context.
- Keep policies testable outside route handlers.
- Start with simple tenant membership roles such as owner, admin, manager, foreman, worker, and external.
- Support RBAC first and leave room for scoped permissions later.
- Avoid customer-defined roles in Phase 1 unless required.
- Keep external/subcontractor permissions tightly scoped and fully auditable.

Support access:

- Plan for internal support/admin impersonation, but do not treat it as casual access.
- Require explicit permission, reason capture, time-bounded sessions, visible acting-as UI, and complete audit logging before enabling impersonation.
- Prefer logs, audit history, and admin diagnostics before impersonation.

## Audit, Activity, Events, And Notifications

Audit/activity:

- Treat audit and activity history as first-class from day one.
- Store user-visible activity and admin audit records in Postgres.
- Capture tenant, actor, action, entity type/id, timestamp, source app/device, request context when available, and useful metadata.
- Use activity for entity timelines, accountability, support/debugging, compliance-lite, notifications, and future reporting.
- Keep activity/audit separate from BullMQ jobs and integration events.
- Do not use event sourcing as primary persistence in Phase 1.

Domain events:

- Use consistent past-tense fact names for domain events, such as `task.created`, `move.completed`, `report.submitted`, `time_entry.approved`, `asset.assigned`, and `document.version_created`.
- Keep commands/actions imperative at API/service boundaries, such as `submit_report` or `complete_move`.
- Do not use event names for requested actions that may fail or be rejected.

Notifications:

- Model notifications as product-domain records in Postgres, not just delivery jobs.
- Store notification intent, recipient, tenant, entity reference, read/unread state, timestamps, priority/type, and metadata.
- Store notification preferences by notification type and delivery channel.
- Support tenant-level defaults and user/member-level overrides.
- Keep preferences simple initially: in-app, email, push later, SMS later, enabled/disabled, and perhaps digest/immediate when justified.
- Avoid a broad notification rules engine until real customer needs demand it.
- Use workers for channel delivery such as in-app fanout, email, push, SMS, and future webhooks.
- Record delivery attempts/status separately from the durable notification record.
- Start with polling/refetch for notification badges/lists. Add SSE/WebSockets/Redis fanout later if realtime value justifies it.
- Do not use Redis, BullMQ, Kafka, RabbitMQ, NATS, or an external notification platform as the notification source of truth.
- Evaluate Novu, Knock, Courier, or similar platforms later only if multi-channel complexity becomes a drag.

## Workers, Queues, And Scheduled Jobs

- Use BullMQ + Redis as the first background job system.
- Use a Postgres transactional outbox to reliably bridge committed database transactions to queue jobs.
- Do not use Postgres as the primary queue.
- Start with one worker app/container using the same domain/service packages as the API.
- Split by queues and job handlers first, not separate services per domain.
- Initial queues: default, notifications, documents, integrations, exports, telemetry, and maintenance.
- Keep heavy/long-running jobs from blocking notifications/exports through queue separation and concurrency controls.
- Workers should be horizontally scalable by queue.
- Important jobs must be idempotent, retry-safe, timeout-bounded, observable, and replayable where practical.
- Define queue standards early: idempotency keys, retries, backoff, failed-job handling, dead-letter convention, structured logs, metrics, and admin replay.
- Keep workflow logic in domain/application services, not buried in BullMQ plumbing.

Scheduled work:

- Run cron-style work through the worker system, not inside normal API request handling.
- Scheduled jobs should enqueue normal worker jobs rather than doing all work in the scheduler tick.
- Examples: report reminders, maintenance due checks, recurring task/work-order generation, stale move checks, payroll cutoff prep, integration polling, telemetry polling, cleanup jobs, and export expiration.
- Ensure only one scheduler instance fires each schedule in production, or use locks/leader patterns.
- Make scheduled jobs idempotent.

Future workflow/broker options:

- Reserve Temporal for durable long-running workflows with timers, signals, compensation, human-in-the-loop steps, or complex retry semantics.
- Good future Temporal candidates: payroll exports, accounting sync, document pipelines, equipment lifecycle workflows, maintenance threshold workflows, and move orchestration if dispatch complexity grows.
- Reserve RabbitMQ for broker-style service messaging, Kafka for future event streaming/telemetry/analytics pipelines, and NATS for lightweight eventing/edge messaging if those needs become real.

## Files, Documents, Photos, And Attachments

Storage:

- Use an S3-compatible object storage abstraction.
- Use MinIO locally.
- Use Cloudflare R2 or AWS S3 for production.
- Store binary file contents in object storage.
- Store file metadata, document versions, attachment links, permissions, processing status, and audit data in Postgres.
- Use private object storage, signed URLs, file size limits, and file type validation in Phase 1.
- Use direct signed uploads for larger files. The API owns permissions and metadata.
- Add async malware scanning/quarantine before broad external uploads or document sharing. ClamAV is a likely open-source starting point.

Document processing:

- Keep upload metadata, permissions, and signed-upload creation in the API.
- Run thumbnails/previews, PDF page extraction, plan image generation, OCR later, markup flattening/export, malware scanning later, and document indexing through workers.
- Track processing states in Postgres: pending, processing, ready, failed, quarantined.
- Keep processing idempotent and retry-safe.
- Preserve original uploaded files.
- Treat PDF as the stable archival/rendering format where practical, especially for plans and external sharing.
- Generate page previews for fast web/mobile viewing.
- Store markups as structured overlay data tied to document id, version, page, coordinates, author, timestamps, and markup type.
- Do not flatten markups into the only source of truth.
- Generate flattened/annotated exports when needed.

Photos/media:

- Treat field photos and media as first-class attachments.
- Store tenant, linked entity, uploader, upload timestamp, captured timestamp if available, optional location, device/source context, content type, size, object key, processing status, and preview references.
- Process thumbnails, previews, compression/transcoding if needed, malware scanning later, and metadata extraction asynchronously.
- Strip, normalize, or explicitly control EXIF metadata because it can contain sensitive location/device/timestamp data.

Attachment links:

- Use a constrained generic attachment link model.
- Supported targets should be explicit and validated, such as job, task, report, work order, asset, move, location, material, subcontractor/vendor, time entry, crew, and worker.
- Do not allow arbitrary unvalidated entity strings as attachment targets.
- Derive attachment permissions from tenant, linked entity, document/file permissions, and user policy context.
- Allow one file/document to link to multiple entities when useful.

## Geospatial, Maps, Devices, And Telemetry

Backend:

- Use PostGIS for geospatial foundations.
- Keep early geospatial usage simple, but store locations and telemetry to support distance, containment, nearest-location, geofence, and expected-versus-observed queries later.
- Treat GPS/location capture as contextual evidence, not unquestioned truth.
- Store location with source, device/session context when available, timestamp, accuracy, and action/entity context.
- Design for bad signal, stale readings, spoofing risk, dead zones, and privacy expectations.
- Preserve admin review/override paths for location-related exceptions.

Maps:

- Use MapLibre GL as the first-choice browser map engine.
- Prefer Svelte-first map UI components, including evaluating or copy-owning from mapcn-svelte where useful.
- Treat MapCN/mapcn-svelte as accelerators or references, not the strategic geospatial foundation.
- Keep tile, geocoding, routing, and basemap provider choices separate from the UI component library.
- Allow React map islands only when a React-only map component/library is clearly worth the framework boundary.
- Start with simple/free or low-cost tiles/geocoding with correct attribution and acceptable limits.
- Reevaluate MapTiler, Stadia, CARTO, Mapbox, Google Maps Platform, or self-hosted tiles for production based on cost, licensing, coverage, satellite needs, routing/ETA, offline needs, and support.

Devices and push:

- Start with normal user authentication and session tracking.
- Preserve room for device records tied to users, memberships, sessions, push tokens, and offline state.
- Defer trusted devices, kiosk/shared-device mode, MDM-managed tablets, and device-level access policy until field deployment requires it.
- Treat push notifications as a planned future channel.
- Model device tokens per user/member/device when push is implemented.
- Defer APNs/FCM/Expo push decisions until the mobile shell is proven.

## Integrations, Imports, Exports, And Webhooks

Provider adapters:

- Use provider adapters so local/dev/test can run fake implementations without external side effects.
- Fake adapters should exist for email, SMS, push, payroll, accounting, GoAardvark/equipment telemetry, billing, object storage, and webhooks where appropriate.
- Prefer open-source local substitutes where useful: Mailpit/MailHog for email, MinIO for object storage, local Redis, local Postgres/PostGIS, and mock webhook/test servers.
- Use real provider sandboxes in staging when available.

Integration model:

- Model integrations with connection/config records per tenant.
- Store external ID mappings in integration mapping tables rather than scattering provider-specific IDs across core tables by default.
- Track sync cursors, last sync timestamps, status, error state, provider rate-limit/backoff state, and audit/activity records.
- Allow multiple integrations to map to the same IronOps entity over time.
- Keep IronOps IDs and business logic authoritative.
- Add provider-specific core columns only when an integration is truly foundational.

Inbound webhooks:

- Webhook handlers should verify/authenticate provider requests, store raw inbound events, dedupe by provider/event id where available, enqueue processing, and return quickly.
- Workers translate raw provider events into validated IronOps domain changes.
- Store processing status, errors, replay metadata, and audit/activity context.
- Keep webhook processing idempotent because providers retry and may deliver out of order.

Outbound delivery:

- Do not send email, push, SMS, webhooks, exports, or document notifications directly from normal API request handlers.
- API handlers create durable records, validate permissions, commit transactions, and enqueue work through the outbox/queue path.
- Workers own provider calls, retries, backoff, delivery logs, idempotency, provider error handling, and provider switching.
- Put email behind a provider adapter.
- Evaluate Resend for developer experience, Postmark for transactional reliability, and AWS SES for cost/control.
- Keep templates owned in code or IronOps-managed records unless provider templates have a clear operational benefit.

Imports:

- Support controlled CSV/XLSX/manual-script imports for onboarding data such as jobs, workers, crews, assets, documents, contacts, vendors/subcontractors, materials catalogs, and historical time/report data.
- Use staged imports with validation, preview, row-level errors, duplicate detection, tenant scoping, and audit logs.
- Keep imports admin-led or IronOps-assisted early, not a broad customer import builder.
- Do not let import mapping become a hidden custom-fields/workflow system.

Exports:

- Treat exports as first-class asynchronous jobs.
- Use workers for payroll, accounting, reports, document bundles, audit, time, asset, CSV/XLSX/PDF generation, and other large exports.
- Store export metadata in Postgres: tenant, requester, type, filters/scope, status, output file reference, timestamps, expiration, and error state.
- Store generated files in object storage and download through signed URLs.
- Add audit/activity entries for sensitive exports.

Future public API/webhooks:

- Design the internal API with future public API and webhook externalization in mind, but do not ship a broad public API in Phase 1.
- Use stable IDs, OpenAPI contracts, idempotency for important mutations, clear error codes, audit history, integration-friendly schemas, and consistent event/action naming.
- Future machine access should use tenant-scoped API keys or service accounts with scopes, expiration, rotation, audit logs, last-used tracking, and rate limits.
- Do not let integrations share human passwords or long-lived all-powerful tokens.
- Outbound webhooks should be worker-delivered and auditable later.
- Defer customer webhook subscriptions, signing secrets, retry policies, delivery logs, replay UI, and public docs until demand justifies them.

## Billing, Entitlements, Usage, And Pricing

- Use tenant module entitlements in the IronOps database from the beginning.
- Initial entitlements can be simple enabled/disabled records or plan-feature flags for modules such as time, assets, moves, maintenance, documents, reports, materials, subcontractors, integrations, payroll export, accounting export, and telemetry.
- Enforce module access through the policy layer.
- Keep PostHog feature flags separate from DB entitlements.
- Use PostHog feature flags for rollout, experiments, beta access, and kill switches.
- Do not use feature flags as the source of truth for security, roles, billing, or entitlements.

Billing:

- Plan for billing, but do not build full subscriptions in Phase 1.
- Keep billing provider integration behind an adapter.
- Manual contract billing or Stripe invoices are acceptable for early Montague-style customers.
- Evaluate Stripe Billing, Stripe Managed Payments, Paddle, Polar, Lemon Squeezy, and other billing/MoR providers before self-serve SaaS packaging.
- Do not assume standard Stripe Payments/Billing is merchant-of-record; MoR requires a specific MoR offering/provider.
- Treat MoR support as valuable for self-serve/global scale because it can shift tax collection/remittance, payment compliance, disputes/refunds, and transaction support to the provider.
- Store tenant plan, billing status, billing provider customer id, subscription/reference ids, billing contact data, and billing metadata when billing is added.
- Keep IronOps entitlement/access state authoritative in the database. Provider events update IronOps state, not replace it.

Usage and pricing:

- Keep entitlements, usage, and billing conceptually separate.
- Entitlements define what a tenant may use.
- Usage records/counters define what a tenant actually used.
- Billing defines how entitlements and usage translate into money.
- Track operational usage before building billing-grade metering.
- Useful usage dimensions: active users/workers, tracked assets, document storage, document processing pages/previews/OCR, telemetry/device count, API/webhook volume later, enabled integrations, payroll exports, SMS/push/email volume, and invited external/subcontractor access.
- Likely packaging: tier plus active user/worker billing plus included usage plus add-ons.
- Possible tiers: Core Ops, Field Ops, Operations Pro, Enterprise.
- Bundle normal usage into tiers; reserve overages/add-ons for expensive or value-correlated resources such as extra workers, extra assets, telemetry/device tracking, SMS, OCR/document processing, accounting sync, premium support, and onboarding.

## Observability, Logging, And Product Analytics

- Use OpenTelemetry as the instrumentation standard for API, workers, queues, and integrations.
- Use SigNoz as the first open-source observability backend candidate for logs, traces, metrics, dashboards, and alerts.
- Use PostHog for product analytics, session replay, feature flags, and user behavior.
- Keep Grafana/LGTM and Sentry as later alternatives if SigNoz/PostHog do not cover operational or error-tracking needs well enough.
- Do not use Datadog by default.

Logging:

- Use structured logs for API, workers, queues, scheduled jobs, integrations, and document processing.
- Include request id, trace/correlation id, tenant id, user id when available, active membership/role where useful, route/action name, job/queue id, integration id, and safe entity references.
- Avoid logging sensitive document contents, tokens, secrets, raw payroll data, full request bodies, signed URLs, or unnecessary PII by default.
- Use explicit redaction/scrubbing utilities.

Performance:

- Treat performance targets as engineering guardrails, not Phase 1 customer SLAs.
- Aim for normal core API read/write p95 latency around 300ms or better where practical.
- Paginate dashboard, list, timeline, audit, search, document, report, move, time, and telemetry endpoints.
- Avoid unbounded queries and response payloads.
- Keep large file, export, document, integration, and telemetry work off normal request paths.
- Optimize mobile field screens for quick load, low bandwidth, and minimal repeated data entry.
- Measure with OpenTelemetry before adding complex caching or infrastructure.

Caching:

- Do not use broad application caching for core domain reads in Phase 1.
- Use Postgres queries, indexes, pagination, and targeted query design first.
- Redis will exist for BullMQ and can also support rate limits, locks, short-lived auth/session helpers if needed, feature/config caching, external API token caching, and safe ephemeral use cases.
- Avoid caching scheduling, assignment, move, time, or workflow state unless there is measured need and clear invalidation.

## Security, Privacy, And Governance

- Use provider-managed encryption at rest for managed databases, object storage, backups, and infrastructure where available.
- Use TLS for data in transit.
- Use provider-native secret management first.
- Use AWS Secrets Manager/SSM if AWS is chosen, Azure Key Vault if Azure is chosen, and Railway variables for Railway experiments/staging.
- Use local `.env` and Compose env files only for development, with strict Zod validation and no committed secrets.
- Consider Doppler, Infisical, 1Password, SOPS/age, or similar tools only if multi-environment/team workflow becomes painful.
- Encrypt integration tokens, refresh tokens, API keys, webhook secrets, and similar credentials at the application layer or store them in a secrets manager.
- Defer broader field-level encryption until IronOps stores data that clearly requires it.

Rate limiting and DDoS:

- Design the API so rate limiting can be added cleanly before public API or broad external access.
- Protect auth, uploads, expensive searches, and public-ish endpoints first.
- Use per-IP, per-user, per-tenant, and future per-API-key limits where appropriate.
- Prefer Redis-backed app limits when identity/tenant context matters.
- Use edge/CDN/WAF protection for volumetric DDoS before traffic reaches the app.
- Defer billing-grade quota plans until public API/commercial packaging requires them.

Sensitive admin actions:

- Plan an internal IronOps superadmin/support surface separate from tenant admin UI.
- Cover tenant management, user/member support, audit/activity lookup, import/export jobs, integration health, failed jobs/replay, module entitlements, feature flags, billing state later, storage/document processing status, and operational diagnostics.
- Gate dangerous actions behind explicit permissions, confirmation, reason capture, and audit logs.
- Require reason capture for support impersonation, bulk data export, tenant suspension/reactivation, permission escalation, destructive deletes/restores, replaying failed integration jobs, bulk imports/migrations, manual billing/module changes, force-resyncing integrations, and sensitive data access later.
- Do not require reason capture for normal tenant operations.

Dependency and license policy:

- Prefer maintained, well-typed, boring dependencies with clear licenses and active communities.
- Avoid tiny unmaintained packages in core paths when small first-party code is safer.
- Be stricter for auth, crypto, uploads, document processing, database access, billing, and integrations.
- Keep lockfiles committed and deterministic.
- Add Dependabot/Renovate when the repo stabilizes.
- Prefer MIT, Apache-2.0, BSD, and ISC licenses.
- Avoid AGPL, SSPL, BUSL, strong copyleft, unclear, or source-available licenses in core product paths unless deliberately reviewed.
- Review GPL/LGPL based on linking, distribution, deployment, and SaaS exposure.
- Do not assume server-side/SaaS usage removes license risk.

## Environments, Deployment, CI/CD, And Operations

Local development:

- Use Docker Compose as the default local development entrypoint.
- Run web, API, workers, Postgres/PostGIS, Redis, MinIO, mail catcher, and optional observability through Compose.
- Support hot reload inside containers through bind mounts and dev server configuration.
- Use named volumes for dependency caches where useful.
- Keep host-run commands only as an escape hatch.

Testing and fixtures:

- Use Vitest for unit and service-level tests.
- Use real Postgres/PostGIS and Redis-backed integration tests via Docker Compose where behavior depends on constraints, transactions, queues, or migrations.
- Use Playwright for browser, mobile viewport, and critical workflow E2E tests.
- Add OpenAPI contract checks and generated-client smoke tests.
- Test migrations and seed fixtures as build concerns.
- Maintain minimal, demo, and e2e seed profiles with realistic IronOps data.
- Add optional activity simulation jobs later for schedules, moves, reports, missing reports, time entries, equipment usage, telemetry, notifications, audit events, and integration events.
- Keep simulated data clearly marked.

Environments:

- Support local, development, staging, and production.
- Use staging tenants and seed/demo data for early testing, demos, and training.
- Do not build tenant-level sandbox/test/prod environments in Phase 1.
- Leave room for sandbox tenants later for enterprise training, integration testing, or migration rehearsal.
- Staging should use the same images, deployment flow, migrations, Postgres/PostGIS, Redis, object storage pattern, workers, and env validation as production.
- Staging can use smaller instances, separate databases/buckets, lower retention, fake/sandbox providers, and lower-cost observability.
- Keep staging isolated from production data and provider side effects.
- Do not copy production data to lower environments by default.
- If production-derived data is ever needed, require approval, sanitization/anonymization, limited access, and expiration.

Migrations:

- Run production database migrations as an explicit deploy step/job, not automatically from app startup.
- Use the same built image or release artifact for migrations where practical.
- Deploy app/worker containers only after migrations succeed.
- Use expand/contract discipline: add first, backfill, switch reads/writes, remove later.
- Avoid destructive or long-locking migrations in normal deploys.
- Manually review risky SQL.

Deployment:

- Keep production provider undecided until experiments prove fit.
- Treat OCI container images as the portability contract.
- Railway is acceptable for experiments, demos, and possibly early staging.
- AWS ECS/Fargate and Azure Container Apps are leading serious production candidates.
- Cloudflare should be considered for DNS, CDN, WAF, R2 object storage, Astro frontend hosting, and edge glue, but not first core API/worker hosting.
- EKS/AKS or managed Kubernetes remain later options if service count, orchestration needs, or platform maturity justify them.
- Start Phase 1 single-region.
- Use managed Postgres backups/PITR where available, object storage durability, health checks, restartable/stateless containers, and documented restore procedures.
- Keep app containers horizontally scalable even if only one or a few run early.
- Avoid sticky in-memory app state.
- Defer read replicas, active-active multi-region, failover, distributed consistency, and formal SLA engineering until customer scale or uptime commitments justify them.

CI/CD:

- Use GitHub Actions-compatible workflow files.
- Use Blacksmith as the planned runner provider.
- Keep runner provider swappable for Depot, BuildJet, RunsOn, or GitHub-hosted runners.

Backup, restore, and retention:

- Use managed Postgres backups and PITR where available.
- Configure object storage durability, lifecycle, and versioning policies according to document retention needs.
- Document restore procedures for database, object storage references, and app config.
- Perform periodic restore drills.
- Define retention/deletion as a framework now, with exact durations decided later.
- Cover soft-deleted entities, archived entities, audit/activity, exports, temporary uploads, sessions/tokens, integration raw events, logs/traces/metrics, notifications, and document versions.
- Expire temporary uploads, generated exports, short-term signed URLs, sessions, and tokens explicitly.
- Preserve history where deletion could break reporting, payroll, job history, document history, or trust.

## Code Generation And Documentation

- Use code generation where it strengthens contracts and reduces drift.
- Good generated artifacts include OpenAPI clients, Scalar docs, ERD/entity diagrams, migration review artifacts, typed env/config docs, and future public SDKs.
- Do not generate opaque CRUD/service/business-logic layers.
- Keep domain workflows, policy checks, validations, and side effects explicit and reviewable.
- Architecture/product docs describe principles, terminology, and design intent.
- Schema and migrations remain the source of truth for database behavior.

## Future Bets To Revisit

- WorkOS/SAML/SCIM for enterprise SSO
- Temporal for durable multi-step workflows
- RabbitMQ/Kafka/NATS for broker/event-stream needs
- Dedicated search service for richer fuzzy/global/document search
- Warehouse/analytics store for heavy historical/cross-tenant analytics
- Expo/React Native for deeper native mobile
- Full local-first sync for scoped offline workflows
- Tenant sandbox environments
- Merchant-of-record billing provider and self-serve subscriptions
- Public API keys, customer webhooks, and developer portal
- Kubernetes if orchestration/platform needs justify it
