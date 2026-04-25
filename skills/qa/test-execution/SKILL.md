---
name: "test-execution"
description: "Execute test suites, collect results, and produce structured test reports"
version: "1.0.0"
category: "qa"
min_level: "L3"
models:
  preferred_order:
    - id: "anthropic/claude-haiku-4-5"
      reason: "Fast and cheap for test execution orchestration — no deep reasoning needed"
    - id: "openai/gpt-4o-mini"
      reason: "Efficient for parsing test output and generating structured reports"
    - id: "meta/llama-4-scout"
      reason: "Lightweight open-source model sufficient for test runner coordination"
triggers: ["run tests", "execute tests", "test suite", "check tests", "verify"]
input_artifacts: ["code_artifact", "test_plan"]
output_artifacts: ["test_report"]
allowed_commands: ["npm test", "npm run test", "npx jest", "npx vitest", "pytest", "python -m pytest", "go test", "cargo test", "make test", "cat", "ls", "rg"]
blocked_commands: ["rm", "git push", "sudo", "npm publish", "pip install"]
max_iterations: 1
token_budget: 30000
metadata:
  openclaw:
    requires:
      bins: ["git"]
---

# Skill: Test Execution

## Instructions

1. **Identify the test runner** — read package.json, Makefile, or project config to find the test command
2. **Run the full test suite** — capture stdout and stderr
3. **Parse results** — extract pass/fail counts, coverage, failure details
4. **For each failure:** extract test name, error message, expected vs actual, stack trace
5. **Generate structured report**

## Output Format

```yaml
artifact_type: test_report
task_id: "{referenced task ID}"
test_runner: "jest|pytest|go_test|cargo_test"
tests_run: 42
tests_passed: 40
tests_failed: 2
tests_skipped: 0
coverage_percent: 84.2
duration_seconds: 12.5
failures:
  - test_name: "should return 401 for invalid token"
    file: "tests/auth/middleware.test.ts"
    error: "Expected 401 but received 200"
    expected: "401"
    actual: "200"
    stack_trace: "at Object.<anonymous> (tests/auth/middleware.test.ts:42:5)"
    probable_cause: "Auth middleware not checking token expiry"
    severity: "P0"
  - test_name: "should paginate results correctly"
    file: "tests/api/users.test.ts"
    error: "Expected array of length 10 but got 11"
    expected: "10"
    actual: "11"
    probable_cause: "Off-by-one in pagination logic"
    severity: "P1"
recommendations:
  - "Fix auth middleware token expiry check before proceeding"
  - "Review pagination boundary conditions"
overall_status: "FAIL"  # PASS if 0 failures, FAIL otherwise
```
