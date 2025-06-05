# Release Notes - v0.9.2

## Summary

TaskValidator v0.9.2 is ready for release with comprehensive documentation updates, bug fixes, and new LLM support.

## What's New in v0.9.2

### Added
- **llm.txt** - Machine-readable instructions for AI assistants
  - Comprehensive guide for LLMs to understand and use the library
  - Quick reference for all validation rules and formats
  - Common error patterns and solutions
  - API usage examples and best practices
  - Designed to help AI assistants work effectively with TaskValidator

### Improved
- **Testing Philosophy** - Integration-first approach
  - All test requirement references now emphasize testing against real dependencies first
  - "Document actual behavior before mocking" is a core principle
  - Unit tests should be extracted from integration test observations
  - Specific real-world test scenarios for different task categories
  - Clear message: unrealistic mocks are worse than no tests

## What's New in v0.9.1

### Bug Fixes
- **BUG001**: Fixed subtask content parsing in MarkdownParser
  - Subtasks now properly capture all content between headers
  - Both numbered (#### format) and checkbox formats work correctly
  
- **BUG002**: Enhanced all templates with proper subtask examples  
  - All 6 category templates now include comprehensive subtask demonstrations
  - Templates show both numbered and checkbox subtask formats
  - All templates pass validation

### Documentation
- Created comprehensive `guides/` directory with:
  - `configuration.md` - How to configure TaskValidator
  - `writing_compliant_tasks.md` - Complete guide for writing valid task lists
  - `sample_tasklist.md` - Full example demonstrating all features
- Created `docs/examples/` directory with 6 category-specific examples
- Updated CHANGELOG.md to reflect actual project state
- Fixed all broken documentation references

### Developer Experience
- Created `Mix.Tasks.TaskValidator` as main entry point
- Enhanced help documentation for all Mix tasks  
- Fixed naming inconsistency - all tasks now appear in `mix help`
- Added `@shortdoc` attributes for better discoverability

## Validation Status

All examples and templates pass validation:
- ✅ docs/examples/business_logic_example.md
- ✅ docs/examples/data_layer_example.md
- ✅ docs/examples/infrastructure_example.md
- ✅ docs/examples/otp_genserver_example.md
- ✅ docs/examples/phoenix_web_example.md
- ✅ docs/examples/testing_example.md
- ✅ guides/sample_tasklist.md

## Test Status

All 167 tests pass with 100% success rate.

## Documentation Structure

```
task_validator/
├── README.md                    # Main documentation
├── CHANGELOG.md                 # Version history
├── guides/                      # User guides
│   ├── configuration.md         # Configuration options
│   ├── writing_compliant_tasks.md # Task writing guide
│   └── sample_tasklist.md       # Complete example
├── docs/
│   ├── TaskList.md             # Project's own task list
│   └── examples/               # Category-specific examples
│       ├── README.md           # Examples overview
│       ├── otp_genserver_example.md
│       ├── phoenix_web_example.md
│       ├── business_logic_example.md
│       ├── data_layer_example.md
│       ├── infrastructure_example.md
│       └── testing_example.md
```

## Breaking Changes

None - all changes maintain backward compatibility.

## Migration Guide

No migration needed. Existing task lists will continue to work as before.

## Known Issues

None.

## Next Steps

1. Tag release as v0.9.1
2. Update hex.pm package
3. Announce release

The project is ready for release with comprehensive documentation and all issues resolved.