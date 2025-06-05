defmodule Mix.Tasks.ValidateTasklist do
  @shortdoc "Validates a TaskList.md file format and structure"

  @moduledoc """
  Validates the format and structure of a TaskList.md file.

  ## Usage

      mix validate_tasklist [OPTIONS]

  ## Options

      --path       Path to the TaskList.md file (default: ./TaskList.md)

  ## Examples

      # Validate default TaskList.md in current directory
      mix validate_tasklist

      # Validate specific file
      mix validate_tasklist --path docs/TaskList.md

      # Validate example templates
      mix validate_tasklist --path docs/examples/phoenix_web_example.md

  ## Task List Structure

  The task list must contain:
  - **Current Tasks** table (active tasks)
  - **Completed Tasks** table (finished tasks)
  - **Task Details** sections for each task

  ## Validation Rules

  ### Task ID Format
  - 2-4 uppercase letters as prefix (e.g., SSH, SCP, ERR)
  - 3-4 digits as sequence number (e.g., 001, 0001)
  - Optional subtask suffix: hyphen + number for numbered subtasks (e.g., SSH0001-1)
  - Optional subtask suffix: letter for checkbox subtasks (e.g., SSH0001a)
  - Examples: SSH0001, SCP0001, ERR001, SSH0001-1, SSH0001a

  ### Status Values
  - **Planned** - Task not yet started
  - **In Progress** - Active work (requires subtasks)
  - **Review** - Under review
  - **Completed** - Finished (requires additional sections)
  - **Blocked** - Work blocked

  ### Priority Values
  - **Critical** - Must be done immediately
  - **High** - Important, should be prioritized
  - **Medium** - Normal priority
  - **Low** - Can be deferred

  ### Error Handling Requirements
  Main tasks and subtasks have different error handling requirements:

  #### Main Tasks
  Must include comprehensive error handling documentation:
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
  **GenServer Specifics**
  - Handle_call/3 error pattern
  - Terminate/2 proper usage
  - Process linking considerations
  ```

  #### Subtasks
  Use simplified error handling format:
  ```markdown
  **Error Handling**
  **Task-Specific Approach**
  - Error pattern for this task
  **Error Reporting**
  - Monitoring approach
  ```

  ### Common Validation Errors:
  - Using wrong error handling format (e.g., main task format for subtasks)
  - Missing error handling sections
  - Incomplete error handling documentation

  ### Required Sections

  #### Main Tasks
  All main tasks must include these sections:
  - **Description** - What the task accomplishes
  - **Status** - Current state (Planned, In Progress, etc.)
  - **Priority** - Task importance (Critical, High, Medium, Low)
  - **Dependencies** - Other tasks that must be completed first (or "None")
  - **Error Handling** - Comprehensive error handling documentation
  - Test sections: ExUnit Test Requirements, Integration Test Scenarios
  - TypeSpec sections: Requirements, Documentation, Verification
  - Code Quality KPIs - Metrics for code quality

  Additional sections for specific categories:
  - **OTP tasks**: Process Design, State Management, Supervision Strategy
  - **Phoenix tasks**: Route Design, Context Integration, Template/Component Strategy
  - **Data tasks**: Schema Design, Migration Strategy, Query Optimization
  - **Business logic**: Context Boundaries, Business Rules

  #### Completed Tasks
  Completed tasks require additional sections:
  - **Implementation Notes** - How it was implemented
  - **Complexity Assessment** - Implementation complexity
  - **Maintenance Impact** - Long-term maintenance considerations
  - **Error Handling Implementation** - How errors were handled
  - **Review Rating** - Quality score (1-5)

  ### Subtask Requirements
  - Must use same prefix as parent task
  - Must have "Status" section
  - If status is "Completed", must have "Review Rating"
  - Review rating format: 1-5 with optional decimal (e.g., 4.5)
  - Review rating can include "(partial)" suffix
  - Can be organized as checkboxes or numbered entries

  ### Subtask Formats

  Tasks can organize subtasks in two formats:

  #### 1. Checkbox Format (for minor items)
  Simple checklist format for quick subtasks:
  ```markdown
  **Subtasks**
  - [x] Basic structure implementation [SSH0001a]
  - [ ] Essential features [SSH0001b]
  - [ ] Integration testing [SSH0001c]
  ```

  #### 2. Numbered Format (for major subtasks)
  Full format with sections for significant subtasks:
  ```markdown
  #### 1. Basic structure implementation (SSH0001-1)
  **Description**
  Implement the core structure with proper error handling

  **Status**
  Completed

  **Review Rating**
  4.5

  \\{\\{error-handling-subtask\\}\\}
  ```

  Use numbered format when subtasks need detailed tracking, checkbox format for simple items.

  ### Additional Rules
  - Tasks marked as "In Progress" must have at least one subtask
  - All non-completed tasks must have detailed entries
  - No duplicate task IDs allowed
  - All subtasks must use the same prefix as their parent task

  ### Reference System

  The validator supports content references to reduce file size by 60-70%:
  - Define references: `## #\\{\\{reference-name\\}\\}`
  - Use references: `\\{\\{reference-name\\}\\}`
  - Common references: \\{\\{error-handling\\}\\}, \\{\\{test-requirements\\}\\}, \\{\\{standard-kpis\\}\\}
  - The validator only checks existence, not content

  ### Common Validation Errors

  1. **Wrong error handling format** - Using main task format for subtasks
  2. **Missing subtasks** - "In Progress" tasks without subtasks
  3. **Prefix mismatch** - Subtask ID doesn't match parent prefix
  4. **Invalid status** - Using non-standard status values
  5. **Missing sections** - Required sections not present
  6. **Invalid review rating** - Wrong format or out of range

  ## See Also

  - Run `mix help task_validator.create_template` to generate templates
  - Check `docs/examples/` for complete working examples
  - See `README.md` for detailed documentation

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
