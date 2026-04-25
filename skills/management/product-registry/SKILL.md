---
name: "product-registry"
description: "Track all products, their services, features, health endpoints, and service maps — the factory's source of truth"
version: "2.0.0"
category: "management"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Reliable structured data management, consistent registry updates"
    - id: "openai/gpt-5.4"
      reason: "Strong at maintaining complex nested data structures"
    - id: "deepseek/deepseek-v3"
      reason: "Capable at structured data operations"
triggers: ["list products", "product registry", "what have we built", "product status", "show services", "service map"]
input_artifacts: ["product_launch_report", "system_design_document", "iteration_report"]
output_artifacts: ["product_registry_entry"]
allowed_commands: ["cat", "ls", "rg", "git log", "curl -s"]
blocked_commands: ["rm", "sudo"]
max_iterations: 1
token_budget: 50000
metadata:
  openclaw:
    requires:
      bins: ["git", "curl"]
---

# Skill: Product Registry

## Purpose

The product registry is the factory's **single source of truth** about every product it has built. It tracks not just the product as a whole, but every service within it, every feature, and every health endpoint. The maintenance system reads this to know what to check and how to check it.

## Registry Location

`workspaces/orchestrator/product-registry.yaml`

Maintained by the orchestrator. Updated automatically by:
- `idea-to-launch.lobster` → on initial product launch
- `product-iteration.lobster` → when features are added/changed/removed
- `product-maintain.lobster` → when health checks run
- `bug-fix.lobster` → when bugs are fixed
- Manual CEO action → "retire product X", "add service Y"

---

## Registry Schema

