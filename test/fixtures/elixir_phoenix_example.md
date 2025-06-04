# Elixir/Phoenix Application TaskList

This example demonstrates the new Elixir/Phoenix-specific task validation features including semantic prefixes, category-specific sections, and enhanced error handling templates.

## Tasks

| ID | Description | Status | Priority |
|----|-------------|--------|----------|
| OTP001 | Implement user session GenServer | Planned | High |
| PHX101 | Create user authentication LiveView | Planned | High |
| CTX201 | Design accounts context module | Planned | High |
| ECT301 | Create user schema and migration | Planned | High |
| TST501 | Unit tests for accounts context | Planned | High |
| TST502 | Integration tests for auth flow | Planned | Medium |
| INF401 | Setup monitoring and deployment | Planned | Medium |

---

## Task Details

### OTP001: Implement user session GenServer

**Description**
Implement a GenServer to manage user sessions with automatic cleanup and monitoring.

**Process Design**
GenServer with state containing active sessions map. Each session has a timeout timer.

**State Management**
State structure: `%{sessions: %{user_id => %Session{}}, monitors: %{ref => user_id}}`

**Supervision Strategy**
Supervised by SessionSupervisor with `:permanent` restart strategy, max 3 restarts in 5 seconds.

**API Design**
- `start_session(user_id, data)` - Creates new session
- `get_session(user_id)` - Retrieves session data
- `refresh_session(user_id)` - Extends session timeout
- `end_session(user_id)` - Terminates session

**Performance Considerations**
- ETS table for read-heavy workloads
- Session cleanup via timer references
- Monitor user processes for automatic cleanup

**ExUnit Test Requirements**
- Test GenServer initialization and state management
- Test session CRUD operations with edge cases
- Test automatic cleanup on process termination
- Test supervisor restart behavior
- Test concurrent session handling

**Integration Test Scenarios**
- Full session lifecycle testing
- Load testing with 1000+ concurrent sessions
- Supervisor failure and recovery testing
- Memory usage under load

**Typespec Requirements**
- All public functions must have @spec
- Define custom types for Session struct
- Document GenServer callback specifications
- Clear @doc for all public functions

**TypeSpec Documentation**
- Session data structure and constraints
- API function parameters and return types
- Error types and reasons

**TypeSpec Verification**
- Run dialyzer with no warnings
- Test with invalid session data
- Verify callback specifications

{{otp-error-handling}}

{{otp-kpis}}

**Dependencies**
- UserContext module
- Phoenix.PubSub for session events

**Status**: Planned
**Priority**: High


---

### PHX101: Create user authentication LiveView

**Description**
Build a LiveView-powered authentication system with real-time validation and smooth UX.

**Route Design**
- `GET /login` - Login LiveView
- `GET /register` - Registration LiveView
- `DELETE /logout` - Logout action

**Context Integration**
Uses Accounts context for user operations and SessionManager for session handling.

**Template/Component Strategy**
- Shared form component for login/register
- Real-time field validation components
- Loading state indicators

**Authorization**
Public routes with automatic redirect for authenticated users.

**Performance**
- Debounced validation (300ms)
- Optimistic UI updates
- Minimal socket assigns

**ExUnit Test Requirements**
- Test LiveView mount and authentication flow
- Test form validation and error display
- Test socket disconnection and recovery
- Test event handlers for all user actions
- Test flash message display

**Integration Test Scenarios**
- Complete authentication workflow
- Session timeout handling
- Concurrent login attempts
- Browser refresh during auth
- Network failure simulation

**Typespec Requirements**
- Define assigns structure with @type
- Specify event handler signatures
- Document socket state types
- Type all handle_event callbacks

**TypeSpec Documentation**
- LiveView assigns structure
- Event names and payloads
- Authentication state machine

**TypeSpec Verification**
- Dialyzer verification of all callbacks
- Test with malformed events
- Verify socket type safety

{{phoenix-error-handling}}

{{phoenix-kpis}}

**Dependencies**
- OTP001 (Session GenServer)
- CTX201 (Accounts Context)

**Status**: Planned
**Priority**: High


---

### CTX201: Design accounts context module

**Description**
Create the Accounts context to handle all user-related business logic.

**Context Boundaries**
Accounts context owns all user data and authentication logic. No direct Repo access outside context.

**Business Rules**
- Email must be unique and verified
- Passwords require minimum 12 characters
- Account lockout after 5 failed attempts

**API Design**
- `create_user/1` - User registration
- `authenticate_user/2` - Login validation
- `get_user!/1` - Fetch user by ID
- `update_user/2` - Profile updates

**Data Access**
All database operations go through the Accounts context. No direct Repo calls outside this module.

**Validation Strategy**
Input validation at context boundaries using Ecto changesets. Business rule validation in dedicated functions.

**ExUnit Test Requirements**
- Test all context functions with valid/invalid inputs
- Test business rule enforcement
- Test email uniqueness validation
- Test password complexity requirements
- Test account lockout mechanism

**Integration Test Scenarios**
- User registration with existing email
- Authentication with locked account
- Password reset workflow
- Concurrent user updates
- Transaction rollback scenarios

