defmodule Mix.Tasks.ValidateTasklist do
  @moduledoc """
  Validates the format and structure of a TaskList.md file.

  ## Task List Structure
  The task list must contain two main sections:
  - Current Tasks (Active tasks in progress)
  - Completed Tasks (Tasks that have been finished)

  ## Validation Rules

  ### Task ID Format
  - 2-4 uppercase letters as prefix (e.g., SSH, SCP, ERR)
  - 3-4 digits as sequence number
  - Optional hyphen and number for subtasks (e.g., SSH0001-1)
  - Examples: SSH0001, SCP0001, ERR001, SSH0001-1

  ### Status Values
  Valid statuses:
  - Planned
  - In Progress
  - Review
  - Completed
  - Blocked

  ### Priority Values
  Valid priorities:
  - Critical
  - High
  - Medium
  - Low

  ### Error Handling Requirements
  All tasks and subtasks must include:
  - Core error handling principles
  - Implementation details
  - Example error scenarios

  Example format:
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
  ```

  ### Common Validation Errors:
  - Missing error handling sections in tasks or subtasks
  - Incomplete error handling documentation
  - Invalid error handling format

  ### Required Sections
  Main tasks must include:
  - Description
  - Simplicity Progression Plan
  - Simplicity Principle
  - Abstraction Evaluation
  - Requirements
  - ExUnit Test Requirements
  - Integration Test Scenarios
  - Typespec Requirements
  - TypeSpec Documentation
  - TypeSpec Verification
  - Status
  - Priority

  ### Subtask Requirements
  - Must use same prefix as parent task
  - Must have "Status" section
  - If status is "Completed", must have "Review Rating"
  - Review rating format: 1-5 with optional decimal (e.g., 4.5)
  - Review rating can include "(partial)" suffix

  ### Additional Rules
  - Tasks marked as "In Progress" must have at least one subtask
  - All non-completed tasks must have detailed entries
  - No duplicate task IDs allowed
  - All subtasks must use the same prefix as their parent task

  ## Usage

      mix validate_tasklist [OPTIONS]

  ## Options

      --path  Specify a non-default path to the TaskList.md file (default: docs/TaskList.md)

  ## Example

      mix validate_tasklist
      mix validate_tasklist --path ./custom/path/TaskList.md
  """

  use Mix.Task

  def run(args) do
    {options, _, _} = OptionParser.parse(args, strict: [path: :string])
    path = options[:path] || "docs/TaskList.md"

    Mix.shell().info("Validating #{path}...")

    # Check if the file exists
    if !File.exists?(path) do
      Mix.shell().error("Error: File #{path} not found!")
      exit({:shutdown, 1})
    end

    # Use the TaskValidator module
    case TaskValidator.validate_file(path) do
      {:ok, message} ->
        Mix.shell().info(message)
        Mix.shell().info("✅ TaskList validation successful!")
        :ok

      {:error, reason} ->
        Mix.shell().error(reason)
        Mix.shell().error("❌ TaskList validation failed!")
        exit({:shutdown, 1})
    end
  end
end
