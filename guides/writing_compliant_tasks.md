# Writing Compliant Task Lists

This guide explains how to create task lists that comply with the `TaskValidator` specifications.

## Task List Structure

A compliant task list has two main sections:

```markdown
## Current Tasks

| ID      | Description          | Status      | Priority |
| ------- | -------------------- | ----------- | -------- |
| SSH0001 | SSH authentication   | In Progress | High     |
| SCP0001 | File transfer module | Planned     | Medium   |
| ERR001  | Error handling       | In Progress | High     |

## Completed Tasks

| ID      | Description    | Status    | Completed By | Review Rating |
| ------- | -------------- | --------- | ------------ | ------------- |
| SSH0002 | Key generation | Completed | @developer1  | 4.5           |
```

## Task ID Format

Task IDs must follow this pattern:

- 2-4 uppercase letters as a prefix (representing a component or module)
- 3-4 digits as a sequential number
- Optional hyphen and digit(s) for subtasks

Examples:

- `SSH0001` - Main task for SSH component
- `SSH0001-1` - First subtask of SSH0001
- `ERR001` - Error handling task
- `SCP0005` - File transfer task

## Error Handling Requirements

Main tasks and subtasks have different error handling documentation requirements.

### Main Tasks Error Handling Format

Main tasks must include comprehensive error handling sections that follow this format:

```markdown
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
```

### Subtasks Error Handling Format

Subtasks have a simplified error handling format:

```markdown
**Error Handling**
**Task-Specific Approach**
- Error pattern for this task
**Error Reporting**
- Monitoring approach
```

These sections ensure consistent error handling practices across the project while providing appropriate level of detail for each task type. Tasks without proper error handling sections will fail validation.

## Detailed Task Entries

Each task needs a detailed entry with the following format:

```markdown
### SSH0001: Implement SSH authentication module

**Description**
Develop the SSH authentication module supporting key-based and password authentication.

**Simplicity Progression Plan**

1. Start with basic password auth
2. Add key-based auth
3. Refine error handling

**Simplicity Principle**
Progressive enhancement

**Abstraction Evaluation**
Medium - abstracts authentication but maintains clear interfaces

**Requirements**

- Support for password auth
- Support for public key auth
- Configurability of allowed auth methods

**ExUnit Test Requirements**

- Test both auth methods
- Test failure scenarios
- Mock SSH server for integration tests

**Integration Test Scenarios**

- Auth with valid/invalid password
- Auth with valid/invalid key
- Auth with disabled methods

**Typespec Requirements**

- Define types for credentials
- Define auth result types

**TypeSpec Documentation**
All types should be documented clearly

**TypeSpec Verification**
Use Dialyzer to verify type correctness

**Status**
In Progress

**Priority**
High

#### 1. Implement password authentication (SSH0001-1)

**Status**
Completed

**Review Rating**
4.5

#### 2. Add key-based authentication (SSH0001-2)

**Status**
In Progress

#### 1. Implement password authentication (SSH0001-1)

**Description**
Initial implementation of password-based authentication.

**Error Handling**
**Task-Specific Approach**
- Handle invalid credentials with specific error tuples
- Use clean separation for auth failures vs. connection failures
**Error Reporting**
- Log auth attempts with appropriate level (info/warn)
- Track failed attempts for rate limiting

**Status**
Completed

**Review Rating**
4.5

#### 2. Add key-based authentication (SSH0001-2)

**Description**
Support for RSA and ED25519 keys with proper validation.

**Error Handling**
**Task-Specific Approach**
- Return descriptive error for invalid key formats
- Handle key verification timeout with custom error
**Error Reporting**
- Log key verification attempts
- Report metrics on key type usage

**Status**
In Progress
```

## Status Values

Valid status values are:

- `Planned`
- `In Progress`
- `Review`
- `Completed`
- `Blocked`

## Priority Values

Valid priority values are:

- `Critical`
- `High`
- `Medium`
- `Low`

## Review Ratings

For completed tasks, include a review rating:

- Scale of 1-5 with optional decimal (e.g., `4.5`)
- Can include `(partial)` suffix for partially meeting requirements

## Required Sections for Completed Tasks

When a task is marked as "Completed", it must include these additional sections:

**Implementation Notes**
Describe the implementation approach and patterns used.

**Complexity Assessment**
Assess the final complexity level (High/Medium/Low) and explain why.

**Maintenance Impact**
Evaluate the maintenance burden and any special considerations.

Example:
```markdown
**Implementation Notes**
Elegant indirection pattern using Registry for PID resolution

**Complexity Assessment**
Low - Used built-in Registry with minimal custom code

**Maintenance Impact**
Low - Self-contained solution with clear interface
```

## Common Validation Errors

1. **Missing error handling sections** - All tasks and subtasks must include complete error handling documentation
2. **Incomplete error handling documentation** - All three error handling subsections (Core Principles, Implementation, Examples) are required
3. **Missing detailed entries** - All non-completed tasks need detailed entries
4. **Missing required sections** - Ensure all required sections are present
5. **Missing completion details** - Completed tasks must include implementation notes, complexity assessment and maintenance impact
6. **Inconsistent subtask prefixes** - Subtasks must use same prefix as parent
7. **In Progress tasks without subtasks** - Any "In Progress" task needs subtasks
8. **Invalid status values** - Must be one of the valid status values
9. **Missing review ratings** - Completed subtasks need review ratings
