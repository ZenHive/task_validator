# Project Task List

## Current Tasks

| ID | Description | Status | Priority | Assignee | Review Rating |
| --- | --- | --- | --- | --- | --- |
| PRJ0301 | Design user schema and migration | In Progress | High | - | - |

## Active Task Details

### PRJ0301: Design user schema and migration

**Description**
Create comprehensive user schema with proper database design and migration strategy.

{{data-layer-sections}}

**Simplicity Progression Plan**
1. Design schema fields and types
2. Create migration with indexes
3. Implement changeset validations
4. Add query helpers

**Simplicity Principle**
Clean schema design with efficient queries and proper constraints.

**Abstraction Evaluation**
Low - Direct Ecto schema with minimal abstraction.

**Requirements**
- Ecto schema with proper types and validations
- Safe database migrations
- Optimized query patterns
- Constraint and index strategy

{{test-requirements}}
{{typespec-requirements}}
{{ecto-kpis}}
{{ecto-error-handling}}
{{def-no-dependencies}}

**Status**: In Progress
**Priority**: High

#### 1. Design schema structure (PRJ0301-1)
**Description**
Define Ecto schema with appropriate field types, defaults, and relationships

**Status**
Planned

{{error-handling-subtask}}

#### 2. Create database migration (PRJ0301-2)
**Description**
Write migration with proper indexes, constraints, and rollback support

**Status**
Planned

{{error-handling-subtask}}

#### 3. Implement changeset functions (PRJ0301-3)
**Description**
Build changeset functions with validations and error handling

**Status**
Planned

{{error-handling-subtask}}

**Subtasks** (Quick items)
- [ ] Add unique index on email [PRJ0301a]
- [ ] Add database constraints [PRJ0301b]

## Reference Definitions

## #{{otp-error-handling}}
**Error Handling**
**OTP Principles**
- Let it crash with supervisor restart
- Use {:ok, result} | {:error, reason} for client functions
- Handle_call/3 returns for synchronous operations
**Supervision Strategy**
- Define restart strategy (permanent/temporary/transient)
- Set max_restarts and max_seconds appropriately
- Consider escalation to parent supervisor
**GenServer Specifics**
- Handle unexpected messages gracefully
- Use terminate/2 for cleanup when needed
- Proper state validation in handle_cast/2
**Error Examples**
- Client timeout: {:error, :timeout}
- Invalid state: {:error, :invalid_state}
- Resource unavailable: {:error, :unavailable}

## #{{phoenix-error-handling}}
**Error Handling**
**Phoenix Principles**
- Use action_fallback for controller error handling
- Leverage Plug.ErrorHandler for global error handling
- Return appropriate HTTP status codes
**LiveView Error Handling**
- Handle socket disconnects gracefully
- Validate assigns before rendering
- Use handle_info for async error recovery
**Context Layer**
- Return structured errors from contexts
- Use Ecto.Multi for transaction error handling
- Validate input at context boundaries
**Error Examples**
- Validation errors: {:error, %Ecto.Changeset{}}
- Not found: {:error, :not_found}
- Unauthorized: {:error, :unauthorized}

## #{{context-error-handling}}
**Error Handling**
**Context Principles**
- Return structured errors with clear reasons
- Use Ecto.Multi for complex transactions
- Validate input at context boundaries
**Error Examples**
- Validation: {:error, %Ecto.Changeset{}}
- Not found: {:error, :not_found}
- Constraint violation: {:error, :constraint_violation}

## #{{ecto-error-handling}}
**Error Handling**
**Ecto Principles**
- Use changesets for validation errors
- Handle constraint violations gracefully
- Use Multi for transactional operations
**Migration Safety**
- Always test rollback procedures
- Handle data integrity during migrations
- Use constraints instead of validations where possible
**Error Examples**
- Validation: {:error, %Ecto.Changeset{}}
- Constraint: {:error, :constraint_violation}
- Transaction: {:error, :transaction_failed}

## #{{infrastructure-error-handling}}
**Error Handling**
**Infrastructure Principles**
- Monitor system resources and limits
- Handle network failures gracefully
- Use circuit breakers for external services
**Deployment Safety**
- Health checks and readiness probes
- Graceful shutdown procedures
- Rollback strategies for failed deployments
**Error Examples**
- Resource exhaustion: {:error, :resource_limit}
- Network failure: {:error, :network_timeout}
- Service unavailable: {:error, :service_down}

## #{{error-handling-subtask}}
**Error Handling**
**Task-Specific Approach**
- Error pattern for this task
**Error Reporting**
- Monitoring approach

## #{{elixir-kpis}}
**Code Quality KPIs**
- Functions per module: ≤ 8 (Elixir modules tend to be focused)
- Lines per function: ≤ 12 (functional style favors small functions)
- Pattern match depth: ≤ 3 (avoid deeply nested patterns)
- GenServer state complexity: Simple maps/structs preferred
- Dialyzer warnings: Zero warnings required
- Credo score: Minimum A grade
- Test coverage: ≥ 95% line coverage
- Documentation coverage: 100% for public functions

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
- Functions per module: 8
- Lines per function: 15
- Call depth: 3

## #{{elixir-kpis}}
**Code Quality KPIs**
- Functions per module: 8
- Lines per function: 15
- Call depth: 3
- Pattern match depth: 4
- Dialyzer warnings: 0
- Credo score: 8.0

## #{{otp-kpis}}
**Code Quality KPIs**
- Functions per module: 8
- Lines per function: 15
- Call depth: 3
- Pattern match depth: 4
- Dialyzer warnings: 0
- Credo score: 8.0
- GenServer state complexity: 5

## #{{phoenix-kpis}}
**Code Quality KPIs**
- Functions per module: 8
- Lines per function: 15
- Call depth: 3
- Pattern match depth: 4
- Dialyzer warnings: 0
- Credo score: 8.0
- Phoenix context boundaries: 3

## #{{ecto-kpis}}
**Code Quality KPIs**
- Functions per module: 8
- Lines per function: 15
- Call depth: 3
- Pattern match depth: 4
- Dialyzer warnings: 0
- Credo score: 8.0
- Ecto query complexity: 4

## #{{phoenix-web-sections}}
**Route Design**
RESTful routes with proper HTTP verbs and path helpers. Clear resource mapping and nested routes where appropriate.

**Context Integration**
Clean integration with Phoenix contexts following domain boundaries. Minimal coupling between web and business logic layers.

**Template/Component Strategy**
LiveView components or traditional templates with proper separation of concerns. Reusable components and clear state management.

## #{{data-layer-sections}}
**Schema Design**
Well-normalized Ecto schemas with proper field types, constraints, and relationships. Clear separation of concerns.

**Migration Strategy**
Rollback-safe migrations with proper indexes and constraints. Zero-downtime deployment considerations.

**Query Optimization**
Efficient query patterns with proper preloading and indexes. Performance monitoring for critical database operations.

## #{{business-logic-sections}}
**Context Boundaries**
Clear domain boundaries with focused contexts. Minimal cross-context dependencies and clean public APIs.

**Business Rules**
Explicit business rule validation and enforcement. Clear error handling for business logic violations.

## #{{def-no-dependencies}}
**Dependencies**
- None
