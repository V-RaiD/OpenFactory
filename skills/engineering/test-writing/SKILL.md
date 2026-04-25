---
name: "test-writing"
description: "Write comprehensive test suites covering happy paths, edge cases, and failure modes"
version: "1.0.0"
category: "engineering"
min_level: "L3"
models:
  preferred_order:
    - id: "anthropic/claude-sonnet-4-6"
      reason: "Excellent structured test output, cost-effective for high-volume test generation"
    - id: "openai/gpt-5.4"
      reason: "Strong test generation with good coverage of edge cases"
    - id: "deepseek/deepseek-v3"
      reason: "Competitive open-source test generation, understands testing patterns well"
triggers: ["write tests", "add tests", "test coverage", "unit tests", "integration tests"]
input_artifacts: ["code_artifact", "task_breakdown", "api_specification"]
output_artifacts: ["code_artifact"]
allowed_commands: ["npm test", "pytest", "go test", "cargo test", "jest", "vitest", "rg", "cat", "ls"]
blocked_commands: ["rm", "git push", "sudo", "curl"]
max_iterations: 3
token_budget: 60000
metadata:
  openclaw:
    requires:
      bins: ["git"]
---

# Skill: Test Writing

## Context Constraints

### [L3] Junior Test Bounds
- Write unit tests ONLY for the files specified in the task
- Follow existing test patterns exactly (framework, naming, structure)
- Minimum coverage: every public function must have at least one happy-path and one error-path test
- Do NOT mock infrastructure unless the existing tests already do so

### [L5] Senior Test Bounds
- Write integration tests spanning multiple modules
- Design test fixtures and factories
- May add new test utilities if they reduce duplication across 3+ test files

## Instructions

1. **Read the source code** — understand every public function, its inputs, outputs, and error conditions
2. **Read existing tests** — match the framework (Jest, pytest, Go testing, etc.), naming conventions, and patterns
3. **Design test cases** using this matrix for each function:
   - Happy path (normal input → expected output)
   - Boundary values (empty input, max values, zero, negative)
   - Error cases (invalid input, missing required fields, null/undefined)
   - Edge cases (concurrent access, Unicode, very large payloads)
4. **Write tests** following the Arrange-Act-Assert pattern:
   ```
   // Arrange: set up test data and dependencies
   // Act: call the function under test
   // Assert: verify the result
   ```
5. **Run the tests** — verify they pass
6. **Check coverage** — ensure no obvious paths are missed

## Output Format

```yaml
artifact_type: code_artifact
task_id: "{referenced task ID}"
test_suite: true
files:
  - path: "tests/path/to/file.test.ts"
    language: "typescript"
    content: |
      // test file content
    action: "create"
test_framework: "jest|pytest|go_testing|cargo_test"
test_count: 12
coverage_targets:
  - file: "src/path/to/file.ts"
    functions_tested: ["functionA", "functionB"]
    paths_covered: ["happy", "error", "edge"]
all_tests_passing: true
```
