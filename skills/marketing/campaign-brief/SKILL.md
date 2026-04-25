---
name: "campaign-brief"
description: "Create comprehensive go-to-market campaign briefs with audience, messaging, channels, and KPIs"
version: "1.0.0"
category: "marketing"
min_level: "L5"
models:
  preferred_order:
    - id: "openai/gpt-5.4"
      reason: "Best creative marketing strategy — understands audience psychology and channel dynamics"
    - id: "anthropic/claude-opus-4-6"
      reason: "Strong analytical approach to campaign planning with rigorous audience segmentation"
    - id: "meta/llama-4-maverick-400b"
      reason: "Capable at structured marketing plans with good creative range"
triggers: ["create campaign", "marketing plan", "GTM strategy", "launch plan", "go to market"]
input_artifacts: ["prd", "market_research_report", "competitive_analysis"]
output_artifacts: ["campaign_brief"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo", "curl"]
max_iterations: 3
token_budget: 120000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Campaign Brief

## Instructions

1. **Start with the audience, not the product:**
   - Who are we talking to? Define 2-3 segments with demographics, psychographics, behavior
   - Where do they spend time online? What do they read? Who do they follow?
   - What language do they use to describe their problem?
2. **Define the messaging framework:**
   - Value proposition: One sentence explaining why this matters
   - Key messages: 3 supporting points
   - Proof points: Evidence, data, testimonials
   - Tone: Professional/casual/technical — match the audience
3. **Select channels** based on audience presence:
   - Owned: Blog, email, social accounts, product
   - Earned: PR, guest posts, community, Product Hunt
   - Paid: Google Ads, LinkedIn Ads, Twitter/X Ads, sponsorships
4. **Build the content calendar** — week-by-week for launch window
5. **Set KPIs** — traffic, signups, activation, MQLs, revenue
6. **Allocate budget** across channels with expected ROI

Use the template at `templates/campaign-brief.md`.

## Output Format

```yaml
artifact_type: campaign_brief
campaign_name: "Launch Campaign: {Product Name}"
objective: "Drive 1,000 signups in first 30 days"
target_audiences:
  - segment: "Technical founders"
    size: "~50,000 reachable"
    channels: ["Twitter/X", "Hacker News", "Dev.to"]
    pain_point: "Spending 40% of time on infrastructure instead of product"
messaging:
  value_proposition: "Ship 10x faster with AI-powered infrastructure"
  key_messages: ["Message 1", "Message 2", "Message 3"]
  tone: "technical but approachable"
channels:
  - channel: "Product Hunt"
    type: "earned"
    timing: "Launch day"
    expected_impact: "500-2,000 visits"
    budget: "$0"
  - channel: "LinkedIn Ads"
    type: "paid"
    timing: "Week 1-4"
    expected_impact: "200 MQLs"
    budget: "$2,000"
content_calendar:
  - week: "Pre-launch (Week -1)"
    activities: ["Teaser posts", "Email to waitlist", "Influencer outreach"]
  - week: "Launch (Week 0)"
    activities: ["Product Hunt launch", "Blog post", "Press release", "Social blitz"]
  - week: "Post-launch (Week 1-2)"
    activities: ["Customer stories", "Technical deep-dive blog", "Webinar"]
kpis:
  - metric: "Website visits"
    target: "10,000 in 30 days"
  - metric: "Signups"
    target: "1,000 in 30 days"
  - metric: "Activation rate"
    target: "30% of signups"
total_budget: "$5,000"
```
