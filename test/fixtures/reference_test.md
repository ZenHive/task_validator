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

# Task List

## Current Tasks

| ID      | Description     | Status      | Priority |
| ------- | --------------- | ----------- | -------- |
| REF0001 | Task with refs  | In Progress | High     |

## Task Details

### REF0001: Task with references

**Description**
Testing reference resolution

**Simplicity Progression Plan**
1. Test basic references

**Simplicity Principle**
Keep it simple

**Abstraction Evaluation**
Low

**Requirements**
- Test references work

**ExUnit Test Requirements**
- Unit tests

**Integration Test Scenarios**
- Integration tests

**Typespec Requirements**
- Type specs

**TypeSpec Documentation**
Documentation

**TypeSpec Verification**
Verification

**Dependencies**
- None

{{standard-kpis}}

{{error-handling-main}}

**Status**
In Progress

**Priority**
High

**Architecture Notes**
Simple test

**Complexity Assessment**
Low

**Subtasks**
#### 1. Test subtask (REF0001-1)

**Description**
Test subtask

{{error-handling-subtask}}

**Status**
In Progress

<!-- CONTENT DEFINITIONS - DO NOT MODIFY SECTION HEADERS -->

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

## #{{subtask-error-handling}}
**Error Handling**
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
**Code Quality KPIs**
- Functions per module: 5
- Lines per function: 15
- Call depth: 2

## #{{def-no-dependencies}}
**Dependencies**
- None

## #{{error-handling-subtask}}
**Error Handling**
**Task-Specific Approach**
- Error pattern for this task
**Error Reporting**
- Monitoring approach

## #{{reference-name}}
**Example Reference Content**
This is an example of how reference content works.
