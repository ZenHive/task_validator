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
      --prefix    Project prefix for example tasks (default: PRJ)

  ## Example

      mix task_validator.create_template
      mix task_validator.create_template --path ./docs/TaskList.md --prefix SSH
  """

  use Mix.Task

  @template """
  # Project Task List

  ## Current Tasks

  | ID | Description | Status | Priority | Assignee | Review Rating |
  | --- | --- | --- | --- | --- | --- |
  | <%= @prefix %>0001 | Implement core functionality | In Progress | High | - | - |
  | <%= @prefix %>0002 | Add documentation framework | Planned | Medium | - | - |

  ## Completed Tasks

  | ID | Description | Status | Completed By | Review Rating |
  | --- | --- | --- | ------------ | ------------- |
  | <%= @prefix %>0003 | Project setup | Completed | @developer | 4.5 |

  ## Active Task Details

  ### <%= @prefix %>0001: Implement core functionality

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

  **Status**: In Progress
  **Priority**: High

  #### 1. Basic structure implementation (<%= @prefix %>0001-1)

  **Description**
  Create the foundational structure and interfaces

  **Error Handling**
  **Task-Specific Approach**
  - Error pattern for this task
  **Error Reporting**
  - Monitoring approach

  **Status**: Completed
  **Review Rating**: 4.5

  #### 2. Essential features (<%= @prefix %>0001-2)

  **Description**
  Implement core features and functionality

  **Error Handling**
  **Task-Specific Approach**
  - Error pattern for this task
  **Error Reporting**
  - Monitoring approach

  **Status**: In Progress

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

  **Status**: Planned
  **Priority**: Medium
  """

  def run(args) do
    {options, _, _} = OptionParser.parse(args, strict: [path: :string, prefix: :string])
    path = options[:path] || "TaskList.md"
    prefix = options[:prefix] || "PRJ"

    if File.exists?(path) do
      Mix.shell().yes?("File #{path} already exists. Overwrite?") || exit(:normal)
    end

    content = EEx.eval_string(@template, assigns: [prefix: prefix])

    case File.write(path, content) do
      :ok ->
        Mix.shell().info("✅ Created template task list at #{path}")
        validate_template(path)

      {:error, reason} ->
        Mix.shell().error("Failed to create template: #{:file.format_error(reason)}")
        exit({:shutdown, 1})
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
