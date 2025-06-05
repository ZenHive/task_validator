# Sample Task List

This is a complete sample task list demonstrating all features of TaskValidator.

```markdown
# Project Task List

## Current Tasks

| ID | Description | Status | Priority | Assignee | Review Rating |
| --- | --- | --- | --- | --- | --- |
| OTP0001 | Implement GenServer worker pool | In Progress | High | alice | - |
| PHX0101 | Create user registration LiveView | Planned | High | - | - |
| CTX0201 | Design order management context | Planned | Medium | bob | - |

## Completed Tasks

| ID | Description | Status | Priority | Assignee | Review Rating |
| --- | --- | --- | --- | --- | --- |
| OTP0002 | Set up supervision tree | Completed | High | alice | 4.5 |
| DB0301 | Create user schema | Completed | High | charlie | 5.0 |

## Active Task Details

### OTP0001: Implement GenServer worker pool

**Description**
Create a pool of GenServer workers for handling background jobs with proper load balancing and fault tolerance.

**Simplicity Progression Plan**
1. Design worker GenServer module
2. Implement pool supervisor
3. Add job distribution logic
4. Create monitoring and metrics

**Simplicity Principle**
Use OTP patterns with minimal custom abstractions. Leverage existing poolboy library if complexity warrants.

**Abstraction Evaluation**
Medium - Standard OTP patterns with pool management abstraction.

**Requirements**
- Pool of 5-10 workers
- Job queue with priority support
- Automatic worker restart on failure
- Metrics and monitoring
- Backpressure handling

**Process Design**
GenServer workers managed by a DynamicSupervisor. Each worker maintains its own job queue with overflow to siblings.

**State Management**
Worker state includes current job, queue, and metrics. Pool supervisor tracks worker availability.

**Supervision Strategy**
One-for-one restart strategy with max_restarts: 3, max_seconds: 60. Worker failures don't affect siblings.

{{test-requirements}}
{{typespec-requirements}}
{{otp-error-handling}}
{{otp-kpis}}

**Dependencies**
- None

**Architecture Notes**
Standard OTP worker pool pattern with custom job distribution.

**Complexity Assessment**
Medium - Requires careful state management and job distribution logic.

**Status**: In Progress
**Priority**: High

#### 1. Design worker GenServer module (OTP0001-1)
**Description**
Create the worker GenServer with job processing callbacks

**Status**
Completed

**Review Rating**
4.5

{{error-handling-subtask}}

#### 2. Implement pool supervisor (OTP0001-2)
**Description**
Set up DynamicSupervisor for managing worker processes

**Status**
In Progress

{{error-handling-subtask}}

#### 3. Add job distribution logic (OTP0001-3)
**Description**
Implement smart job routing to available workers

**Status**
Planned

{{error-handling-subtask}}

### PHX0101: Create user registration LiveView

**Description**
Build a real-time user registration form with live validation and smooth UX.

{{phoenix-web-sections}}

**Simplicity Progression Plan**
1. Create LiveView module structure
2. Implement form with changesets
3. Add real-time validations
4. Integrate with Accounts context

**Simplicity Principle**
Leverage Phoenix LiveView patterns with minimal custom JavaScript.

**Abstraction Evaluation**
Low - Direct use of LiveView features.

**Requirements**
- Email and password fields
- Real-time validation feedback
- Password strength indicator
- Terms acceptance
- Email confirmation flow

{{test-requirements}}
{{typespec-requirements}}
{{phoenix-error-handling}}
{{phoenix-kpis}}
{{def-no-dependencies}}

**Status**: Planned
**Priority**: High

### CTX0201: Design order management context

**Description**
Create a comprehensive order management context with proper business logic separation.

{{business-logic-sections}}

**Simplicity Progression Plan**
1. Define context API and functions
2. Implement order CRUD operations
3. Add business rule validations
4. Optimize query patterns

**Simplicity Principle**
Clear context boundaries with focused, testable business logic.

**Abstraction Evaluation**
Medium - Context pattern provides clean separation from web layer.

**Requirements**
- Order lifecycle management
- Inventory integration
- Pricing calculations
- Order status tracking

{{test-requirements}}
{{typespec-requirements}}
{{context-error-handling}}
{{phoenix-kpis}}
{{def-no-dependencies}}

**Status**: Planned
**Priority**: Medium

## Completed Task Details

### OTP0002: Set up supervision tree

**Description**
Design and implement the application supervision tree with proper restart strategies.

**Process Design**
Application supervisor with separate subtrees for web, workers, and background jobs.

**State Management**
Minimal supervisor state, relying on OTP defaults.

**Supervision Strategy**
Rest-for-one strategy at top level, one-for-one for subsystems.

{{test-requirements}}
{{typespec-requirements}}
{{otp-error-handling}}
{{otp-kpis}}
{{def-no-dependencies}}

**Architecture Notes**
Clean separation of concerns with isolated failure domains.

**Implementation Notes**
Used standard OTP supervision patterns with three main subtrees.

**Complexity Assessment**
Low - Standard OTP patterns throughout.

**Maintenance Impact**
Low - Well-understood OTP patterns make maintenance straightforward.

**Error Handling Implementation**
Supervisor handles all crashes with appropriate restart strategies.

**Status**: Completed
**Priority**: High
**Review Rating**: 4.5

### DB0301: Create user schema

**Description**
Design and implement the User schema with authentication fields.

{{data-layer-sections}}

**Simplicity Progression Plan**
1. Define schema fields
2. Create migration
3. Add changesets
4. Implement query helpers

**Simplicity Principle**
Simple schema with standard Ecto patterns.

**Abstraction Evaluation**
Low - Direct Ecto usage.

**Requirements**
- User authentication fields
- Profile information
- Timestamps and soft delete
- Unique constraints

{{test-requirements}}
{{typespec-requirements}}
{{ecto-error-handling}}
{{ecto-kpis}}
{{def-no-dependencies}}

**Architecture Notes**
Standard Ecto schema with careful index planning.

**Implementation Notes**
Clean schema with separate changesets for different operations.

**Complexity Assessment**
Low - Standard Ecto patterns.

**Maintenance Impact**
Low - Well-structured schema with clear boundaries.

**Error Handling Implementation**
Changeset-based validation with database constraints as backup.

**Status**: Completed
**Priority**: High
**Review Rating**: 5.0

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

## #{{error-handling-subtask}}
**Error Handling**
**Task-Specific Approach**
- Error pattern for this task
**Error Reporting**
- Monitoring approach

## #{{test-requirements}}
**ExUnit Test Requirements**
- Integration tests FIRST against real dependencies
- Document actual behavior before mocking
- Unit tests extracted from integration test observations
- Test error paths with real error conditions
- Verify supervisor integration with real processes

**Integration Test Scenarios**
- Real GenServer processes under supervision
- Actual message passing and timeouts
- Real process crashes and restarts
- Genuine state persistence and recovery
- Actual distributed node communication
- Real resource exhaustion scenarios

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
RESTful routes with proper HTTP verbs and path helpers.

**Context Integration**
Clean integration with Phoenix contexts following domain boundaries.

**Template/Component Strategy**
LiveView components for real-time features, traditional templates for static content.

## #{{data-layer-sections}}
**Schema Design**
Well-normalized schemas with proper field types and constraints.

**Migration Strategy**
Rollback-safe migrations with proper indexes.

**Query Optimization**
Efficient queries with proper preloading.

## #{{business-logic-sections}}
**Context Boundaries**
Clear domain boundaries with focused contexts. Minimal cross-context dependencies and clean public APIs.

**Business Rules**
Explicit business rule validation and enforcement. Clear error handling for business logic violations.

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

## #{{def-no-dependencies}}
**Dependencies**
- None
```

## Key Features Demonstrated

1. **Multiple Task Categories** - OTP, Phoenix, Context, Database tasks
2. **Both Task Formats** - Numbered and checkbox subtasks
3. **Status Progression** - In Progress with subtasks, Completed with all sections
4. **Reference System** - Extensive use of references to reduce duplication
5. **Category Sections** - Process Design, Route Design, Schema Design
6. **Error Handling** - Both main task and subtask formats
7. **Review Ratings** - Proper format for completed tasks

## Common Patterns

### Starting a New Task
1. Add to Current Tasks table
2. Create detailed section with all required fields
3. Use appropriate category-specific sections
4. Start with "Planned" status

### Moving to In Progress
1. Change status to "In Progress"
2. Add numbered subtasks for major work
3. Or add checkbox subtasks for minor items
4. Update main table

### Completing a Task
1. Add Implementation Notes
2. Add Complexity Assessment
3. Add Maintenance Impact
4. Add Error Handling Implementation
5. Add Review Rating
6. Move to Completed Tasks table

## Validation

This sample passes all validation rules:
```bash
mix validate_tasklist --path guides/sample_tasklist.md
```

Use this as a template for your own task lists!