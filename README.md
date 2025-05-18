# TaskValidator

A library for validating Markdown task lists against a structured format specification.

## Installation

Add `task_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:task_validator, "~> 0.3.0"}
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

The TaskValidator enforces a specific format for task lists:

- Task IDs must follow a consistent pattern: 2-4 uppercase letters followed by 3-4 digits (e.g., SSH0001, SCP0001, ERR001, REF0002)
- Subtasks must use the same prefix as their parent task (e.g., SSH0001-1 for a subtask of SSH0001)
- Each task must have required sections (Description, Status, Priority, etc.)
- Tasks marked as "In Progress" must have subtasks
- Review ratings must follow the specified format (1-5 scale)

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
