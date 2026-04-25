---
name: "budget-management"
description: "Monitor token spending, generate cost reports, and optimize model usage across the factory"
version: "1.0.0"
category: "management"
min_level: "L7"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best at strategic cost optimization decisions that balance quality vs. spend"
    - id: "openai/gpt-5.4"
      reason: "Strong analytical capability for cost breakdowns and projection"
    - id: "deepseek/deepseek-r1"
      reason: "Reasoning model good for optimization problems"
triggers: ["check budget", "cost report", "optimize spending", "token usage", "how much has this cost"]
input_artifacts: ["token_usage_logs", "resource_allocation_plan"]
output_artifacts: ["budget_report"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 1
token_budget: 50000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Budget Management

## Context Constraints
- Only L7+ (C-Suite) can invoke this skill
- Must flag to CEO (via Telegram) if any single phase exceeds $50
- Must flag if total project cost is projected to exceed $200

## Instructions

1. **Collect token usage data** from all agents in the current pipeline run
2. **Calculate costs** using current model pricing:
   - Claude Opus 4.6: $15/M input, $75/M output
   - Claude Sonnet 4.6: $3/M input, $15/M output
   - Claude Haiku 4.5: $0.80/M input, $4/M output
   - GPT-5.4: $10/M input, $40/M output
   - GPT-4o: $2.50/M input, $10/M output
   - GPT-4o-mini: $0.15/M input, $0.60/M output
   - DeepSeek V3: $0.27/M input, $1.10/M output
   - DeepSeek R1: $0.55/M input, $2.19/M output
   - Llama 4 Maverick: free (self-hosted) or $0.50/M (hosted)
   - Llama 4 Scout: free (self-hosted) or $0.20/M (hosted)
3. **Identify waste:**
   - Agents that consumed tokens without producing useful output
   - Tasks where a cheaper model would have sufficed
   - Excessive retry loops
4. **Recommend optimizations:**
   - Downgrade specific agents to cheaper models where quality allows
   - Batch operations to reduce overhead
   - Cache repeated prompts
5. **Project remaining cost** based on pipeline progress

## Output Format

```yaml
artifact_type: budget_report
project_id: "{project ID}"
pipeline_phase: "development"  # current phase
cost_summary:
  total_spent: "$12.45"
  total_budget: "$100.00"
  remaining: "$87.55"
  projected_total: "$45.00"
by_agent:
  - agent: "tech-lead"
    tokens_used: 120000
    cost: "$3.60"
    tasks_completed: 3
    cost_per_task: "$1.20"
  - agent: "junior-dev"
    tokens_used: 80000
    cost: "$0.64"
    tasks_completed: 5
    cost_per_task: "$0.13"
by_phase:
  - phase: "product-definition"
    cost: "$4.50"
    status: "complete"
  - phase: "development"
    cost: "$7.95"
    status: "in-progress"
    projected: "$15.00"
waste_identified:
  - agent: "junior-dev"
    issue: "3 retry loops on TASK-004 due to ambiguous spec"
    wasted_tokens: 25000
    wasted_cost: "$0.20"
    recommendation: "Improve task specs before assigning to L3 agents"
optimization_recommendations:
  - "Downgrade qa-engineer from Sonnet to Haiku — test execution doesn't need reasoning"
  - "Cache the system design doc in prompts — it's being re-sent to every agent"
  - "Batch TASK-007 and TASK-008 into a single agent call — they're related"
  estimated_savings: "$3.00"
ceo_alerts:
  - type: "phase_budget_exceeded"
    phase: "none"
    triggered: false
  - type: "total_budget_warning"
    threshold: "$200"
    triggered: false
```
