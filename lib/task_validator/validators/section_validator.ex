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

  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationError
  alias TaskValidator.Core.ValidationResult

  # Required sections for completed tasks
  @completed_task_sections [
    "**Implementation Notes**",
    "**Complexity Assessment**",
    "**Maintenance Impact**",
    "**Error Handling Implementation**"
  ]

  # Phoenix Web (100-199) specific required sections
  @phoenix_web_sections [
    "**Route Design**",
    "**Context Integration**",
    "**Template/Component Strategy**"
  ]

  # Data Layer (300-399) specific required sections  
  @data_layer_sections [
    "**Schema Design**",
    "**Migration Strategy**",
    "**Query Optimization**"
  ]

  # Business Logic (200-299) specific sections
  @business_logic_sections [
    "**Context Boundaries**",
    "**Business Rules**"
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
      &validate_status_specific_sections/2,
      &validate_category_specific_sections/2
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
        message: "Task '#{id}' is missing required sections: #{Enum.join(missing_sections, ", ")}",
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
        message: "Subtask '#{id}' is missing required sections: #{Enum.join(missing_sections, ", ")}",
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

  # Validates status-specific required sections
  defp validate_status_specific_sections(%Task{status: "Completed", type: :main, content: content, id: id}, _references) do
    missing_sections = find_missing_sections(content, @completed_task_sections)

    if missing_sections == [] do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :incomplete_completed_task,
        message: "Completed task '#{id}' is missing required completion sections: #{Enum.join(missing_sections, ", ")}",
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

  # Finds sections that are missing from the content
  defp find_missing_sections(content, required_sections) do
    content_text = Enum.join(content, "\n")

    Enum.filter(required_sections, fn section ->
      !String.contains?(content_text, section)
    end)
  end

  # Validates category-specific required sections based on task category
  defp validate_category_specific_sections(%Task{type: :subtask}, _references) do
    # Subtasks don't need category-specific sections
    ValidationResult.success()
  end

  defp validate_category_specific_sections(%Task{category: nil}, _references) do
    # Tasks without category don't need category-specific sections
    ValidationResult.success()
  end

  defp validate_category_specific_sections(%Task{} = task, references) do
    required_sections = get_category_sections(task.category)

    if required_sections == [] do
      ValidationResult.success()
    else
      validate_category_sections(task, required_sections, references)
    end
  end

  # Gets required sections for a specific category
  defp get_category_sections(category) do
    case category do
      :phoenix_web -> @phoenix_web_sections
      :data_layer -> @data_layer_sections
      :business_logic -> @business_logic_sections
      _ -> []
    end
  end

  # Validates that category-specific sections are present
  defp validate_category_sections(%Task{content: content, id: task_id, category: category}, required_sections, references) do
    missing_sections = find_missing_category_sections(content, required_sections, references)

    if missing_sections == [] do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_required_section,
        message: "Task '#{task_id}' is missing required #{category} sections: #{Enum.join(missing_sections, ", ")}",
        task_id: task_id,
        severity: :error,
        context: %{
          category: category,
          missing_sections: missing_sections,
          required_sections: required_sections
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Finds category sections that are missing (allowing for references)
  defp find_missing_category_sections(content, required_sections, references) do
    content_text = Enum.join(content, "\n")

    Enum.filter(required_sections, fn section ->
      # Check if section exists directly or via reference
      section_exists = String.contains?(content_text, section)

      # Check if any reference might contain this section
      reference_contains_section = check_references_for_section(content, references, section)

      not (section_exists or reference_contains_section)
    end)
  end

  # Checks if any referenced content contains the required section
  defp check_references_for_section(content, references, section) do
    content_text = Enum.join(content, "\n")

    # Extract all reference names from content
    reference_names =
      ~r/\{\{([^}]+)\}\}/
      |> Regex.scan(content_text)
      |> Enum.map(fn [_, ref] -> ref end)
      |> Enum.uniq()

    # Check if any referenced content contains the section
    Enum.any?(reference_names, fn ref_name ->
      case Map.get(references, ref_name) do
        nil ->
          false

        ref_content when is_list(ref_content) ->
          ref_text = Enum.join(ref_content, "\n")
          String.contains?(ref_text, section)

        ref_content when is_binary(ref_content) ->
          String.contains?(ref_content, section)

        _ ->
          false
      end
    end)
  end
end
