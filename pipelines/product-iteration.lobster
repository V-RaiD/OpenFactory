name: product-iteration
description: |
  Add features or improvements to an existing, deployed product.
  Triggered by CEO ("add X to product Y") or by the product-lifecycle skill.
  Reuses the factory pipeline from Phase 3 onward, but scoped to the existing codebase.

args:
  product_id:
    description: "ID of the product in the product registry"
    required: true
  request:
    description: "What the CEO wants — feature request, improvement, change"
    required: true
  request_type:
    description: "feature | improvement | refactor | dependency_update | bug_batch"
    default: "feature"

steps:
  # ── Assess Impact ──────────────────────────────────────
  - id: assess-impact
    description: "CTO evaluates: does this fit the existing architecture or need redesign?"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "cto",
        "message": "Assess impact of this change on product ${product_id}: ${request}\n\nDoes the current architecture support this? Output JSON: {fits_architecture: bool, changes_needed: string, effort_estimate: string, risk_level: string}"
      }'

  # ── Branch: Architecture Change Needed? ────────────────
  - id: check-architecture-fit
    run: echo "$assess_impact_stdout" | jq -e '.fits_architecture'
    condition: true  # always run, exit code determines branch

  # ── Path A: Fits Architecture → Quick Iteration ────────
  - id: task-breakdown
    description: "Tech Lead breaks the feature into tasks against existing codebase"
    condition: $check-architecture-fit.exitCode == 0
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "tech-lead",
        "message": "Break this feature request into implementable tasks for product ${product_id}: ${request}\n\nExisting architecture is sufficient. Output task breakdown YAML."
      }'

  - id: resource-plan
    description: "Tech Lead decides agent allocation"
    condition: $check-architecture-fit.exitCode == 0
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "tech-lead",
        "message": "Create resource allocation plan for these tasks on product ${product_id}:\n$task_breakdown_stdout"
      }'

  - id: ceo-approve-iteration
    description: "CEO approves the iteration plan"
    condition: $check-architecture-fit.exitCode == 0
    approval: |
      ITERATION PLAN for product ${product_id}
      Request: ${request}
      Tasks: See task breakdown
      Estimated cost: See resource plan
      Approve to start implementation?

  # ── Path B: Needs Architecture Change → Design Review ──
  - id: design-revision
    description: "CTO proposes architecture changes"
    condition: $check-architecture-fit.exitCode != 0
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "cto",
        "message": "Propose architecture changes for product ${product_id} to support: ${request}\n\nOutput: revised system design diff, migration plan, risk assessment."
      }'

  - id: ceo-approve-redesign
    description: "CEO reviews architecture changes (Live Meeting recommended)"
    condition: $check-architecture-fit.exitCode != 0
    approval: |
      ARCHITECTURE CHANGE REQUIRED for product ${product_id}
      Request: ${request}
      Changes needed: See design revision
      This is a significant change — consider joining a Live Meeting to discuss.
      Approve to proceed?

  # ── Implementation (both paths converge) ───────────────
  - id: implement
    description: "Run feature-development pipeline for each task"
    lobster: ./feature-development.lobster
    args:
      task_id: "from-task-breakdown"
      task_description: "${request}"
      architecture_context: "existing product ${product_id}"
      assignee_agent: "from-resource-plan"
    loop:
      maxIterations: 5
      condition: '! echo "$LOBSTER_LOOP_JSON" | jq -e ".approved"'

  # ── Test Full Product (regression) ─────────────────────
  - id: regression-test
    description: "QA runs full regression suite — new feature must not break existing ones"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "qa-engineer",
        "message": "Run full regression test suite for product ${product_id}. Verify: 1) new feature works, 2) existing features still work, 3) no performance regression."
      }'

  - id: ceo-approve-deploy
    approval: |
      ITERATION COMPLETE for product ${product_id}
      Feature: ${request}
      Tests: See regression report
      Ready to deploy update?

  # ── Deploy Update ──────────────────────────────────────
  - id: deploy-update
    description: "DevOps deploys the updated product"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "devops-engineer",
        "message": "Deploy update for product ${product_id}. Strategy: rolling update with rollback plan."
      }'

  - id: verify-deployment
    description: "Verify the deployment is healthy"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "devops-engineer",
        "message": "Verify deployment of product ${product_id}. Check: health endpoint, smoke tests, error rate, latency."
      }'

  # ── Update GTM if Needed ───────────────────────────────
  - id: check-gtm-update
    description: "Is this a user-facing feature that needs marketing/sales update?"
    run: |
      openclaw.invoke --tool llm-task --action json --args-json '{
        "prompt": "Is this change user-facing and marketable? ${request}\nOutput: {needs_gtm_update: bool, reason: string}"
      }'

  - id: gtm-update
    description: "Update marketing/sales materials if needed"
    condition: echo "$check_gtm_update_stdout" | jq -e '.needs_gtm_update' 2>/dev/null
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "marketing-lead",
        "message": "Product ${product_id} has a new feature: ${request}. Update: changelog, blog post if significant, email to existing users if impactful."
      }'

  # ── Update Product Registry ─────────────────────────────
  - id: update-registry
    description: "Update product registry with new feature, services, connections, version bump"
    run: |
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "orchestrator",
        "message": "Update the product registry for ${product_id} after this iteration.\n\nWhat changed: ${request}\nRequest type: ${request_type}\n\nDo ALL of the following:\n  1. Bump version (patch for bugfix, minor for feature, major if architecture changed)\n  2. Add iteration history entry with date, type, and changes\n  3. If new feature: add feature entry with id, name, services_involved, metrics_source, prd_requirement_id\n  4. If new service: add service entry with id, type, url, all health endpoints, deployment config\n  5. If new connections between services: add connection entries\n  6. If feature modified: update the feature entry\n  7. If feature removed: set status to deprecated (do not delete — keep audit trail)\n  8. If service removed: set status to retired, remove from active connections\n  9. Update last_updated timestamp\n\nWrite updated registry to workspaces/orchestrator/product-registry.yaml"
      }'

  - id: iteration-complete
    description: "Report completion"
    run: |
      echo "Product iteration complete for ${product_id}."
      echo "Feature: ${request}"
      echo "Status: deployed, verified, registry updated"
