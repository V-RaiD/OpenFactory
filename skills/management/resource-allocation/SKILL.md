---
name: "resource-allocation"
description: "Decide how many agents, which agents, and which models each pipeline step needs"
version: "1.0.0"
category: "management"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best at complex optimization — balances quality, cost, and parallelism tradeoffs"
    - id: "openai/gpt-5.4"
      reason: "Strong at resource planning with multi-constraint optimization"
    - id: "deepseek/deepseek-r1"
      reason: "Reasoning model handles constraint satisfaction well"
triggers: ["allocate resources", "assign agents", "team composition", "how many agents", "who should work on"]
input_artifacts: ["task_breakdown", "system_design"]
output_artifacts: ["resource_allocation_plan"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 2
token_budget: 150000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Resource Allocation

## Context Constraints
- This is THE key management skill — it decides the agent composition for each pipeline execution
- Only L6+ agents (Tech Lead, PM, Marketing Lead, Sales Lead) can invoke this
- The orchestrator calls this after task breakdown to determine how to staff the work

## Instructions

1. **Analyze the task breakdown** — for each task, assess:
   - Complexity (S/M/L/XL)
   - Required skill category
   - Minimum agent level needed
   - Dependencies (what must finish first)
2. **Determine agent assignments:**
   - Match tasks to agents based on skill fit and level
   - Parallelize independent tasks across different agents
   - Assign complex tasks to higher-level agents, routine to lower-level
3. **Optimize for cost:**
   - Use the cheapest model that can handle each task (don't use Opus for boilerplate)
   - Batch similar tasks to the same agent (reduces context-switching overhead)
   - Prefer parallel execution where dependencies allow (reduces wall-clock time)
4. **Estimate total cost:**
   - For each agent: (estimated tokens) × (model cost per token)
   - Sum across all agents
   - Flag if total exceeds $50 (CEO notification threshold)
5. **Identify bottlenecks:**
   - Critical path tasks that block everything
   - Agents that are overloaded
   - Missing capabilities (need to spawn a new agent type)

## Output Format

```yaml
artifact_type: resource_allocation_plan
project_id: "{project ID}"
total_tasks: 12
assignments:
  - task_id: "TASK-001"
    title: "Setup project scaffold"
    assigned_agent: "junior-dev"
    agent_level: "L3"
    model: "anthropic/claude-haiku-4-5"
    reason: "Simple scaffolding task, no judgment calls needed"
    estimated_tokens: 15000
    estimated_cost: "$0.02"
    parallel_group: "A"  # tasks in same group run in parallel
  - task_id: "TASK-002"
    title: "Design auth module"
    assigned_agent: "senior-dev"
    agent_level: "L5"
    model: "anthropic/claude-sonnet-4-6"
    reason: "Security-critical design requires senior judgment"
    estimated_tokens: 50000
    estimated_cost: "$0.45"
    parallel_group: "A"
  - task_id: "TASK-003"
    title: "Implement auth module"
    assigned_agent: "senior-dev"
    agent_level: "L5"
    model: "anthropic/claude-sonnet-4-6"
    reason: "Auth implementation needs careful handling"
    estimated_tokens: 80000
    estimated_cost: "$0.72"
    parallel_group: "B"
    depends_on: ["TASK-002"]
execution_plan:
  parallel_groups:
    - group: "A"
      tasks: ["TASK-001", "TASK-002"]
      estimated_duration: "parallel, ~5 min"
    - group: "B"
      tasks: ["TASK-003", "TASK-004"]
      estimated_duration: "parallel, ~10 min"
      depends_on_group: "A"
cost_summary:
  total_estimated_tokens: 450000
  total_estimated_cost: "$4.20"
  cost_by_model:
    "anthropic/claude-opus-4-6": "$1.50"
    "anthropic/claude-sonnet-4-6": "$2.20"
    "anthropic/claude-haiku-4-5": "$0.50"
  ceo_notification_required: false  # true if > $50
bottlenecks:
  - "TASK-005 (database schema) blocks 4 downstream tasks"
  - "Only one senior-dev available — consider spawning a second for parallel work"
```
