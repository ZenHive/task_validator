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

1. **Missing detailed entries** - All non-completed tasks need detailed entries
2. **Missing required sections** - Ensure all required sections are present
3. **Missing completion details** - Completed tasks must include implementation notes, complexity assessment and maintenance impact
4. **Inconsistent subtask prefixes** - Subtasks must use same prefix as parent
5. **In Progress tasks without subtasks** - Any "In Progress" task needs subtasks
6. **Invalid status values** - Must be one of the valid status values
7. **Missing review ratings** - Completed subtasks need review ratings
