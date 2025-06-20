# Release Notes - v0.9.5

## Summary

TaskValidator v0.9.5 fixes a compilation error that occurred with Elixir 1.19.0+ due to regex patterns in module attributes.

## What's Fixed in v0.9.5

### Fixed
- **KPI Validator Compilation Error**
  - Fixed "cannot inject attribute into function/macro" error when compiling
  - Moved regex patterns from module attributes to a runtime function
  - Resolves compatibility issues with Elixir 1.19.0-rc.0 and later
  - No changes to validation behavior - purely an internal implementation fix

## Technical Details

The issue occurred because Elixir 1.19.0+ has stricter rules about what can be stored in module attributes when those attributes are used in function bodies. Regex patterns with the `~r` sigil create references that cannot be escaped at compile time.

The fix moves the KPI pattern definitions from a module attribute (`@kpi_patterns`) to a private function (`get_kpi_patterns/0`) that returns the patterns at runtime.

## Upgrade Instructions

Simply update your dependency in `mix.exs`:

```elixir
{:task_validator, "~> 0.9.5"}
```

This is a bug fix release with no breaking changes or behavioral differences.

## Compatibility

- Elixir 1.18.0 and later (including 1.19.0+)
- No changes to the public API
- Fully backward compatible