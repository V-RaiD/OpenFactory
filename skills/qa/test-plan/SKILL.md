---
name: "test-plan"
description: "Create comprehensive test plans with test cases, coverage matrices, and risk-based prioritization"
version: "1.0.0"
category: "qa"
min_level: "L4"
models:
  preferred_order:
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Excellent structured planning output, thorough edge case identification"
    - id: "openai/gpt-5.4"
      reason: "Strong test scenario generation with good requirements traceability"
    - id: "meta/llama-4-maverick-400b"
      reason: "Capable reasoning for comprehensive test matrix generation"
triggers: ["create test plan", "QA plan", "testing strategy", "test matrix"]
input_artifacts: ["prd", "system_design", "code_artifact"]
output_artifacts: ["test_plan"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "git push", "sudo"]
max_iterations: 2
token_budget: 80000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Test Plan

## Instructions

1. **Map requirements to test cases** — every functional requirement in the PRD must have at least one test case
2. **Categorize tests:**
   - Unit tests (per function/method)
   - Integration tests (component interactions)
   - E2E tests (critical user flows)
   - Performance tests (load, stress, endurance)
   - Security tests (auth bypass, injection, data exposure)
3. **Prioritize by risk** — high-impact, high-probability failures get tested first
4. **Define test environments** — what infrastructure is needed
5. **Set exit criteria** — what must pass before QA sign-off

## Output Format

```yaml
artifact_type: test_plan
prd_id: "{referenced PRD ID}"
test_cases:
  - id: "TC-001"
    category: "unit|integration|e2e|performance|security"
    requirement_id: "REQ-001"
    title: "User login with valid credentials"
    preconditions: "User exists in database"
    steps: ["Navigate to login", "Enter valid email/password", "Click submit"]
    expected_result: "Redirect to dashboard, session token set"
    priority: "P0|P1|P2"
coverage_matrix:
  - requirement: "REQ-001"
    test_cases: ["TC-001", "TC-002", "TC-003"]
    coverage: "full"
risk_areas:
  - area: "Authentication"
    risk_level: "high"
    test_density: "high"
environments_needed: ["local", "staging"]
exit_criteria:
  - "All P0 test cases pass"
  - "Code coverage > 80%"
  - "No critical or high severity bugs open"
  - "Performance: p99 latency < 500ms under 100 concurrent users"
```
