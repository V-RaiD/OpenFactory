---
name: "backlog-prioritization"
description: "Prioritize feature backlogs using RICE/WSJF scoring and sprint planning"
version: "1.0.0"
category: "product"
min_level: "L5"
models:
  preferred_order:
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Excellent at structured ranking with consistent scoring methodology"
    - id: "openai/gpt-5.4"
      reason: "Strong analytical prioritization with business context awareness"
    - id: "deepseek/deepseek-v3"
      reason: "Capable at scoring frameworks and dependency graph analysis"
triggers: ["prioritize backlog", "rank features", "sprint planning", "what to build first"]
input_artifacts: ["prd", "task_breakdown"]
output_artifacts: ["prioritized_backlog"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 2
token_budget: 60000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Backlog Prioritization

## Instructions

1. **Score each item** using RICE framework:
   - **Reach:** How many users will this impact per quarter? (number)
   - **Impact:** How much will it impact each user? (3=massive, 2=high, 1=medium, 0.5=low, 0.25=minimal)
   - **Confidence:** How confident are we? (100%=high, 80%=medium, 50%=low)
   - **Effort:** Person-weeks to implement (number)
   - **RICE Score = (Reach * Impact * Confidence) / Effort**
2. **Respect hard dependencies** — if B depends on A, A must come first regardless of RICE
3. **Group into sprints** based on capacity and dependencies
4. **Flag items that need scope negotiation** — if total effort exceeds budget

## Output Format

```yaml
artifact_type: prioritized_backlog
items:
  - id: "TASK-001"
    title: "User authentication"
    rice_score: 45.0
    reach: 1000
    impact: 3
    confidence: 0.75
    effort: 2
    priority: "P0"
    sprint: 1
    depends_on: []
  - id: "TASK-002"
    title: "Dashboard UI"
    rice_score: 30.0
    priority: "P0"
    sprint: 1
    depends_on: ["TASK-001"]
sprints:
  - sprint: 1
    tasks: ["TASK-001", "TASK-002"]
    total_effort_weeks: 4
  - sprint: 2
    tasks: ["TASK-003", "TASK-004"]
    total_effort_weeks: 3
scope_warnings:
  - "Total effort (12 weeks) exceeds implied 8-week timeline — scope negotiation recommended"
```
