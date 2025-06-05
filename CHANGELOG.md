# Changelog

## v0.9.2 (2025-06-05)

### Added
- **llm.txt** - Machine-readable instructions for LLMs
  - Comprehensive guide for AI assistants using the library
  - Quick reference for validation rules and formats
  - Common error solutions and best practices
  - API usage examples and patterns

### Improved
- **Test Requirements Philosophy** - Emphasize integration-first testing
  - Updated all test requirement references to promote testing against real dependencies first
  - Document actual behavior before creating any mocks
  - Extract unit tests from integration test observations
  - Emphasizes that unrealistic mocks are worse than no tests

## v0.9.1 (2025-06-05)

### Added
- **BUG001 Fix**: Corrected subtask content parsing in MarkdownParser
  - Subtasks now properly capture all content between headers
  - Both numbered (#### format) and checkbox formats work correctly
  
- **BUG002 Fix**: Enhanced all templates with proper subtask examples  
  - All 6 category templates now include comprehensive subtask demonstrations
  - Templates show both numbered and checkbox subtask formats
  - Parent tasks with subtasks correctly show "In Progress" status
  - All templates now pass validation

- **Mix Task Improvements**
  - Created Mix.Tasks.TaskValidator as main entry point
  - Enhanced help documentation with detailed examples
  - Fixed naming inconsistency (all tasks now appear in `mix help`)
  - Added @shortdoc attributes for better discoverability

### Fixed
- Subtask content extraction not capturing full content between headers
- Template generation missing proper subtask examples
- Confusing Mix task naming structure  
- Missing documentation files referenced in README and mix.exs

### Documentation
- Recreated missing guides/ directory with comprehensive documentation
- Updated CHANGELOG to reflect actual project state
- Fixed broken references throughout the codebase

## v0.9.0 (2025-06-04)

### Features

- **Major Architecture Refactoring** - Transformed monolithic validator into modular pipeline architecture
  - Split parsing and validation into separate concerns (MarkdownParser, ReferenceResolver, TaskExtractor)
  - Created 8 specialized validators with behavior-based interface
  - Added ValidationPipeline for coordinated validation with priority ordering
  - New API functions: `validate_file_with_pipeline/2` and `validate_file_detailed/1`
  - Maintains 100% backward compatibility with existing `validate_file/1` API

- **Enhanced Elixir/Phoenix Support** - Added specialized validation for Elixir/Phoenix projects
  - 6 semantic task categories with ID ranges (OTP: 1-99, Phoenix: 100-199, etc.)
  - Category-specific required sections and validation rules
  - Elixir-specific KPIs (GenServer state complexity, Phoenix context boundaries, Ecto query complexity)
  - Enhanced error handling templates for each category

- **Complexity-Based KPI Validation** - Flexible code quality limits based on task complexity
  - Tasks can specify `**Complexity Assessment**: Simple|Medium|Complex|Critical`
  - Complexity levels apply multipliers to base KPI limits:
    - Simple: 1x (default)
    - Medium: 1.5x
    - Complex: 2x
    - Critical: 3x
  - Categories have default complexity levels:
    - Testing: Complex (extensive test scenarios)
    - Infrastructure: Complex (deployment complexity)
    - OTP/GenServer: Medium (state management)
    - Phoenix Web: Simple (thin controllers)
    - Business Logic: Medium (domain complexity)
    - Data Layer: Simple (straightforward schemas)
  - KpiValidator automatically determines category from task ID when category not set

### Documentation

- Created comprehensive guides/ directory with:
  - configuration.md - How to configure TaskValidator
  - writing_compliant_tasks.md - Complete guide for writing valid task lists
  - sample_tasklist.md - Full example demonstrating all features
- Created docs/examples/ directory with 6 category-specific examples
- Added docs/examples/README.md explaining subtask formats
- Updated main README with clearer documentation structure
- Added multiple Elixir/Phoenix-specific examples

### Internal Improvements

- Achieved 100% test coverage (165 tests, all passing)
- Clean separation of concerns across 15+ focused modules
- Extensible validator pipeline supporting custom validators
- Improved error messages with detailed context

### Known Issues

- Some category templates (phoenix_web, business_logic, data_layer) may have minor validation issues when generated. These templates work but may need manual adjustments. This will be fixed in a patch release.

## v0.8.1 (2025-05-28)

### Documentation

- Added missing `guides/configuration.md` file that was referenced in README
- Fixed hex docs warning about missing file reference
- Added configuration guide to mix.exs docs extras list

## v0.8.0 (2025-05-28)

### Features

- Added configurable validation system allowing users to customize validation parameters
  - All hardcoded values are now configurable via Application environment
  - New `TaskValidator.Config` module provides centralized configuration access
  - Configurable parameters include:
    - Valid statuses and priorities
    - Task ID regex pattern and rating regex
    - Code quality KPI thresholds (max functions, lines, call depth)
    - Task category ranges for organizing task numbers
  - Configuration validation ensures only valid values are accepted
  - Comprehensive configuration guide added at `guides/configuration.md`

### Bug Fixes

- Fixed test isolation issues by properly clearing Application configuration between tests
- Added setup blocks to ensure clean configuration state for each test run

## v0.7.1 (2025-01-28)

### Bug Fixes

- Fixed test fixture files to comply with validation requirements
  - Added missing reference definitions in `reference_test.md`
  - Added required **Architecture Notes** and **Complexity Assessment** sections to core category tasks
  - Fixed reference examples in comments to avoid validation conflicts
  - Added missing required sections (Simplicity Principle, TypeSpec requirements, etc.) to various test fixtures
- All 31 tests now pass successfully

## v0.7.0 (2025-05-25)

### Breaking Changes

- Changed subtask ID format from letter suffixes to numeric suffixes (e.g., `SSH0001a` → `SSH0001-1`)
- Updated reference syntax from `{{reference-name}}` to `#{{reference-name}}` for better clarity

### Features

- Added checkbox format as the recommended approach for subtasks
  - `- [x] Completed subtask [TASK0001-1]`
  - `- [ ] Pending subtask [TASK0001-2]`
- Both checkbox and numbered formats are now supported, with checkbox being recommended

### Enhancements

- Updated all templates to use the new numeric subtask ID format
- Enhanced documentation to show both subtask formats with clear recommendations
- Updated mix help output to display the new checkbox format examples
- Improved consistency across all documentation files

### Documentation

- Updated `guides/writing_compliant_tasks.md` with new subtask format examples
- Enhanced README.md to show checkbox format as recommended
- Added comprehensive subtask format examples to mix task help

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
