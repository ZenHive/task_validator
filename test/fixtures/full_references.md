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

# Test Task List with Full Reference Usage

## Current Tasks

| ID      | Description                                           | Status      | Priority | Assignee | Review Rating |
| ------- | ----------------------------------------------------- | ----------- | -------- | -------- | ------------- |
| TST0001 | Test task using all reference types                   | Planned     | High     |          |               |
| TST0001-1 | ├─ Subtask with references                          | Planned     | High     |          |               |

## Task Details

### TST0001: Test task using all reference types

**Description**: A test task that uses reference placeholders for all supported sections.

**Simplicity Progression Plan**
Using traditional content here

**Simplicity Principle**
Keep it simple

**Abstraction Evaluation**
Low

**Requirements**
- Test all reference types

**Architecture Notes**
Simple test architecture

**Complexity Assessment**
Low complexity

{{test-requirements}}
{{typespec-requirements}}
{{error-handling}}
{{standard-kpis}}
{{def-no-dependencies}}

**Status**: Planned
**Priority**: High

#### 1. Subtask with references (TST0001-1)

**Description**: A subtask that uses error handling reference.

{{error-handling}}

**Status**: Planned

<!-- CONTENT DEFINITIONS - DO NOT MODIFY SECTION HEADERS -->
## #{{reference-name}}
this is a reference

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

**GenServer Specifics**
- Handle_call/3 error pattern
- Terminate/2 proper usage
- Process linking considerations

**Task-Specific Approach**
- Error pattern for this task

**Error Reporting**
- Monitoring approach

## #{{test-requirements}}
**ExUnit Test Requirements**:
- Comprehensive unit tests
- Edge case testing
- Error condition testing

**Integration Test Scenarios**:
- End-to-end validation
- Performance testing
- Concurrent operation testing

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

## #{{standard-kpis}}
- Functions per module: 5 maximum
- Lines per function: 15 maximum
- Call depth: 2 maximum

## #{{def-no-dependencies}}
None

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

## #{{error-handling-subtask}}
**Error Handling**
**Task-Specific Approach**
- Validate inputs early
- Return specific error tuples
- Handle edge cases gracefully
**Error Reporting**
- Log errors with appropriate levels
- Include context in error messages
