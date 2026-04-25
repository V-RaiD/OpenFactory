# Platform Standards — The Contract Between Factory and Products

The factory builds products and then maintains them. But products are **independent systems** — they deploy anywhere, use any tech stack, and own their own observability. The factory and the product may not even be on the same network.

This document defines the **contract** — the minimum set of APIs, endpoints, and practices that every product MUST implement so the factory can monitor, maintain, and evolve it.

**Key principle: The factory mandates WHAT, not HOW.** Products must expose a health API — whether they build it with Express, Flask, or Go's net/http is their choice. Products must have logging — whether they use Datadog, Grafana, or CloudWatch is their choice.

---

## The Product Health Contract

Every product MUST expose these HTTP endpoints. The factory polls them to assess product health.

### 1. `GET /health` — Liveness

Is the process alive and responding?

```json
{
  "status": "ok",
  "version": "1.2.0",
  "uptime_seconds": 86400
}
```

- Returns `200` if alive, any other status = down
- Must respond within 5 seconds
- No authentication required (but rate-limit it)

### 2. `GET /health/ready` — Readiness

Is the product fully operational? Are all dependencies connected?

```json
{
  "status": "ready",
  "checks": {
    "database": { "status": "ok", "latency_ms": 12 },
    "cache": { "status": "ok", "latency_ms": 2 },
    "payment_provider": { "status": "ok", "latency_ms": 145 },
    "email_service": { "status": "degraded", "error": "timeout on last check" }
  }
}
```

- Returns `200` if all critical checks pass
- Returns `503` if any critical dependency is down
- Each check reports status + latency or error

### 3. `GET /status` — Product Status Dashboard (for factory consumption)

Comprehensive status report that the factory reads during scheduled pulls and on-demand CEO queries.

```json
{
  "product": {
    "id": "freelance-tracker",
    "name": "FreelanceTracker",
    "version": "1.2.0",
    "environment": "production",
    "deployed_at": "2026-04-18T16:30:00Z"
  },
  "health": {
    "status": "healthy",
    "uptime_percent_30d": 99.8,
    "incidents_last_30d": 1
  },
  "performance": {
    "request_rate_rpm": 450,
    "error_rate_percent": 0.02,
    "latency_p50_ms": 45,
    "latency_p95_ms": 180,
    "latency_p99_ms": 320
  },
  "dependencies": {
    "total": 4,
    "healthy": 3,
    "degraded": 1,
    "down": 0,
    "details": {
      "database": "healthy",
      "cache": "healthy",
      "payment_provider": "healthy",
      "email_service": "degraded"
    }
  },
  "features": {
    "time_tracking": { "usage_24h": 340, "error_rate": 0.001 },
    "invoice_create": { "usage_24h": 89, "error_rate": 0.0 },
    "stripe_billing": { "usage_24h": 12, "error_rate": 0.02 }
  },
  "business_metrics": {
    "dau": 120,
    "wau": 340,
    "signups_7d": 45,
    "activation_rate": 0.71,
    "mrr_cents": 123000
  },
  "alerts": {
    "active": [
      {
        "severity": "p2",
        "message": "Email service response time > 2s",
        "since": "2026-04-18T14:00:00Z"
      }
    ]
  },
  "dashboard_url": "https://grafana.freelancetracker.com/d/overview",
  "logs_url": "https://logs.freelancetracker.com",
  "repo_url": "https://github.com/company/freelance-tracker"
}
```

- This is the richest endpoint — the factory uses it for health reports, CEO queries, and maintenance decisions
- The `features` section maps to PRD success metrics
- The `dashboard_url` lets the CEO click through to the product's own observability dashboard
- The `alerts` section lets the factory see current problems without accessing the product's monitoring system

### 4. `POST /incidents` — Receive Incident Reports (optional, for factory-initiated fixes)

