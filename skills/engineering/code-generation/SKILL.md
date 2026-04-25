---
name: "code-generation"
description: "Generate production-quality code from task specs and system design documents"
version: "1.0.0"
category: "engineering"
min_level: "L3"
models:
  preferred_order:
    - id: "anthropic/claude-opus-4-6"
      reason: "Best code quality, lowest defect rate, understands complex requirements with minimal clarification"
    - id: "openai/gpt-5.4"
      reason: "Strong coding across all languages, excellent at following patterns from existing codebase"
    - id: "deepseek/deepseek-v3"
      reason: "Top open-source coder, competitive with frontier models on standard implementation tasks"
triggers: ["write code", "implement", "build feature", "code this", "generate code"]
input_artifacts: ["task_breakdown", "system_design", "api_specification"]
output_artifacts: ["code_artifact"]
allowed_commands: ["git status", "git diff", "git add", "git commit", "npm install", "npm run build", "npm run lint", "pip install", "pip freeze", "python", "node", "npx", "cargo build", "cargo check", "go build", "go vet", "mkdir", "touch", "ls", "cat", "rg"]
blocked_commands: ["rm -rf", "curl|sh", "wget|bash", "sudo", "ssh", "scp", "chmod 777", "git push --force", "git reset --hard", "DROP TABLE", "TRUNCATE"]
max_iterations: 5
token_budget: 80000
metadata:
  openclaw:
    requires:
      bins: ["git", "node", "python3"]
---

# Skill: Code Generation

## Context Constraints

### [L3] Junior Autonomy Bounds
- Read ONLY the specific file paths provided in the task assignment
- Generate code for a single file or a tightly-scoped function
- Do NOT import from modules outside the task scope without explicit approval
- Do NOT refactor existing code — only write new code to satisfy the task
- Output the complete file content, not just a diff
- Always include inline comments explaining non-obvious logic
- If the task is ambiguous, STOP and escalate to your reporting senior — do not guess

### [L4] Mid Autonomy Bounds
- May read related modules to understand interfaces and types
- May create up to 3 new files if the task requires it
- May install packages from the approved list (check package.json or requirements.txt conventions)
- Must write unit tests for every public function created

### [L5] Senior Autonomy Bounds
- Full read access to the repository
- May refactor adjacent code if it directly improves the implementation
- May create new modules, but must document the rationale
- Must consider performance, security, and maintainability tradeoffs
- Must update existing tests if behavior changes

## Instructions

1. **Read the task specification** — understand the exact requirements, acceptance criteria, and constraints
2. **Read the system design document** — understand where your code fits in the architecture, what interfaces it must implement
3. **Read existing code** — understand the project's conventions (naming, structure, patterns, test style)
4. **Plan before writing** — outline the approach in a brief comment block at the top of your output
5. **Write the code** following project conventions:
   - Match the existing code style exactly (indentation, naming, imports)
   - Use the language and framework specified in the system design
   - Handle errors at system boundaries (user input, API calls, file I/O)
   - Do NOT add speculative abstractions or features not in the task spec
6. **Write tests** — unit tests for every public function, edge cases for business logic
7. **Verify** — run linter and type checker if available, fix any issues

## Output Format

```yaml
artifact_type: code_artifact
version: "1.0.0"
task_id: "{referenced task ID}"
files:
  - path: "src/path/to/file.ts"
    language: "typescript"
    content: |
      // full file content here
    action: "create"  # create | modify | delete
  - path: "tests/path/to/file.test.ts"
    language: "typescript"
    content: |
      // test file content
    action: "create"
dependencies_added:
  - name: "package-name"
    version: "^1.2.3"
    reason: "needed for X"
tests_included: true
build_verified: true  # did you run the build?
notes: "Brief explanation of approach taken"
```