**Typespec Requirements**
- Define User.t() type
- Specify all context function signatures
- Document changeset types
- Type error reasons

**TypeSpec Documentation**
- User data structure
- Context API contracts
- Error types and meanings

**TypeSpec Verification**
- Full dialyzer coverage
- Test with invalid user data
- Verify error type returns

{{context-error-handling}}

{{business-logic-kpis}}

**Dependencies**
- ECT301 (User schema)

**Status**: Planned
**Priority**: High


---

### ECT301: Create user schema and migration

**Description**
Design and implement the user database schema with proper constraints and indexes.

**Schema Design**
```elixir
schema "users" do
  field :email, :string
  field :hashed_password, :string
  field :confirmed_at, :naive_datetime
  field :locked_at, :naive_datetime
  field :failed_attempts, :integer, default: 0
  
  timestamps()
end
```

**Migration Strategy**
- Create users table with constraints
- Add unique index on email
- Add index on confirmed_at for queries
- Include down migration for rollback

**Query Optimization**
- Index on `email` for authentication queries
- Partial index on `confirmed_at` where NULL
- Consider read replica for heavy loads

**Data Validation**
- Email format validation
- Password complexity requirements
- Confirmed_at must be past timestamp

**Database Considerations**
- Use citext for case-insensitive email
- Add check constraint for failed_attempts >= 0
- Consider partitioning for large datasets

**ExUnit Test Requirements**
- Test schema validations and constraints
- Test unique email constraint
- Test migration up and down
- Test query performance with indexes
- Test concurrent updates

**Integration Test Scenarios**
- Duplicate email insertion
- Migration rollback safety
- Index performance testing
- Constraint violation handling
- Large dataset queries

**Typespec Requirements**
- Define schema field types
- Specify changeset function signatures
- Document query return types
- Type cast functions

**TypeSpec Documentation**
- Schema structure and fields
- Changeset transformations
- Query builder functions

**TypeSpec Verification**
- Verify schema type definitions
- Test changeset type safety
- Validate query returns

{{ecto-error-handling}}

{{ecto-kpis}}

**Dependencies**
None

**Status**: Planned
**Priority**: High


---

### TST501: Unit tests for accounts context

**Description**
Comprehensive unit tests for the Accounts context module ensuring all business rules are enforced.

**Complexity Assessment**: Complex
Extensive test scenarios with property-based testing, multiple mock setups, and comprehensive edge case coverage justify higher KPI limits.

**Test Strategy**
Property-based testing with StreamData for user input validation. Traditional unit tests for business logic verification.

**Coverage Requirements**
100% test coverage for all public context functions. Edge case testing for all validation rules and error conditions.

**Test Categories**
- User creation and validation
- Authentication and password checking
- Account lockout mechanism
- Email uniqueness enforcement
- Password complexity validation

**ExUnit Test Requirements**
- Test valid user creation scenarios
- Test all validation failures
- Test concurrent operations
- Test transaction rollbacks
- Mock external dependencies

**Integration Test Scenarios**
- Database constraint testing
- Concurrent user creation
- Transaction isolation
- Performance benchmarks

**Typespec Requirements**
- Test helper function specs
- Mock data type definitions
- Assertion helper types

**TypeSpec Documentation**
- Test data factories
- Helper function contracts
- Mock interfaces

**TypeSpec Verification**
- Dialyzer on test modules
- Type-safe test helpers

**Property-Based Testing**
Use StreamData to generate random user inputs and verify invariants. Test email format validation and password complexity rules.

{{error-handling}}

**Code Quality KPIs**
- Functions per module: 15  # Complex: test scenarios, helpers, factories
- Lines per function: 25    # Complex: comprehensive test setup and assertions
- Call depth: 5             # Complex: nested test helpers and mocks
- Test speed: < 100ms per unit test
- Coverage: 100% of public API

**Dependencies**
- CTX201 (Accounts Context)
- ECT301 (User Schema)

**Status**: Planned
**Priority**: High

---

### TST502: Integration tests for auth flow

**Description**
End-to-end integration tests for the complete authentication workflow.

**Test Strategy**
Browser-based tests using Wallaby. API integration tests for backend flows.

**Coverage Requirements**
All critical user paths tested. Happy path and error scenarios covered.

**Test Scenarios**
- User registration flow
- Login with valid/invalid credentials
- Session management
- Password reset workflow
- Account lockout testing

**ExUnit Test Requirements**
- LiveView integration tests
- API endpoint testing
- Session persistence tests
- Concurrent user scenarios

**Integration Test Scenarios**
- Full browser automation
- Multi-step workflows
- Network failure simulation
- Performance under load

**Typespec Requirements**
- Integration test helpers
- Page object models
- API client specs

**TypeSpec Documentation**
- Test scenario definitions
- Helper function usage
- Assertion utilities

**TypeSpec Verification**
- Type-safe page objects
- Validated test data

**Property-Based Testing**
Generate random user interaction sequences to test state machine consistency. Verify session state transitions.

{{error-handling}}

**Code Quality KPIs**
- Functions per module: 16  # Testing category default: complex
- Lines per function: 30    # Testing category default: complex
- Call depth: 6             # Testing category default: complex
- Test duration: < 30s per scenario
- Flakiness: < 1% failure rate

