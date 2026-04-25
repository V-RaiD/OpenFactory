---
name: "cold-outreach"
description: "Create personalized cold email and LinkedIn outreach sequences for prospecting"
version: "1.0.0"
category: "sales"
min_level: "L3"
models:
  preferred_order:
    - id: "openai/gpt-5.4"
      reason: "Best personalized outreach — natural, non-spammy, high reply rates"
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Strong at research-backed personalization with professional tone"
    - id: "meta/llama-4-maverick-400b"
      reason: "Capable personalized outreach at low cost for high-volume generation"
triggers: ["cold email", "outreach", "prospecting", "lead generation", "cold outreach"]
input_artifacts: ["campaign_brief", "competitive_analysis"]
output_artifacts: ["outreach_sequence"]
allowed_commands: ["cat", "ls", "rg"]
blocked_commands: ["rm", "sudo", "curl"]
max_iterations: 2
token_budget: 50000
metadata:
  openclaw:
    requires:
      bins: []
---

# Skill: Cold Outreach

## Instructions

1. **Define the ICP (Ideal Customer Profile)** from the campaign brief
2. **Create personalization framework:**
   - Personalization tokens: {{company}}, {{role}}, {{pain_point}}, {{recent_news}}
   - Research hooks: recent funding, job postings, tech stack changes, content they published
3. **Write a 3-5 touch sequence:**
   - Touch 1 (Email): Value-first, reference their specific situation, ask a question
   - Touch 2 (LinkedIn): Connection request with personalized note
   - Touch 3 (Email): Follow-up with proof point (case study, metric)
   - Touch 4 (Email): Breakup email — "Is this not relevant? Happy to stop"
4. **Keep emails short** — under 150 words. No attachments. One question per email.
5. **Never be pushy** — consultative tone, focus on their problem not your product

## Output Format

```yaml
artifact_type: outreach_sequence
icp:
  title: "VP Engineering / CTO"
  company_size: "50-500 employees"
  industry: "B2B SaaS"
  trigger_events: ["recent funding round", "hiring DevOps engineers", "cloud migration mentioned in blog"]
touches:
  - order: 1
    channel: "email"
    timing: "Day 0"
    subject: "Quick question about {{company}}'s deployment process"
    body: |
      Hi {{first_name}},

      Noticed {{company}} is scaling the engineering team (saw the DevOps roles on your careers page). When teams grow from 10 to 50 engineers, deployment bottlenecks usually become the #1 velocity killer.

      We built [Product] specifically for this stage — [one-line value prop].

      Worth a 15-min chat to see if it's relevant?
    personalization_tokens: ["company", "first_name", "trigger_event"]
  - order: 2
    channel: "linkedin"
    timing: "Day 2"
    note: "Hi {{first_name}} — I work with engineering teams scaling past the 'deploy bottleneck' stage. Thought our work might be relevant to {{company}}. Happy to share what we've seen work."
  - order: 3
    channel: "email"
    timing: "Day 5"
    subject: "Re: Quick question about {{company}}'s deployment process"
    body: |
      Following up — [Social proof: specific metric from similar company].
      
      15 minutes — worth it?
  - order: 4
    channel: "email"
    timing: "Day 10"
    subject: "Should I close the loop?"
    body: |
      {{first_name}}, totally understand if the timing isn't right. Should I check back next quarter, or is this just not relevant?
cadence_rules:
  min_days_between_touches: 2
  stop_on: ["reply", "meeting_booked", "unsubscribe", "bounce"]
```