```yaml
products:
  - id: "freelance-tracker"
    name: "FreelanceTracker"
    description: "Time tracking and invoicing for freelancers"
    status: "live"           # live | staging | maintenance | retired
    version: "1.3.0"
    created_at: "2026-04-18T14:30:00Z"
    launched_at: "2026-04-18T16:30:00Z"
    last_updated: "2026-04-22T09:15:00Z"
    last_health_check: "2026-04-22T10:00:00Z"

    # ──────────────────────────────────────────────────
    # SERVICE MAP — every independently deployable unit
    # ──────────────────────────────────────────────────
    services:
      - id: "ft-web"
        name: "Frontend"
        type: "next.js"
        url: "https://app.freelancetracker.com"
        health_endpoint: "https://app.freelancetracker.com/health"
        ready_endpoint: "https://app.freelancetracker.com/health/ready"
        status_endpoint: "https://app.freelancetracker.com/status"
        deployment:
          target: "vercel"
          project_id: "prj_abc123"
          git_repo: "https://github.com/company/ft-web"
          branch: "main"
        status: "healthy"
        version: "1.3.0"

      - id: "ft-api"
        name: "Backend API"
        type: "express"
        url: "https://api.freelancetracker.com"
        health_endpoint: "https://api.freelancetracker.com/health"
        ready_endpoint: "https://api.freelancetracker.com/health/ready"
        status_endpoint: "https://api.freelancetracker.com/status"
        deployment:
          target: "local-rack"
          coolify_app_id: "app-xyz789"
          git_repo: "local://workspaces/senior-dev/ft-api"
          branch: "main"
        status: "healthy"
        version: "1.3.0"
        dependencies:
          - service_id: "ft-db"
            type: "database"
            connection: "postgresql://..."
          - service_id: "ft-cache"
            type: "cache"
            connection: "redis://..."
          - external: "stripe"
            type: "payment_provider"
            health_check: "https://status.stripe.com/api/v2/status.json"

      - id: "ft-worker"
        name: "Invoice Worker"
        type: "bull-queue"
        url: null  # workers don't have HTTP URLs
        health_endpoint: null
        status_endpoint: null
        # Workers are monitored via the API service's /status
        monitored_via: "ft-api"
        deployment:
          target: "local-rack"
          coolify_app_id: "app-worker456"
          git_repo: "local://workspaces/senior-dev/ft-api"  # same repo, different entry point
          branch: "main"
        status: "healthy"
        version: "1.3.0"

      - id: "ft-db"
        name: "PostgreSQL Database"
        type: "postgresql"
        url: "localhost:5432"
        health_endpoint: null  # monitored via ft-api's readiness check
        monitored_via: "ft-api"
        deployment:
          target: "local-rack"
          managed: true  # managed by Coolify/Docker, not custom code
        status: "healthy"

      - id: "ft-cache"
        name: "Valkey Cache"
        type: "valkey"
        url: "localhost:6380"  # different port from factory's valkey
        health_endpoint: null
        monitored_via: "ft-api"
        deployment:
          target: "local-rack"
          managed: true
        status: "healthy"

    # ──────────────────────────────────────────────────
    # SERVICE CONNECTIONS — how services talk to each other
    # ──────────────────────────────────────────────────
    connections:
      - from: "ft-web"
        to: "ft-api"
        protocol: "HTTPS/REST"
        description: "Frontend calls backend API"
      - from: "ft-api"
        to: "ft-db"
        protocol: "TCP/PostgreSQL"
        description: "API reads/writes user data"
      - from: "ft-api"
        to: "ft-cache"
        protocol: "TCP/Redis"
        description: "API caches sessions and rate limits"
      - from: "ft-api"
        to: "ft-worker"
        protocol: "Redis/BullMQ"
        description: "API enqueues invoice generation jobs"
      - from: "ft-worker"
        to: "ft-db"
        protocol: "TCP/PostgreSQL"
        description: "Worker reads invoice data, writes PDF URLs"
      - from: "ft-api"
        to: "external:stripe"
        protocol: "HTTPS/REST"
        description: "Payment processing"

    # ──────────────────────────────────────────────────
    # FEATURES — every user-facing feature and its health
    # ──────────────────────────────────────────────────
    features:
      - id: "time-tracking"
        name: "Time Tracking"
        description: "Start/stop timers, manual time entry, weekly view"
        status: "healthy"
        services_involved: ["ft-web", "ft-api", "ft-db"]
        # Which service's /status exposes this feature's metrics
        metrics_source:
          service_id: "ft-api"
          status_path: "features.time_tracking"
        added_in_version: "1.0.0"
        prd_requirement_id: "REQ-001"
        last_usage_24h: 340
        error_rate: 0.001

      - id: "invoice-create"
        name: "Invoice Generation"
        description: "Create, preview, and send PDF invoices"
        status: "healthy"
        services_involved: ["ft-web", "ft-api", "ft-worker", "ft-db"]
        metrics_source:
          service_id: "ft-api"
          status_path: "features.invoice_create"
        added_in_version: "1.0.0"
        prd_requirement_id: "REQ-003"
        last_usage_24h: 89
        error_rate: 0.0

      - id: "stripe-billing"
        name: "Stripe Billing"
        description: "Subscription management, payment processing"
        status: "healthy"
        services_involved: ["ft-web", "ft-api", "external:stripe"]
        metrics_source:
          service_id: "ft-api"
          status_path: "features.stripe_billing"
        added_in_version: "1.1.0"
        prd_requirement_id: "REQ-019"
        last_usage_24h: 12
        error_rate: 0.02

      - id: "quickbooks-export"
        name: "QuickBooks Export"
        description: "Export invoices and time entries to QuickBooks"
        status: "degraded"  # known issue being tracked
        services_involved: ["ft-api", "external:quickbooks"]
        metrics_source:
          service_id: "ft-api"
          status_path: "features.quickbooks_export"
        added_in_version: "1.2.0"
        prd_requirement_id: "REQ-022"
        last_usage_24h: 5
        error_rate: 0.15
        known_issues:
          - bug_id: "BUG-042"
            severity: "p2"
            description: "Export fails for invoices with > 50 line items"

    # ──────────────────────────────────────────────────
    # BUSINESS METRICS — from PRD success criteria
    # ──────────────────────────────────────────────────
    business_metrics:
      source_service: "ft-api"  # which service's /status has these
      status_path: "business_metrics"
      activation_event: "created first invoice"
      metrics:
        dau: 120
        wau: 340
        activation_rate: 0.71
        d7_retention: 0.45
        mrr_cents: 123000
        churn_rate_monthly: 0.03
      last_updated: "2026-04-22T10:00:00Z"

    # ──────────────────────────────────────────────────
    # EXTERNAL LINKS — product's own dashboards
    # ──────────────────────────────────────────────────
    dashboards:
      overview: "https://grafana.freelancetracker.com/d/overview"
      api_metrics: "https://grafana.freelancetracker.com/d/api"
      business: "https://posthog.freelancetracker.com/dashboard/1"
      logs: "https://grafana.freelancetracker.com/d/logs"
      error_tracking: "https://sentry.io/organizations/ft/issues/"
    incident_channel: "telegram:@ft_incidents"  # product pushes P0s here

    # ──────────────────────────────────────────────────
    # ITERATION HISTORY
    # ──────────────────────────────────────────────────
    iterations:
      - version: "1.0.0"
        date: "2026-04-18T16:30:00Z"
        type: "launch"
        changes: "Initial launch — time tracking + invoicing"
        features_added: ["time-tracking", "invoice-create"]
      - version: "1.1.0"
        date: "2026-04-19T14:00:00Z"
        type: "feature"
        changes: "Added Stripe billing integration"
        features_added: ["stripe-billing"]
      - version: "1.2.0"
        date: "2026-04-20T09:15:00Z"
        type: "feature"
        changes: "Added QuickBooks export"
        features_added: ["quickbooks-export"]
      - version: "1.3.0"
        date: "2026-04-22T09:15:00Z"
        type: "bugfix"
        changes: "Fixed invoice PDF rendering for multi-page invoices"
        features_modified: ["invoice-create"]
```

