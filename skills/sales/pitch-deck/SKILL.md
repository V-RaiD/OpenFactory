---
name: "pitch-deck"
description: "Create structured pitch deck outlines with speaker notes for investor and sales presentations"
version: "1.0.0"
category: "sales"
min_level: "L5"
models:
  preferred_order:
    - id: "openai/gpt-5.4"
      reason: "Best narrative structure for presentations — compelling storytelling arc"
    - id: "anthropic/claude-opus-4-6"
      reason: "Deep product understanding produces technically accurate pitch content"
    - id: "google/gemini-3.1-pro"
      reason: "Good at market data synthesis and visual content suggestions"
triggers: ["pitch deck", "sales deck", "investor deck", "presentation", "demo script"]
input_artifacts: ["prd", "competitive_analysis", "pricing_strategy"]
output_artifacts: ["pitch_deck_outline"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo"]
max_iterations: 3
token_budget: 80000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Pitch Deck

## Instructions

1. **Identify the audience** — investors, enterprise buyers, SMB buyers, partners
2. **Choose the narrative arc** — Problem → Solution → Why Now → Why Us
3. **Build 12-15 slides** following the template at `templates/pitch-deck.md`
4. **Write speaker notes** for each slide (what to say, not what's on the slide)
5. **Include data** — market size, growth rates, metrics, social proof
6. **End with a clear ask** — meeting, demo, trial, investment

## Output Format

```yaml
artifact_type: pitch_deck_outline
audience: "enterprise_buyers|investors|smb"
slide_count: 12
slides:
  - number: 1
    title: "Opening Hook"
    content: "Headline that captures the core problem"
    visual_suggestion: "Full-screen stat or provocative question"
    speaker_notes: "Start with the problem. Don't introduce the product yet."
  - number: 2
    title: "The Problem"
    content: "3 bullet points describing the pain"
    visual_suggestion: "Before/after comparison or pain point icons"
    speaker_notes: "Spend 60 seconds here. Make them feel the pain."
  # ... slides 3-12
estimated_presentation_duration: "12-15 minutes"
```
