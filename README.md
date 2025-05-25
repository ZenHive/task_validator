# TaskValidator

A library for validating Markdown task lists against a structured format specification.

## Installation

Add `task_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:task_validator, "~> 0.6.0"}
  ]
end
```

## Usage

### Command Line

```bash
# Validate the default TaskList.md file
mix validate_tasklist

# Validate a custom file path
mix validate_tasklist --path ./path/to/custom/TaskList.md

# Create a new task list template
mix create_template

# Create a template with custom prefix
mix create_template --prefix SSH

# Create a template for a specific category
mix create_template --category features
mix create_template --category documentation
```

### Programmatic

```elixir
case TaskValidator.validate_file("path/to/tasklist.md") do
  {:ok, message} ->
    IO.puts("Success: #{message}")
  {:error, reason} ->
    IO.puts("Error: #{reason}")
end
```

## Format Specification

The TaskValidator enforces a specific format for task lists with a strong focus on error handling:

- Task IDs must follow a consistent pattern: 2-4 uppercase letters followed by 3-4 digits (e.g., SSH0001, SCP0001, ERR001, REF0002)
- Subtasks can use either numeric suffixes (SSH0001-1) or letter suffixes for checkbox style (SSH0001a)
- Checkbox subtasks are supported: `- [ ] Subtask description [SSH0001a]`
- Dependencies field tracks relationships between tasks
- Code Quality KPIs enforce limits: max 5 functions/module, 15 lines/function, call depth 2
- Task categories with specific number ranges:
  * Core infrastructure: 1-99
  * Features: 100-199
  * Documentation: 200-299
  * Testing: 300-399
- Main tasks and subtasks have different error handling section requirements:
  * Main tasks: Comprehensive error handling documentation including GenServer specifics
  * Subtasks: Simplified error handling focused on task-specific approaches
- Other required sections include Description, Status, Priority, Dependencies, etc.
- Tasks marked as "In Progress" must have subtasks
- Review ratings must follow the specified format (1-5 scale)
- Support for reference definitions to reduce repetition (e.g., {{error-handling-main}})

### Error Handling Requirements

Main tasks must include the following comprehensive error handling sections:

```markdown
**Error Handling**
**Core Principles**
- Pass raw errors
- Use {:ok, result} | {:error, reason}
- Let it crash
**Error Implementation**
- No wrapping
- Minimal rescue
- function/1 & /! versions
**Error Examples**
- Raw error passthrough
- Simple rescue case
- Supervisor handling
**GenServer Specifics**
- Handle_call/3 error pattern
- Terminate/2 proper usage
- Process linking considerations
```

Subtasks have a simplified error handling format:

```markdown
**Error Handling**
**Task-Specific Approach**
- Error pattern for this task
**Error Reporting**
- Monitoring approach
```

### Dependencies

Tasks can specify dependencies on other tasks using the Dependencies field:

```markdown
**Dependencies**
- SSH0001 (Authentication must be complete)
- ERR001 (Error handling framework required)
```

The validator ensures all referenced tasks exist in the task list.

### Checkbox Subtasks

Subtasks can use checkbox format for better visual tracking:

```markdown
## Task Details

### SSH0001: SSH Session Initialization

**Subtasks**
- [x] Connection setup [SSH0001a]
- [ ] Authentication flow [SSH0001b]
- [ ] Session establishment [SSH0001c]
```

### Code Quality KPIs

All tasks must include code quality metrics that adhere to these limits:
- Maximum functions per module: 5
- Maximum lines per function: 15
- Maximum call depth: 2

```markdown
**Code Quality KPIs**
- Functions per module: 3
- Lines per function: 12
- Call depth: 2
```

### Reference Definitions

To reduce repetition in task lists, you can define reusable content blocks:

```markdown
## Reference Definitions

### error-handling-main
**Error Handling**
**Core Principles**
- Pass raw errors
...

### standard-kpis
**Code Quality KPIs**
- Functions per module: 3
...
```

Then use them in tasks with `{{reference-name}}`:

```markdown
### SSH0001: Some task

**Dependencies**
- None

{{standard-kpis}}

{{error-handling-main}}

**Status**: Planned
```

This significantly reduces file size and maintains consistency across tasks.

### Task Categories

Tasks are organized into categories based on their ID number:
- **Core Infrastructure (1-99)**: Essential system components
- **Features (100-199)**: User-facing functionality
- **Documentation (200-299)**: Documentation tasks
- **Testing (300-399)**: Test implementation

Each category has specific required sections. For example, feature tasks require:
- Feature Specification
- User Impact
- Integration Points

Documentation tasks require:
- Documentation Scope
- Target Audience
- Related Documents

## Multi-Project Support

The task validator supports multiple project prefixes in the same task list. Each prefix typically represents a different component or subproject:

```markdown
## Current Tasks

| ID      | Description          | Status      | Priority |
| ------- | -------------------- | ----------- | -------- |
| SSH0001 | SSH authentication   | In Progress | High     |
| SCP0001 | File transfer module | Planned     | Medium   |
| ERR001  | Error handling       | In Progress | High     |
```

The validator ensures consistency within each task hierarchy, so a task with ID "SSH0001" must have subtasks with IDs like "SSH0001-1", "SSH0001-2", etc.

## Example Files

The repository includes several example files in the `test/fixtures` directory:

- `sample_tasklist.md` - A basic valid task list
- `multi_prefix_tasklist.md` - A valid task list with multiple project prefixes
- `prefix_mismatch.md` - Demonstrates prefix mismatch validation (subtask has different prefix than parent)
- `invalid_rating.md` - Shows validation of review rating format
- `invalid_mix_prefixes.md` - Contains various validation errors

You can test validation against these examples:

```bash
mix validate_tasklist --path test/fixtures/multi_prefix_tasklist.md  # Should pass
mix validate_tasklist --path test/fixtures/prefix_mismatch.md        # Should fail
```

## License

MIT License

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/task_validator>.
