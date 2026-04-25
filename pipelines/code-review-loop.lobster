# code-review-loop.lobster
# Reusable code review iteration loop.
# Can be included from any pipeline that needs a review-revise cycle.

args:
  code_ref:
    type: string
    required: true
    description: "Reference to the code to review (branch name, PR URL, or diff)"
  reviewer_agent:
    type: string
    required: true
    description: "Agent ID of the reviewer (e.g., tech-lead, senior-dev)"
  developer_agent:
    type: string
    required: true
    description: "Agent ID of the developer who wrote the code"
  review_context:
    type: string
    required: false
    default: ""
    description: "Additional context for the reviewer (architecture docs, requirements, etc.)"

steps:

  - id: review-loop
    name: "Code Review Iteration Loop"
    loop:
      maxIterations: 5
      condition: "$review.json.approved != true"
    steps:

      - id: review
        name: "Reviewer Evaluates Code"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "{{args.reviewer_agent}}",
            "message": "Review the code at {{args.code_ref}}. Evaluate:\n- Correctness: Does it do what it should?\n- Architecture: Does it follow established patterns?\n- Security: Any vulnerabilities or data exposure risks?\n- Performance: Any bottlenecks or N+1 queries?\n- Readability: Is it maintainable and well-documented?\n- Tests: Adequate coverage and quality?\n\nContext: {{args.review_context}}\n\nReturn JSON: {\"approved\": true/false, \"verdict\": \"approve|request-changes|reject\", \"comments\": [{\"file\": \"...\", \"line\": N, \"severity\": \"blocking|major|minor|nitpick\", \"comment\": \"...\"}], \"summary\": \"...\", \"feedback\": \"...\"}"
          }'

      - id: check-approved
        name: "Check if Approved"
        condition: "$review.json.approved == true"
        command: >
          openclaw.invoke --tool llm-task --action json --args-json '{
            "prompt": "Code review approved. Return {\"status\": \"approved\", \"message\": \"Code review passed.\"}"
          }'

      - id: send-feedback
        name: "Send Review Feedback to Developer"
        condition: "$review.json.approved != true"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "{{args.developer_agent}}",
            "message": "Your code review had feedback that needs to be addressed.\n\nVerdict: $review.json.verdict\nSummary: $review.json.summary\n\nComments:\n$review.json.comments\n\nPlease address all blocking and major comments. Minor and nitpick items are at your discretion."
          }'

      - id: revise
        name: "Developer Revises Code"
        condition: "$review.json.approved != true"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "{{args.developer_agent}}",
            "message": "Address all review feedback and push updated code to {{args.code_ref}}. For each comment, either fix the issue or explain why you disagree. Return JSON with {\"addressed\": [{\"comment_index\": N, \"action\": \"fixed|wont-fix\", \"explanation\": \"...\"}], \"ready_for_re_review\": true}"
          }'
        timeout: 600

  - id: stuck-escalation
    name: "Escalate if Stuck"
    condition: "$review-loop.iterations >= 5 && $review.json.approved != true"
    command: >
      openclaw.invoke --tool sessions-spawn --args-json '{
        "agent": "tech-lead",
        "prompt": "Code review for {{args.code_ref}} has not converged after 5 iterations. Review the history of feedback and revisions. Determine: (1) Is the developer stuck on a fundamental misunderstanding? (2) Is the reviewer being too strict? (3) Should we pair-program to resolve? (4) Should the task be reassigned? Return a recommendation with next steps.",
        "model": "anthropic/claude-sonnet"
      }'
