# Task Validator Development Task List

<!-- AI INSTRUCTION: This document uses content references to reduce repetition -->
<!-- When you see "DEF: Standard Error Handling", substitute content from #def-error-handling -->
<!-- When you see "DEF: Standard KPI Limits", substitute content from #def-kpi-limits -->
<!-- When you see "DEF: No Dependencies", substitute content from #def-no-dependencies -->

## Current Tasks

| ID      | Description                                           | Status      | Priority | Assignee | Review Rating |
| ------- | ----------------------------------------------------- | ----------- | -------- | -------- | ------------- |
| VAL0001 | Support AI-Friendly Content References                | In Progress | High     |          |               |
| VAL0001-1 | ├─ Update validator to recognize def- sections      | Planned     | High     |          |               |
| VAL0001-2 | ├─ Implement reference expansion in validation      | Planned     | High     |          |               |
| VAL0001-3 | └─ Add tests for reference format                   | Planned     | Medium   |          |               |
| VAL0002 | Update Template Generator for New Format              | Planned     | Medium   |          |               |
| VAL0003 | Create Migration Guide for Existing Task Lists        | Planned     | Low      |          |               |

## Task Details

### VAL0001: Support AI-Friendly Content References

**Description**: Enhance the task validator to support content references that reduce repetition while remaining AI-editor friendly. This allows task lists to use references like "DEF: Standard Error Handling" which AI editors can expand using definitions at the end of the file.

**Simplicity Progression Plan**:
1. Parse def- sections at end of file
2. Build reference map during validation
3. Expand references when validating sections
4. Maintain backward compatibility

**Simplicity Principle**: Keep the reference system simple - just string replacement during validation, no complex templating.

**Abstraction Evaluation**:
- **Challenge**: How to reduce repetition without making files unreadable for AI?
- **Minimal Solution**: Simple reference definitions with clear AI instructions
- **Justification**: Reduces file size by 60-70% while keeping content accessible

**Requirements**:
- Support #def-{name} section headers
- Expand references during validation
- Maintain human readability
- Clear AI instructions at top

**ExUnit Test Requirements**:
- Test reference extraction
- Test reference expansion
- Test validation with references
- Test missing reference handling

**Integration Test Scenarios**:
- Validate files with references
- Ensure backward compatibility
- Test error messages with references
- Validate nested references

**Typespec Requirements**:
- Update validate_file/1 spec
- Add reference-related type specs
- Document reference format

**TypeSpec Documentation**:
- Document reference format in moduledoc
- Example of reference usage
- Reference naming conventions

**TypeSpec Verification**:
- Run dialyzer on updated code
- Verify type consistency
- Test with invalid references

**Error Handling**: DEF: Standard Error Handling

**Code Quality KPIs**:
- Lines of code: ~100 lines (validator enhancement)
- DEF: Standard KPI Limits

**Dependencies**: DEF: No Dependencies

**Architecture Notes**:
- References are expanded during validation only
- Original file remains unchanged
- References can contain any valid markdown

**Status**: In Progress
**Priority**: High

#### 1. Update validator to recognize def- sections (VAL0001-1)

**Description**: Modify extract_references/1 to recognize sections with #def- prefix as reference definitions.

**Error Handling**: DEF: Standard Error Handling

**Task-Specific Approach**:
- Parse sections starting with ## def-
- Store content until next section
- Build reference map

**Error Reporting**:
- Log duplicate reference definitions
- Report invalid reference names

**Status**: Planned

#### 2. Implement reference expansion in validation (VAL0001-2)

**Description**: Update validation logic to expand "Standard X" references using the reference map.

**Error Handling**: DEF: Standard Error Handling

**Task-Specific Approach**:
- Pattern match on "Standard {Name}"
- Look up in reference map
- Substitute during validation

**Error Reporting**:
- Report missing references
- Show which task uses invalid reference

**Status**: Planned

#### 3. Add tests for reference format (VAL0001-3)

**Description**: Create comprehensive tests for the new reference system.

**Error Handling**: DEF: Standard Error Handling

**Task-Specific Approach**:
- Test valid reference files
- Test missing references
- Test validation with expansion

**Error Reporting**:
- Clear test failure messages
- Show actual vs expected

**Status**: Planned

### VAL0002: Update Template Generator for New Format

