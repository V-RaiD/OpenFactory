name: product-maintain
description: |
  Pull-based product maintenance. Reads the product registry to discover
  all services, features, and health endpoints. Walks the service map
  to assess health at every level.

  Triggered by:
    - Scheduled (every 15 min for health, daily for full audit)
    - CEO on-demand ("how's FreelanceTracker?")
    - P0 push from product's incident channel

args:
  product_id:
    description: "ID of the product to check"
    required: true
  check_type:
    description: "health | full_audit | ceo_query | incident_response"
    default: "health"

steps:
  # ── Step 1: Read Product Registry ──────────────────────
  - id: read-registry
    description: "Load the product's full service map, features, and endpoints from registry"
    run: |
      openclaw.invoke --tool llm-task --action json --args-json '{
        "prompt": "Read workspaces/orchestrator/product-registry.yaml. Find product ${product_id}. Return the full entry as JSON including: all services with their health/status endpoints, all features with their metrics_source, all connections, business_metrics config, dashboard URLs, and incident_channel."
      }'

  # ── Step 2: Walk the Service Map ───────────────────────
  - id: check-services
    description: "Hit every service health and status endpoint in the service map"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "devops-engineer",
        "message": "Walk the service map for product ${product_id}. From the registry: $read_registry_stdout\n\nFor each service that has a health_endpoint:\n  1. curl the health_endpoint — record alive/dead and response time\n  2. curl the ready_endpoint — record dependency health\n  3. curl the status_endpoint — capture full status JSON\n\nFor services with monitored_via (no own endpoint):\n  Read the parent services status response and find this services health in the dependency section.\n\nFor external dependencies with health_check URLs:\n  curl the health_check URL — record available/degraded/down.\n\nOutput a structured JSON report with status per service."
      }'

  # ── Step 3: Assess Features ────────────────────────────
  - id: check-features
    description: "For each feature, read its metrics from the appropriate service status"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "product-manager",
        "message": "Assess every feature in product ${product_id}.\n\nRegistry data: $read_registry_stdout\nService health data: $check_services_stdout\n\nFor each feature in the registry:\n  1. Find its metrics_source (which service, which path in /status)\n  2. Extract: usage count, error rate from the service status data\n  3. Compare against previous check (from registry last_usage_24h and error_rate)\n  4. Classify: healthy (error_rate < 1%), degraded (1-10%), unhealthy (> 10%)\n  5. Flag features with declining usage (> 20% drop) or rising error rates\n\nAlso assess business_metrics from the source service status:\n  Compare against PRD targets if available.\n\nOutput structured JSON: per-feature health + business metrics assessment."
      }'

  # ── Step 4: Compile Overall Assessment ─────────────────
  - id: compile
    description: "Merge service health + feature health into an overall product assessment"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "product-manager",
        "message": "Compile overall health assessment for product ${product_id}.\n\nService data: $check_services_stdout\nFeature data: $check_features_stdout\n\nDetermine:\n  1. Overall product status: healthy / degraded / critical / down\n  2. List of issues by severity (P0/P1/P2/P3)\n  3. Services that are down or degraded\n  4. Features that are unhealthy or degraded\n  5. Business metrics that are below target\n  6. Recommended actions\n\nOutput structured JSON with: overall_status, issues[], service_summary[], feature_summary[], business_summary, recommendations[]"
      }'

  # ── Step 5: Update Registry ────────────────────────────
  - id: update-registry
    description: "Write fresh health data back into the product registry"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "orchestrator",
        "message": "Update the product registry for ${product_id} with latest health check results.\n\nUpdate these fields:\n  - last_health_check: now\n  - Each service status field\n  - Each feature last_usage_24h, error_rate, status\n  - business_metrics values\n  - Add any new known_issues found\n  - Remove known_issues that are no longer present\n\nData: $compile_stdout\n\nWrite the updated registry back to workspaces/orchestrator/product-registry.yaml"
      }'

  # ── Step 6: Route Based on Findings ────────────────────
  - id: check-critical
    description: "Are there P0/P1 issues?"
    run: echo "$compile_stdout" | jq -e '(.issues | map(select(.severity == "p0" or .severity == "p1")) | length) > 0'

  # Critical path: alert CEO immediately
  - id: alert-ceo-critical
    description: "Alert CEO of critical issue via Telegram"
    condition: $check-critical.exitCode == 0
    approval: |
      PRODUCT ALERT: ${product_id}

      Critical issues detected during health check.
      See assessment for details.

      Trigger immediate fix?

  - id: trigger-bugfix
    description: "Launch bug-fix pipeline for critical issues"
    condition: $alert-ceo-critical.approved == true
    lobster: ./bug-fix.lobster
    args:
      bug_report: "$compile_stdout"

  # ── Step 7: Full Audit (daily, deeper analysis) ────────
  - id: full-audit
    description: "Dependency audit, security check, performance trends"
    condition: ${check_type} == "full_audit"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "tech-lead",
        "message": "Deep audit of product ${product_id}.\n\nCurrent status: $compile_stdout\nService map: $read_registry_stdout\n\nAnalyze:\n  1. Any services consistently degraded over last 7 days?\n  2. Any features with steadily declining usage?\n  3. Any connections that are bottlenecks (high latency between services)?\n  4. Is the architecture still right for the current scale?\n  5. Any external dependencies at risk (deprecated APIs, EOL services)?\n\nRecommendations for CEO."
      }'

  - id: send-audit-report
    condition: ${check_type} == "full_audit"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "orchestrator",
        "message": "Send full audit summary to CEO via Telegram:\nProduct: ${product_id}\n$full_audit_stdout"
      }'

  # ── Step 8: CEO On-Demand Response ─────────────────────
  - id: ceo-response
    condition: ${check_type} == "ceo_query"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "orchestrator",
        "message": "CEO asked about product ${product_id}. Format a concise Telegram response.\n\nProduct status: $compile_stdout\nDashboard URLs from registry: $read_registry_stdout\n\nFormat:\n  Product name — overall status emoji\n  Per-service: name — status emoji\n  Top features: name — usage — status\n  Business: DAU, MRR, retention\n  Active issues count by severity\n  Dashboard link\n\nKeep under 500 chars. Use emoji for status (green/yellow/red circle)."
      }'
