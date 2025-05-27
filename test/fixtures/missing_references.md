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

| ID      | Description          | Status      | Priority |
| ------- | -------------------- | ----------- | -------- |
| REF0002 | Missing references   | In Progress | High     |

## Task Details

### REF0002: Task with missing references

**Description**
Testing missing reference validation

**Simplicity Progression Plan**
1. Test missing references

**Simplicity Principle**
Keep it simple

**Abstraction Evaluation**
Low

**Requirements**
- Test missing references detection

**ExUnit Test Requirements**: {{test-requirements}}
**Integration Test Scenarios**: {{integration-scenarios}}
**Typespec Requirements**: {{typespec-requirements}}
**TypeSpec Documentation**: {{typespec-documentation}}
**TypeSpec Verification**: {{typespec-verification}}

**Dependencies**
- None

**Code Quality KPIs**: {{standard-kpis}}

**Error Handling**: {{error-handling-main}}

{{non-existent-reference}}

**Status**
In Progress

**Priority**
High

**Architecture Notes**
Simple test

**Complexity Assessment**
Low

**Subtasks**
#### 1. Test subtask (REF0002-1)

**Description**
Test subtask

**Error Handling**: {{error-handling-subtask}}

{{another-missing-ref}}

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

## #{{standard-kpis}}
**Code Quality KPIs**
- Functions per module: 3
- Lines per function: 12
- Call depth: 2

<!-- Note: Missing definitions for:
  - {{test-requirements}}
  - {{integration-scenarios}}
  - {{typespec-documentation}}
  - {{typespec-verification}}
  - {{error-handling-subtask}}
  - {{non-existent-reference}}
  - {{another-missing-ref}}
-->
