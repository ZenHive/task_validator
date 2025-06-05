# Configuration Guide

This guide explains how to configure and use the TaskValidator in your project.

## Installation

Add `task_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:task_validator, "~> 0.9.0"}
  ]
end
```

## Configuration Options

TaskValidator can be configured through your application's config:

```elixir
# config/config.exs
config :task_validator,
  default_path: "docs/TaskList.md",
  strict_mode: true,
  categories: [
    :otp_genserver,
    :phoenix_web,
    :business_logic,
    :data_layer,
    :infrastructure,
    :testing
  ]
```

### Configuration Parameters

- **default_path** - Default file path for task lists (default: "docs/TaskList.md")
- **strict_mode** - Enable strict validation rules (default: true)
- **categories** - List of valid task categories for your project

## Environment-Specific Configuration

You can override configuration for different environments:

```elixir
# config/dev.exs
config :task_validator,
  strict_mode: false  # More lenient validation in development
```

## CLI Configuration

The Mix tasks support command-line options that override configuration:

```bash
# Override default path
mix validate_tasklist --path custom/TaskList.md

# Use semantic prefixes
mix task_validator.create_template --semantic

# Specify category
mix task_validator.create_template --category otp_genserver
```

## Advanced Configuration

### Custom Validators

You can disable specific validators if needed:

```elixir
config :task_validator,
  disabled_validators: [:kpi_validator]
```

### Custom Categories

To add custom categories beyond the default Elixir/Phoenix ones:

```elixir
config :task_validator,
  custom_categories: [
    {:machine_learning, 700..799, "ML"},
    {:blockchain, 800..899, "BC"}
  ]
```

## Validation Levels

TaskValidator supports different validation levels:

1. **Strict** - All rules enforced (default)
2. **Standard** - Common rules enforced, some flexibility
3. **Lenient** - Basic structure validation only

```elixir
config :task_validator,
  validation_level: :strict
```

## Integration with CI/CD

For CI/CD pipelines, you may want stricter validation:

```elixir
# config/test.exs
config :task_validator,
  strict_mode: true,
  fail_on_warnings: true
```

## Troubleshooting

If validation seems incorrect:

1. Check your configuration with `mix task_validator.config`
2. Ensure you're using the correct environment
3. Verify file paths are correct
4. Check for typos in category names

## See Also

- [Writing Compliant Tasks](writing_compliant_tasks.md)
- [Example Task Lists](sample_tasklist.md)
- [README](../README.md) for quick start