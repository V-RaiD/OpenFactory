---
name: "competitive-analysis"
description: "Deep competitive research — feature matrices, positioning maps, and sales battlecards"
version: "1.0.0"
category: "sales"
min_level: "L5"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best analytical reasoning for nuanced competitor assessment and positioning strategy"
    - id: "google/gemini-3.1-pro"
      reason: "Strong research capability for gathering competitor intelligence"
    - id: "deepseek/deepseek-r1"
      reason: "Reasoning model handles multi-dimensional comparisons methodically"
triggers: ["competitive analysis", "competitor research", "battlecard", "market landscape", "how do we compare"]
input_artifacts: ["prd", "market_research_report"]
output_artifacts: ["competitive_analysis_doc"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 2
token_budget: 100000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Competitive Analysis

## Instructions

1. **Identify competitors** — direct (same solution), indirect (different approach to same problem), aspirational (where we want to be)
2. **Profile each competitor:**
   - Company overview (funding, team size, growth stage)
   - Product capabilities (features, pricing, integrations)
   - Target market (ICP, verticals, company size)
   - Positioning and messaging (how they describe themselves)
   - Strengths and weaknesses
3. **Build a feature comparison matrix** — our product vs. each competitor across key features
4. **Map positioning** — where does each player sit on relevant axes (price vs. capability, ease-of-use vs. power)
5. **Create battlecards** — one per competitor, for sales team use:
   - Quick overview, their pitch, our counter-pitch
   - When we win against them (and why)
   - When we lose against them (and why)
   - Landmines to plant ("Ask them about X — they can't do it")
   - Trap questions they'll set ("They'll say we can't do Y — here's how we handle it")
6. **Recommend positioning** — how should we differentiate?

## Output Format

```yaml
artifact_type: competitive_analysis_doc
competitors:
  direct:
    - name: "Competitor A"
      funding: "$50M Series B"
      team_size: "~200"
      pricing: "$49-499/mo"
      strengths: ["Feature X", "Brand recognition"]
      weaknesses: ["No API", "Slow support"]
      win_rate_vs_us: "estimated 40%"
  indirect:
    - name: "Alternative B"
      approach: "Different approach to same problem"
      overlap: "30% feature overlap"
feature_matrix:
  features: ["Feature A", "Feature B", "Feature C"]
  comparison:
    "Our Product": ["yes", "yes", "partial"]
    "Competitor A": ["yes", "no", "yes"]
    "Competitor B": ["partial", "yes", "no"]
battlecards:
  - competitor: "Competitor A"
    their_pitch: "Enterprise-grade platform with 10 years of experience"
    our_counter: "Modern architecture, 10x faster setup, built for the AI era"
    we_win_when: "Speed matters, modern stack, API-first"
    we_lose_when: "Enterprise compliance requirements, large existing deployment"
    landmines: ["Ask about their API — it's SOAP-based from 2015"]
    trap_questions: ["They'll claim we lack SOC2 — show our certification"]
positioning_recommendation:
  differentiation: "Speed + Developer experience"
  tagline_suggestion: "The modern alternative to [Competitor A]"
  key_messaging: ["10x faster setup", "API-first", "AI-native"]
```
