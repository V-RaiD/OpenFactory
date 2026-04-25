---
name: "debugging"
description: "Diagnose and fix bugs using systematic root cause analysis"
version: "1.0.0"
category: "engineering"
min_level: "L4"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best debugging reasoning — traces complex execution paths and identifies non-obvious root causes"
    - id: "openai/gpt-5.4"
      reason: "Strong at pattern matching against known bug classes and generating targeted fixes"
    - id: "deepseek/deepseek-r1"
      reason: "Reasoning model ideal for step-by-step debugging traces and hypothesis testing"
triggers: ["debug", "fix bug", "investigate error", "troubleshoot", "why is this failing"]
input_artifacts: ["bug_report", "code_artifact", "test_report"]
output_artifacts: ["code_artifact"]
allowed_commands: ["git diff", "git log", "git blame", "rg", "cat", "ls", "node", "python3", "npm test", "pytest", "go test", "cargo test", "curl -s"]
blocked_commands: ["rm -rf", "sudo", "git push", "git reset --hard"]
max_iterations: 5
token_budget: 120000
metadata:
  openclaw:
    requires:
      bins: ["git", "rg"]
---

# Skill: Debugging

## Context Constraints

### [L4] Mid Debugging Bounds
- Investigate bugs within your assigned module only
- May read adjacent modules to trace call chains
- Must document root cause before writing any fix
- If bug originates in another module, escalate to Senior with your analysis

### [L5] Senior Debugging Bounds
- May investigate across the entire codebase
- May fix bugs in any module with documented rationale
- Must add a regression test for every fix
- May temporarily revert changes if needed to isolate the bug

## Instructions

1. **Reproduce the bug** — read the bug report, understand expected vs actual behavior
2. **Form a hypothesis** — based on the error message, stack trace, or symptoms, hypothesize the root cause
3. **Gather evidence** — use `git blame`, `rg`, and reading code to verify or refute your hypothesis
4. **Narrow down** — if the hypothesis is wrong, form a new one. Track hypotheses tried:
   ```
   Hypothesis 1: Off-by-one in loop → REFUTED (loop bounds are correct)
   Hypothesis 2: Race condition in async handler → CONFIRMED (missing await on line 42)
   ```
5. **Fix the root cause** — not the symptom. Don't add a band-aid if the underlying logic is wrong
6. **Write a regression test** — a test that fails before the fix and passes after
7. **Verify** — run the full test suite to ensure no regressions

## Anti-Patterns
- Do NOT add try-catch around the symptom — fix the cause
- Do NOT suppress the error — understand it
- Do NOT change more code than necessary — minimize blast radius
- If you've tried 3 hypotheses and none pan out, ESCALATE with your findings

## Output Format

```yaml
artifact_type: code_artifact
task_id: "{bug report ID}"
bug_fix: true
root_cause: "Missing await on async database call in auth handler, causing race condition where session writes interleave"
hypotheses_tested:
  - hypothesis: "Off-by-one in pagination loop"
    result: "refuted"
    evidence: "Loop bounds correctly use < not <="
  - hypothesis: "Race condition in async handler"
    result: "confirmed"
    evidence: "git blame shows await was removed in commit abc123"
files:
  - path: "src/auth/handler.ts"
    language: "typescript"
    content: |
      // patched file content
    action: "modify"
  - path: "tests/auth/handler.test.ts"
    language: "typescript"
    content: |
      // regression test
    action: "modify"
regression_test_added: true
full_suite_passed: true
```
