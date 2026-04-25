---
name: "dispute-resolution"
description: "Resolve conflicting recommendations between agents when they reach a deadlock"
version: "1.0.0"
category: "management"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best nuanced reasoning — weighs competing arguments fairly, avoids false compromises"
    - id: "openai/gpt-5.4"
      reason: "Strong at evaluating multi-perspective technical arguments"
    - id: "deepseek/deepseek-r1"
      reason: "Deep reasoning model excels at structured argument evaluation"
triggers: ["resolve dispute", "agents disagree", "conflicting recommendations", "deadlock", "break tie"]
input_artifacts: ["conflict_description"]
output_artifacts: ["resolution_decision"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo", "git push"]
max_iterations: 1
token_budget: 100000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Dispute Resolution

## Context Constraints
- Only L6+ agents can invoke this skill
- This skill is triggered when two or more agents produce conflicting outputs and cannot self-resolve
- Common scenarios: QA and developer disagree on bug severity, architect and developer disagree on approach, marketing and product disagree on positioning

## Instructions

1. **Collect both positions** — read each agent's argument, evidence, and proposed solution
2. **Identify the root disagreement** — is it factual (one is wrong), preferential (both are valid), or scope-based (different optimization targets)?
3. **Evaluate on merit:**
   - Which position has stronger evidence?
   - Which aligns better with the PRD/system design?
   - Which carries lower risk?
   - Which is more cost-effective?
4. **Make a decision** — do NOT default to compromise. Pick the better position. Weak compromises create worse outcomes than either option alone.
5. **Acknowledge the dissent** — explain why the other position wasn't chosen
6. **Assign action items** — clear instructions for each agent on what to do next
7. **If genuinely uncertain (both positions equally valid)** — escalate to CEO with your analysis

## Anti-Patterns
- Do NOT split the difference arbitrarily
- Do NOT defer the decision by asking for "more research" unless genuinely needed
- Do NOT override a junior agent's correct technical analysis just because a senior disagreed

## Output Format

```yaml
artifact_type: resolution_decision
dispute_id: "{unique ID}"
parties:
  - agent: "qa-engineer"
    position: "This is a P0 bug that blocks release"
    evidence: "Authentication bypass in edge case"
  - agent: "senior-dev"
    position: "This is P2 — the edge case is unreachable in production"
    evidence: "Input validation prevents this path"
root_disagreement: "factual|preferential|scope"
decision: "Treat as P1 — fix before release but don't block current sprint"
rationale: "The edge case IS reachable via API (not just UI), but exploitation requires specific conditions. Fix is small (2 hours). Risk of delay is lower than risk of shipping."
dissent_acknowledged: "Senior dev's point about UI validation is correct, but API access bypasses it — this was the gap in analysis."
action_items:
  - agent: "senior-dev"
    task: "Fix the auth check in API handler"
    deadline: "end of current sprint"
  - agent: "qa-engineer"
    task: "Add regression test for API-based auth bypass"
escalated_to_ceo: false
```
