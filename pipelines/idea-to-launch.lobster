# idea-to-launch.lobster
# The main pipeline: takes an idea from conception through launch with 6 CEO approval gates.
# Usage: openclaw run idea-to-launch.lobster --args '{"idea":"..."}'

args:
  idea:
    type: string
    required: true
    description: "The product idea or feature concept to evaluate and build"

steps:

  # ──────────────────────────────────────────────
  # PHASE 1 — Ideation & Validation
  # ──────────────────────────────────────────────

  - id: receive-idea
    name: "Receive & Normalize Idea"
    command: >
      openclaw.invoke --tool llm-task --action json --args-json '{
        "prompt": "You are a product strategist. Take the following raw idea and produce a structured idea brief with: title, one-line summary, target audience hypothesis, and key assumptions to validate.\n\nRaw idea: {{args.idea}}"
      }'

  - id: market-research
    name: "Market Research & User Discovery"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "cpo",
        "prompt": "Conduct user research for this idea. Identify target market size (TAM/SAM/SOM), existing solutions, user pain points, and willingness to pay. Idea brief:\n\n$receive-idea.json",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 600

  - id: opportunity-assessment
    name: "CPO Opportunity Assessment"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "cpo",
        "message": "Based on the market research you just completed, produce an opportunity assessment with: (1) market attractiveness score 1-10, (2) competitive intensity, (3) differentiation potential, (4) estimated effort vs. impact, (5) go/no-go recommendation with reasoning.\n\nMarket research:\n$market-research.stdout"
      }'

  - id: gate-1
    name: "Gate 1 — Pursue Idea?"
    approval: "Gate 1: Pursue this idea?\n\nIdea: $receive-idea.json\n\nMarket Research Summary:\n$market-research.stdout\n\nOpportunity Assessment:\n$opportunity-assessment.stdout"

  # ──────────────────────────────────────────────
  # PHASE 2 — Product Definition
  # ──────────────────────────────────────────────

  - id: write-prd
    name: "Write Product Requirements Document"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "product-manager",
        "prompt": "Write a comprehensive PRD using the standard PRD template. Base it on the approved idea and market research.\n\nIdea brief: $receive-idea.json\nMarket research: $market-research.stdout\nOpportunity assessment: $opportunity-assessment.stdout",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 900

  - id: prd-review-loop
    name: "CPO Reviews PRD"
    loop:
      maxIterations: 3
      condition: "$prd-review.json.approved != true"
    steps:
      - id: prd-review
        name: "CPO Review Pass"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "cpo",
            "message": "Review this PRD for completeness, clarity, and strategic alignment. Return JSON with {\"approved\": true/false, \"feedback\": \"...\"} .\n\nPRD:\n$write-prd.stdout"
          }'

      - id: prd-revise
        name: "PM Revises PRD"
        condition: "$prd-review.json.approved != true"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "product-manager",
            "message": "Revise the PRD based on CPO feedback. Address every point.\n\nFeedback: $prd-review.json.feedback"
          }'

  - id: gate-2
    name: "Gate 2 — Approve PRD?"
    approval: "Gate 2: Approve PRD?\n\nPRD:\n$write-prd.stdout\n\nCPO Review Status: $prd-review.json"

  # ──────────────────────────────────────────────
  # PHASE 3 — Technical Planning
  # ──────────────────────────────────────────────

  - id: system-design
    name: "System Design & Architecture"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "tech-lead",
        "prompt": "Create a system design document using the standard system-design template. Cover architecture, components, data models, API contracts, technology choices, and infrastructure needs.\n\nPRD:\n$write-prd.stdout",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 900

  - id: task-breakdown
    name: "Break Down into Engineering Tasks"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "tech-lead",
        "message": "Break the system design into discrete engineering tasks. For each task provide: task_id, title, description, estimated hours, dependencies (other task_ids), priority (P0/P1/P2), and required skills. Return as a JSON array.\n\nSystem design:\n$system-design.stdout"
      }'

  - id: resource-allocation
    name: "Resource Allocation & Agent Assignment"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "tech-lead",
        "message": "Given these tasks, determine how many developer agents are needed for parallel execution, assign each task to an agent role, and produce an execution schedule with critical path analysis. Return JSON with {\"agents_needed\": N, \"assignments\": [...], \"critical_path\": [...], \"estimated_total_hours\": N, \"estimated_calendar_days\": N}.\n\nTasks:\n$task-breakdown.json"
      }'

  - id: gate-3
    name: "Gate 3 — Approve Architecture & Resources?"
    approval: "Gate 3: Approve architecture & commit resources?\n\nSystem Design:\n$system-design.stdout\n\nTask Breakdown ($task-breakdown.json tasks):\n$task-breakdown.stdout\n\nResource Plan:\n$resource-allocation.stdout"

  # ──────────────────────────────────────────────
  # PHASE 4 — Development & QA
  # ──────────────────────────────────────────────

  - id: implement
    name: "Implement Features"
    loop:
      over: "$task-breakdown.json"
      as: "task"
      parallel: true
    lobster: feature-development.lobster
    args:
      task_id: "$task.task_id"
      task_description: "$task.description"
      architecture_context: "$system-design.stdout"
      assignee_agent: "$resource-allocation.json.assignments[$task.task_id].agent"

  - id: integration-testing
    name: "Integration Testing"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "qa-engineer",
        "prompt": "Run the full integration test suite. Verify all implemented features work together. Test every acceptance criterion from the PRD. Produce a test report with: total tests, passed, failed, skipped, coverage percentage, and a list of any failures with reproduction steps.\n\nPRD: $write-prd.stdout\nTasks completed: $implement.stdout",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 1200

  - id: code-review-final
    name: "Tech Lead Final Code Review"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "tech-lead",
        "message": "Conduct a final holistic code review of the entire implementation. Check for: architectural consistency, security issues, performance concerns, code quality, test coverage gaps, and documentation completeness. Return JSON with {\"approved\": true/false, \"issues\": [...], \"risk_level\": \"low|medium|high\"}.\n\nSystem design: $system-design.stdout\nTest report: $integration-testing.stdout"
      }'

  - id: gate-4
    name: "Gate 4 — QA Sign-off?"
    approval: "Gate 4: QA sign-off?\n\nTest Report:\n$integration-testing.stdout\n\nFinal Code Review:\n$code-review-final.stdout"

  # ──────────────────────────────────────────────
  # PHASE 5 — GTM Preparation
  # ──────────────────────────────────────────────

  - id: gtm-campaign
    name: "Go-to-Market Campaign"
    lobster: gtm-campaign.lobster
    args:
      product_name: "$receive-idea.json.title"
      prd: "$write-prd.stdout"
      market_research: "$market-research.stdout"
      skip_final_approval: true

  - id: staging-deploy
    name: "Deploy to Staging"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "devops-engineer",
        "prompt": "Deploy the application to the staging environment. Run smoke tests, verify health checks, and confirm the staging URL is accessible. Return JSON with {\"staging_url\": \"...\", \"deploy_status\": \"success|failed\", \"smoke_tests_passed\": true/false, \"health_check\": \"ok|degraded|down\"}.",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 600

  - id: staging-validation
    name: "Validate Staging Deployment"
    condition: "$staging-deploy.json.deploy_status == 'success'"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "qa-engineer",
        "message": "Validate the staging deployment. Run a final round of smoke tests on $staging-deploy.json.staging_url and confirm everything is production-ready."
      }'

  - id: gate-5
    name: "Gate 5 — Approve Launch?"
    approval: "Gate 5: Approve launch?\n\nStaging URL: $staging-deploy.json.staging_url\nStaging Validation: $staging-validation.stdout\n\nMarketing Plan:\n$gtm-campaign.stdout\n\nAll materials are ready for production deployment."

  # ──────────────────────────────────────────────
  # PHASE 6 — Launch & Post-Launch
  # ──────────────────────────────────────────────

  - id: production-deploy
    name: "Deploy to Production"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "devops-engineer",
        "prompt": "Deploy to production using blue-green deployment strategy. Enable canary traffic at 10% initially, monitor error rates for 5 minutes, then roll to 100% if healthy. Return JSON with {\"production_url\": \"...\", \"deploy_status\": \"success|rolled-back\", \"canary_metrics\": {...}}.",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 900

  - id: production-deploy-check
    name: "Verify Production Health"
    condition: "$production-deploy.json.deploy_status == 'success'"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "devops-engineer",
        "message": "Confirm production deployment is healthy. Check error rates, latency p50/p95/p99, and all health endpoints. Set up alerting if not already configured."
      }'

  - id: execute-marketing
    name: "Execute Marketing Campaign"
    condition: "$production-deploy.json.deploy_status == 'success'"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "marketing-lead",
        "message": "Product is live at $production-deploy.json.production_url — execute the marketing campaign now. Publish all content, activate email sequences, and launch paid campaigns per the GTM plan.\n\nGTM Plan: $gtm-campaign.stdout"
      }'

  - id: enable-sales
    name: "Enable Sales Outreach"
    condition: "$production-deploy.json.deploy_status == 'success'"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "sales-lead",
        "message": "Product is live. Begin outbound sales motions: activate cold outreach sequences, brief the SDR team with the pitch deck and objection-handling guide, and set up demo scheduling.\n\nPitch deck: $gtm-campaign.stdout"
      }'

  - id: post-launch-report
    name: "Compile Post-Launch Report"
    command: >
      openclaw.invoke --tool llm-task --action json --args-json '{
        "prompt": "Compile a comprehensive post-launch report covering:\n1. What was built (from PRD)\n2. Architecture decisions made\n3. Development metrics (tasks completed, review iterations, test coverage)\n4. Deployment status\n5. GTM execution status\n6. Immediate next steps and monitoring plan\n\nIdea: $receive-idea.json\nPRD: $write-prd.stdout\nSystem Design: $system-design.stdout\nTest Report: $integration-testing.stdout\nDeployment: $production-deploy.json\nGTM: $gtm-campaign.stdout"
      }'

  - id: gate-6
    name: "Gate 6 — Post-Launch Review"
    approval: "Gate 6: Post-launch review — continue or iterate?\n\nPost-Launch Report:\n$post-launch-report.stdout\n\nProduction URL: $production-deploy.json.production_url\nDeploy Status: $production-deploy.json.deploy_status"
