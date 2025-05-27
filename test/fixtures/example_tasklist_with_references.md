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
<!-- 1. References are defined at the bottom with format: ## #`{{example-reference}}` -->
<!-- 2. References are used in tasks with format: `{{example-reference}}` -->
<!-- 3. The validator checks references exist but doesn't expand them -->
<!-- 4. AI tools expand references when processing the file -->

# Example TaskList with References

This example demonstrates proper usage of references in TaskValidator task lists.

## Integration Test Setup Notes

Brief notes about integration testing setup and requirements.

## Simplicity Guidelines for All Tasks

Follow KISS principle - Keep It Simple, Stupid. Focus on clarity over cleverness.

## Current Tasks

| ID      | Description                     | Status      | Priority | Assignee   | Review Rating |
| ------- | ------------------------------- | ----------- | -------- | ---------- | ------------- |
| SSH0001 | Implement SSH connection module | In Progress | High     | developer1 | -             |
| SSH0002 | Add SSH key authentication      | Planned     | High     | developer2 | -             |
| ERR001  | Standardize error handling      | Planned     | Medium   | developer3 | -             |

## Completed Tasks

| ID      | Description                  | Status    | Priority | Assignee   | Review Rating |
| ------- | ---------------------------- | --------- | -------- | ---------- | ------------- |
| SSH0003 | Setup SSH client structure   | Completed | High     | developer1 | 4.5           |

## Active Task Details

### SSH0001: Implement SSH connection module

**Description**: Create the core SSH connection module for establishing secure connections to remote servers
**Simplicity Progression Plan**: Start with basic TCP connection, then add SSH protocol layers
**Simplicity Principle**: Keep connection logic separate from authentication and session management
**Abstraction Evaluation**: Hide protocol details behind simple connect/disconnect interface
**Requirements**: TCP connection establishment, SSH handshake, session initialization
{{test-requirements}}
{{typespec-requirements}}
{{def-no-dependencies}}
{{standard-kpis}}
{{error-handling}}
**Status**: In Progress
**Priority**: High
**Architecture Decision**: Use erlang's gen_tcp for low-level connectivity
**System Impact**: Foundation for all SSH operations
**Dependency Analysis**: Only standard library dependencies
**Architecture Notes**: Layered architecture with clear separation between TCP transport and SSH protocol
**Complexity Assessment**: Medium - Requires careful handling of asynchronous communication and state management

#### 1. Implement TCP connection (SSH0001-1)

**Test-First Approach**: Write tests for TCP connection establishment and teardown
**Simplicity Constraints**: Use gen_tcp directly without additional abstractions
**Implementation**: Basic TCP client with timeout support
{{error-handling-subtask}}
**Status**: Completed
**Review Rating**: 5

#### 2. Add SSH handshake (SSH0001-2)

**Test-First Approach**: Test SSH version exchange and algorithm negotiation
**Simplicity Constraints**: Support only essential algorithms initially
**Implementation**: SSH protocol version 2 handshake
{{error-handling-subtask}}
**Status**: In Progress

### SSH0002: Add SSH key authentication

**Description**: Implement SSH key-based authentication support for secure passwordless connections
**Simplicity Progression Plan**: Parse keys first, then implement auth flow
**Simplicity Principle**: Clear separation between key parsing and authentication logic
**Abstraction Evaluation**: Expose simple authenticate_with_key/2 function
**Requirements**: Support RSA, ED25519, and ECDSA key formats
{{test-requirements}}
{{typespec-requirements}}
**Dependencies**
- SSH0001
{{standard-kpis}}
{{error-handling}}
**Status**: Planned
**Priority**: High
**Architecture Decision**: Use :public_key module for cryptographic operations
**System Impact**: Enables secure authentication without passwords
**Dependency Analysis**: Depends on SSH0001 for connection establishment
**Architecture Notes**: Modular design with pluggable authentication methods
**Complexity Assessment**: High - Requires proper key parsing and cryptographic validation

