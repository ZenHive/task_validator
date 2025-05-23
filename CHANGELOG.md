# Changelog

## v0.6.0 (2025-05-23)

### Features

- Added support for checkbox-style subtasks (e.g., `- [ ] Subtask a [SSH0001a]`)
- Added Dependencies field validation with cross-reference checking
- Added Code Quality KPIs validation (max functions per module: 5, max lines per function: 15, max call depth: 2)
- Added task category validation with predefined ranges:
  - Core infrastructure: 1-99
  - Features: 100-199
  - Documentation: 200-299
  - Testing: 300-399
- Added category-specific required sections for different task types
- Enhanced template generator with `--category` option for category-specific templates
- Added reference definitions support to reduce repetition in task lists
  - Define reusable content blocks with `## Reference Definitions`
  - Use references in tasks with `{{reference-name}}` syntax
  - Templates now use references for error handling and KPIs
  - Significantly reduces task list file size

### Enhancements

- Improved task ID regex to support letter suffixes for checkbox subtasks
- Enhanced validation to ensure dependencies reference existing tasks
- Added comprehensive category validation rules
- Updated templates to include new required fields and sections

## v0.5.0 (2025-05-19)

### Breaking Changes

- Changed error handling requirements: main tasks and subtasks now have different formats
- Main tasks require comprehensive error handling with GenServer specifics
- Subtasks use simplified error handling focused on task-specific approaches

### Documentation

- Updated all documentation to reflect different error handling requirements
- Added clear examples showing main task vs subtask error handling formats
- Fixed test fixtures and templates to follow the new error handling patterns

## v0.4.1 (2025-05-18)

### Features

- Added validation for completed tasks requiring implementation notes, complexity assessment, and maintenance impact
- Enhanced documentation with examples of required completion sections
- Updated guides with examples of compliant task documentation

## v0.4.0 (2025-05-18)

### Features

- Added `mix create_template` task for generating new task list templates
- Added `mix validate_tasklist` task for validating task lists
- Improved CLI interface with better error handling and user feedback

## v0.3.0 (2024-05-29)

### Enhancements

- Improved module documentation
- Better HexDocs integration
- Added more examples and guides

### Bug Fixes

- Fixed formatting issues in the validator
- Improved error messages for better clarity

## v0.2.1 (2024-05-25)

### Enhancements

- Added support for multi-project prefixes
- Improved validation for subtask prefixes

### Bug Fixes

- Fixed issue with partial review ratings

## v0.1.0 (2024-05-20)

- Initial release
- Basic task validation functionality
- Command-line interface via mix task
