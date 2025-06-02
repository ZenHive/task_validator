defmodule TaskValidator.Validators.ErrorHandlingValidator do
  @moduledoc """
  Validates error handling sections and requirements for tasks.

  This validator ensures that tasks have appropriate error handling documentation
  according to their type (main task vs subtask) and implements the comprehensive
  error handling guidelines defined for the project.

  ## Validation Rules

  1. **Main Tasks**: Must have comprehensive error handling sections
     - **Error Handling** with Core Principles, Implementation, Examples, GenServer Specifics
     - Can use `{{error-handling}}` reference instead of explicit sections
     - All required subsections must be present if not using references

  2. **Subtasks**: Have simplified error handling requirements
     - **Error Handling** with Task-Specific Approach and Error Reporting
     - Can use `{{error-handling-subtask}}` or `{{subtask-error-handling}}` references
     - More focused on task-specific error patterns

  3. **Reference Support**: Validates proper reference usage
     - Checks for valid error handling references in content
     - Allows references to substitute for explicit sections
     - Maintains compatibility with reference system

  4. **Completed Tasks**: Additional error handling implementation validation
     - Must have **Error Handling Implementation** section
     - Documents actual error handling patterns used

  ## Error Types

  - `:missing_error_handling` - No error handling section or reference found
  - `:incomplete_error_handling` - Missing required error handling subsections
  - `:invalid_error_handling_format` - Error handling content doesn't match expected format
  - `:missing_error_implementation` - Completed task missing implementation details

  ## Examples

      # Valid main task error handling (explicit)
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

      # Valid using reference
      {{error-handling}}

      # Valid subtask error handling
      **Error Handling**
      **Task-Specific Approach**
      - Error pattern for this task
      **Error Reporting**
      - Monitoring approach
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}

  # Required sections for main task error handling
  @main_error_handling_sections [
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

  # Required sections for subtask error handling
  @subtask_error_handling_sections [
    "**Error Handling**",
    "**Task-Specific Approach**",
    "- Error pattern for this task",
    "**Error Reporting**",
    "- Monitoring approach"
  ]

  @doc """
  Validates error handling sections according to task type and status.

  ## Context Requirements
  - `:references` - Available references for validation (optional)

  ## Returns
  - Success if error handling requirements are met
  - Failure with specific error details for missing or invalid sections
  """
  @impl true
  def validate(%Task{} = task, context) do
    references = Map.get(context, :references, %{})

    validators = [
      &validate_error_handling/2,
      &validate_completed_error_implementation/2
    ]

    validators
    |> Enum.map(fn validator -> validator.(task, references) end)
    |> ValidationResult.combine()
  end

  @doc """
  Returns medium priority (55) since error handling validation is important
  but should run after basic structure validation.
  """
  @impl true
  def priority, do: 55

  # Validates error handling sections based on task type
  defp validate_error_handling(%Task{type: :main, content: content, id: id}, references) do
    # Check if task has error handling section or reference
    has_error_handling = has_section?(content, "**Error Handling**")
    has_reference = has_error_handling_reference?(content, references)

    cond do
      has_error_handling ->
        # Validate explicit error handling structure
        validate_error_handling_structure(content, @main_error_handling_sections, id, :main)

      has_reference ->
        # Reference is present, validate it exists
        validate_reference_exists(content, references, id)

      true ->
        # No error handling found
        error = %ValidationError{
          type: :missing_error_handling,
          message:
            "Main task '#{id}' is missing error handling section. Must have explicit **Error Handling** section or use {{error-handling}} reference.",
          task_id: id,
          severity: :error,
          context: %{
            task_type: :main,
            available_references: Map.keys(references),
            expected_section: "**Error Handling**"
          }
        }

        ValidationResult.failure(error)
    end
  end

  defp validate_error_handling(%Task{type: :subtask, content: content, id: id}, references) do
    # Check if subtask has error handling section or reference
    has_error_handling = has_section?(content, "**Error Handling**")
    has_reference = has_subtask_error_handling_reference?(content, references)

    cond do
      has_error_handling ->
        # Validate explicit error handling structure for subtasks
        validate_error_handling_structure(content, @subtask_error_handling_sections, id, :subtask)

      has_reference ->
        # Reference is present, validate it exists
        validate_reference_exists(content, references, id)

      true ->
        # No error handling found
        error = %ValidationError{
          type: :missing_error_handling,
          message:
            "Subtask '#{id}' is missing error handling section. Must have explicit **Error Handling** section or use {{error-handling-subtask}} reference.",
          task_id: id,
          severity: :error,
          context: %{
            task_type: :subtask,
            available_references: Map.keys(references),
            expected_section: "**Error Handling**"
          }
        }

        ValidationResult.failure(error)
    end
  end

  # Validates that completed tasks have error handling implementation
  defp validate_completed_error_implementation(
         %Task{status: "Completed", content: content, id: id},
         _references
       ) do
    if has_section?(content, "**Error Handling Implementation**") do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_error_implementation,
        message:
          "Completed task '#{id}' is missing **Error Handling Implementation** section. Completed tasks must document actual error handling patterns used.",
        task_id: id,
        severity: :error,
        context: %{
          status: "Completed",
          expected_section: "**Error Handling Implementation**"
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Non-completed tasks don't need implementation section
  defp validate_completed_error_implementation(%Task{}, _references) do
    ValidationResult.success()
  end

  # Validates that all required error handling sections are present
  defp validate_error_handling_structure(content, required_sections, task_id, task_type) do
    missing_sections = find_missing_sections(content, required_sections)

    if Enum.empty?(missing_sections) do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :incomplete_error_handling,
        message:
          "Task '#{task_id}' has incomplete error handling documentation. Missing sections: #{Enum.join(missing_sections, ", ")}",
        task_id: task_id,
        severity: :error,
        context: %{
          task_type: task_type,
          missing_sections: missing_sections,
          required_sections: required_sections
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates that referenced error handling actually exists
  defp validate_reference_exists(content, references, task_id) do
    referenced_names = extract_error_handling_references(content)

    missing_references =
      Enum.reject(referenced_names, fn ref -> Map.has_key?(references, ref) end)

    if Enum.empty?(missing_references) do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_error_handling,
        message:
          "Task '#{task_id}' references undefined error handling: #{Enum.join(missing_references, ", ")}",
        task_id: task_id,
        severity: :error,
        context: %{
          missing_references: missing_references,
          available_references: Map.keys(references)
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Checks if content has a specific section
  defp has_section?(content, section_header) do
    Enum.any?(content, fn line ->
      String.starts_with?(line, section_header)
    end)
  end

  # Checks if content has main task error handling references
  defp has_error_handling_reference?(content, references) do
    error_refs = ["error-handling", "error-handling-main", "def-error-handling"]

    Enum.any?(content, fn line ->
      Enum.any?(error_refs, fn ref ->
        String.contains?(line, "{{#{ref}}}") and Map.has_key?(references, ref)
      end)
    end)
  end

  # Checks if content has subtask error handling references
  defp has_subtask_error_handling_reference?(content, references) do
    subtask_refs = [
      "error-handling-subtask",
      "subtask-error-handling",
      "def-error-handling-subtask"
    ]

    Enum.any?(content, fn line ->
      Enum.any?(subtask_refs, fn ref ->
        String.contains?(line, "{{#{ref}}}") and Map.has_key?(references, ref)
      end)
    end)
  end

  # Extracts error handling reference names from content
  defp extract_error_handling_references(content) do
    content
    |> Enum.flat_map(fn line ->
      Regex.scan(
        ~r/\{\{(error-handling[^}]*|def-error-handling[^}]*|subtask-error-handling[^}]*)\}\}/,
        line
      )
      |> Enum.map(fn [_, ref] -> ref end)
    end)
    |> Enum.uniq()
  end

  # Finds sections that are missing from the content
  defp find_missing_sections(content, required_sections) do
    Enum.reject(required_sections, fn section ->
      Enum.any?(content, fn line ->
        String.starts_with?(line, section)
      end)
    end)
  end
end
