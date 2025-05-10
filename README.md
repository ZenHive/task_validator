# TaskValidator

A library for validating Markdown task lists against a structured format specification.

## Installation

Add `task_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:task_validator, "~> 0.1.0"}
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

- Task IDs must follow the SSH#### pattern
- Each task must have required sections (Description, Status, Priority, etc.)
- Tasks marked as "In Progress" must have subtasks
- Review ratings must follow the specified format (1-5 scale)

## License

MIT License

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/task_validator>.
