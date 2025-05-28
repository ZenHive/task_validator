# Configuration Guide

The TaskValidator library supports extensive configuration options to customize validation rules according to your project's needs.

## Setting Up Configuration

Configuration is managed through Elixir's application environment. Add your custom settings to your `config/config.exs` file:

```elixir
# config/config.exs
config :task_validator,
  valid_statuses: ["Planning", "Active", "Done", "Paused"],
  max_functions_per_module: 7,
  category_ranges: %{
    "infrastructure" => {1, 50},
    "business_logic" => {51, 150},
    "ui" => {151, 250},
    "testing" => {251, 350}
  }
```

## Available Configuration Options

### Validation Rules

#### `:valid_statuses`
- **Type**: List of strings
- **Default**: `["Planned", "In Progress", "Review", "Completed", "Blocked"]`
- **Description**: Defines the allowed status values for tasks

Example:
```elixir
config :task_validator,
  valid_statuses: ["Todo", "Doing", "Done", "Cancelled"]
```

#### `:valid_priorities`
- **Type**: List of strings
- **Default**: `["Critical", "High", "Medium", "Low"]`
- **Description**: Defines the allowed priority values for tasks

Example:
```elixir
config :task_validator,
  valid_priorities: ["P0", "P1", "P2", "P3", "P4"]
```

#### `:id_regex`
- **Type**: Regular expression
- **Default**: `~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/`
- **Description**: Pattern for validating task IDs

Example:
```elixir
config :task_validator,
  id_regex: ~r/^PROJ-\d{4}(-\d+)?$/  # Matches PROJ-0001, PROJ-0001-1
```

#### `:rating_regex`
- **Type**: Regular expression
- **Default**: `~r/^([1-5](\.\d)?)\s*(\(partial\))?$/`
- **Description**: Pattern for validating review ratings

### Code Quality KPIs

#### `:max_functions_per_module`
- **Type**: Positive integer
- **Default**: `5`
- **Description**: Maximum allowed functions per module

#### `:max_lines_per_function`
- **Type**: Positive integer
- **Default**: `15`
- **Description**: Maximum allowed lines per function

#### `:max_call_depth`
- **Type**: Positive integer
- **Default**: `2`
- **Description**: Maximum allowed call depth

Example:
```elixir
config :task_validator,
  max_functions_per_module: 10,
  max_lines_per_function: 20,
  max_call_depth: 3
```

### Task Categories

#### `:category_ranges`
- **Type**: Map of string keys to `{min, max}` integer tuples
- **Default**: 
  ```elixir
  %{
    "core" => {1, 99},
    "features" => {100, 199},
    "documentation" => {200, 299},
    "testing" => {300, 399}
  }
  ```
- **Description**: Defines number ranges for task categories

Example:
```elixir
config :task_validator,
  category_ranges: %{
    "backend" => {1000, 1999},
    "frontend" => {2000, 2999},
    "devops" => {3000, 3999},
    "qa" => {4000, 4999}
  }
```

## Advanced Usage

### Runtime Configuration

You can access configuration values programmatically:

```elixir
# Get a specific configuration value
statuses = TaskValidator.Config.get(:valid_statuses)

# Get all configuration as a map
all_config = TaskValidator.Config.get_all()
```

### Validation

The configuration module validates all settings when accessed:

```elixir
# This will raise if the configuration is invalid
TaskValidator.Config.get(:max_functions_per_module)
```

### Testing with Different Configurations

You can override configuration in your test environment:

```elixir
# config/test.exs
config :task_validator,
  max_functions_per_module: 3,
  max_lines_per_function: 10
```

## Common Configuration Scenarios

### Strict Quality Standards

```elixir
config :task_validator,
  max_functions_per_module: 3,
  max_lines_per_function: 10,
  max_call_depth: 1
```

### Enterprise Project Structure

```elixir
config :task_validator,
  id_regex: ~r/^[A-Z]{2,6}-\d{6}(-\d+)?$/,  # DEV-202401, INFRA-202402-1
  valid_statuses: ["Backlog", "Sprint", "In Progress", "Code Review", "QA", "Done"],
  valid_priorities: ["Blocker", "Critical", "Major", "Minor", "Trivial"],
  category_ranges: %{
    "architecture" => {100000, 199999},
    "implementation" => {200000, 299999},
    "optimization" => {300000, 399999},
    "maintenance" => {400000, 499999}
  }
```

### Agile Team Workflow

```elixir
config :task_validator,
  valid_statuses: ["Icebox", "Ready", "In Dev", "In Review", "Deployed"],
  valid_priorities: ["Must Have", "Should Have", "Could Have", "Won't Have"]
```

## Best Practices

1. **Start with defaults**: Only configure what differs from the standard behavior
2. **Document your choices**: Add comments explaining why certain limits were chosen
3. **Be consistent**: Use configuration that aligns with your team's workflow
4. **Version control**: Always commit configuration changes with clear messages
5. **Test configuration**: Verify that your custom configuration works as expected

## Troubleshooting

### Invalid Configuration Errors

If you see errors like:
```
** (ArgumentError) Invalid configuration for max_functions_per_module: must be a positive integer
```

Check that:
- The value type matches the expected type
- Numeric values are positive integers where required
- Regular expressions are properly formatted
- Maps have the correct structure

### Configuration Not Taking Effect

Ensure you:
1. Have recompiled your project after configuration changes
2. Are setting configuration in the correct environment file
3. Haven't accidentally overridden configuration elsewhere

### Performance Considerations

Configuration values are validated on access. For performance-critical code, consider caching configuration values:

```elixir
defmodule MyModule do
  @statuses TaskValidator.Config.get(:valid_statuses)
  
  def validate_status(status) do
    status in @statuses
  end
end
```