**Dependencies**
- OTP001 (Session GenServer)
- PHX101 (LiveView Auth)
- CTX201 (Accounts Context)
- TST501 (Unit tests)

**Status**: Planned
**Priority**: Medium

---

### INF401: Setup monitoring and deployment

**Description**
Configure production monitoring, alerting, and deployment pipeline for the authentication system.

**Release Configuration**
Elixir releases with runtime configuration. Health check endpoints for load balancers.

**Environment Variables**
- DATABASE_URL
- SECRET_KEY_BASE
- SESSION_SIGNING_SALT
- SMTP configuration

**Deployment Strategy**
Blue-green deployment with automated rollback. Zero-downtime migrations.

**Monitoring Setup**
- AppSignal/New Relic integration
- Custom metrics for auth events
- Error tracking with Sentry
- Database query monitoring

**Health Checks**
- /health endpoint for basic checks
- /ready for dependency checks
- Database connection monitoring
- External service health

**ExUnit Test Requirements**
- Config loading tests
- Health endpoint tests
- Metric collection tests
- Alert threshold tests

**Integration Test Scenarios**
- Deployment simulation
- Rollback procedures
- Config hot-reloading
- Graceful shutdown

**Typespec Requirements**
- Config schema types
- Metric data types
- Health check responses

**TypeSpec Documentation**
- Configuration options
- Metric definitions
- Alert conditions

**TypeSpec Verification**
- Runtime config validation
- Type-safe metrics

{{infrastructure-error-handling}}

**Code Quality KPIs**
- Functions per module: 8
- Lines per function: 15
- Call depth: 3
- Startup time: < 30 seconds
- Memory usage: < 512MB base
- Response time: < 100ms p95
- Error rate: < 0.1%
- Availability: 99.9%

**Dependencies**
- All application tasks

**Status**: Planned
**Priority**: Medium

---

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
- All functions return {:ok, result} or {:error, reason}
- Use Ecto.Multi for complex transactions
- Wrap external service calls with proper error handling
**Validation Strategy**
- Validate at context boundaries before DB operations
- Return changesets for detailed validation errors
- Use custom error types for business rule violations
**Transaction Handling**
- Use Ecto.Multi for multi-step operations
- Define clear rollback strategies
- Log transaction failures with context
**Error Examples**
- Invalid input: {:error, %Ecto.Changeset{}}
- Business rule violation: {:error, :account_locked}
- External service failure: {:error, :service_unavailable}

## #{{ecto-error-handling}}
**Error Handling**
**Ecto Principles**
- Use changesets for validation errors
- Handle constraint violations gracefully
- Properly handle transaction failures
**Migration Safety**
- Always test rollback procedures
- Use transactions for data migrations
- Handle partial migration failures
**Query Error Handling**
- Use ! functions only when errors are unexpected
- Handle Ecto.NoResultsError appropriately
- Consider using Repo.one vs Repo.one!
**Error Examples**
- Constraint violation: {:error, :unique_violation}
- Invalid changeset: {:error, %Ecto.Changeset{}}
- Query timeout: {:error, :timeout}

## #{{otp-kpis}}
**Code Quality KPIs**
- **Functions per module**: ≤ 8
- **Lines per function**: ≤ 15
- **GenServer state complexity**: Simple maps/structs only
- **Message handling time**: < 100ms per handle_* callback
- **Supervision tree depth**: ≤ 3 levels
- **Process memory usage**: Monitor and alert on > 100MB

## #{{phoenix-kpis}}
**Code Quality KPIs**
- **Functions per module**: ≤ 8
- **Lines per function**: ≤ 15
- **LiveView mount complexity**: Minimal initial assigns
- **Socket memory usage**: < 1MB per connection
- **Event handler time**: < 50ms per handle_event
- **Template complexity**: Extract components for reuse

## #{{business-logic-kpis}}
**Code Quality KPIs**
- **Functions per module**: ≤ 8
- **Lines per function**: ≤ 15
- **Context API surface**: ≤ 10 public functions
- **Function arity**: ≤ 3 parameters preferred
- **Query complexity**: Preload associations efficiently
- **Test coverage**: 100% for public API

## #{{ecto-kpis}}
**Code Quality KPIs**
- **Functions per module**: ≤ 8
- **Lines per function**: ≤ 15
- **Migration complexity**: One concern per migration
- **Query joins**: ≤ 3 tables per query
- **Index usage**: All WHERE clauses indexed
- **Schema associations**: ≤ 5 per schema

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

## #{{infrastructure-error-handling}}
**Error Handling**
**Infrastructure Principles**
- Graceful degradation for external services
- Circuit breakers and retries with backoff
- Health check based automatic recovery
**Deployment Safety**
- Blue-green deployment with validation
- Automated rollback on failure
- Smoke tests in staging environment
**Monitoring Integration**
- Error rates tracked in metrics
- Alerts on threshold breaches
- Detailed error logging with context
**Error Examples**
- Database connection pool exhausted
- External API timeout or 5xx
- Configuration missing or invalid