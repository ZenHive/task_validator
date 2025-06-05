# TaskValidator

A library for validating Markdown task lists against a structured format specification, with enhanced support for Elixir/Phoenix projects.

## Installation

Add `task_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:task_validator, "~> 0.9.0"}
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
mix task_validator.create_template

# Create a template with custom prefix
mix task_validator.create_template --prefix SSH

# Create a template for a specific category (Elixir/Phoenix categories)
mix task_validator.create_template --category otp_genserver
mix task_validator.create_template --category phoenix_web
mix task_validator.create_template --category testing

# Use semantic prefixes automatically
mix task_validator.create_template --semantic --category phoenix_web
```

### Programmatic

```elixir
# Simple validation
case TaskValidator.validate_file("path/to/tasklist.md") do
  {:ok, message} ->
    IO.puts("Success: #{message}")
  {:error, reason} ->
    IO.puts("Error: #{reason}")
end

# Detailed validation with custom validators
validators = [
  TaskValidator.Validators.IdValidator,
  TaskValidator.Validators.StatusValidator,
  TaskValidator.Validators.KpiValidator
]

case TaskValidator.validate_file_with_pipeline("path/to/tasklist.md", validators) do
  {:ok, result} ->
    IO.puts("Valid: #{result.valid?}")
    IO.puts("Warnings: #{length(result.warnings)}")
  {:error, reason} ->
    IO.puts("Error: #{reason}")
end
```

## Configuration

TaskValidator supports extensive configuration options. You can customize validation rules by adding settings to your `config/config.exs`:

```elixir
config :task_validator,
  valid_statuses: ["Todo", "Doing", "Done"],
  max_functions_per_module: 7,
  max_lines_per_function: 20
```

See the [Configuration Guide](guides/configuration.md) for all available options.

## Format Specification

The TaskValidator enforces a specific format for task lists with a strong focus on error handling:

- Task IDs must follow a consistent pattern: 2-4 uppercase letters followed by 3-4 digits (e.g., SSH0001, SCP0001, ERR001, REF0002)
- Subtasks use numeric suffixes (SSH0001-1, SSH0001-2, etc.)
- Checkbox format is recommended for subtasks: `- [x] Completed task [SSH0001-1]` or `- [ ] Pending task [SSH0001-2]`
- Dependencies field tracks relationships between tasks
- Code Quality KPIs with complexity-based limits:
  * Base limits: max 8 functions/module, 15 lines/function, call depth 3
  * Complexity multipliers: Simple (1x), Medium (1.5x), Complex (2x), Critical (3x)
  * Categories have default complexity levels (e.g., Testing: Complex)
- Task categories for Elixir/Phoenix projects:
  * OTP/GenServer: 1-99 (OTP, GEN, SUP prefixes)
  * Phoenix Web: 100-199 (PHX, WEB, LV prefixes)
  * Business Logic: 200-299 (CTX, BIZ, DOM prefixes)
  * Data Layer: 300-399 (DB, ECT, MIG prefixes)
  * Infrastructure: 400-499 (INF, DEP, ENV prefixes)
  * Testing: 500-599 (TST, TES, INT prefixes)
- Main tasks and subtasks have different error handling section requirements:
  * Main tasks: Comprehensive error handling documentation including GenServer specifics
  * Subtasks: Simplified error handling focused on task-specific approaches
- Other required sections include Description, Status, Priority, Dependencies, etc.
- Tasks marked as "In Progress" must have subtasks
- Review ratings must follow the specified format (1-5 scale)
- Support for reference definitions to reduce repetition by 60-70% (e.g., {{error-handling}}, {{test-requirements}})

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

### Subtask Formats

Subtasks can be organized in two formats:

**Checkbox Format (Simplified):**
```markdown
### SSH0001: SSH Session Initialization

**Subtasks**
- [x] Implement password authentication [SSH0001a]
- [ ] Add key-based authentication [SSH0001b]
- [ ] Implement host verification [SSH0001c]
```

This format provides immediate visual feedback on task progress and is ideal for minor subtasks or quick checklists.

**Numbered Format (Full sections):**
```markdown
#### 1. Implement password authentication (SSH0001-1)
**Description**
Create password-based authentication mechanism with secure credential handling

**Status**
Completed

**Review Rating**
4.5

{{error-handling-subtask}}
```

The numbered format is recommended for significant subtasks that need detailed tracking. Both formats are valid and can be mixed within the same task list. See `docs/examples/` for complete working examples demonstrating both formats.

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

### Reference Definitions (Content Placeholders)

References are a powerful feature to reduce file size by 60-70% while maintaining consistency. They work as content placeholders that the validator recognizes but doesn't expand.

Define references at the end of your task list:

```markdown
## References

## #{{error-handling}}
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

## #{{standard-kpis}}
**Code Quality KPIs**
- Functions per module: ≤ 10
- Lines per function: ≤ 20
- Call depth: ≤ 3
```

Then use them in tasks with `{{reference-name}}`:

```markdown
### SSH0001: Implement SSH connection module

**Description**: Create core SSH connection module
**Requirements**: TCP connection, SSH handshake
{{test-requirements}}
{{typespec-requirements}}
{{def-no-dependencies}}
{{standard-kpis}}
{{error-handling}}
**Status**: In Progress
**Priority**: High
```

Key points about references:
- **Definition format**: `## #{{reference-name}}` (note the `#`)
- **Usage format**: `{{reference-name}}` (no `#`)
- **Common references**: `{{error-handling}}`, `{{error-handling-subtask}}`, `{{test-requirements}}`, `{{typespec-requirements}}`, `{{standard-kpis}}`, `{{def-no-dependencies}}`
- **Validation**: The validator only checks that references exist, expansion is done by AI tools
- **Flexibility**: References can replace entire sections or multiple sections at once

See `/docs/example_tasklist_with_references.md` for a complete working example.

### Task Categories

For Elixir/Phoenix projects, tasks are organized into semantic categories:

| Category | ID Range | Prefix | Description |
| --- | --- | --- | --- |
| OTP/GenServer | 0001-0099 | OTP | Process management, supervisors, state machines |
| Phoenix Web | 0100-0199 | PHX | Controllers, LiveView, routes, plugs |
| Business Logic | 0200-0299 | CTX | Contexts, domain logic, business rules |
| Data Layer | 0300-0399 | DB | Schemas, migrations, queries, repos |
| Infrastructure | 0400-0499 | INF | Deployment, monitoring, configuration |
| Testing | 0500-0599 | TST | Test implementation, coverage, CI/CD |

Each category has specific required sections tailored to its domain. For example:
- **OTP tasks**: Process Design, State Management, Supervision Strategy
- **Phoenix tasks**: Route Design, Context Integration, Template/Component Strategy
- **Data tasks**: Schema Design, Migration Strategy, Query Optimization

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

The repository includes several example files:

### Complete Task List Examples (`docs/examples/`)

Full working examples for different project categories:

- `otp_genserver_example.md` - OTP/GenServer tasks with supervision patterns
- `phoenix_web_example.md` - Phoenix web development tasks (LiveView, controllers)
- `business_logic_example.md` - Phoenix contexts and business logic tasks
- `data_layer_example.md` - Ecto schemas and database design tasks
- `infrastructure_example.md` - Deployment and infrastructure tasks
- `testing_example.md` - Comprehensive testing strategy tasks

Each example demonstrates proper subtask formatting, including both numbered subtasks with full sections and checkbox format for minor items. See `docs/examples/README.md` for detailed explanations.

### Test Fixtures (`test/fixtures/`)

Validation test cases:

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
