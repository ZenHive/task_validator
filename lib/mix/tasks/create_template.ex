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
      --category   Task category to generate template for: core, features, documentation, testing (default: features)

  ## Example

      mix task_validator.create_template
      mix task_validator.create_template --path ./docs/TaskList.md --prefix SSH --category core
      mix task_validator.create_template --category documentation
  """

  use Mix.Task

  @reference_definitions """

  ## Reference Definitions

  ## \#{{error-handling-main}}
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

  ## \#{{error-handling-subtask}}
  **Error Handling**
  **Task-Specific Approach**
  - Error pattern for this task
  **Error Reporting**
  - Monitoring approach

  ## \#{{standard-kpis}}
  **Code Quality KPIs**
  - Functions per module: 3
  - Lines per function: 12
  - Call depth: 2
  """

  @features_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Implement core functionality | In Progress | High | - | - |
  | <%= @prefix %>0002 | Add documentation framework | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Completed By | Review Rating |
  | --- | --- | --- | ------------ | ------------- |
  | <%= @prefix %>0003 | Project setup | Completed | @developer | 4.5 |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Implement core functionality

  **Description**
  Develop and implement the core functionality with a focus on maintainability and extensibility.

  **Simplicity Progression Plan**
  1. Create basic structure
  2. Add essential features
  3. Implement error handling
  4. Add extensibility points

  **Simplicity Principle**
  Design with simplicity and clarity as primary goals. Start with minimal functionality
  and add features incrementally based on validated needs.

  **Abstraction Evaluation**
  Medium - provides necessary abstractions while keeping interfaces clear and intuitive

  **Requirements**
  - Core functionality implementation
  - Error handling
  - Performance considerations
  - Documentation
  - Tests coverage

  **ExUnit Test Requirements**
  - Unit tests for core functions
  - Integration tests for key workflows
  - Performance benchmarks
  - Error condition tests

  **Integration Test Scenarios**
  - Happy path workflows
  - Error handling cases
  - Edge case scenarios
  - Performance under load

  **Typespec Requirements**
  - Define types for core functions
  - Document type constraints
  - Ensure proper type coverage

  **TypeSpec Documentation**
  Types should be clearly documented with examples and usage patterns

  **TypeSpec Verification**
  Use Dialyzer to verify type correctness

  **Dependencies**
  - None

  {{standard-kpis}}

  {{error-handling-main}}

  **Status**: Planned
  **Priority**: High

  **Architecture Notes**
  Core system component design

  **Complexity Assessment**
  Medium - Requires careful design but implementation is straightforward

  **System Impact**
  Foundation for other modules

  **Dependency Analysis**
  No external dependencies

  **Subtasks**
  - [x] Basic structure implementation [<%= @prefix %><%= @task_number %>-1]
  - [ ] Essential features [<%= @prefix %><%= @task_number %>-2]
  - [ ] Error handling implementation [<%= @prefix %><%= @task_number %>-3]
  - [ ] Add extensibility points [<%= @prefix %><%= @task_number %>-4]

  #### <%= @prefix %><%= @task_number %>-1: Basic structure implementation

  **Description**
  Create the foundational structure and interfaces

  **Status**
  Completed

  **Review Rating**
  4.5

  {{error-handling-subtask}}

  #### <%= @prefix %><%= @task_number %>-2: Essential features

  **Description**
  Implement core features and functionality

  **Status**
  Planned

  {{error-handling-subtask}}

  ### <%= @prefix %>0002: Add documentation framework

  **Description**
  Set up and implement the documentation framework for the project.

  **Simplicity Progression Plan**
  1. Set up documentation tools
  2. Create basic structure
  3. Add API documentation
  4. Create user guides

  **Simplicity Principle**
  Keep documentation clear, concise, and maintainable

  **Abstraction Evaluation**
  Low - straightforward documentation structure

  **Requirements**
  - Documentation tool setup
  - API documentation
  - User guides
  - Example code

  **ExUnit Test Requirements**
  - Documentation generation tests
  - Link validation
  - Code example tests

  **Integration Test Scenarios**
  - Documentation generation
  - Format validation
  - Cross-reference checks

  **Typespec Requirements**
  - Document type specifications
  - Include type examples

  **TypeSpec Documentation**
  Clear documentation of all public types

  **TypeSpec Verification**
  Regular verification of documentation accuracy

  **Dependencies**
  - None

  {{standard-kpis}}

  {{error-handling-main}}

  **Status**: Planned
  **Priority**: Medium

  **Architecture Notes**
  Documentation framework choice

  **Complexity Assessment**
  Low - Standard documentation setup

  **System Impact**
  Developer experience improvement

  **Dependency Analysis**
  Depends on core module
  """

  @core_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %>0001 | Core architecture implementation | Planned | High | - | - |
  | <%= @prefix %>0002 | Add documentation framework | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Completed By | Review Rating |
  | --- | --- | --- | ------------ | ------------- |
  | <%= @prefix %>0003 | Project setup | Completed | @developer | 4.5 |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Core architecture implementation

  **Description**
  Implement core system architecture with focus on performance and reliability.

  **Simplicity Progression Plan**
  1. Design core interfaces
  2. Implement basic functionality
  3. Add error handling
  4. Optimize performance

  **Simplicity Principle**
  Focus on essential functionality with minimal complexity and maximum reliability.

  **Abstraction Evaluation**
  Low-level implementation with clear separation of concerns

  **Requirements**
  - High performance architecture
  - Robust error handling
  - Scalable design patterns
  - Comprehensive testing

  **ExUnit Test Requirements**
  - Performance benchmarks
  - Load testing
  - Failure scenario testing

  **Integration Test Scenarios**
  - System integration tests
  - Performance under load
  - Failure recovery testing

  **Typespec Requirements**
  - Core type definitions
  - Interface specifications

  **TypeSpec Documentation**
  Complete documentation of all core types and interfaces

  **TypeSpec Verification**
  Strict type checking with Dialyzer

  **Dependencies**
  - None

  **Code Quality KPIs**
  - Functions per module: 3
  - Lines per function: 12
  - Call depth: 2

  **Architecture Notes**
  Core system design using proven patterns and minimal dependencies

  **Complexity Assessment**
  Medium complexity focused on correctness and performance

  {{error-handling-main}}

  **Status**: Planned
  **Priority**: High

  **Architecture Notes**
  Simple initial design

  **Complexity Assessment**
  Low - Basic structure only

  **Subtasks**
  - [x] Basic structure implementation [<%= @prefix %><%= @task_number %>-1]
  - [ ] Performance optimization [<%= @prefix %><%= @task_number %>-2]
  - [ ] Add error handling [<%= @prefix %><%= @task_number %>-3]
  - [ ] Optimize performance [<%= @prefix %><%= @task_number %>-4]

  #### <%= @prefix %><%= @task_number %>-1: Basic structure implementation

  **Description**
  Create the foundational architecture and core interfaces

  **Status**
  Completed

  **Review Rating**
  4.5

  {{error-handling-subtask}}

  #### <%= @prefix %><%= @task_number %>-2: Performance optimization

  **Description**
  Implement performance optimizations and monitoring

  **Status**
  Planned

  {{error-handling-subtask}}


  ### <%= @prefix %>0002: Add documentation framework

  **Description**
  Set up and implement the documentation framework for the project.

  **Simplicity Progression Plan**
  1. Set up documentation tools
  2. Create basic structure
  3. Add API documentation
  4. Create user guides

  **Simplicity Principle**
  Keep documentation clear, concise, and maintainable

  **Abstraction Evaluation**
  Low - straightforward documentation structure

  **Requirements**
  - Documentation tool setup
  - API documentation
  - User guides
  - Example code

  **ExUnit Test Requirements**
  - Documentation generation tests
  - Link validation
  - Code example tests

  **Integration Test Scenarios**
  - Documentation generation
  - Format validation
  - Cross-reference checks

  **Typespec Requirements**
  - Document type specifications
  - Include type examples

  **TypeSpec Documentation**
  Clear documentation of all public types

  **TypeSpec Verification**
  Regular verification of documentation accuracy

  **Dependencies**
  - <%= @prefix %>0001

  {{standard-kpis}}

  **Subtasks**
  - [ ] Set up documentation tools [<%= @prefix %>0002-1]
  - [ ] Create basic structure [<%= @prefix %>0002-2]
  - [ ] Add API documentation [<%= @prefix %>0002-3]
  - [ ] Create user guides [<%= @prefix %>0002-4]

  **Architecture Notes**
  Standard documentation framework

  **Complexity Assessment**
  Low - Standard tooling

  {{error-handling-main}}

  **Status**: Planned
  **Priority**: Medium

  ## Completed Task Details

  ### <%= @prefix %>0003: Project setup

  **Description**
  Initial project setup and structure implementation

  **Simplicity Progression Plan**
  1. Create directory structure
  2. Set up build configuration
  3. Initialize version control

  **Simplicity Principle**
  Standard project layout with minimal configuration

  **Abstraction Evaluation**
  Low - Direct implementation

  **Requirements**
  - Directory structure
  - Build configuration
  - Initial documentation

  **ExUnit Test Requirements**
  - Verify build process
  - Test configuration loading

  **Integration Test Scenarios**
  - Full project build and test

  **Typespec Requirements**
  - Basic type definitions
  - Module specifications

  **TypeSpec Documentation**
  Document core type specifications

  **TypeSpec Verification**
  Initial Dialyzer setup and verification

  **Dependencies**
  - None

  {{standard-kpis}}

  **Architecture Notes**
  Simple standard structure

  **Complexity Assessment**
  Low - Basic setup only

  {{error-handling-main}}

  **Error Handling Implementation**
  Standard error patterns

  **Status**: Completed
  **Priority**: High

  **Implementation Notes**
  Basic project structure created

  **Maintenance Impact**
  Minimal - standard structure

  **Review Rating**: 4.5

  """

  @documentation_template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %><%= @task_number %> | Create comprehensive documentation | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Completed By | Review Rating |
  | --- | --- | --- | ------------ | ------------- |

  ## Active Task Details

  ### <%= @prefix %><%= @task_number %>: Create comprehensive documentation

  **Description**
  Develop user-focused documentation with clear examples and usage patterns.

  **Simplicity Progression Plan**
  1. Analyze target audience
  2. Create content structure
  3. Write core documentation
  4. Add examples and tutorials

  **Simplicity Principle**
  Clear, concise documentation that enables users to succeed quickly.

  **Abstraction Evaluation**
  Documentation structure that hides complexity while providing necessary details

  **Requirements**
  - User-focused content
  - Clear examples
  - Comprehensive API documentation
  - Getting started guides

  **ExUnit Test Requirements**
  - Documentation example tests
  - Link validation
  - Code snippet verification

  **Integration Test Scenarios**
  - Documentation build process
  - Cross-reference validation
  - Example code execution

  **Typespec Requirements**
  - Documented type examples
  - Usage pattern documentation

  **TypeSpec Documentation**
  Clear examples of type usage in documentation

  **TypeSpec Verification**
  Ensure all documented types are valid

  **Dependencies**
  - None

  **Code Quality KPIs**
  - Functions per module: 3
  - Lines per function: 12
  - Call depth: 2

  **Content Strategy**
  User-focused approach with progressive disclosure and practical examples

  **Audience Analysis**
  Target developers with varying experience levels, prioritize clarity over completeness

  {{error-handling-main}}

  **Status**: Planned
  **Priority**: Medium
  **Dependencies**: None
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
    category = options[:category] || "features"

    # Validate category
    valid_categories = ["core", "features", "documentation", "testing"]

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
      "core" -> "0001"
      "features" -> "0101"
      "documentation" -> "0201"
      "testing" -> "0301"
    end
  end

  defp get_template_for_category(category) do
    case category do
      "core" -> @core_template
      "features" -> @features_template
      "documentation" -> @documentation_template
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
