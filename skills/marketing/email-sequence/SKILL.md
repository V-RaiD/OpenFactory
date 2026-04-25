---
name: "email-sequence"
description: "Create email nurture sequences for onboarding, engagement, and conversion"
version: "1.0.0"
category: "marketing"
min_level: "L4"
models:
  preferred_order:
    - id: "openai/gpt-5.4"
      reason: "Best email copywriting — highest open rates and click-through in A/B testing"
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Strong at personalized, structured email sequences with good CTA design"
    - id: "meta/llama-4-maverick-400b"
      reason: "Capable email copy generation with decent personalization"
triggers: ["email sequence", "nurture campaign", "drip campaign", "email marketing", "onboarding emails"]
input_artifacts: ["campaign_brief", "prd"]
output_artifacts: ["email_sequence"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo", "curl"]
max_iterations: 2
token_budget: 60000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Email Sequence

## Instructions

1. **Define the sequence goal** — onboarding? Re-engagement? Conversion? Announcement?
2. **Map the journey** — what does the recipient know/feel at each stage?
3. **Write 5-7 emails:**
   - Subject line (under 50 chars, create curiosity or urgency)
   - Preview text (under 90 chars, complements subject)
   - Body (150-300 words, single column, one CTA per email)
   - CTA button text (action verb + benefit)
4. **Create A/B variants** for subject lines (2 variants per email)
5. **Define send timing** — day and time for each email
6. **Set exit conditions** — when to stop the sequence (converted, unsubscribed, no engagement after N emails)

## Output Format

```yaml
artifact_type: email_sequence
sequence_name: "New User Onboarding"
goal: "Activate new signups within 7 days"
total_emails: 5
emails:
  - order: 1
    send_timing: "Immediately after signup"
    subject_line_a: "Welcome — here's your quickstart guide"
    subject_line_b: "You're in! Let's get you set up in 5 minutes"
    preview_text: "Everything you need to start shipping faster"
    body: |
      Hi {{first_name}},

      Welcome to [Product]...
    cta_text: "Start your first project"
    cta_url: "{{app_url}}/onboarding"
  - order: 2
    send_timing: "Day 1 (24 hours after signup)"
    subject_line_a: "..."
    subject_line_b: "..."
    body: |
      ...
    cta_text: "..."
exit_conditions:
  - "User completes onboarding (converted)"
  - "User unsubscribes"
  - "No opens after email 3 — move to re-engagement sequence"
expected_metrics:
  open_rate: "40-50%"
  click_rate: "8-12%"
  conversion_rate: "15-25%"
```