**Description**: Modify mix task create_template to generate task lists using the new reference format, reducing repetition in generated templates.

**Simplicity Progression Plan**:
1. Update template strings
2. Add reference definitions section
3. Use references in generated tasks
4. Test generated templates

**Simplicity Principle**: Generated templates should demonstrate best practices for the reference system.

**Abstraction Evaluation**:
- **Challenge**: How much should templates use references?
- **Minimal Solution**: Use references for truly repetitive content only
- **Justification**: Balance between file size and readability

**Requirements**:
- Generate AI instruction header
- Include common reference definitions
- Use references in task sections
- Maintain template readability

**ExUnit Test Requirements**:
- Test template generation
- Validate generated templates
- Test with different categories
- Ensure references are valid

**Integration Test Scenarios**:
- Generate and validate template
- Test all category types
- Verify reference usage
- Check AI instructions

**Typespec Requirements**:
- Update run/1 spec if needed
- Document new options
- Type specs for references

**TypeSpec Documentation**:
- Document reference usage in templates
- Example generated output
- Template customization

**TypeSpec Verification**:
- Validate generated templates
- Check type consistency
- Test edge cases

**Error Handling**: DEF: Standard Error Handling

**Code Quality KPIs**:
- Lines of code: ~80 lines (template updates)
- DEF: Standard KPI Limits

**Dependencies**: VAL0001

**Architecture Notes**:
- Templates demonstrate reference best practices
- Include most common references
- Keep generated files validatable

**Status**: Planned
**Priority**: Medium

### VAL0003: Create Migration Guide for Existing Task Lists

**Description**: Write documentation explaining how to migrate existing task lists to the new reference format, with examples and best practices.

**Simplicity Progression Plan**:
1. Analyze common patterns
2. Create migration examples
3. Document best practices
4. Provide migration script

**Simplicity Principle**: Make migration as simple as possible - provide clear before/after examples.

**Content Strategy**:
- Step-by-step migration guide
- Common patterns to reference
- When NOT to use references
- Troubleshooting section

**Audience Analysis**:
- Developers maintaining task lists
- Teams adopting the validator
- AI tool users
- Project managers

**Requirements**:
- Clear migration steps
- Before/after examples
- Reference naming guide
- Common pitfalls

**Documentation Requirements**:
- Add to guides/ directory
- Link from README
- Include in template
- Version migration notes

**Review Process**:
- Technical review by team
- Test with real migrations
- Gather user feedback
- Iterate on clarity

**Error Handling**: DEF: Standard Error Handling

**Code Quality KPIs**:
- Lines of code: ~100 lines (documentation)
- DEF: Standard KPI Limits

**Dependencies**: VAL0001, VAL0002

**Status**: Planned
**Priority**: Low

<!-- CONTENT DEFINITIONS - DO NOT MODIFY SECTION HEADERS -->

## def-error-handling
**Error Handling**
**Core Principles**
- Pass raw errors
- Use {:ok, result} | {:error, reason}
- Let it crash

**Error Implementation**
- No wrapping
- Minimal rescue
- function/1 & /! versions

**Error Examples**
- Raw error passthrough
- Simple rescue case
- Supervisor handling

**GenServer Specifics** (if applicable to main tasks)
- Handle_call/3 error pattern
- Terminate/2 proper usage
- Process linking considerations

**Task-Specific Approach** (for subtasks)
- Define error patterns specific to this task
- Document any special error handling needs

**Error Reporting**
- Use Logger for error tracking
- Include context in error messages
- Monitor error rates

## def-kpi-limits
- Functions per module: 5 maximum
- Lines per function: 15 maximum
- Call depth: 2 maximum

## def-no-dependencies
None

## def-test-requirements
**ExUnit Test Requirements**:
- Comprehensive unit tests for all functions
- Edge case testing
- Error condition testing
- Integration testing where applicable

**Integration Test Scenarios**:
- End-to-end validation testing
- Performance testing for large inputs
- Concurrent operation testing
- Failure recovery testing

## def-typespec-requirements
**Typespec Requirements**:
- All public functions must have @spec
- Use custom types for clarity
- Document complex types

**TypeSpec Documentation**:
- Clear @doc for all public functions
- Examples in documentation
- Parameter constraints documented

**TypeSpec Verification**:
- Run dialyzer with no warnings
- Test with invalid inputs
- Verify type coverage


