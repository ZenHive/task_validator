# Task Validator Development Task List

<!-- REFERENCE USAGE EXAMPLE: This file demonstrates proper use of content references -->
<!-- References reduce file size by 60-70% while maintaining consistency -->
<!-- The TaskValidator library ONLY validates references exist - it does NOT expand them -->

<!-- For guidance on writing task lists, see:
     - guides/writing_compliant_tasks.md - Complete guide
     - guides/configuration.md - Configuration options  
     - guides/sample_tasklist.md - Full example
     - docs/examples/ - Category-specific examples -->
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
| BUG001  | Fix Subtask Content Parsing in MarkdownParser         | Completed   | Critical | AI       | 5.0           |
| BUG002  | Fix Template Generation Missing Subtasks              | Completed   | High     | AI       | 5.0           |

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

#### 1. Add tests for TaskList module (TST001-1)
**Description**
Create comprehensive unit tests for TaskValidator.Core.TaskList module including struct creation, validation, and edge cases

**Status**
Planned

{{error-handling-subtask}}

#### 2. Add tests for ValidationError module (TST001-2)
**Description**
Test ValidationError creation, formatting, and error aggregation functionality

**Status**
Planned

{{error-handling-subtask}}

#### 3. Add tests for TaskExtractor module (TST001-3)
**Description**
Test TaskExtractor parsing functionality for various task formats and edge cases

**Status**
Planned

{{error-handling-subtask}}

#### 4. Add property-based tests (TST001-4)
**Description**
Implement property-based testing using StreamData for robust edge case coverage

**Status**
Planned

{{error-handling-subtask}}

#### 5. Add integration tests (TST001-5)
**Description**
Create integration tests that verify the interaction between core modules

**Status**
Planned

{{error-handling-subtask}}

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

**Current Status**: Completed

**Priority**: Critical

**Technical Requirements**:
- Fix `extract_subtasks` function in MarkdownParser (line 232)
- After finding `#### N. Description (ID)` line, extract subsequent lines until next `####` or section boundary
- Populate the `content` field of subtask Task structs (currently hardcoded as empty array at line 255)
- Preserve accurate line numbers for error reporting
- Handle edge cases: last subtask in section, empty subtasks, nested content

**Dependencies**: None

#### 1. Analyze extract_subtasks function (BUG001-1)
**Description**
Understand the current implementation and identify where content extraction fails

**Status**
Completed

**Review Rating**: 5.0

{{error-handling-subtask}}

#### 2. Implement content extraction logic (BUG001-2)
**Description**
Modify extract_subtasks to capture content between subtask headers

**Status**
Completed

**Review Rating**: 5.0

{{error-handling-subtask}}

#### 3. Handle edge cases (BUG001-3)
**Description**
Ensure proper handling of empty subtasks, consecutive headers, and last subtask

**Status**
Completed

**Review Rating**: 5.0

{{error-handling-subtask}}

#### 4. Add comprehensive tests (BUG001-4)
**Description**
Create tests for various subtask formats and edge cases

**Status**
Completed

**Review Rating**: 5.0

{{error-handling-subtask}}

{{error-handling-main}}

{{test-requirements}}

{{typespec-requirements}}

**Implementation Notes**: 
- Modified `extract_subtasks` function to track positions of all subtasks and extract content between them
- Added logic to handle edge cases where subtasks have no content (consecutive headers)
- Updated status and priority extraction to use content from subtasks
- Fixed range warning by checking if start index is less than or equal to end index
- Added comprehensive tests including edge cases

**Complexity Assessment**: Medium - Required understanding of list processing and edge case handling

**Maintenance Impact**: Low - The fix is self-contained within the parser module

**Error Handling Implementation**: Used existing error handling patterns, no rescue blocks needed

**Code Quality Metrics**: {{standard-kpis}}

**Testing Strategy**:
- Test subtask content extraction with various formats
- Verify line number accuracy
- Test edge cases (empty content, nested sections)
- Ensure backward compatibility

**Performance Requirements**:
- No significant parsing performance degradation
- Memory efficient content extraction

**Status**: Completed

---

### BUG002: Fix Template Generation Missing Subtasks

**Description**: The `mix task_validator.create_template` command creates task list templates with incomplete or missing subtask examples. Only the phoenix_web template includes subtasks, but they use a simplified checkbox format that wouldn't pass validation if the parent task status was "In Progress". None of the templates demonstrate the full subtask format with proper sections (Status, Error Handling, etc.) or numbered subtasks (#### format). This makes it unclear to users how to properly format subtasks in their task lists.

**Current Status**: Completed

**Priority**: High

**Technical Requirements**:
- Fix phoenix_web template: Replace simple checkbox format with proper subtask structure
- Add subtask examples to all other templates (otp_genserver, business_logic, data_layer, infrastructure, testing)
- Include at least one numbered subtask example (#### format) with full sections
- Keep checkbox subtask examples but ensure they're noted as simplified format
- Ensure subtasks follow proper ID formatting (PARENT-N for numbered, PARENTa for checkbox)
- Include proper subtask sections (Status, Error Handling reference, Review Rating for completed)
- Ensure generated templates still pass validation

**Dependencies**: None

{{error-handling-main}}

{{test-requirements}}

{{typespec-requirements}}

**Implementation Notes**: 
- Updated all 6 template categories to include proper subtask examples
- Each template now shows numbered subtasks with full sections (Status, Error Handling)
- Phoenix_web and data_layer templates also demonstrate checkbox format for minor items
- Templates now properly demonstrate "In Progress" status with subtasks
- All enhanced templates pass validation
- Testing template includes multiple tasks to show variety

**Code Quality Metrics**: {{standard-kpis}}

**Testing Strategy**:
- Test template generation includes subtasks
- Verify generated templates pass validation
- Test both default and custom prefix scenarios
- Ensure subtask IDs match parent task prefix

**Performance Requirements**:
- No performance impact on template generation
- Template should remain readable and not overly complex

**Complexity Assessment**: Low - Template string updates only

**Maintenance Impact**: Low - Self-contained template improvements

**Error Handling Implementation**: No error handling changes needed

**Status**: Completed
**Review Rating**: 5.0

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
**ExUnit Test Requirements**
- Integration tests FIRST against real dependencies
- Document actual behavior before mocking
- Unit tests extracted from integration test observations
- Test error paths with real error conditions
- Property-based testing for complex validations

**Integration Test Scenarios**
- Real file system operations with actual TaskList.md files
- Actual Mix task execution with real command output
- Genuine validation errors from malformed files
- Real pipeline execution with multiple validators
- Actual performance testing with large task lists
- Concurrent validation of multiple files
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