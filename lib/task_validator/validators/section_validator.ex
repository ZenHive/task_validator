defmodule TaskValidator.Validators.SectionValidator do
  @moduledoc """
  Validates that tasks contain all required sections according to their type and status.

  This validator ensures that tasks have the appropriate content sections based on:
  - Task type (main task vs subtask)
  - Task status (Planned, In Progress, Completed, etc.)
  - Task category (core, features, documentation, testing)

  ## Validation Rules

  1. **Main Task Required Sections**:
     - **Description**: Task description and purpose
     - **Requirements**: What needs to be accomplished
     - **Dependencies**: Other tasks this depends on
     - **Error Handling**: Comprehensive error handling documentation
     - **Status**: Current status
     - **Priority**: Task priority level

  2. **Completed Task Additional Sections**:
     - **Implementation Notes**: How the task was completed
     - **Complexity Assessment**: Assessment of implementation complexity
     - **Maintenance Impact**: How this affects ongoing maintenance
     - **Error Handling Implementation**: Actual error handling implemented

  3. **Subtask Sections**:
     - **Description**: What the subtask accomplishes
     - **Status**: Current status
     - **Error Handling**: Simplified task-specific error handling

  4. **Status-Specific Requirements**:
     - "In Progress" tasks may have additional status tracking sections
     - "Blocked" tasks should document blocking issues
     - "Review" tasks should have review criteria

  ## Error Types

  - `:missing_required_section` - Required section not found in task content
  - `:invalid_section_format` - Section exists but format is incorrect
  - `:missing_error_handling` - Error handling section missing or incomplete
  - `:incomplete_completed_task` - Completed task missing required sections

  ## Examples

      # Required sections for main task
      **Description**
      **Requirements** 
      **Dependencies**
      **Error Handling**
      **Status**
      **Priority**
      
      # Additional sections for completed tasks
      **Implementation Notes**
      **Complexity Assessment** 
      **Maintenance Impact**
      **Error Handling Implementation**
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}

  # Required sections for error handling - main tasks
  @error_handling_sections [
    "**Error Handling**",
    "**Core Principles**",
    "- Pass raw errors",
    "- Use {:ok, result} | {:error, reason}",
    "- Let it crash",
    "**Error Implementation**",
    "- No wrapping",
    "- Minimal rescue",
    "- function/1 & /! versions",
    "**Error Examples**",
    "- Raw error passthrough",
    "- Simple rescue case",
    "- Supervisor handling",
    "**GenServer Specifics**",
    "- Handle_call/3 error pattern",
    "- Terminate/2 proper usage",
    "- Process linking considerations"
  ]

  # Required sections for error handling in subtasks - simplified format
  @subtask_error_handling_sections [
    "**Error Handling**",
    "**Task-Specific Approach**",
    "- Error pattern for this task",
    "**Error Reporting**",
    "- Monitoring approach"
  ]

  # Required sections for completed tasks
  @completed_task_sections [
    "**Implementation Notes**",
    "**Complexity Assessment**",
    "**Maintenance Impact**",
    "**Error Handling Implementation**"
  ]

  @doc """
  Validates that tasks contain all required sections for their type and status.

  ## Context Requirements
  - `:references` - Available references that might contain required sections

  ## Returns
  - Success if all required sections are present
  - Failure with specific details about missing sections
  """
  @impl true
  def validate(%Task{} = task, context) do
    references = Map.get(context, :references, %{})

    validators = [
      &validate_basic_sections/2,
      &validate_error_handling/2,
      &validate_status_specific_sections/2
    ]

    validators
    |> Enum.map(fn validator -> validator.(task, references) end)
    |> ValidationResult.combine()
  end

  @doc """
  Returns medium priority (50) as section validation depends on
  task structure being valid first.
  """
  @impl true
  def priority, do: 50

  # Validates basic required sections for all tasks
  defp validate_basic_sections(%Task{type: :main, content: content, id: id}, _references) do
    required_sections = [
      "**Description**",
      "**Status**",
      "**Priority**"
    ]

    missing_sections = find_missing_sections(content, required_sections)

    if missing_sections == [] do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_required_section,
        message:
          "Task '#{id}' is missing required sections: #{Enum.join(missing_sections, ", ")}",
        task_id: id,
        severity: :error,
        context: %{
          missing_sections: missing_sections,
          task_type: :main
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Subtasks have simpler requirements
  defp validate_basic_sections(%Task{type: :subtask, content: content, id: id}, _references) do
    required_sections = [
      "**Description**",
      "**Status**"
    ]

    missing_sections = find_missing_sections(content, required_sections)

    if missing_sections == [] do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_required_section,
        message:
          "Subtask '#{id}' is missing required sections: #{Enum.join(missing_sections, ", ")}",
        task_id: id,
        severity: :error,
        context: %{
          missing_sections: missing_sections,
          task_type: :subtask
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates error handling sections
  defp validate_error_handling(%Task{type: :main, content: content, id: id}, references) do
    # Check if error handling is present in content or via reference
    has_error_handling =
      has_section?(content, "**Error Handling**") or
        has_reference?(content, references, ["error-handling", "error-handling-main"])

    if has_error_handling do
      # If using reference, assume it's valid. If inline, validate structure
      if has_section?(content, "**Error Handling**") do
        validate_error_handling_structure(content, @error_handling_sections, id, :main)
      else
        ValidationResult.success()
      end
    else
      error = %ValidationError{
        type: :missing_error_handling,
        message:
          "Main task '#{id}' is missing error handling section. Main tasks require comprehensive error handling documentation.",
        task_id: id,
        severity: :error,
        context: %{
          task_type: :main,
          required_sections: @error_handling_sections
        }
      }

      ValidationResult.failure(error)
    end
  end

  defp validate_error_handling(%Task{type: :subtask, content: content, id: id}, references) do
    # Check if error handling is present in content or via reference
    has_error_handling =
      has_section?(content, "**Error Handling**") or
        has_reference?(content, references, ["error-handling-subtask"])

    if has_error_handling do
      # If using reference, assume it's valid. If inline, validate structure
      if has_section?(content, "**Error Handling**") do
        validate_error_handling_structure(content, @subtask_error_handling_sections, id, :subtask)
      else
        ValidationResult.success()
      end
    else
      error = %ValidationError{
        type: :missing_error_handling,
        message:
          "Subtask '#{id}' is missing error handling section. Subtasks require simplified error handling documentation.",
        task_id: id,
        severity: :error,
        context: %{
          task_type: :subtask,
          required_sections: @subtask_error_handling_sections
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates status-specific required sections
  defp validate_status_specific_sections(
         %Task{status: "Completed", type: :main, content: content, id: id},
         _references
       ) do
    missing_sections = find_missing_sections(content, @completed_task_sections)

    if missing_sections == [] do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :incomplete_completed_task,
        message:
          "Completed task '#{id}' is missing required completion sections: #{Enum.join(missing_sections, ", ")}",
        task_id: id,
        severity: :error,
        context: %{
          missing_sections: missing_sections,
          status: "Completed"
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Non-completed tasks don't need completion sections
  defp validate_status_specific_sections(%Task{}, _references) do
    ValidationResult.success()
  end

  # Validates the structure of error handling sections
  defp validate_error_handling_structure(content, required_sections, task_id, task_type) do
    missing_sections = find_missing_sections(content, required_sections)

    if missing_sections == [] do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_section_format,
        message:
          "Task '#{task_id}' has incomplete error handling section. Missing: #{Enum.join(missing_sections, ", ")}",
        task_id: task_id,
        severity: :error,
        context: %{
          missing_error_handling_parts: missing_sections,
          task_type: task_type
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Finds sections that are missing from the content
  defp find_missing_sections(content, required_sections) do
    content_text = Enum.join(content, "\n")

    Enum.filter(required_sections, fn section ->
      !String.contains?(content_text, section)
    end)
  end

  # Checks if a section exists in the content
  defp has_section?(content, section_name) do
    content_text = Enum.join(content, "\n")
    String.contains?(content_text, section_name)
  end

  # Checks if content contains any of the specified reference patterns
  defp has_reference?(content, references, reference_names) do
    content_text = Enum.join(content, "\n")

    Enum.any?(reference_names, fn ref_name ->
      # Check if the reference is used in content and exists in definitions
      String.contains?(content_text, "{{#{ref_name}}}") and Map.has_key?(references, ref_name)
    end)
  end
end
