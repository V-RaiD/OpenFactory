# feature-development.lobster
# Engineering sub-pipeline: implements a single task through code, test, review, merge.
# Called by idea-to-launch.lobster for each task in the breakdown.

args:
  task_id:
    type: string
    required: true
    description: "Unique identifier for the task"
  task_description:
    type: string
    required: true
    description: "Full description of what needs to be implemented"
  architecture_context:
    type: string
    required: true
    description: "System design context for architectural consistency"
  assignee_agent:
    type: string
    required: true
    description: "Agent ID assigned to implement this task"

steps:

  - id: setup-branch
    name: "Create Feature Branch"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "{{args.assignee_agent}}",
        "message": "Create a feature branch named feature/{{args.task_id}} from the latest main branch. Confirm the branch is created and checked out."
      }'

  - id: dev-loop
    name: "Implement, Test & Review Loop"
    loop:
      maxIterations: 5
      condition: "$review-code.json.approved != true"
    steps:

      - id: implement-task
        name: "Implement the Feature"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "{{args.assignee_agent}}",
            "message": "Implement the following task. Write clean, well-documented code that follows the system architecture.\n\nTask ID: {{args.task_id}}\nTask Description: {{args.task_description}}\nArchitecture Context: {{args.architecture_context}}\n\nIf this is a revision, address the previous feedback:\n$review-code.json.feedback"
          }'
        timeout: 900

      - id: write-tests
        name: "Write Tests"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "{{args.assignee_agent}}",
            "message": "Write comprehensive tests for the implementation of task {{args.task_id}}. Include: unit tests for all functions/methods, edge case tests, integration tests if the task touches multiple components, and error handling tests. Aim for >90% coverage of new code."
          }'
        timeout: 600

      - id: run-tests
        name: "Execute Tests"
        command: >
          openclaw.invoke --tool sessions-spawn --args-json '{
            "agent": "qa-engineer",
            "prompt": "Run all tests for the feature branch feature/{{args.task_id}}. Execute unit tests, integration tests, and linting checks. Return JSON with {\"passed\": N, \"failed\": N, \"skipped\": N, \"coverage_pct\": N, \"lint_errors\": N, \"failures\": [{\"test\": \"...\", \"error\": \"...\"}], \"all_passed\": true/false}.",
            "model": "anthropic/claude-sonnet"
          }'
        timeout: 600

      - id: tests-check
        name: "Check Test Results"
        condition: "$run-tests.json.all_passed != true"
        command: >
          openclaw.invoke --tool sessions-send --args-json '{
            "agent": "{{args.assignee_agent}}",
            "message": "Tests failed. Fix the following failures and re-run:\n\n$run-tests.json.failures\n\nLint errors: $run-tests.json.lint_errors"
          }'

      - id: review-code
        name: "Code Review"
        condition: "$run-tests.json.all_passed == true"
        command: >
          openclaw.invoke --tool sessions-spawn --args-json '{
            "agent": "tech-lead",
            "prompt": "Review the code for task {{args.task_id}} on branch feature/{{args.task_id}}. Evaluate: correctness, adherence to architecture, code quality, test coverage, security, performance. Return JSON with {\"approved\": true/false, \"feedback\": \"...\", \"severity\": \"nitpick|minor|major|blocking\", \"comments\": [{\"file\": \"...\", \"line\": N, \"comment\": \"...\"}]}.\n\nArchitecture context: {{args.architecture_context}}\nTest results: $run-tests.json",
            "model": "anthropic/claude-sonnet"
          }'

  - id: stuck-detection
    name: "Check for Stuck Loop"
    condition: "$dev-loop.iterations >= 5 && $review-code.json.approved != true"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "tech-lead",
        "message": "Task {{args.task_id}} has gone through 5 review iterations without approval. Escalate: either pair-program with the developer to resolve, simplify the requirements, or split the task. Return a recommended action."
      }'

  - id: merge
    name: "Merge to Main"
    condition: "$review-code.json.approved == true"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "{{args.assignee_agent}}",
        "message": "Code review approved. Merge feature/{{args.task_id}} into main. Squash commits with message: [{{args.task_id}}] {{args.task_description}}. Delete the feature branch after merge. Confirm merge was successful."
      }'

  - id: merge-verify
    name: "Verify Merge"
    condition: "$review-code.json.approved == true"
    command: >
      openclaw.invoke --tool sessions-send --args-json '{
        "agent": "qa-engineer",
        "message": "Run the full test suite on main after merging task {{args.task_id}} to verify no regressions were introduced. Return JSON with {\"regression_detected\": true/false, \"details\": \"...\"}."
      }'
