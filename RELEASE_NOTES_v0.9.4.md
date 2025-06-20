# Release Notes - v0.9.4

## Summary

TaskValidator v0.9.4 adds support for flexible task header formats, making it compatible with more markdown formatting styles.

## What's New in v0.9.4

### Improved
- **Markdown Parser Enhancement** - Support for flexible task header formats
  - Now accepts both `###` and `####` (3 or 4 hashes) for task headers
  - Enables validation of task lists with different markdown formatting styles
  - Fixes compatibility with projects using 4-hash headers for task details
  - No breaking changes - fully backward compatible

## Example

The validator now properly handles both of these task header formats:

```markdown
### SSH0001: Implement SSH Connection Manager
```

```markdown
#### TEST0001: Cloud Test Infrastructure
```

This enhancement makes TaskValidator more flexible and compatible with a wider variety of markdown task list formats.

## Upgrade Instructions

Simply update your dependency in `mix.exs`:

```elixir
{:task_validator, "~> 0.9.4"}
```

No changes are required to existing task lists - this is a backward-compatible enhancement.