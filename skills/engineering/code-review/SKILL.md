---
name: "code-review"
description: "Analyze code for bugs, security vulnerabilities, style issues, and architectural conformance"
version: "1.0.0"
category: "engineering"
min_level: "L5"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best at finding subtle bugs, security flaws, and architectural violations — deepest reasoning"
    - id: "openai/gpt-5.4"
      reason: "Strong analytical review, good at catching patterns and anti-patterns across languages"
    - id: "deepseek/deepseek-r1"
      reason: "Reasoning model excels at step-by-step analysis needed for thorough code review"
triggers: ["review code", "check code", "PR review", "code review", "review this"]
input_artifacts: ["code_artifact", "system_design", "task_breakdown"]
output_artifacts: ["code_review_result"]
allowed_commands: ["git diff", "git log", "git blame", "rg", "ast-grep", "cat", "ls", "wc"]
blocked_commands: ["git push", "git commit", "rm", "write", "edit", "npm install"]
max_iterations: 1
token_budget: 100000
metadata:
  openclaw:
    requires:
      bins: ["git", "rg"]
---

# Skill: Code Review

## Context Constraints

### [L5] Senior Review Bounds
- Review code within your team's domain
- Can approve or request changes
- Escalate to Tech Lead if the change touches architecture or crosses module boundaries
- Cannot merge — only approve

### [L6] Tech Lead Review Bounds
- Review any code in the repository
- Can approve, request changes, or reject
- Can override junior reviewer decisions with documented rationale
- Can merge after approval

## Instructions

1. **Understand context first** — read the task spec and system design before looking at code
2. **Review systematically** through these lenses in order:
   - **Correctness:** Does the code do what the task spec requires? Are edge cases handled?
   - **Security:** OWASP Top 10 check — injection, XSS, auth bypass, data exposure, SSRF. Check every user input path.
   - **Performance:** O(n) analysis on loops and data structures. Database query patterns. Memory allocation.
   - **Architecture:** Does the code fit the system design? Are boundaries respected? Are interfaces clean?
   - **Maintainability:** Can someone else understand this in 6 months? Are names descriptive? Is complexity justified?
   - **Testing:** Are tests adequate? Do they cover happy path AND failure modes?
3. **Be specific** — cite exact line numbers, explain WHY something is wrong, suggest a concrete fix
4. **Don't nitpick style** unless it violates established project conventions
5. **Score the review** 0-10 reflecting overall quality

## Output Format

```yaml
artifact_type: code_review_result
task_id: "{referenced task ID}"
reviewer_level: "L5|L6"
verdict: "approved|changes_requested|rejected"
score: 7  # 0-10
summary: "One-paragraph overall assessment"
issues:
  - severity: "critical|warning|info"
    category: "correctness|security|performance|architecture|maintainability|testing"
    file: "src/path/to/file.ts"
    line: 42
    message: "What is wrong"
    suggestion: "How to fix it"
  - severity: "critical"
    category: "security"
    file: "src/auth/handler.ts"
    line: 18
    message: "SQL injection via unsanitized user input"
    suggestion: "Use parameterized query: db.query('SELECT * FROM users WHERE id = $1', [userId])"
strengths:
  - "Good separation of concerns"
  - "Tests cover edge cases"
blocking_issues_count: 0  # number of critical issues that must be fixed
```