---

## Health Check Workflow

The maintenance pipeline reads this registry to know HOW to check each product. Here's the workflow:

```
product-maintain.lobster reads product registry
  │
  ├── For each SERVICE with a health_endpoint:
  │     GET {health_endpoint}
  │     → Record: alive/dead, response time
  │
  ├── For each SERVICE with a status_endpoint:
  │     GET {status_endpoint}
  │     → Extract: performance metrics, dependency health, feature metrics
  │
  ├── For services with monitored_via (no own endpoint):
  │     Read the parent service's /status
  │     → Check the dependency section for this service's health
  │
  ├── For EXTERNAL dependencies:
  │     GET {health_check} (e.g., Stripe status page API)
  │     → Record: available/degraded/down
  │
  ├── For each FEATURE:
  │     Read metrics from {metrics_source.service_id}/status
  │     → Navigate to {metrics_source.status_path}
  │     → Compare error_rate against baseline
  │     → Compare usage against previous period
  │     → Flag: degraded if error_rate > 5%, unhealthy if > 15%
  │
  ├── For BUSINESS METRICS:
  │     Read from {business_metrics.source_service}/status
  │     → Compare against PRD targets
  │     → Flag trends: retention dropping, activation declining
  │
  └── COMPILE REPORT:
        Product status: healthy / degraded / critical
        Per-service status
        Per-feature status
        Business metrics vs targets
        Action items (P0/P1/P2/P3)
        → Update registry with latest data
        → Notify CEO if critical
```

---

## Registry Update Rules

The registry is a **living document**. These events trigger updates:

### On Product Launch (`idea-to-launch.lobster` Phase 6)
- Create full registry entry
- Populate: services (from system design), features (from PRD), connections, endpoints
- Set status: "live", version: "1.0.0"

### On Feature Added (`product-iteration.lobster`)
- Add new feature entry under `features`
- Update `services_involved` if new services were created
- Add new service entries if architecture changed
- Add new connections if service relationships changed
- Bump version, add iteration history entry

### On Feature Removed or Deprecated
- Set feature status to "deprecated" or remove entry
- Remove connections that no longer exist
- Do NOT remove iteration history (keep the audit trail)

### On Service Added (architecture change)
- Add new service entry with all endpoints
- Add connections to/from existing services
- Update features that use the new service

### On Service Removed
- Set service status to "retired"
- Remove from active connections
- Update features to remove this service from `services_involved`

### On Health Check (`product-maintain.lobster`)
- Update `last_health_check` timestamp
- Update each service's `status` field
- Update each feature's `last_usage_24h`, `error_rate`, `status`
- Update `business_metrics` values
- Update `known_issues` if new bugs found

### On Bug Fix (`bug-fix.lobster`)
- Remove fixed bug from feature's `known_issues`
- Update feature status if it was degraded due to the bug
- Add iteration history entry (type: "bugfix")
- Bump patch version

### On CEO Query
- Pull fresh data from all service endpoints BEFORE responding
- Update registry with fresh data
- Then format and respond
