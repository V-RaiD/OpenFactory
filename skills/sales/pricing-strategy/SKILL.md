---
name: "pricing-strategy"
description: "Design pricing models, tier packaging, and revenue projections"
version: "1.0.0"
category: "sales"
min_level: "L6"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best strategic reasoning for pricing optimization and market positioning tradeoffs"
    - id: "openai/gpt-5.4"
      reason: "Strong at pricing psychology and revenue modeling"
    - id: "deepseek/deepseek-r1"
      reason: "Reasoning model handles multi-variable pricing optimization well"
triggers: ["pricing", "monetization", "pricing model", "packaging", "how much to charge"]
input_artifacts: ["prd", "competitive_analysis", "market_research_report"]
output_artifacts: ["pricing_strategy_doc"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 2
token_budget: 80000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Pricing Strategy

## Instructions

1. **Analyze the value metric** — what unit does the customer get value from? (users, API calls, projects, storage, seats)
2. **Research competitor pricing** from the competitive analysis
3. **Evaluate pricing models:**
   - Freemium (free tier + paid upgrade)
   - Free trial (time-limited full access)
   - Usage-based (pay per unit)
   - Seat-based (per user/month)
   - Flat-rate (fixed monthly price)
4. **Design 3 tiers** (Good/Better/Best):
   - Free/Starter: Attract users, demonstrate value
   - Pro: Core monetization, most customers here
   - Enterprise: High-touch, custom pricing
5. **Apply pricing psychology:**
   - Anchor with the expensive plan
   - Highlight the "recommended" plan
   - Use odd pricing ($49 not $50)
   - Annual discount (save 20%)
6. **Project revenue** based on conversion assumptions

## Output Format

```yaml
artifact_type: pricing_strategy_doc
value_metric: "seats|api_calls|projects|storage"
pricing_model: "freemium|trial|usage|seat|flat"
competitor_pricing_range: "$29-$499/mo"
tiers:
  - name: "Free"
    price: "$0/mo"
    target: "Individual developers, evaluation"
    includes: ["3 projects", "1 user", "Community support"]
    limits: ["No API access", "1GB storage"]
    purpose: "Lead generation and product-led growth"
  - name: "Pro"
    price: "$49/mo"
    annual_price: "$39/mo (billed annually)"
    target: "Small teams, startups"
    includes: ["Unlimited projects", "10 users", "API access", "Email support"]
    purpose: "Core revenue driver — 70% of revenue"
    highlighted: true
  - name: "Enterprise"
    price: "Custom (starting $499/mo)"
    target: "Large organizations"
    includes: ["Everything in Pro", "SSO/SAML", "SLA", "Dedicated support"]
    purpose: "High-value accounts, 30% of revenue"
revenue_projections:
  month_6:
    free_users: 5000
    pro_customers: 200
    enterprise_customers: 5
    mrr: "$12,300"
  month_12:
    free_users: 20000
    pro_customers: 800
    enterprise_customers: 20
    mrr: "$49,200"
  assumptions: "3% free-to-pro conversion, 0.1% free-to-enterprise"
psychological_notes:
  - "Pro tier is the anchor — Enterprise makes Pro feel like a deal"
  - "Annual billing shows monthly price with 'save 20%' badge"
  - "Free tier has visible 'Upgrade' prompts at usage limits"
```
