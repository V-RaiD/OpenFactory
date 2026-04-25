# bug-fix.lobster
# Quick bug-fix pipeline. Can be triggered independently for any reported bug.
# Includes triage, reproduction, fix, verification, review, and deployment.
# CEO approval gate only for P0/P1 severity bugs.

args:
  bug_report:
    type: string
    required: true
    description: "Description of the bug including steps to reproduce if available"
  reported_by:
    type: string
    required: false
    default: "user"
    description: "Who reported the bug (user, QA, monitoring, etc.)"
  source_url:
    type: string
    required: false
    default: ""
    description: "URL to the bug report, issue, or error log"

steps:

  - id: triage
    name: "Triage Bug"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "tech-lead",
        "prompt": "Triage this bug report. Determine severity (P0-critical/P1-high/P2-medium/P3-low), category (crash, data-loss, functional, UI, performance, security), affected component, estimated fix complexity (trivial/small/medium/large), and assign to the most appropriate developer agent.\n\nBug report: {{args.bug_report}}\nReported by: {{args.reported_by}}\nSource: {{args.source_url}}\n\nReturn JSON: {\"severity\": \"P0|P1|P2|P3\", \"category\": \"...\", \"component\": \"...\", \"complexity\": \"trivial|small|medium|large\", \"assignee_agent\": \"...\", \"summary\": \"...\", \"requires_hotfix\": true/false}",
        "model": "anthropic/claude-sonnet"
      }'

  - id: p0-p1-alert
    name: "Alert on Critical Bugs"
    condition: "$triage.json.severity == 'P0' || $triage.json.severity == 'P1'"
    approval: "URGENT: $triage.json.severity bug detected.\n\nSummary: $triage.json.summary\nCategory: $triage.json.category\nComponent: $triage.json.component\nRequires hotfix: $triage.json.requires_hotfix\n\nProceed with immediate fix?"

  - id: reproduce
    name: "Reproduce & Document Bug"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "qa-engineer",
        "prompt": "Reproduce the following bug and document detailed reproduction steps. Capture: exact steps to reproduce, expected behavior, actual behavior, environment details, screenshots/logs if available, and frequency (always, intermittent, rare).\n\nBug report: {{args.bug_report}}\nTriage: $triage.json\n\nReturn JSON: {\"reproducible\": true/false, \"reproduction_steps\": [...], \"expected\": \"...\", \"actual\": \"...\", \"environment\": \"...\", \"frequency\": \"always|intermittent|rare\", \"root_cause_hypothesis\": \"...\"}",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 600

  - id: fix-loop
    name: "Fix & Verify Loop"
    loop:
      maxIterations: 3
      condition: "$verify.json.fixed != true"
    steps:

      - id: fix
        name: "Implement Fix"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "$triage.json.assignee_agent",
            "message": "Fix this bug. Create a branch named bugfix/$triage.json.severity-{{args.bug_report | slugify}}.\n\nBug summary: $triage.json.summary\nReproduction: $reproduce.json\nRoot cause hypothesis: $reproduce.json.root_cause_hypothesis\n\nRequirements:\n1. Fix the root cause, not just the symptom\n2. Add a regression test that would have caught this bug\n3. Ensure no other functionality is broken\n4. Document what caused the bug in code comments\n\nIf this is a retry, the previous fix did not pass verification:\n$verify.json.failure_details"
          }'
        timeout: 600

      - id: verify
        name: "Verify Fix"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "qa-engineer",
            "message": "Verify the bug fix. Run the reproduction steps from $reproduce.json and confirm the bug is resolved. Also run the regression test suite to ensure nothing else broke.\n\nReturn JSON: {\"fixed\": true/false, \"reproduction_result\": \"pass|fail\", \"regression_tests\": {\"passed\": N, \"failed\": N}, \"failure_details\": \"...\"}"
          }'

  - id: fix-escalation
    name: "Escalate if Fix Fails"
    condition: "$fix-loop.iterations >= 3 && $verify.json.fixed != true"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "tech-lead",
        "message": "Bug fix has failed verification 3 times. Escalating. Review the bug, attempted fixes, and verification results. Determine if we need to: (1) reassign to a more senior developer, (2) pair-program on the fix, (3) revert recent changes that may have caused this, or (4) implement a temporary workaround while a proper fix is developed.\n\nBug: $triage.json\nReproduction: $reproduce.json\nLast verification: $verify.json"
      }'

  - id: review
    name: "Code Review"
    condition: "$verify.json.fixed == true"
    lobster: code-review-loop.lobster
    args:
      code_ref: "bugfix/$triage.json.severity"
      reviewer_agent: "tech-lead"
      developer_agent: "$triage.json.assignee_agent"
      review_context: "Bug fix for $triage.json.severity issue: $triage.json.summary"

  - id: deploy
    name: "Deploy Fix"
    condition: "$verify.json.fixed == true"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "devops-engineer",
        "prompt": "Deploy the bug fix to production. Use hotfix deployment process if severity is P0/P1, otherwise standard deployment.\n\nSeverity: $triage.json.severity\nRequires hotfix: $triage.json.requires_hotfix\nBranch: bugfix/$triage.json.severity\n\nReturn JSON: {\"deploy_status\": \"success|failed\", \"deployment_type\": \"hotfix|standard\", \"rollback_available\": true/false}",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 600

  - id: deploy-verify
    name: "Post-Deploy Verification"
    condition: "$deploy.json.deploy_status == 'success'"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "qa-engineer",
        "message": "Verify the bug fix in production. Run the reproduction steps against the production environment and confirm the fix is live and working. Monitor error rates for 10 minutes after deployment."
      }'

  - id: close-report
    name: "Generate Fix Report"
    command: >
      openclaw.invoke --tool llm-task --action json --args-json '{
        "prompt": "Generate a bug fix report:\n- Bug: $triage.json.summary\n- Severity: $triage.json.severity\n- Root cause: $reproduce.json.root_cause_hypothesis\n- Fix iterations needed: $fix-loop.iterations\n- Deployment status: $deploy.json.deploy_status\n- Production verification: $deploy-verify.stdout\n\nReturn JSON with the full report for logging."
      }'
