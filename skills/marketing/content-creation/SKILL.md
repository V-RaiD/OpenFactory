---
name: "content-creation"
description: "Write blog posts, social media content, landing page copy, and press releases"
version: "1.0.0"
category: "marketing"
min_level: "L3"
models:
  preferred_order:
    - id: "openai/gpt-5.4"
      reason: "Best creative prose — most natural, engaging, and persuasive marketing copy"
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Strong structured content with excellent tone control and accuracy"
    - id: "meta/llama-4-maverick-400b"
      reason: "Surprisingly good creative writing for an open-source model"
triggers: ["write blog", "social media post", "landing page", "press release", "marketing copy", "write content"]
input_artifacts: ["campaign_brief", "prd"]
output_artifacts: ["content_bundle"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo", "curl"]
max_iterations: 3
token_budget: 80000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Content Creation

## Instructions

1. **Read the campaign brief** — internalize the audience, messaging, and tone
2. **Create content for each channel:**

### Blog Post (1,200-2,000 words)
- Hook in the first sentence — lead with the problem, not the product
- Structure: Problem → Agitation → Solution → Proof → CTA
- Include subheadings every 200-300 words for scannability
- End with a clear CTA (signup, demo, download)
- SEO: include target keywords naturally (don't stuff)

### Social Media Posts
- **LinkedIn:** Professional, 150-300 words, insight-driven, no hashtag spam (3 max)
- **Twitter/X:** Under 280 chars, punchy, thread format for deep content (5-8 tweets)
- **Product Hunt tagline:** Under 60 chars, benefit-focused

### Landing Page Copy
- Headline: Benefit-driven, under 10 words
- Subheadline: Expand on the benefit, under 25 words
- 3 feature blocks: Icon + headline + 2-line description
- Social proof section: quotes, logos, numbers
- CTA: Action verb + benefit ("Start shipping faster" not "Sign up")
- FAQ: 5-7 common objections addressed

### Press Release (AP Style)
- Headline, dateline, lead paragraph (who/what/when/where/why)
- Supporting quotes from "CEO"
- Product details
- Availability and pricing
- Boilerplate company description

## Output Format

```yaml
artifact_type: content_bundle
campaign_id: "{campaign brief ID}"
pieces:
  - type: "blog_post"
    title: "Blog post title"
    content: |
      Full blog post in markdown
    word_count: 1500
    target_keywords: ["keyword1", "keyword2"]
    meta_description: "Under 160 chars"
  - type: "linkedin_post"
    content: |
      Post text
    char_count: 250
  - type: "twitter_thread"
    tweets:
      - "Tweet 1 (under 280 chars)"
      - "Tweet 2"
  - type: "landing_page"
    headline: "Ship 10x faster"
    subheadline: "AI-powered infrastructure management"
    features: [{title, description, icon_suggestion}]
    cta_text: "Start free trial"
    faq: [{question, answer}]
  - type: "press_release"
    content: |
      Full press release in AP style
```
