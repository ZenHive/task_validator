# Task Validator Development Task List

<!-- AI INSTRUCTION: This document uses content references to reduce repetition -->
<!-- When you see "{{error-handling}}", substitute content from #{{error-handling}} -->
<!-- When you see "{{standard-kpis}}", substitute content from #{{standard-kpis}}-->
<!-- When you see "{{def-no-dependencies}}", substitute content from #def-no-dependencies -->
<!-- When you see "{{test-requirements}}", substitute content from #{{test-requirements}} -->
<!-- When you see "{{typespec-requirements}}", substitute content from #{{typespec-requirements}} -->


## Current Tasks

| ID      | Description                                           | Status      | Priority | Assignee | Review Rating |
| ------- | ----------------------------------------------------- | ----------- | -------- | -------- | ------------- |
| VAL0001 | Support AI-Friendly Content References                | In Progress | High     |          |               |
| VAL0001-1 | ├─ Update validator to recognize def- sections      | Planned     | High     |          |               |
| VAL0001-2 | ├─ Implement reference expansion in validation      | Planned     | High     |          |               |
| VAL0001-3 | ├─ Add tests for reference format                   | Planned     | Medium   |          |               |
| VAL0001-4 | └─ Update test fixtures to use content references   | Planned     | High     |          |               |
| VAL0002 | Update Template Generator for New Format              | Planned     | Medium   |          |               |
| VAL0003 | Create Migration Guide for Existing Task Lists        | Planned     | Low      |          |               |

## Task Details

### VAL0001: Support AI-Friendly Content References

**Description**: Enhance the task validator to support content references that reduce repetition while remaining AI-editor friendly. This allows task lists to use references like "{{error-handling}}" which AI editors can expand using definitions at the end of the file.

**Simplicity Progression Plan**:
1. Parse {{reference}} sections at end of file
2. Build reference map during validation
3. Expand references when validating sections
4. No backward compatibility needed

**Simplicity Principle**: Keep the reference system simple - just string replacement during validation, no complex templating.

**Abstraction Evaluation**:
- **Challenge**: How to reduce repetition without making files unreadable for AI?
- **Minimal Solution**: Simple reference definitions with clear AI instructions
- **Justification**: Reduces file size by 60-70% while keeping content accessible

**Requirements**:
- Support #{{reference-name}} section headers
- Expand references during validation
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
- References are expanded during validation only
- Original file remains unchanged
- References can contain any valid markdown

**Status**: In Progress
**Priority**: High

#### 1. Update validator to recognize def- sections (VAL0001-1)

**Description**: Modify extract_references/1 to recognize sections with #{{reference-name}} format as reference definitions.

**Error Handling**: {{error-handling}}

**Task-Specific Approach**:
- Parse sections starting with ## {{reference-name}}
- Store content until next section
- Build reference map

**Error Reporting**:
- Log duplicate reference definitions
- Report invalid reference names

**Status**: Planned

#### 2. Implement reference expansion in validation (VAL0001-2)

**Description**: Update validation logic to expand "{{reference-name}}" references using the reference map.

**Error Handling**: {{error-handling}}

**Task-Specific Approach**:
- Pattern match on "{{reference-name}}"
- Look up in reference map
- Substitute during validation

**Error Reporting**:
- Report missing references
- Show which task uses invalid reference

**Status**: Planned

#### 3. Add tests for reference format (VAL0001-3)

**Description**: Create comprehensive tests for the new reference system.

**Error Handling**: {{error-handling}}

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

**Error Handling**: {{error-handling}}

**Code Quality KPIs**:
- Lines of code: ~100 lines (documentation)
- {{standard-kpis}}

**Dependencies**: VAL0001, VAL0002

**Status**: Planned
**Priority**: Low

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
