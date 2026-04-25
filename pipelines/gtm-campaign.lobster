# gtm-campaign.lobster
# Go-to-market sub-pipeline: competitive analysis through content creation to sales enablement.
# Called by idea-to-launch.lobster or run standalone for GTM planning.

args:
  product_name:
    type: string
    required: true
    description: "Name of the product being launched"
  prd:
    type: string
    required: true
    description: "Product Requirements Document content"
  market_research:
    type: string
    required: true
    description: "Market research findings"
  skip_final_approval:
    type: boolean
    required: false
    default: false
    description: "Skip final GTM approval if already gated in parent pipeline"

steps:

  # ── Research & Strategy ──

  - id: competitive-analysis
    name: "Competitive Analysis"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "sales-lead",
        "prompt": "Conduct a detailed competitive analysis for {{args.product_name}}. For each competitor, document: company name, product name, pricing, strengths, weaknesses, market share estimate, key differentiators, and our competitive advantage against them. Return as structured JSON.\n\nMarket research: {{args.market_research}}\nPRD: {{args.prd}}",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 600

  - id: pricing-strategy
    name: "Define Pricing Strategy"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "sales-lead",
        "message": "Based on the competitive analysis and market research, define a pricing strategy for {{args.product_name}}. Include: pricing model (subscription/usage/one-time), tier structure with features per tier, price points with justification, comparison to competitors, expected conversion rates per tier, and annual revenue projections.\n\nCompetitive analysis: $competitive-analysis.json\nMarket research: {{args.market_research}}"
      }'

  # ── Marketing Content ──

  - id: campaign-brief
    name: "Create Campaign Brief"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "marketing-lead",
        "prompt": "Create a comprehensive marketing campaign brief for {{args.product_name}} using the campaign-brief template. Include target audience segments, messaging framework, channel strategy with budget allocation, content calendar, and KPIs.\n\nPRD: {{args.prd}}\nMarket research: {{args.market_research}}\nCompetitive analysis: $competitive-analysis.json\nPricing: $pricing-strategy.stdout",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 600

  - id: content-creation
    name: "Create Marketing Content"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "content-specialist",
        "prompt": "Create all marketing content for the {{args.product_name}} launch based on the campaign brief. Produce:\n1. Landing page copy (hero, features, benefits, social proof, CTA)\n2. Blog post announcing the launch (800-1200 words)\n3. Social media posts (LinkedIn, Twitter/X — 5 posts each)\n4. Product one-pager (PDF-ready)\n5. Press release draft\n\nCampaign brief: $campaign-brief.stdout\nPRD: {{args.prd}}",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 900

  - id: seo-optimization
    name: "SEO Optimization"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "content-specialist",
        "message": "Optimize all content for SEO. For each piece of content, provide: target keywords (primary + secondary), meta title, meta description, header structure, internal linking suggestions, and schema markup recommendations. Also produce a keyword strategy document with search volume estimates and difficulty ratings."
      }'

  # ── Sales Enablement ──

  - id: email-sequence
    name: "Create Email Drip Sequence"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "marketing-lead",
        "message": "Create an email drip sequence for {{args.product_name}} with:\n1. Welcome / announcement email (day 0)\n2. Feature deep-dive (day 2)\n3. Use case / case study (day 5)\n4. Social proof / testimonials (day 8)\n5. Limited-time offer / urgency (day 12)\n6. Final follow-up (day 15)\n\nFor each email: subject line (+ 2 A/B variants), preview text, body copy, CTA, and send timing.\n\nCampaign brief: $campaign-brief.stdout"
      }'

  - id: cold-outreach
    name: "Create Cold Outreach Sequences"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "sales-dev-rep",
        "prompt": "Create cold outreach sequences for {{args.product_name}} targeting each persona in the market research. For each persona create:\n1. LinkedIn connection request message\n2. 5-touch email sequence (each with subject, body, CTA)\n3. Cold call script with objection handling\n4. Follow-up cadence timeline\n\nCompetitive analysis: $competitive-analysis.json\nPricing: $pricing-strategy.stdout\nMarket research: {{args.market_research}}",
        "model": "anthropic/claude-sonnet"
      }'
    timeout: 600

  - id: pitch-deck
    name: "Create Sales Pitch Deck"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "sales-lead",
        "message": "Create a sales pitch deck for {{args.product_name}} using the pitch-deck template. Include 12 slides with speaker notes. Incorporate competitive positioning, pricing, and market data.\n\nPRD: {{args.prd}}\nCompetitive analysis: $competitive-analysis.json\nPricing: $pricing-strategy.stdout\nMarket research: {{args.market_research}}"
      }'

  # ── Review ──

  - id: review-gtm-bundle
    name: "CPO Reviews GTM Bundle"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "cpo",
        "message": "Review the complete GTM bundle for {{args.product_name}}. Evaluate strategic alignment, messaging consistency, pricing competitiveness, and channel coverage. Return JSON with {\"approved\": true/false, \"feedback\": \"...\", \"risk_areas\": [...]}.\n\nCampaign brief: $campaign-brief.stdout\nPricing: $pricing-strategy.stdout\nCompetitive analysis: $competitive-analysis.json\nContent summary: $content-creation.stdout\nOutreach plan: $cold-outreach.stdout"
      }'

  - id: gtm-approval
    name: "GTM Materials Approval"
    condition: "{{args.skip_final_approval}} != true"
    approval: "Review GTM materials before launch?\n\nCampaign Brief:\n$campaign-brief.stdout\n\nPricing Strategy:\n$pricing-strategy.stdout\n\nCPO Review:\n$review-gtm-bundle.json\n\nContent pieces created: landing page, blog post, social posts, one-pager, press release, email sequence, outreach sequences, pitch deck."
