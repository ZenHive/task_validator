# Configuration Guide

The TaskValidator library provides a flexible configuration system that allows you to customize validation parameters to match your project's specific requirements.

## Overview

All configuration is managed through Elixir's Application environment. The `TaskValidator.Config` module provides centralized access to all configuration values with sensible defaults.

## Configuration Options

### Basic Configuration

```elixir
# config/config.exs
config :task_validator,
  valid_statuses: ["Not Started", "Planned", "In Progress", "Completed", "On Hold"],
  valid_priorities: ["High", "Medium", "Low"]
```

### Task ID Format

Customize the regex pattern for task IDs:

```elixir
config :task_validator,
  task_id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+)?$/
```

This default pattern matches:
- Main tasks: `SSH0001`, `ERR001`, `SCP0005`
- Subtasks: `SSH0001-1`, `ERR001-2`

### Review Ratings

Configure the valid review rating format:

```elixir
config :task_validator,
  rating_regex: ~r/^\d+\.\d+\/10$/
```

### Code Quality KPIs

Set thresholds for code quality metrics:

```elixir
config :task_validator,
  kpis: %{
    max_functions_per_module: 5,
    max_lines_per_function: 15,
    max_call_depth: 2
  }
```

### Task Categories

Define task number ranges for different categories:

```elixir
config :task_validator,
  task_categories: %{
    "core" => 1..99,
    "features" => 100..199,
    "documentation" => 200..299,
    "testing" => 300..399
  }
```

## Complete Example

Here's a complete configuration example:

```elixir
# config/config.exs
config :task_validator,
  valid_statuses: ["Not Started", "Planned", "In Progress", "Completed", "On Hold", "Cancelled"],
  valid_priorities: ["Critical", "High", "Medium", "Low"],
  task_id_regex: ~r/^[A-Z]{3}\d{4}(-\d+)?$/,
  rating_regex: ~r/^\d+\.\d+\/10$/,
  kpis: %{
    max_functions_per_module: 7,
    max_lines_per_function: 20,
    max_call_depth: 3
  },
  task_categories: %{
    "infrastructure" => 1..99,
    "api" => 100..199,
    "ui" => 200..299,
    "testing" => 300..399,
    "documentation" => 400..499
  }
```

## Runtime Configuration

You can also configure values at runtime:

```elixir
# Set a single value
Application.put_env(:task_validator, :valid_statuses, ["Draft", "Active", "Done"])

# Set multiple values
Application.put_all_env([
  {:task_validator, :valid_priorities, ["P0", "P1", "P2", "P3"]},
  {:task_validator, :kpis, %{max_functions_per_module: 10}}
])
```

## Configuration Validation

The `TaskValidator.Config` module validates configuration values when accessed:

- Status and priority lists must be non-empty lists of strings
- KPI values must be positive integers
- Task categories must be non-overlapping ranges

Invalid configurations will raise an error with a descriptive message.

## Testing with Configuration

When testing, you may want to temporarily override configuration:

```elixir
defmodule MyTest do
  use ExUnit.Case

  setup do
    # Store original config
    original_statuses = Application.get_env(:task_validator, :valid_statuses)
    
    # Set test config
    Application.put_env(:task_validator, :valid_statuses, ["Test Status"])
    
    on_exit(fn ->
      # Restore original config
      Application.put_env(:task_validator, :valid_statuses, original_statuses)
    end)
    
    :ok
  end
  
  test "validates with custom status" do
    # Your test here
  end
end
```

## Default Values

If no configuration is provided, the following defaults are used:

- **Valid Statuses**: "Not Started", "Planned", "In Progress", "Completed", "On Hold"
- **Valid Priorities**: "High", "Medium", "Low"
- **Task ID Regex**: `^[A-Z]{2,4}\d{3,4}(-\d+)?$`
- **Rating Regex**: `^\d+\.\d+\/10$`
- **Max Functions per Module**: 5
- **Max Lines per Function**: 15
- **Max Call Depth**: 2
- **Task Categories**:
  - core: 1-99
  - features: 100-199
  - documentation: 200-299
  - testing: 300-399

## Best Practices

1. **Use config files** for environment-specific settings
2. **Document your custom configuration** in your project's README
3. **Validate early** by checking configuration at application startup
4. **Keep defaults sensible** to minimize required configuration
5. **Test with different configurations** to ensure flexibility