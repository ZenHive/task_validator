# Task Validator Development Task List

<!-- REFERENCE USAGE EXAMPLE: This file demonstrates proper use of content references -->
<!-- References reduce file size by 60-70% while maintaining consistency -->
<!-- The TaskValidator library ONLY validates references exist - it does NOT expand them -->
<!-- AI tools should expand references when editing/processing this file -->

<!-- COMMON REFERENCES USED IN THIS FILE: -->
<!-- {{error-handling}} - Main task error handling (expands from #{{error-handling}}) -->
<!-- {{error-handling-subtask}} - Subtask error handling -->
<!-- {{standard-kpis}} - Code quality metrics (expands from #{{standard-kpis}}) -->
<!-- {{def-no-dependencies}} - Standard "None" for dependencies -->
<!-- {{test-requirements}} - All test-related sections -->
<!-- {{typespec-requirements}} - All TypeSpec sections -->

<!-- HOW IT WORKS: -->
<!-- 1. References are defined at the bottom with format: ## #{{reference-name}} -->
<!-- 2. References are used in tasks with format: {{reference-name}} -->
<!-- 3. The validator checks references exist but doesn't expand them -->
<!-- 4. AI tools expand references when processing the file -->


## Current Tasks

| ID      | Description                                           | Status      | Priority | Assignee | Review Rating |
| ------- | ----------------------------------------------------- | ----------- | -------- | -------- | ------------- |
| TST001  | Improve Test Coverage for Core Modules                | Planned     | High     | AI       | -             |
| BUG001  | Fix Subtask Content Parsing in MarkdownParser         | Planned     | Critical | AI       | -             |

## Task Details

### TST001: Improve Test Coverage for Core Modules

**Description**: Enhance test coverage for core modules that currently have 0% coverage, particularly TaskValidator.Core.TaskList, TaskValidator.Core.ValidationError, and TaskValidator.Parsers.TaskExtractor. This will improve overall codebase quality and catch potential issues.

**Current Status**: Planned

**Priority**: High

**Technical Requirements**:
- Add comprehensive unit tests for TaskList module
- Test ValidationError creation and handling
- Test TaskExtractor parsing functionality
- Ensure edge cases are covered

**Dependencies**: None

{{error-handling-main}}

{{test-requirements}}

{{typespec-requirements}}

**Implementation Notes**: (To be completed)

**Code Quality Metrics**: {{standard-kpis}}

**Testing Strategy**:
- Unit tests for each public function
- Property-based testing where applicable
- Mock external dependencies
- Test error conditions thoroughly

**Performance Requirements**:
- Test execution should complete within 1 second
- No memory leaks in test fixtures
- Efficient test data setup/teardown

**Status**: Planned

---

### BUG001: Fix Subtask Content Parsing in MarkdownParser

**Description**: The MarkdownParser's `extract_subtasks` function currently creates subtasks with empty content arrays. It only extracts the `#### N. Description (ID)` header line but doesn't capture the content between that header and the next subtask or section. This causes all subtasks to fail validation because required sections like **Status** and **Error Handling** cannot be found in empty content arrays.

**Current Status**: Planned

**Priority**: Critical

**Technical Requirements**:
- Fix `extract_subtasks` function in MarkdownParser (line 232)
- After finding `#### N. Description (ID)` line, extract subsequent lines until next `####` or section boundary
- Populate the `content` field of subtask Task structs (currently hardcoded as empty array at line 255)
- Preserve accurate line numbers for error reporting
- Handle edge cases: last subtask in section, empty subtasks, nested content

**Dependencies**: None

{{error-handling-main}}

{{test-requirements}}

{{typespec-requirements}}

**Implementation Notes**: (To be completed)

**Code Quality Metrics**: {{standard-kpis}}

**Testing Strategy**:
- Test subtask content extraction with various formats
- Verify line number accuracy
- Test edge cases (empty content, nested sections)
- Ensure backward compatibility

**Performance Requirements**:
- No significant parsing performance degradation
- Memory efficient content extraction

**Status**: Planned

---

<!-- CONTENT DEFINITIONS - DO NOT MODIFY SECTION HEADERS -->

## #{{error-handling}}
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

## #{{standard-kpis}}
- Functions per module: 5 maximum
- Lines per function: 15 maximum
- Call depth: 2 maximum

## #{{def-no-dependencies}}
None

## #{{error-handling-subtask}}
**Error Handling**
**Task-Specific Approach**
- Validate inputs early
- Return specific error tuples
- Handle edge cases gracefully
**Error Reporting**
- Log errors with appropriate levels
- Include context in error messages

## #{{test-requirements}}
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

## #{{typespec-requirements}}
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

## #{{error-handling-main}}
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
**GenServer Specifics**
- Handle_call/3 error pattern
- Terminate/2 proper usage
- Process linking considerations

## #{{reference-name}}
(Placeholder for reference name - used in documentation)

## #{{reference}}
(Placeholder for reference - used in documentation)