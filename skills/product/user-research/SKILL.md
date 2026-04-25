---
name: "user-research"
description: "Conduct market research, competitive analysis, and opportunity assessment"
version: "1.0.0"
category: "product"
min_level: "L5"
models:
  preferred_order:
    - id: "openai/gpt-5.4"
      reason: "Best at synthesizing market insights and user behavior patterns from available data"
    - id: "google/gemini-3.1-pro"
      reason: "Strong research capability with broad knowledge of market trends"
    - id: "meta/llama-4-maverick-400b"
      reason: "Capable analysis for market sizing and competitive positioning"
triggers: ["user research", "market research", "competitive analysis", "TAM analysis", "market sizing"]
input_artifacts: ["ceo_idea"]
output_artifacts: ["market_research_report"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 2
token_budget: 120000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: User Research & Market Analysis

## Instructions

1. **Analyze the CEO's idea** — what market category does this fall into?
2. **Estimate market size:**
   - TAM (Total Addressable Market) — the entire market
   - SAM (Serviceable Addressable Market) — the segment we can reach
   - SOM (Serviceable Obtainable Market) — realistic first-year capture
3. **Map the competitive landscape:**
   - Direct competitors (solve the same problem)
   - Indirect competitors (solve adjacent problems)
   - For each: name, positioning, pricing, strengths, weaknesses
4. **Identify user pain points:**
   - What are users currently doing to solve this problem?
   - Where does the current solution fail them?
   - What would make them switch?
5. **Assess the opportunity:**
   - Is the market growing or shrinking?
   - Is there a timing advantage?
   - What's the defensibility angle?
6. **Produce an opportunity score:** 1-10 with justification

## Output Format

```yaml
artifact_type: market_research_report
idea: "{CEO's original idea}"
market_sizing:
  tam: "$X billion"
  sam: "$X million"
  som: "$X million (year 1)"
  methodology: "How the numbers were derived"
competitive_landscape:
  direct_competitors:
    - name: "Competitor A"
      positioning: "How they describe themselves"
      pricing: "$X/mo"
      strengths: ["S1", "S2"]
      weaknesses: ["W1", "W2"]
      market_share: "~X%"
  indirect_competitors:
    - name: "Alternative B"
      overlap: "Where they compete with us"
user_pain_points:
  - pain: "Current tools require manual X"
    severity: "high"
    frequency: "daily"
    current_workaround: "Spreadsheets"
opportunity_assessment:
  market_trend: "growing|stable|declining"
  timing: "Why now is the right time"
  defensibility: "Network effects|data moat|switching costs|brand"
  opportunity_score: 8
  recommendation: "proceed|pivot|abandon"
  reasoning: "Why this score"
```