### ERR001: Standardize error handling

**Description**: Create consistent error handling patterns across all modules
**Simplicity Progression Plan**: Define error tuples, then implement across modules
**Simplicity Principle**: Use simple {:ok, result} | {:error, reason} pattern everywhere
**Abstraction Evaluation**: Minimal - errors should be transparent
**Requirements**: Consistent error types, clear error messages, proper error propagation
{{test-requirements}}
{{typespec-requirements}}
{{def-no-dependencies}}
{{standard-kpis}}
{{error-handling}}
**Status**: Planned
**Priority**: Medium
**Architecture Decision**: Follow OTP conventions for error handling
**System Impact**: Improves debugging and error recovery
**Dependency Analysis**: No dependencies, but affects all modules
**Architecture Notes**: Centralized error types with consistent formatting across all modules
**Complexity Assessment**: Low - Simple pattern application across codebase

### SSH0003: Setup SSH client structure

**Description**: Initial project setup and module structure for SSH client

**Simplicity Progression Plan**: Create basic structure, then add components incrementally

**Simplicity Principle**: Clear module boundaries with single responsibilities

**Abstraction Evaluation**: Low - Standard OTP application structure

**Requirements**:
- Application structure
- Supervisor tree
- Basic configuration

{{test-requirements}}
{{typespec-requirements}}

{{def-no-dependencies}}

{{standard-kpis}}

{{error-handling}}

**Status**: Completed

**Priority**: High

**Architecture Decision**: Standard OTP application with supervisor

**System Impact**: Foundation for entire SSH client

**Dependency Analysis**: No external dependencies

**Architecture Notes**: Three-layer supervision tree with separate supervisors for connections, sessions, and utilities

**Implementation Notes**: Created clean OTP structure with proper supervision tree

**Complexity Assessment**: Low - Standard OTP patterns used throughout

**Maintenance Impact**: Low - Well-organized module structure

**Error Handling Implementation**: Basic supervisor with restart strategies

**Review Rating**: 4.5

## References

## #{{error-handling}}
**Error Handling**
**Core Principles**
- Pass raw errors without wrapping
- Use {:ok, result} | {:error, reason} tuples
- Let it crash for unexpected errors
**Error Implementation**
- No unnecessary error wrapping
- Minimal rescue clauses
- Provide both safe and bang (!) function versions
**Error Examples**
- Connection errors: {:error, :connection_refused}
- Auth errors: {:error, :authentication_failed}
- Timeout errors: {:error, :timeout}
**GenServer Specifics**
- Handle errors in handle_call/3 callbacks
- Use terminate/2 for cleanup
- Consider process linking for error propagation

## #{{error-handling-subtask}}
**Error Handling**
**Task-Specific Approach**
- Validate inputs early
- Return specific error tuples
**Error Reporting**
- Log errors with appropriate levels
- Include context in error messages

## #{{test-requirements}}
**ExUnit Test Requirements**:
- Comprehensive unit tests for all public functions
- Edge case testing for boundary conditions
- Error condition testing for all failure modes

**Integration Test Scenarios**:
- End-to-end connection and authentication flow
- Performance testing under load
- Concurrent operation testing

## #{{typespec-requirements}}
**Typespec Requirements**:
- All public functions must have @spec annotations
- Use custom types for domain concepts
- Document complex type structures

**TypeSpec Documentation**:
- Clear @doc for all public functions
- Usage examples in documentation
- Parameter constraints clearly specified

**TypeSpec Verification**:
- Run dialyzer with no warnings
- Test type constraints with invalid inputs
- Ensure 100% spec coverage for public API

## #{{standard-kpis}}
**Code Quality KPIs**
- Functions per module: ≤ 10
- Lines per function: ≤ 20
- Call depth: ≤ 3
- Test coverage: ≥ 90%
- Documentation coverage: 100%

## #{{def-no-dependencies}}
**Dependencies**
- None

## #{{example-reference}}
