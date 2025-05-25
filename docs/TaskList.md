# Task Validator Development Task List

<!-- AI INSTRUCTION: This document uses content references to reduce repetition -->
<!-- The TaskValidator library ONLY validates references exist - it does NOT expand them -->
<!-- AI tools should expand references when editing/processing this file -->
<!-- When you see "{{error-handling}}", substitute content from #{{error-handling}} -->
<!-- When you see "{{standard-kpis}}", substitute content from #{{standard-kpis}}-->
<!-- When you see "{{def-no-dependencies}}", substitute content from #def-no-dependencies -->
<!-- When you see "{{test-requirements}}", substitute content from #{{test-requirements}} -->
<!-- When you see "{{typespec-requirements}}", substitute content from #{{typespec-requirements}} -->


## Current Tasks

| ID      | Description                                           | Status      | Priority | Assignee | Review Rating |
| ------- | ----------------------------------------------------- | ----------- | -------- | -------- | ------------- |
| VAL0001 | Support AI-Friendly Content References                | Completed   | High     |          | 5.0           |
| VAL0001-1 | ├─ Update validator to recognize def- sections      | Completed   | High     |          | 5/5           |
| VAL0001-2 | ├─ Implement reference validation                   | Completed   | High     |          | 5/5           |
| VAL0001-3 | ├─ Add tests for reference format                   | Completed   | Medium   |          | 5/5           |
| VAL0001-4 | └─ Update test fixtures to use content references   | Completed   | High     |          | 5             |
| VAL0002 | Update Template Generator for New Format              | Completed   | Medium   | @assistant | 5.0          |

## Task Details

### VAL0001: Support AI-Friendly Content References

**Description**: Enhance the task validator to fully support content references that reduce repetition while remaining AI-editor friendly. The validator has three core responsibilities:
1. Parse definition sections (`## {{reference-name}}`) 
2. Check that all `{{reference}}` placeholders have corresponding definitions
3. Accept the placeholders as valid content (not require expansion)

The validator does NOT expand {{reference}} placeholders - that is the responsibility of AI tools and editors.

**Simplicity Progression Plan**:
1. Parse `## {{reference-name}}` definition sections at end of file
2. Build reference map during validation
3. Check all `{{reference}}` placeholders have definitions
4. Accept placeholders as valid content (no expansion required)
5. No backward compatibility needed

**Simplicity Principle**: Keep the reference system simple - just validate references exist, no expansion or complex templating by the validator.

**Abstraction Evaluation**:
- **Challenge**: How to reduce repetition without making files unreadable for AI?
- **Minimal Solution**: Simple reference definitions with clear AI instructions
- **Justification**: Reduces file size by 60-70% while keeping content accessible

**Requirements**:
- Parse `## {{reference-name}}` definition sections
- Validate all `{{reference}}` placeholders have corresponding definitions  
- Accept placeholders as valid content without requiring expansion
- Maintain human readability
- Clear AI instructions at top

**ExUnit Test Requirements**: {{test-requirements}}
**Integration Test Scenarios**: {{test-requirements}}
**Typespec Requirements**: {{typespec-requirements}}
**TypeSpec Documentation**: {{typespec-requirements}}
**TypeSpec Verification**: {{typespec-requirements}}
**Error Handling**: {{error-handling}}

**Code Quality KPIs**:
- Lines of code: ~100 lines (validator enhancement)
- {{standard-kpis}}

**Dependencies**: {{def-no-dependencies}}

**Architecture Notes**:
- Validator parses `## {{reference-name}}` sections into reference map
- Validator checks `{{reference}}` placeholders have definitions
- Validator accepts placeholders as valid content (no expansion)
- AI tools are responsible for expanding references when editing
- Original file remains unchanged by validator
- References can contain any valid markdown

**Status**: Completed
**Priority**: High
**Review Rating**: 5.0

#### 1. Update validator to parse definition sections (VAL0001-1)

**Description**: Modify extract_references/1 to parse sections with `## {{reference-name}}` format as reference definitions and build a reference map.

**Error Handling**: {{error-handling}}

**Task-Specific Approach**:
- Parse sections starting with `## {{reference-name}}`
- Extract content until next section header
- Build reference map for validation lookup
- Store reference names and content locations

**Error Reporting**:
- Log duplicate reference definitions
- Report invalid reference names

**Status**: Completed

#### 2. Implement placeholder validation (VAL0001-2)

**Description**: Update validation logic to check that all `{{reference-name}}` placeholders have corresponding definitions in the reference map, and accept placeholders as valid content.

**Error Handling**: {{error-handling}}

**Task-Specific Approach**:
- Pattern match on `{{reference-name}}` placeholders in task content
- Look up each placeholder in reference map
- Validate reference definition exists (no expansion/substitution)
- Accept placeholders as valid content during validation

**Error Reporting**:
- Report missing references
- Show which task uses invalid reference

**Status**: Completed

#### 3. Add tests for reference format (VAL0001-3)

**Description**: Create comprehensive tests for the new reference validation system.

**Error Handling**: {{error-handling}}

**Task-Specific Approach**:
- Test valid reference files
- Test missing references
- Test validation without expansion (validator only checks existence)

**Error Reporting**:
- Clear test failure messages
- Show actual vs expected validation results

**Status**: Completed
**Review Rating**: 5/5

#### 4. Update test fixtures to use content references (VAL0001-4)

**Description**: Convert all test fixtures in test/fixtures/* to use the new content reference format. This ensures our test cases demonstrate best practices and validate the reference system properly.

**Error Handling**: {{error-handling}}

**Task-Specific Approach**:
- Identify repetitive content in fixtures
- Create appropriate references
- Update fixture files with references
- Ensure fixtures still test edge cases

**Error Reporting**:
- Maintain test coverage
- Keep invalid fixtures invalid
- Document changes in comments

**Status**: Planned

### VAL0002: Update Template Generator for New Format

**Description**: Modify mix task create_template to generate task lists using the new reference format, reducing repetition in generated templates. The generated templates will be validated by the library but expanded by AI tools.

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

**ExUnit Test Requirements**: {{test-requirements}}
**Integration Test Scenarios**: {{test-requirements}}
**Typespec Requirements**: {{typespec-requirements}}
**TypeSpec Documentation**: {{typespec-requirements}}
**TypeSpec Verification**: {{typespec-requirements}}

**Error Handling**: {{error-handling}}

**Code Quality KPIs**:
- Lines of code: ~80 lines (template updates)
- {{standard-kpis}}

**Dependencies**: VAL0001

**Architecture Notes**:
- Templates demonstrate reference best practices
- Include most common references
- Keep generated files validatable (but not expanded by validator)
- AI tools handle reference expansion when editing templates

**Status**: Completed
**Priority**: Medium

**Implementation Notes**:
- Updated @reference_definitions module attribute to use ## #{{ref}} format
- Escaped hash symbols in template strings to prevent Elixir interpolation
- Templates now include {{standard-kpis}}, {{error-handling-main}}, and {{error-handling-subtask}} references
- All template categories (core, features, documentation, testing) updated
- Generated templates pass validation with new reference format

**Maintenance Impact**:
- Template changes are backward compatible
- AI tools expanding references will handle both old and new formats
- No changes needed to existing task lists

**Review Rating**: 5.0

<!-- CONTENT DEFINITIONS - DO NOT MODIFY SECTION HEADERS -->

## {{error-handling}}
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

## {{standard-kpis}}
- Functions per module: 5 maximum
- Lines per function: 15 maximum
- Call depth: 2 maximum

## {{def-no-dependencies}}
None

## {{test-requirements}}
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

## {{typespec-requirements}}
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
