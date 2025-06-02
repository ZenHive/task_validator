defmodule Mix.Tasks.TaskValidator.CreateTemplate do
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
      --category   Task category to generate template for: otp_genserver, phoenix_web, business_logic, data_layer, infrastructure, testing (default: phoenix_web)

  ## Example

      mix task_validator.create_template
      mix task_validator.create_template --path ./docs/TaskList.md --prefix SSH --category otp_genserver
      mix task_validator.create_template --category testing
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
  """

  @otp_genserver_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement GenServer worker | Planned | High | - | - |
  | <%= @prefix %>0002 | Add supervision tree | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Completed By | Review Rating |
  | --- | --- | --- | ------------ | ------------- |
  | <%= @prefix %>0003 | Project setup | Completed | @developer | 4.5 |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Implement GenServer worker

  **Description**
  Develop a GenServer-based worker process with proper OTP patterns, state management, and supervision integration.

  **Process Design**
  GenServer chosen for stateful process with synchronous and asynchronous operations. State-based message handling with proper timeout management.

  **State Management**
  Simple map-based state with version tracking and periodic cleanup. Clear state transitions with validation on each update.

  **Supervision Strategy**
  Permanent restart strategy with exponential backoff. Parent supervisor escalation after 3 restarts in 60 seconds.

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

  **ExUnit Test Requirements**
  - Unit tests for client API functions
  - GenServer callback tests with different scenarios
  - State transition and validation tests
  - Error condition and timeout tests
  - Supervision integration tests

  **Integration Test Scenarios**
  - Normal operation workflows
  - Error recovery and restart scenarios
  - High load and concurrent access patterns
  - Supervisor escalation testing

  **Typespec Requirements**
  - Full type coverage for state structure
  - Client API function specifications
  - GenServer callback return types

  **TypeSpec Documentation**
  Complete documentation of state types, API contracts, and error conditions

  **TypeSpec Verification**
  Dialyzer verification with zero warnings required

  **Dependencies**
  - None

  {{elixir-kpis}}

  {{otp-error-handling}}

  **Status**: Planned
  **Priority**: High

  **Subtasks**
  - [ ] Define state structure and types [<%= @prefix %><%= @task_number %>-1]
  - [ ] Implement client API functions [<%= @prefix %><%= @task_number %>-2]
  - [ ] Add GenServer callbacks [<%= @prefix %><%= @task_number %>-3]
  - [ ] Integration with supervision tree [<%= @prefix %><%= @task_number %>-4]

  #### <%= @prefix %><%= @task_number %>-1: Define state structure and types

  **Description**
  Create comprehensive type definitions and state management patterns

  **Status**
  Planned

  {{error-handling-subtask}}

  ### <%= @prefix %>0002: Add supervision tree

  **Description**
  Design and implement supervision tree with proper restart strategies and escalation patterns.

  **Process Design**
  Supervisor with one_for_one strategy managing worker processes. Dynamic child management with proper shutdown procedures.

  **State Management**
  Supervisor state tracking child processes with health monitoring and restart statistics.

  **Supervision Strategy**
  One_for_one restart with max_restarts: 3, max_seconds: 60. Escalate to parent supervisor on repeated failures.

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

  **ExUnit Test Requirements**
  - Supervisor startup and shutdown tests
  - Child restart and escalation scenarios
  - Dynamic child management tests

  **Integration Test Scenarios**
  - Full supervision tree integration
  - Failure recovery and escalation
  - System-wide restart scenarios

  **Typespec Requirements**
  - Supervisor specification types
  - Child specification documentation

  **TypeSpec Documentation**
  Clear supervision tree structure and child management contracts

  **TypeSpec Verification**
  Full type coverage with Dialyzer validation

  **Dependencies**
  - <%= @prefix %><%= @task_number %>

  {{elixir-kpis}}

  {{otp-error-handling}}

  **Status**: Planned
  **Priority**: Medium
  """

  @phoenix_web_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement user authentication LiveView | Planned | High | - | - |
  | <%= @prefix %>0102 | Add product catalog controller | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Completed By | Review Rating |
  | --- | --- | --- | ------------ | ------------- |
  | <%= @prefix %>0103 | Phoenix project setup | Completed | @developer | 4.5 |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Implement user authentication LiveView

  **Description**
  Create a LiveView-based authentication system with real-time validation and smooth UX.

  **Route Design**
  RESTful routes: GET /login, POST /session, DELETE /session with proper path helpers and redirects.

  **Context Integration**
  Integrate with Accounts context for user validation, session management, and role-based access control.

  **Template/Component Strategy**
  Stateful LiveView component with reusable form components and real-time validation feedback.

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

  **ExUnit Test Requirements**
  - LiveView mount and event handling tests
  - Authentication flow integration tests
  - Form validation and error display tests
  - Session management tests

  **Integration Test Scenarios**
  - Complete authentication workflow
  - Invalid credentials handling
  - Session timeout and renewal
  - Multiple concurrent sessions

  **Typespec Requirements**
  - LiveView assign types and validation
  - Authentication event specifications
  - Session data type definitions

  **TypeSpec Documentation**
  Clear documentation of LiveView state, events, and authentication contracts

  **TypeSpec Verification**
  Dialyzer verification of LiveView callbacks and type safety

  **Dependencies**
  - None

  {{elixir-kpis}}

  {{phoenix-error-handling}}

  **Status**: Planned
  **Priority**: High

  **Subtasks**
  - [ ] Design LiveView component structure [<%= @prefix %><%= @task_number %>-1]
  - [ ] Implement form validation [<%= @prefix %><%= @task_number %>-2]
  - [ ] Add session management [<%= @prefix %><%= @task_number %>-3]
  - [ ] Style and UX polish [<%= @prefix %><%= @task_number %>-4]

  #### <%= @prefix %><%= @task_number %>-1: Design LiveView component structure

  **Description**
  Create the foundational LiveView component with proper mount and event handling

  **Status**
  Planned

  {{error-handling-subtask}}

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

  **ExUnit Test Requirements**
  - Controller action tests for all routes
  - Integration tests for search and filtering
  - Performance tests for large datasets

  **Integration Test Scenarios**
  - Product catalog browsing workflows
  - Search and filter combinations
  - Image upload and display
  - Admin product management

  **Typespec Requirements**
  - Product schema type definitions
  - Controller parameter specifications
  - Search and filter option types

  **TypeSpec Documentation**
  Complete API documentation for product catalog endpoints

  **TypeSpec Verification**
  Type safety for all controller actions and business logic integration

  **Dependencies**
  - None

  {{elixir-kpis}}

  {{phoenix-error-handling}}

  **Status**: Planned
  **Priority**: Medium
  """

  @business_logic_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement user management context | Planned | High | - | - |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Implement user management context

  **Description**
  Create a comprehensive user management context with proper business logic separation.

  **API Design**
  Clear function contracts: create_user/1, update_user/2, authenticate_user/2 with proper documentation.

  **Data Access**
  Proper Repo usage with optimized queries, preloading strategies, and transaction management.

  **Validation Strategy**
  Comprehensive changeset validation with custom validators and error message internationalization.

  **Requirements**
  - Context module with clear API boundaries
  - Comprehensive changesets and validations
  - Optimized database queries
  - Business rule enforcement

  {{elixir-kpis}}
  {{context-error-handling}}

  **Status**: Planned
  **Priority**: High
  """

  @data_layer_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Design user schema and migration | Planned | High | - | - |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Design user schema and migration

  **Description**
  Create comprehensive user schema with proper database design and migration strategy.

  **Schema Design**
  Well-normalized schema with proper constraints, indexes, and relationships.

  **Migration Strategy**
  Rollback-safe migrations with data integrity checks and zero-downtime deployment patterns.

  **Query Optimization**
  Strategic indexes, query analysis, and performance monitoring for critical paths.

  **Requirements**
  - Ecto schema with proper types and validations
  - Safe database migrations
  - Optimized query patterns
  - Constraint and index strategy

  {{elixir-kpis}}
  {{context-error-handling}}

  **Status**: Planned
  **Priority**: High
  """

  @infrastructure_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Configure production release | Planned | High | - | - |

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

  **Requirements**
  - Production-ready release configuration
  - Secure secret management
  - Monitoring and observability
  - Deployment automation

  {{elixir-kpis}}
  {{context-error-handling}}

  **Status**: Planned
  **Priority**: High
  """

  @testing_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement comprehensive testing strategy | Planned | High | - | - |

  ## Completed Tasks

  | ID | Description | Status | Completed By | Review Rating |
  | --- | --- | --- | ------------ | ------------- |

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

  {{error-handling-main}}

  **Status**: Planned
  **Priority**: High

  **Architecture Notes**
  Simple initial design

  **Complexity Assessment**
  Low - Basic structure only
  """

  def run(args) do
    {options, _, _} =
      OptionParser.parse(args, strict: [path: :string, prefix: :string, category: :string])

    path = options[:path] || "TaskList.md"
    prefix = options[:prefix] || "PRJ"
    category = options[:category] || "phoenix_web"

    # Validate category
    valid_categories = [
      "otp_genserver",
      "phoenix_web",
      "business_logic",
      "data_layer",
      "infrastructure",
      "testing"
    ]

    unless category in valid_categories do
      Mix.shell().error(
        "Invalid category: #{category}. Valid options: #{Enum.join(valid_categories, ", ")}"
      )

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
