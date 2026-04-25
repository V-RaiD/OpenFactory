---
name: "monitoring"
description: "Configure observability stack — metrics, logging, alerting, and dashboards"
version: "1.0.0"
category: "devops"
min_level: "L4"
models:
  preferred_order:
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Reliable config generation for Prometheus, Grafana, and alert rules"
    - id: "openai/gpt-4o"
      reason: "Good at generating PromQL queries and Grafana dashboard JSON"
    - id: "deepseek/deepseek-v3"
      reason: "Competent at standard monitoring configurations"
triggers: ["setup monitoring", "observability", "alerting", "metrics", "dashboard"]
input_artifacts: ["system_design", "deployment_config"]
output_artifacts: ["monitoring_config"]
allowed_commands: ["cat", "ls", "rg", "curl -s"]
blocked_commands: ["rm", "sudo", "kubectl delete"]
max_iterations: 2
token_budget: 60000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Monitoring

## Instructions

1. **Identify key metrics** from the system design — request latency, error rate, throughput, saturation
2. **Apply the RED method** for services (Rate, Errors, Duration) and USE method for resources (Utilization, Saturation, Errors)
3. **Generate Prometheus scrape configs and alerting rules**
4. **Generate Grafana dashboard definitions** for the key metrics
5. **Define PagerDuty/Slack/Telegram alert routing** — P0 alerts go to CEO via Telegram

## Output Format

```yaml
artifact_type: monitoring_config
files:
  - path: "monitoring/prometheus/rules.yml"
    content: |
      # alert rules
  - path: "monitoring/grafana/dashboards/overview.json"
    content: |
      # dashboard JSON
  - path: "monitoring/alertmanager/config.yml"
    content: |
      # alert routing
sla_targets:
  availability: "99.9%"
  p99_latency_ms: 500
  error_rate: "< 0.1%"
alert_channels:
  p0_critical: "telegram_ceo"
  p1_high: "telegram_team"
  p2_medium: "email"
```
