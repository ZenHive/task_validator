# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

```bash
# Test commands
mix test                      # Run all tests
mix test test/task_validator_test.exs  # Run specific test file
mix test --only=focus        # Run focused tests

# Lint and format
mix format                   # Format code
mix dialyzer                 # Run type checking

# Documentation
mix docs                     # Generate documentation
mix help task_validator      # Get help for a specific task

# Task validator commands
mix validate_tasklist        # Validate default TaskList.md
mix validate_tasklist --path ./path/to/TaskList.md  # Validate custom file
mix task_validator.create_template  # Create template task list
mix task_validator.create_template --prefix SSH --path ./docs/TaskList.md

# Development
iex -S mix                   # Start interactive shell
```

## Architecture Overview

This is an Elixir library for validating Markdown task lists against structured format specifications. The core architecture consists of:

1. **TaskValidator Module**: The main validation engine that:
   - Parses task lists from Markdown files
   - Validates task ID formats (e.g., SSH0001, SCP0001)
   - Enforces required sections and error handling documentation
   - Ensures subtask consistency with parent task prefixes
   - Validates status values, priorities, and review ratings

2. **Mix Tasks**: Command-line interface for users:
   - `Mix.Tasks.ValidateTasklist`: Validates task list files
   - `Mix.Tasks.TaskValidator.CreateTemplate`: Generates compliant templates

3. **Error Handling Patterns**: Two-tier approach:
   - Main tasks: Comprehensive error handling with GenServer specifics
   - Subtasks: Simplified error handling focused on task-specific approaches

## Key Validation Rules

1. **Task ID Format**: `[A-Z]{2,4}\d{3,4}(-\d+)?`
   - Main tasks: SSH0001, ERR001, SCP0005
   - Subtasks: SSH0001-1, ERR001-2

2. **Error Handling Sections**:
   - Main tasks require full error handling documentation
   - Subtasks use simplified error handling format
   - Different requirements based on task hierarchy level

3. **Task States**:
   - "In Progress" tasks must have subtasks
   - "Completed" tasks need additional sections (implementation notes, complexity assessment, maintenance impact)
   - Completed subtasks require review ratings

4. **Consistency Rules**:
   - Subtask prefixes must match parent task prefix
   - No duplicate task IDs
   - Valid status/priority values only

5. **Reference System** (Content Placeholders):
   - References reduce file size by 60-70% and ensure consistency
   - Definition format: `## #{{reference-name}}`
   - Usage format: `{{reference-name}}`
   - Validator only checks existence, doesn't expand references
   - Common references: `{{error-handling}}`, `{{test-requirements}}`, `{{standard-kpis}}`

## Testing Approach

The project uses ExUnit with specific test patterns:
- Unit tests for validation logic in `test/task_validator_test.exs`
- Test fixtures in `test/fixtures/` for various validation scenarios
- Tests cover both valid and invalid task list formats
- Error handling validation is thoroughly tested

## Working with References

When editing TaskList files that use references:
1. **Don't expand references** - The validator expects `{{reference-name}}` placeholders to remain as-is
2. **Check reference definitions** - Look for `## #{{reference-name}}` sections at the bottom
3. **Use existing references** - Common ones include:
   - `{{error-handling}}` - Main task error handling
   - `{{error-handling-subtask}}` - Subtask error handling  
   - `{{test-requirements}}` - All test-related sections
   - `{{typespec-requirements}}` - All TypeSpec sections
   - `{{standard-kpis}}` - Code quality metrics
   - `{{def-no-dependencies}}` - Standard "None" for dependencies
4. **Add new references** - Define with `## #{{new-reference}}` format

## Important Files

- `lib/task_validator.ex`: Core validation logic
- `lib/mix/tasks/validate_tasklist.ex`: CLI validation task
- `lib/mix/tasks/create_template.ex`: Template generation task
- `guides/writing_compliant_tasks.md`: Documentation on task format
- `docs/example_tasklist_with_references.md`: Complete example using references
- `docs/TaskList.md`: Project's own task list (demonstrates references)
- `test/fixtures/`: Example task lists for testing