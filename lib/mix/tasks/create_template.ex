defmodule Mix.Tasks.TaskValidator.CreateTemplate do
  @shortdoc "Creates a template TaskList.md with example tasks"

  @moduledoc """
  Creates a template TaskList.md file with example tasks.

  This task generates a new TaskList.md file with example tasks that follow
  the required structure and format specifications. Use this as a starting
  point for your own task list.

  ## Usage

      mix task_validator.create_template [OPTIONS]

  ## Options

      --path       Path where to create the TaskList.md file (default: ./TaskList.md)
      --prefix     Project prefix for example tasks (default: PRJ)
      --category   Task category to generate template for (default: phoenix_web)
      --semantic   Use semantic prefixes instead of custom prefix

  ## Categories

  Each category generates a template tailored for specific development areas:

      * otp_genserver    - OTP/GenServer development (processes, supervisors, state management)
      * phoenix_web      - Phoenix web development (LiveView, controllers, routes)
      * business_logic   - Phoenix contexts and domain logic (CRUD operations, validations)
      * data_layer       - Ecto schemas and database design (migrations, queries)
      * infrastructure   - Deployment and DevOps (releases, monitoring, configuration)
      * testing          - Test implementation (unit tests, integration, property-based)

  ## Semantic Prefixes

  When using --semantic, the following domain-specific prefixes are used:

      * OTP - OTP/GenServer tasks
      * PHX - Phoenix web tasks
      * CTX - Context/business logic tasks
      * DB  - Database/Ecto tasks
      * INF - Infrastructure tasks
      * TST - Testing tasks

  ## Examples

      # Generate default Phoenix web template
      mix task_validator.create_template

      # Generate OTP template with custom prefix
      mix task_validator.create_template --path ./docs/TaskList.md --prefix SSH --category otp_genserver

      # Generate testing template with semantic prefix (TST)
      mix task_validator.create_template --category testing --semantic

      # Generate all templates in a directory
      for cat in otp_genserver phoenix_web business_logic data_layer infrastructure testing; do
        mix task_validator.create_template --category $cat --path docs/$cat.md
      done

  ## Template Features

  All generated templates include:

      * Main tasks demonstrating "In Progress" status with subtasks
      * Numbered subtasks with full sections (Status, Error Handling)
      * Checkbox subtasks for minor items (phoenix_web and data_layer templates)
      * Completed task examples with all required sections
      * Proper use of the reference system ({{error-handling}}, {{test-requirements}}, etc.)
      * Category-specific sections and requirements

  The generated templates are guaranteed to pass validation.
  """

  use Mix.Task

  @reference_definitions """

  ## Reference Definitions

  ## \#{{otp-error-handling}}
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

  ## \#{{phoenix-error-handling}}
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

  ## \#{{context-error-handling}}
  **Error Handling**
  **Context Principles**
  - Return structured errors with clear reasons
  - Use Ecto.Multi for complex transactions
  - Validate input at context boundaries
  **Error Examples**
  - Validation: {:error, %Ecto.Changeset{}}
  - Not found: {:error, :not_found}
  - Constraint violation: {:error, :constraint_violation}

  ## \#{{ecto-error-handling}}
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

  ## \#{{infrastructure-error-handling}}
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

  ## \#{{error-handling-subtask}}
  **Error Handling**
  **Task-Specific Approach**
  - Error pattern for this task
  **Error Reporting**
  - Monitoring approach

  ## \#{{elixir-kpis}}
  **Code Quality KPIs**
  - Functions per module: ≤ 8 (Elixir modules tend to be focused)
  - Lines per function: ≤ 12 (functional style favors small functions)
  - Pattern match depth: ≤ 3 (avoid deeply nested patterns)
  - GenServer state complexity: Simple maps/structs preferred
  - Dialyzer warnings: Zero warnings required
  - Credo score: Minimum A grade
  - Test coverage: ≥ 95% line coverage
  - Documentation coverage: 100% for public functions

  ## \#{{error-handling}}
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

  ## \#{{test-requirements}}
  **ExUnit Test Requirements**:
  - Comprehensive unit tests
  - Edge case testing
  - Error condition testing

  **Integration Test Scenarios**:
  - End-to-end validation
  - Performance testing
  - Concurrent operation testing

  ## \#{{typespec-requirements}}
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

  ## \#{{standard-kpis}}
  **Code Quality KPIs**
  - Functions per module: 8
  - Lines per function: 15
  - Call depth: 3

  ## \#{{elixir-kpis}}
  **Code Quality KPIs**
  - Functions per module: 8
  - Lines per function: 15
  - Call depth: 3
  - Pattern match depth: 4
  - Dialyzer warnings: 0
  - Credo score: 8.0

  ## \#{{otp-kpis}}
  **Code Quality KPIs**
  - Functions per module: 8
  - Lines per function: 15
  - Call depth: 3
  - Pattern match depth: 4
  - Dialyzer warnings: 0
  - Credo score: 8.0
  - GenServer state complexity: 5

  ## \#{{phoenix-kpis}}
  **Code Quality KPIs**
  - Functions per module: 8
  - Lines per function: 15
  - Call depth: 3
  - Pattern match depth: 4
  - Dialyzer warnings: 0
  - Credo score: 8.0
  - Phoenix context boundaries: 3

  ## \#{{ecto-kpis}}
  **Code Quality KPIs**
  - Functions per module: 8
  - Lines per function: 15
  - Call depth: 3
  - Pattern match depth: 4
  - Dialyzer warnings: 0
  - Credo score: 8.0
  - Ecto query complexity: 4

  ## \#{{phoenix-web-sections}}
  **Route Design**
  RESTful routes with proper HTTP verbs and path helpers. Clear resource mapping and nested routes where appropriate.

  **Context Integration**
  Clean integration with Phoenix contexts following domain boundaries. Minimal coupling between web and business logic layers.

  **Template/Component Strategy**
  LiveView components or traditional templates with proper separation of concerns. Reusable components and clear state management.

  ## \#{{data-layer-sections}}
  **Schema Design**
  Well-normalized Ecto schemas with proper field types, constraints, and relationships. Clear separation of concerns.

  **Migration Strategy**
  Rollback-safe migrations with proper indexes and constraints. Zero-downtime deployment considerations.

  **Query Optimization**
  Efficient query patterns with proper preloading and indexes. Performance monitoring for critical database operations.

  ## \#{{business-logic-sections}}
  **Context Boundaries**
  Clear domain boundaries with focused contexts. Minimal cross-context dependencies and clean public APIs.

  **Business Rules**
  Explicit business rule validation and enforcement. Clear error handling for business logic violations.

  ## \#{{def-no-dependencies}}
  **Dependencies**
  - None
  """

  @otp_genserver_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement GenServer worker | Planned | High | - | - |
  | <%= @prefix %>0002 | Add supervision tree | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %>0003 | Project setup | Completed | High | developer1 | 4.5 |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Implement GenServer worker

  **Description**
  Develop a GenServer-based worker process with proper OTP patterns, state management, and supervision integration.

  **Simplicity Progression Plan**
  1. Define GenServer callbacks and state structure
  2. Implement basic client API functions
  3. Add state validation and error handling
  4. Integrate with supervision tree

  **Simplicity Principle**
  Follow OTP conventions with minimal state and clear separation between client and server functions.

  **Abstraction Evaluation**
  Low-level GenServer implementation with clear API boundaries and minimal abstraction layers.

  **Requirements**
  - GenServer implementation with proper callbacks
  - Client API with {:ok, result} | {:error, reason} patterns
  - State validation and transition management
  - Integration with supervision tree
  - Comprehensive test coverage

  **Process Design**
  GenServer chosen for stateful process with synchronous and asynchronous operations. State-based message handling with proper timeout management.

  **State Management**
  Simple map-based state with version tracking and periodic cleanup. Clear state transitions with validation on each update.

  **Supervision Strategy**
  Permanent restart strategy with exponential backoff. Parent supervisor escalation after 3 restarts in 60 seconds.

  {{test-requirements}}
  {{typespec-requirements}}
  {{otp-error-handling}}
  {{otp-kpis}}
  {{def-no-dependencies}}

  **Architecture Notes**
  Standard OTP GenServer pattern with proper client/server separation.

  **Complexity Assessment**
  Medium - Requires understanding of OTP patterns and state management.

  **Status**: In Progress
  **Priority**: High

  #### 1. Define GenServer callbacks and state (<%= @prefix %><%= @task_number %>-1)
  **Description**
  Implement init/1, handle_call/3, handle_cast/2, and handle_info/2 callbacks with proper state structure

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 2. Implement client API functions (<%= @prefix %><%= @task_number %>-2)
  **Description**
  Create public API functions that interface with the GenServer using call/cast appropriately

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 3. Add state validation (<%= @prefix %><%= @task_number %>-3)
  **Description**
  Implement state validation on transitions and handle invalid state scenarios

  **Status**
  Planned

  {{error-handling-subtask}}

  ### <%= @prefix %>0002: Add supervision tree

  **Description**
  Design and implement supervision tree with proper restart strategies and escalation patterns.

  **Simplicity Progression Plan**
  1. Design supervision tree structure
  2. Implement supervisor with restart strategies
  3. Add dynamic child management
  4. Integrate health monitoring

  **Simplicity Principle**
  Standard OTP supervision patterns with minimal configuration and clear escalation paths.

  **Abstraction Evaluation**
  Direct supervision implementation following OTP best practices

  **Requirements**
  - Supervisor implementation with proper strategies
  - Dynamic child process management
  - Health monitoring and metrics
  - Graceful shutdown handling

  **Process Design**
  Supervisor with one_for_one strategy managing worker processes. Dynamic child management with proper shutdown procedures.

  **State Management**
  Supervisor state tracking child processes with health monitoring and restart statistics.

  **Supervision Strategy**
  One_for_one restart with max_restarts: 3, max_seconds: 60. Escalate to parent supervisor on repeated failures.

  {{test-requirements}}
  {{typespec-requirements}}
  {{otp-error-handling}}
  {{otp-kpis}}

  **Dependencies**
  - <%= @prefix %><%= @task_number %>

  **Architecture Notes**
  Standard OTP supervision tree following established patterns.

  **Complexity Assessment**
  Low - Uses well-established OTP supervisor patterns.

  **Status**: Planned
  **Priority**: Medium

  ## Completed Task Details

  ### <%= @prefix %>0003: Project setup

  **Description**
  Initial project setup and structure implementation.

  **Simplicity Progression Plan**
  Incremental setup of project components with proper tooling.

  **Simplicity Principle**
  Clear organization and separation of concerns with standard Elixir project structure.

  **Abstraction Evaluation**
  Low - Standard project structure with minimal abstraction.

  **Requirements**
  - Mix project initialization
  - Directory structure setup
  - Basic configuration and dependencies

  **Process Design**
  Standard OTP application structure with proper supervision tree setup.

  **State Management**
  Application configuration state with environment-based management.

  **Supervision Strategy**
  One-for-one supervision with application startup and shutdown handling.

  {{test-requirements}}
  {{typespec-requirements}}
  {{otp-error-handling}}
  {{otp-kpis}}
  {{def-no-dependencies}}

  **Architecture Notes**
  Standard OTP application structure with proper supervision tree.

  **Implementation Notes**
  Elegant setup using standard Mix tasks with minimal custom configuration.

  **Complexity Assessment**
  Low - Used built-in Mix tooling with minimal custom code.

  **Maintenance Impact**
  Low - Self-contained setup with clear interface.

  **Error Handling Implementation**
  Used standard OTP patterns with minimal custom error handling.

  **Status**: Completed
  **Priority**: High
  **Review Rating**: 4.5
  """

  @phoenix_web_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement user authentication LiveView | In Progress | High | - | - |
  | <%= @prefix %>0102 | Add product catalog controller | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %>0103 | Phoenix project setup | Completed | High | developer1 | 4.5 |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Implement user authentication LiveView

  **Description**
  Create a LiveView-based authentication system with real-time validation and smooth UX.

  {{phoenix-web-sections}}

  **Simplicity Progression Plan**
  1. Design route structure and controller actions
  2. Implement LiveView component with form handling
  3. Add real-time validation and error feedback
  4. Integrate with authentication context

  **Simplicity Principle**
  Clean separation between web layer and business logic with intuitive user experience.

  **Abstraction Evaluation**
  Medium - Phoenix conventions with LiveView abstraction for rich interactions.

  **Requirements**
  - LiveView authentication form with real-time validation
  - Session management and secure token handling
  - Flash messages and error feedback
  - Responsive design and accessibility

  {{test-requirements}}
  {{typespec-requirements}}
  {{def-no-dependencies}}

  {{elixir-kpis}}

  {{phoenix-error-handling}}

  **Status**: In Progress
  **Priority**: High

  #### 1. Design LiveView component structure (<%= @prefix %><%= @task_number %>-1)
  **Description**
  Create the LiveView module structure with proper mount/2, render/1, and handle_event/3 callbacks

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 2. Implement form validation (<%= @prefix %><%= @task_number %>-2)
  **Description**
  Add real-time validation with error display and user feedback

  **Status**
  Planned

  {{error-handling-subtask}}

  **Subtasks** (Simplified checkbox format for minor items)
  - [ ] Design LiveView component structure [<%= @prefix %><%= @task_number %>a]
  - [ ] Implement form validation [<%= @prefix %><%= @task_number %>b]
  - [ ] Add session management [<%= @prefix %><%= @task_number %>c]
  - [ ] Style and UX polish [<%= @prefix %><%= @task_number %>d]

  ### <%= @prefix %>0102: Add product catalog controller

  **Description**
  Implement RESTful product catalog with pagination, search, and filtering capabilities.

  **Route Design**
  Standard RESTful routes with nested resources and query parameter handling for search and filters.

  **Context Integration**
  Integration with Products context for data access, search indexing, and inventory management.

  **Template/Component Strategy**
  Server-rendered templates with Phoenix components for product cards and pagination.

  **Simplicity Progression Plan**
  1. Create controller actions and route definitions
  2. Implement basic product listing and pagination
  3. Add search and filtering functionality
  4. Optimize database queries and caching

  **Simplicity Principle**
  Standard Phoenix patterns with efficient database access and clean template organization.

  **Abstraction Evaluation**
  Low - Direct Phoenix controller implementation with minimal abstractions.

  **Requirements**
  - RESTful product CRUD operations
  - Pagination and search functionality
  - Image upload and management
  - Performance optimization for large catalogs

  {{test-requirements}}
  {{typespec-requirements}}
  {{def-no-dependencies}}

  {{elixir-kpis}}

  {{phoenix-error-handling}}

  **Status**: Planned
  **Priority**: Medium

  ## Completed Task Details

  ### <%= @prefix %>0103: Phoenix project setup

  **Description**
  Initial Phoenix project setup with basic configuration and dependencies.

  **Route Design**
  Basic router setup with health check endpoint and static asset serving.

  **Context Integration**
  Initial context structure following Phoenix conventions.

  **Template/Component Strategy**
  Standard Phoenix template structure with layouts and components.

  **Simplicity Progression Plan**
  1. Generate Phoenix project
  2. Configure dependencies
  3. Setup database
  4. Configure deployment

  **Simplicity Principle**
  Start with minimal Phoenix setup and add features progressively.

  **Abstraction Evaluation**
  Low - Standard Phoenix project structure.

  **Requirements**
  - Phoenix project generation
  - Database configuration
  - Basic route setup
  - Development environment

  **ExUnit Test Requirements**
  - Basic controller tests
  - Router tests
  - View tests

  **Integration Test Scenarios**
  - Application startup
  - Database connectivity
  - Basic route access

  **Typespec Requirements**
  - Basic type definitions
  - Controller types

  **TypeSpec Documentation**
  Standard Phoenix type documentation

  **TypeSpec Verification**
  Basic dialyzer setup

  **Dependencies**
  - None

  {{elixir-kpis}}

  {{phoenix-error-handling}}

  **Architecture Notes**
  Standard Phoenix architecture with contexts.

  **Implementation Notes**
  Used Phoenix generators for initial setup.

  **Complexity Assessment**
  Low - Standard Phoenix setup.

  **Maintenance Impact**
  Low - Following Phoenix conventions.

  **Error Handling Implementation**
  Standard Phoenix error handling with fallback controller.

  **Status**: Completed
  **Priority**: High
  **Review Rating**: 4.5
  """

  @business_logic_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement user management context | In Progress | High | - | - |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Implement user management context

  **Description**
  Create a comprehensive user management context with proper business logic separation.

  {{business-logic-sections}}

  **Simplicity Progression Plan**
  1. Define context API and functions
  2. Implement user CRUD operations
  3. Add business rule validations
  4. Optimize query patterns

  **Simplicity Principle**
  Clear context boundaries with focused, testable business logic.

  **Abstraction Evaluation**
  Medium - Context pattern provides clean separation from web layer.

  **Requirements**
  - Context module with clear API boundaries
  - Comprehensive changesets and validations
  - Optimized database queries
  - Business rule enforcement

  {{test-requirements}}
  {{typespec-requirements}}
  {{phoenix-kpis}}
  {{context-error-handling}}
  {{def-no-dependencies}}

  **Status**: In Progress
  **Priority**: High

  #### 1. Define context API functions (<%= @prefix %><%= @task_number %>-1)
  **Description**
  Create the public API for the user management context with proper function signatures

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 2. Implement user CRUD operations (<%= @prefix %><%= @task_number %>-2)
  **Description**
  Build create_user, update_user, get_user, list_users with proper error handling

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 3. Add business validations (<%= @prefix %><%= @task_number %>-3)
  **Description**
  Implement domain-specific validations and business rules

  **Status**
  Planned

  {{error-handling-subtask}}
  """

  @data_layer_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Design user schema and migration | In Progress | High | - | - |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Design user schema and migration

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

  #### 1. Design schema structure (<%= @prefix %><%= @task_number %>-1)
  **Description**
  Define Ecto schema with appropriate field types, defaults, and relationships

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 2. Create database migration (<%= @prefix %><%= @task_number %>-2)
  **Description**
  Write migration with proper indexes, constraints, and rollback support

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 3. Implement changeset functions (<%= @prefix %><%= @task_number %>-3)
  **Description**
  Build changeset functions with validations and error handling

  **Status**
  Planned

  {{error-handling-subtask}}

  **Subtasks** (Quick items)
  - [ ] Add unique index on email [<%= @prefix %><%= @task_number %>a]
  - [ ] Add database constraints [<%= @prefix %><%= @task_number %>b]
  """

  @infrastructure_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Configure production release | In Progress | High | - | - |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Configure production release

  **Description**
  Set up production release configuration with proper deployment and monitoring.

  **Release Configuration**
  Elixir release with proper runtime configuration, clustering, and resource limits.

  **Environment Variables**
  Secure configuration management with runtime.exs and environment-specific settings.

  **Deployment Strategy**
  Blue-green deployment with health checks, rollback procedures, and monitoring integration.

  **Simplicity Progression Plan**
  1. Configure Elixir releases
  2. Set up runtime configuration
  3. Implement health checks
  4. Add monitoring integration

  **Simplicity Principle**
  Standard release configuration with minimal custom scripts.

  **Abstraction Evaluation**
  Low - Direct use of Elixir release tooling.

  **Requirements**
  - Production-ready release configuration
  - Secure secret management
  - Monitoring and observability
  - Deployment automation

  {{test-requirements}}
  {{typespec-requirements}}
  {{elixir-kpis}}
  {{infrastructure-error-handling}}

  **Dependencies**
  - All application tasks

  **Status**: In Progress
  **Priority**: High

  #### 1. Configure Elixir releases (<%= @prefix %><%= @task_number %>-1)
  **Description**
  Set up mix release configuration with proper settings for production

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 2. Set up runtime configuration (<%= @prefix %><%= @task_number %>-2)
  **Description**
  Implement runtime.exs with environment variable handling

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 3. Implement health checks (<%= @prefix %><%= @task_number %>-3)
  **Description**
  Add health check endpoints and readiness probes

  **Status**
  Planned

  {{error-handling-subtask}}
  """

  @testing_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement comprehensive testing strategy | In Progress | High | - | - |
  | <%= @prefix %>0502 | Add property-based testing | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Completed By | Review Rating |
  | --- | --- | --- | ------------ | ------------- |
  | <%= @prefix %>0503 | Set up test infrastructure | Completed | developer1 | 4.5 |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Implement comprehensive testing strategy

  **Description**
  Design and implement comprehensive testing approach covering unit, integration, and performance testing.

  **Simplicity Progression Plan**
  1. Define testing strategy
  2. Implement unit tests
  3. Add integration tests
  4. Set up performance testing

  **Simplicity Principle**
  Comprehensive test coverage with maintainable test code and clear assertions.

  **Abstraction Evaluation**
  Test abstractions that simplify test writing while maintaining clarity

  **Requirements**
  - Unit test coverage
  - Integration test scenarios
  - Performance benchmarks
  - Continuous integration

  **ExUnit Test Requirements**
  - Comprehensive unit tests
  - Property-based testing
  - Mock and stub strategies

  **Integration Test Scenarios**
  - End-to-end workflow testing
  - External service integration
  - Error condition testing

  **Typespec Requirements**
  - Test helper type definitions
  - Mock interface specifications

  **TypeSpec Documentation**
  Clear documentation of test interfaces and utilities

  **TypeSpec Verification**
  Type-safe test utilities and helpers

  **Dependencies**
  - None

  **Code Quality KPIs**
  - Functions per module: 3
  - Lines per function: 12
  - Call depth: 2

  **Test Strategy**
  Comprehensive approach using unit tests, integration tests, and performance benchmarks

  **Coverage Requirements**
  Minimum 90% code coverage with focus on critical business logic and error paths

  **Property-Based Testing**
  StreamData generators for input validation and property verification

  {{error-handling}}

  **Status**: In Progress
  **Priority**: High

  #### 1. Design test architecture (<%= @prefix %><%= @task_number %>-1)
  **Description**
  Create test helper modules and establish testing patterns for the codebase

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 2. Implement unit test suite (<%= @prefix %><%= @task_number %>-2)
  **Description**
  Build comprehensive unit tests for all modules with edge case coverage

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 3. Add integration tests (<%= @prefix %><%= @task_number %>-3)
  **Description**
  Create end-to-end tests that verify component interactions

  **Status**
  Planned

  {{error-handling-subtask}}

  #### 4. Set up performance benchmarks (<%= @prefix %><%= @task_number %>-4)
  **Description**
  Implement performance tests and benchmarks for critical paths

  **Status**
  Planned

  {{error-handling-subtask}}

  **Architecture Notes**
  Modular test structure with shared test helpers

  **Complexity Assessment**
  Medium - Requires comprehensive coverage strategy

  ### <%= @prefix %>0502: Add property-based testing

  **Description**
  Integrate StreamData for property-based testing of core functions.

  **Simplicity Progression Plan**
  1. Add StreamData dependency
  2. Create generators for domain types
  3. Write property tests
  4. Integrate with CI

  **Simplicity Principle**
  Use property testing to find edge cases automatically.

  **Abstraction Evaluation**
  Medium - StreamData provides good abstractions for property testing.

  **Requirements**
  - StreamData integration
  - Custom generators
  - Property tests for core functions
  - CI integration

  {{test-requirements}}
  {{typespec-requirements}}
  {{elixir-kpis}}
  {{error-handling}}

  **Dependencies**
  - <%= @prefix %><%= @task_number %>

  **Status**: Planned
  **Priority**: Medium

  ## Completed Task Details

  ### <%= @prefix %>0503: Set up test infrastructure

  **Description**
  Initial test setup with ExUnit configuration and test helpers.

  **Simplicity Progression Plan**
  1. Configure ExUnit
  2. Create test helpers
  3. Set up factories
  4. Add CI integration

  **Simplicity Principle**
  Standard ExUnit setup with minimal custom configuration.

  **Abstraction Evaluation**
  Low - Direct use of ExUnit features.

  **Requirements**
  - ExUnit configuration
  - Test helper modules
  - Factory setup
  - CI pipeline

  **ExUnit Test Requirements**
  - Basic test structure
  - Helper functions
  - Async test support

  **Integration Test Scenarios**
  - Test database setup
  - Sandbox configuration
  - Fixture management

  **Typespec Requirements**
  - Test helper specs
  - Factory type definitions

  **TypeSpec Documentation**
  Clear documentation of test utilities

  **TypeSpec Verification**
  Dialyzer runs on test helpers

  **Dependencies**
  - None

  **Code Quality KPIs**
  - Functions per module: 5
  - Lines per function: 10
  - Call depth: 2

  **Test Strategy**
  Standard ExUnit configuration with async tests enabled

  **Coverage Requirements**
  Track coverage from the start

  **Property-Based Testing**
  StreamData dependency added for future use

  {{error-handling}}

  **Architecture Notes**
  Clean test structure with shared helpers.

  **Implementation Notes**
  Used ExUnit's built-in features effectively.

  **Complexity Assessment**
  Low - Standard test setup.

  **Maintenance Impact**
  Low - Well-organized test infrastructure.

  **Error Handling Implementation**
  Test helpers include proper error handling.

  **Status**: Completed
  **Priority**: High
  **Review Rating**: 4.5
  """

  def run(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [path: :string, prefix: :string, category: :string, semantic: :boolean]
      )

    path = options[:path] || "TaskList.md"
    use_semantic = options[:semantic] || false
    category = options[:category] || "phoenix_web"

    prefix =
      if use_semantic do
        get_semantic_prefix_for_category(category)
      else
        options[:prefix] || "PRJ"
      end

    # Validate category
    valid_categories = [
      "otp_genserver",
      "phoenix_web",
      "business_logic",
      "data_layer",
      "infrastructure",
      "testing"
    ]

    if category not in valid_categories do
      Mix.shell().error("Invalid category: #{category}. Valid options: #{Enum.join(valid_categories, ", ")}")

      exit({:shutdown, 1})
    end

    if File.exists?(path) do
      Mix.shell().yes?("File #{path} already exists. Overwrite?") || exit(:normal)
    end

    # Generate appropriate task number for the category
    task_number = get_category_task_number(category)
    template = get_template_for_category(category)

    content =
      EEx.eval_string(template <> @reference_definitions,
        assigns: [prefix: prefix, task_number: task_number]
      )

    case File.write(path, content) do
      :ok ->
        Mix.shell().info("✅ Created #{category} category template task list at #{path}")
        validate_template(path)

      {:error, reason} ->
        Mix.shell().error("Failed to create template: #{:file.format_error(reason)}")
        exit({:shutdown, 1})
    end
  end

  defp get_category_task_number(category) do
    case category do
      "otp_genserver" -> "0001"
      "phoenix_web" -> "0101"
      "business_logic" -> "0201"
      "data_layer" -> "0301"
      "infrastructure" -> "0401"
      "testing" -> "0501"
    end
  end

  # Gets semantic prefix for a category
  defp get_semantic_prefix_for_category(category) do
    case category do
      "otp_genserver" -> "OTP"
      "phoenix_web" -> "PHX"
      "business_logic" -> "CTX"
      "data_layer" -> "DB"
      "infrastructure" -> "INF"
      "testing" -> "TST"
      # fallback
      _ -> "PRJ"
    end
  end

  defp get_template_for_category(category) do
    case category do
      "otp_genserver" -> @otp_genserver_template
      "phoenix_web" -> @phoenix_web_template
      "business_logic" -> @business_logic_template
      "data_layer" -> @data_layer_template
      "infrastructure" -> @infrastructure_template
      "testing" -> @testing_template
    end
  end

  defp validate_template(path) do
    case TaskValidator.validate_file(path) do
      {:ok, _} ->
        Mix.shell().info("✅ Template validation successful!")

      {:error, reason} ->
        Mix.shell().error("⚠️  Generated template failed validation: #{reason}")
        Mix.shell().error("Please report this as a bug")
        exit({:shutdown, 1})
    end
  end
end