When the factory detects an issue and wants to notify the product (or when the factory's bug-fix pipeline wants to report a fix):

```json
{
  "incident_id": "INC-20260418-001",
  "severity": "p1",
  "title": "Email service degraded",
  "description": "Factory detected email_service dependency reporting degraded status for >30 min",
  "action_taken": "Bug filed, assigned to engineering",
  "factory_contact": "telegram:@factory_ceo_bot"
}
```

---

## How the Factory Monitors Products

### Scheduled Pull (default: every 15 minutes, configurable per product)

```
Every 15 min:
  Factory orchestrator → for each product in registry:
    1. GET {product_url}/health       → alive? yes/no
    2. GET {product_url}/health/ready  → deps healthy?
    3. GET {product_url}/status        → full status report
    4. Store results in product registry
    5. Compare against previous check:
       - New alert appeared? → classify severity
       - Error rate spiked? → classify severity
       - Dependency went down? → classify severity
    6. If P0 detected → immediate Telegram alert to CEO
    7. If P1 detected → queue for next maintenance cycle
    8. If P2/P3 detected → add to backlog
```

### Push for P0/P1 Emergencies (real-time)

Products can push critical incidents to the factory via:

**Option A: Dedicated Telegram Channel**
- Create a Telegram group: "Factory Incidents"
- Add the factory bot and a webhook from the product's alerting system
- Product fires alert → Telegram message → factory bot picks it up → triggers bug-fix.lobster

**Option B: Webhook to Factory API**
- Factory exposes `POST /api/incidents` on its gateway
- Product's alerting system (PagerDuty, Grafana alerts, custom) calls this webhook
- Factory receives, triages, notifies CEO

**Option C: Product sends Telegram message directly**
- Product includes a Telegram notification in its alerting pipeline
- Factory bot monitors for messages tagged with product ID
- Simplest — no extra infrastructure

**Recommendation: Option C** (simplest, works across any network, Telegram is already the communication backbone)

### CEO On-Demand

```
CEO (Telegram): "How's FreelanceTracker doing?"

Factory orchestrator:
  1. Reads product registry → finds FreelanceTracker
  2. GET https://freelancetracker.com/status → gets fresh data
  3. Compares against historical baseline
  4. Formats concise report for Telegram:

     "FREELANCETRACKER — Healthy ✓
      Uptime: 99.8% (30d)
      p99 latency: 320ms
      DAU: 120 | Signups this week: 45
      1 active alert: email service slow (P2)
      MRR: $1,230 (+$260 this month)
      [Open Dashboard →]"
```

---

## What the Factory Mandates vs. What Products Decide

| Aspect | Factory Mandates (the contract) | Product Decides (the implementation) |
|---|---|---|
| **Health API** | Must have `/health`, `/health/ready`, `/status` | Framework, language, how checks work internally |
| **Logging** | Must be structured (JSON with timestamp, level, message) | Logging library (pino, structlog, zap, winston), storage (Datadog, Loki, CloudWatch, ELK) |
| **Metrics** | Must track: request rate, error rate, latency, feature usage | Metrics system (Prometheus, Datadog, New Relic, custom), dashboards |
| **Tracing** | Should have distributed tracing (recommended, not mandatory) | Tracing system (Jaeger, Tempo, Datadog APM, X-Ray) |
| **Alerting** | Must have P0 alerting that can notify the factory | Alerting tool (PagerDuty, Grafana alerts, OpsGenie), notification method |
| **Dashboard** | Must provide a `dashboard_url` the CEO can open | Dashboard tool (Grafana, Datadog, custom) |
| **Feature metrics** | Must track per-feature usage and error rate (defined in PRD) | How they're tracked and stored |
| **Business metrics** | Must track PRD success metrics (activation, retention, revenue) | Analytics tool (Mixpanel, Amplitude, PostHog, custom) |
| **Incident channel** | Must be able to send P0/P1 alerts to factory's Telegram | How the product detects incidents internally |

---

## Product Observability Decision Tree (for Architecture Phase)

During the system design phase, the CTO/Tech Lead decides the product's observability stack:

```
Is the product deployed to the factory's local rack?
  │
  ├── YES → Suggest self-hosted stack:
  │         Grafana + Prometheus + Loki (all free, open source)
  │         Runs alongside the product on the rack
  │
  └── NO → Where is it deployed?
           │
           ├── Vercel/Railway/Fly → Use their built-in metrics
           │   + Add PostHog or Mixpanel for business metrics (free tier)
           │   + Add Sentry for error tracking (free tier)
           │
           ├── AWS → CloudWatch + X-Ray (included)
           │   or self-hosted Grafana on ECS
           │
           └── Client's infrastructure → Discuss with client
               Minimum: health endpoints + structured logging

In ALL cases: the /health, /health/ready, and /status endpoints are mandatory.
```

---

## Customer Success Methodology

Every product tracks a standard customer success framework. The PM defines the specifics during PRD writing, but the structure is standard:

| Metric | What | Defined In | Exposed In |
|---|---|---|---|
| **Activation** | User got first value | PRD: "activation event" field | `/status` → `business_metrics.activation_rate` |
| **Engagement** | User keeps coming back | PRD: "engagement signals" field | `/status` → `business_metrics.dau`, `wau` |
| **Retention** | User stays over time | PRD: "retention targets" field | `/status` → reportable, or product's analytics dashboard |
| **Revenue** | User is paying | PRD: "revenue model" field | `/status` → `business_metrics.mrr_cents` |
| **Satisfaction** | User is happy | PRD: "feedback mechanism" field | In-app surveys, NPS, support tickets |

The factory reads these from `/status` during scheduled pulls. The weekly customer success report is compiled by the product-lifecycle skill and sent to CEO via Telegram.

If a metric is trending badly (retention dropping, error rate rising on a feature), the factory:
1. Flags it to CEO in the weekly report
2. Suggests action: "Retention dropped 8% — investigate onboarding flow?"
3. If CEO approves → triggers `product-iteration.lobster` to fix it
