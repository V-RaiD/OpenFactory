---
name: "observability"
description: "Ensure products implement the health contract — health APIs, structured logging, metrics, alerting"
version: "2.0.0"
category: "platform"
min_level: "L4"
models:
  preferred_order:
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Most reliable at implementing health endpoints and structured logging across any language"
    - id: "openai/gpt-5.4"
      reason: "Strong at generating correct API endpoint implementations"
    - id: "deepseek/deepseek-v3"
      reason: "Capable at generating health check and logging boilerplate"
triggers: ["add observability", "add health endpoint", "add logging", "add metrics", "product contract"]
input_artifacts: ["system_design", "prd"]
output_artifacts: ["code_artifact"]
allowed_commands: ["npm install", "pip install", "go get", "cargo add", "cat", "ls", "rg"]
blocked_commands: ["rm -rf", "sudo"]
max_iterations: 2
token_budget: 60000
metadata:
  openclaw:
    requires:
      bins: ["git"]
---

# Skill: Product Observability Contract

## Purpose

Every product built by the factory must implement the **Product Health Contract** defined in `docs/PLATFORM-STANDARDS.md`. This skill ensures those endpoints and practices exist in the product's codebase.

**This skill mandates WHAT the product exposes, not HOW it's built internally.** The technology choices (Grafana vs Datadog, Prometheus vs CloudWatch, pino vs winston) are made during the architecture phase by the CTO/Tech Lead.

## Mandatory Deliverables

The deployment skill will **reject** any product missing these:

1. `GET /health` — liveness check (200 = alive)
2. `GET /health/ready` — readiness check (200 = all deps connected)
3. `GET /status` — full status report (JSON, per the contract schema)
4. **Structured logging** — JSON format with timestamp, level, message, service, attributes
5. **Feature-level metrics** — per-feature usage count and error rate, exposed in `/status`
6. **Business metrics** — PRD success metrics, exposed in `/status`
7. **P0 alerting** — the product can send critical alerts to the factory's Telegram incident channel
8. **Dashboard URL** — a URL the CEO can open to see the product's own monitoring dashboard

## Instructions

### 1. Read the System Design

Identify:
- What language/framework is being used
- What observability stack the architect chose (if any)
- What deployment target (determines available monitoring options)

### 2. Implement Health Endpoints

Using whatever HTTP framework the product uses, add three endpoints matching the JSON schemas in `docs/PLATFORM-STANDARDS.md`.

The `/status` endpoint must include:
- Product metadata (id, name, version, environment)
- Performance metrics (request rate, error rate, latency percentiles)
- Dependency health (for each external dependency)
- Feature usage (from PRD's feature list)
- Business metrics (from PRD's success metrics)
- Active alerts
- Dashboard URL

### 3. Add Structured Logging

Replace any `console.log` / `print` with the project's chosen structured logger.
- Every log entry: JSON with timestamp, level, message, service name
- Log at API boundaries: request in, response out, errors
- Log business events: signup, purchase, feature use
- Do NOT log sensitive data: passwords, tokens, PII

### 4. Add Feature Tracking

For each feature defined in the PRD:
- Track usage count (how many times used per day)
- Track error count (how many times it failed)
- Expose in `/status` response under `features`

How this is tracked internally (OTel counter, database increment, analytics event) is the product's choice.

### 5. Add P0 Alert Channel

The product must be able to send critical alerts. Implementation options (architect chooses):
- Telegram bot message to the factory's incident channel
- Webhook to the factory's API
- Email alert to CEO
- All of the above

### 6. Add Dashboard URL

The product must have a monitoring dashboard somewhere. Options:
- Self-hosted Grafana (if on rack)
- Vercel Analytics (if on Vercel)
- CloudWatch dashboard (if on AWS)
- Datadog / New Relic (if using SaaS)
- Even a simple `/admin/status` HTML page counts

Store the URL in the product's config. Expose it in the `/status` response.

## What This Skill Does NOT Do

- Does NOT choose the monitoring technology (that's the architect's job)
- Does NOT install Grafana/Prometheus/Datadog (that's the product's concern)
- Does NOT share infrastructure between factory and product
- Does NOT require the product and factory to be on the same network
