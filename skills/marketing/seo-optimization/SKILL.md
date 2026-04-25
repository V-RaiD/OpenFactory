---
name: "seo-optimization"
description: "Optimize content for search engines — keyword research, meta tags, and content structure"
version: "1.0.0"
category: "marketing"
min_level: "L4"
models:
  preferred_order:
    - id: "google/gemini-3.1-pro"
      reason: "Google's model has deepest understanding of search ranking factors and content quality signals"
    - id: "openai/gpt-5.4"
      reason: "Strong SEO knowledge with good keyword clustering and content gap analysis"
    - id: "deepseek/deepseek-v3"
      reason: "Capable at structured SEO analysis and recommendation generation"
triggers: ["SEO", "optimize for search", "keyword research", "meta tags", "search optimization"]
input_artifacts: ["content_bundle", "prd"]
output_artifacts: ["seo_report"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 2
token_budget: 60000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: SEO Optimization

## Instructions

1. **Keyword research** — identify primary and secondary keywords based on:
   - Product category and features
   - User problem language (how do they search for solutions?)
   - Competitor keywords
   - Long-tail opportunities
2. **On-page optimization** for each content piece:
   - Title tag (under 60 chars, primary keyword near start)
   - Meta description (under 160 chars, includes CTA)
   - H1, H2, H3 structure with keyword placement
   - Image alt text suggestions
   - Internal linking opportunities
3. **Content gap analysis** — what topics should we cover that competitors rank for?
4. **Technical SEO checklist** — URL structure, canonical tags, schema markup

## Output Format

```yaml
artifact_type: seo_report
target_keywords:
  primary:
    - keyword: "AI infrastructure management"
      monthly_search_volume: "estimated 2,400"
      difficulty: "medium"
      intent: "commercial"
  secondary:
    - keyword: "automate cloud deployment"
      monthly_search_volume: "estimated 1,800"
      difficulty: "low"
      intent: "informational"
  long_tail:
    - keyword: "how to automate AWS ECS deployment"
      monthly_search_volume: "estimated 400"
      difficulty: "low"
      intent: "informational"
page_optimizations:
  - page: "landing page"
    title_tag: "AI Infrastructure Management | Ship 10x Faster"
    meta_description: "Automate your cloud infrastructure with AI. Deploy, monitor, and scale without the DevOps overhead. Start free."
    h1: "Ship 10x Faster with AI-Powered Infrastructure"
    schema_markup: "SoftwareApplication"
  - page: "blog post"
    title_tag: "How AI is Changing Cloud Deployment in 2026"
    meta_description: "..."
content_gaps:
  - topic: "Comparison: AI deployment tools 2026"
    opportunity: "No quality content exists, 800 monthly searches"
    recommended_format: "comparison blog post"
technical_checklist:
  url_structure: "/blog/topic-keyword (lowercase, hyphens)"
  canonical_tags: "self-referencing on all pages"
  sitemap: "auto-generated, submit to Search Console"
  page_speed: "Target < 2.5s LCP"
```
