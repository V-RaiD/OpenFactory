---
name: "product-lifecycle"
description: "Manage a launched product — monitor health, triage issues, plan iterations, maintain dependencies"
version: "1.0.0"
category: "management"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best at strategic product decisions — triage, prioritization, roadmap planning"
    - id: "openai/gpt-5.4"
      reason: "Strong product sense for feature planning and issue assessment"
    - id: "deepseek/deepseek-r1"
      reason: "Reasoning model for systematic issue triage and dependency analysis"
triggers: ["product health", "maintain product", "update product", "product status", "what needs attention"]
input_artifacts: ["product_registry_entry", "monitoring_alerts", "customer_feedback", "dependency_audit"]
output_artifacts: ["product_health_report", "iteration_plan"]
allowed_commands: ["cat", "ls", "rg", "git log", "git status", "npm outdated", "pip list --outdated"]
blocked_commands: ["rm -rf", "sudo", "git push --force"]
max_iterations: 2
token_budget: 100000
metadata:
  openclaw:
    requires:
      bins: ["git"]
---

# Skill: Product Lifecycle Management

## Context

After a product launches (Phase 6 of idea-to-launch), it enters the **lifecycle phase**. The factory doesn't abandon products — it maintains them. This skill manages the ongoing health and evolution of deployed products.

## What This Skill Does

1. **Health Monitoring** — Check if deployed products are running, responding, and performing within SLA
2. **Issue Triage** — When bugs or problems are reported, classify severity and route to the right agent
3. **Feature Planning** — When the CEO wants to add features, create an iteration plan that feeds back into the factory pipeline
4. **Dependency Maintenance** — Track outdated packages, security vulnerabilities, and breaking changes
5. **Cost Tracking** — Monitor infrastructure costs for deployed products

## Instructions

### Health Check
```yaml
health_check:
  - endpoint: "{product_url}/health"
    expected_status: 200
    timeout_ms: 5000
  - database: "check connectivity and query latency"
  - error_rate: "check logs for error rate over last 24h"
  - performance: "check p50/p95/p99 latency"
  - disk: "check storage usage trends"
```

### Issue Triage
When an issue is reported (by CEO, monitoring alert, or user feedback):

1. **Classify severity:**
   - **P0 Critical:** Product down, data loss, security breach → trigger bug-fix.lobster immediately
   - **P1 High:** Major feature broken, >10% users affected → schedule fix within 24h
   - **P2 Medium:** Minor feature broken, workaround exists → add to next sprint
   - **P3 Low:** Cosmetic, enhancement request → add to backlog

2. **Route to correct pipeline:**
   - P0/P1 → `bug-fix.lobster` (immediate)
   - P2 → backlog for next `feature-development.lobster` batch
   - P3 → backlog, prioritize with RICE scoring
   - Feature request → `product-iteration.lobster`

### Feature Iteration
When CEO says "add X to the product":

1. Check if the existing architecture supports it
2. If yes → create task breakdown, route to `feature-development.lobster`
3. If no → propose architecture changes, route to design review (Gate 3 equivalent)
4. Either way → CEO approves the iteration plan before work starts

### Dependency Audit
Run periodically (or on-demand):
1. Check for outdated packages (`npm outdated`, `pip list --outdated`)
2. Check for security vulnerabilities (`npm audit`, `pip-audit`)
3. Classify updates: patch (auto-apply) / minor (review) / major (plan migration)
4. For critical CVEs → trigger immediate update via `bug-fix.lobster`

## Output Format

```yaml
artifact_type: product_health_report
product_id: "{product ID}"
timestamp: "ISO-8601"
status: "healthy|degraded|down"
health:
  uptime: "99.8% over 30 days"
  latency_p99: "320ms"
  error_rate: "0.02%"
  disk_usage: "45%"
open_issues:
  p0: 0
  p1: 1
  p2: 3
  p3: 7
dependency_status:
  outdated_packages: 5
  security_vulnerabilities: 1
  critical_cves: 0
infrastructure_cost:
  monthly: "$12.50"
  trend: "stable"
recommendations:
  - type: "security"
    urgency: "high"
    action: "Update lodash from 4.17.20 to 4.17.21 (CVE-2021-23337)"
  - type: "feature"
    urgency: "low"
    action: "3 feature requests from CEO in backlog — schedule iteration?"
next_actions:
  - "Fix P1 bug: invoice PDF generation fails for > 10 line items"
  - "Run dependency update for 5 outdated packages"
  - "Schedule iteration planning for 3 backlog features"
```
