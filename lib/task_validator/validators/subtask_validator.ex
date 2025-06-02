defmodule TaskValidator.Validators.SubtaskValidator do
  @moduledoc """
  Validates subtask structure, consistency, and format requirements.

  This validator handles validation of subtasks including their format,
  status consistency, and relationships with parent tasks. It supports
  both traditional numbered subtasks and checkbox-style subtasks.

  ## Validation Rules

  1. **Subtask Format Validation**:
     - Traditional numbered format: `#### N. Description (TASKID-N)`
     - Checkbox format: `- [ ] Description [TASKID]` or `- [x] Description [TASKID]`
     - Letter subtasks: `TASKID[a-z]` format support

  2. **Status Consistency**:
     - Checkbox checked state must match status field (for traditional format)
     - Completed subtasks must have review ratings (traditional format only)
     - Valid status values according to configuration

  3. **Required Sections** (Traditional Format):
     - **Status** - Current subtask status
     - Error handling (explicit or via reference)
     - Review rating for completed subtasks

  4. **Prefix Consistency**:
     - Subtask IDs must use same prefix as parent task
     - Validates parent-child relationships are maintained

  ## Error Types

  - `:missing_subtask_status` - Subtask missing status field
  - `:invalid_subtask_status` - Status not in valid values
  - `:missing_review_rating` - Completed subtask without rating
  - `:invalid_review_rating` - Rating format incorrect
  - `:inconsistent_subtask_prefix` - Prefix doesn't match parent
  - `:missing_subtask_sections` - Required sections not present

  ## Examples

      # Valid traditional numbered subtask
      #### 1. Implement basic validation (SSH001-1)
      
      **Status**: In Progress
      
      {{error-handling-subtask}}

      # Valid checkbox subtask
      - [x] Add input validation [SSH001a]
      - [ ] Implement error handling [SSH001b]

      # Valid completed subtask (traditional)
      #### 2. Add comprehensive tests (SSH001-2)
      
      **Status**: Completed
      **Review Rating**: 4.5
      
      {{error-handling-subtask}}
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}
  alias TaskValidator.Config

  @doc """
  Validates subtask structure, status, and required sections.

  ## Context Requirements
  - `:config` - TaskValidator configuration (optional, uses defaults)
  - `:references` - Available references for validation (optional)

  ## Returns
  - Success if all subtask validations pass
  - Failure with specific error details for each validation issue
  """
  @impl true
  def validate(%Task{type: :main, subtasks: subtasks} = task, context) do
    if Enum.empty?(subtasks) do
      ValidationResult.success()
    else
      config = Map.get(context, :config, Config.get_all())
      references = Map.get(context, :references, %{})

      subtasks
      |> Enum.map(fn subtask -> validate_single_subtask(subtask, task, config, references) end)
      |> ValidationResult.combine()
    end
  end

  # Subtask tasks are validated as part of their parent, so skip here
  def validate(%Task{type: :subtask}, _context) do
    ValidationResult.success()
  end

  @doc """
  Returns medium priority (45) since subtask validation depends on
  basic structure but should run before complex business rules.
  """
  @impl true
  def priority, do: 45

  # Validates a single subtask against its parent task
  defp validate_single_subtask(subtask, parent_task, config, references) do
    validators = [
      &validate_subtask_status/4,
      &validate_subtask_sections/4,
      &validate_review_rating/4,
      &validate_prefix_consistency/4
    ]

    validators
    |> Enum.map(fn validator -> validator.(subtask, parent_task, config, references) end)
    |> ValidationResult.combine()
  end

  # Validates subtask status is valid
  defp validate_subtask_status(subtask, _parent_task, config, _references) do
    valid_statuses = Map.get(config, :valid_statuses, Config.get(:valid_statuses))
    status = determine_subtask_status(subtask)

    if status in valid_statuses do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_subtask_status,
        message:
          "Subtask '#{subtask.id}' has invalid status '#{status}'. Valid statuses: #{Enum.join(valid_statuses, ", ")}",
        task_id: subtask.id,
        line_number: subtask.line_number,
        severity: :error,
        context: %{
          invalid_status: status,
          valid_statuses: valid_statuses,
          subtask_format: determine_subtask_format(subtask)
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates required sections for traditional format subtasks
  defp validate_subtask_sections(subtask, _parent_task, _config, references) do
    case determine_subtask_format(subtask) do
      :checkbox ->
        # Checkbox format doesn't require additional sections
        ValidationResult.success()

      :numbered ->
        # Traditional format requires status and error handling
        validate_traditional_subtask_sections(subtask, references)
    end
  end

  # Validates traditional subtask has required sections
  defp validate_traditional_subtask_sections(subtask, references) do
    content = subtask.content || []

    # Check for Status section
    has_status = has_section?(content, "**Status**")

    # Check for error handling (explicit or reference)
    has_error_handling =
      has_section?(content, "**Error Handling**") or
        has_subtask_error_handling_reference?(content, references)

    missing_sections = []

    missing_sections =
      if has_status, do: missing_sections, else: ["**Status**" | missing_sections]

    missing_sections =
      if has_error_handling, do: missing_sections, else: ["**Error Handling**" | missing_sections]

    if Enum.empty?(missing_sections) do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_subtask_sections,
        message:
          "Subtask '#{subtask.id}' is missing required sections: #{Enum.join(missing_sections, ", ")}",
        task_id: subtask.id,
        line_number: subtask.line_number,
        severity: :error,
        context: %{
          missing_sections: missing_sections,
          subtask_format: :numbered
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates review rating for completed subtasks
  defp validate_review_rating(subtask, _parent_task, config, _references) do
    status = determine_subtask_status(subtask)
    format = determine_subtask_format(subtask)

    if status == "Completed" and format == :numbered do
      # Traditional format completed subtasks need review ratings
      rating = subtask.review_rating

      if rating && rating != "" && rating != "-" do
        validate_rating_format(subtask.id, rating, config)
      else
        error = %ValidationError{
          type: :missing_review_rating,
          message:
            "Completed subtask '#{subtask.id}' is missing review rating. Traditional format completed subtasks must have a review rating.",
          task_id: subtask.id,
          line_number: subtask.line_number,
          severity: :error,
          context: %{
            status: status,
            subtask_format: format,
            review_rating: rating
          }
        }

        ValidationResult.failure(error)
      end
    else
      # Checkbox format or non-completed subtasks don't need ratings
      ValidationResult.success()
    end
  end

  # Validates that subtask prefix matches parent task prefix
  defp validate_prefix_consistency(subtask, parent_task, _config, _references) do
    parent_prefix = extract_prefix(parent_task.id)
    subtask_prefix = extract_prefix(subtask.id)

    if parent_prefix == subtask_prefix do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :inconsistent_subtask_prefix,
        message:
          "Subtask '#{subtask.id}' has prefix '#{subtask_prefix}' which doesn't match parent task '#{parent_task.id}' prefix '#{parent_prefix}'",
        task_id: subtask.id,
        line_number: subtask.line_number,
        severity: :error,
        context: %{
          subtask_prefix: subtask_prefix,
          parent_prefix: parent_prefix,
          parent_task_id: parent_task.id
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Determines the status of a subtask based on its format and content
  defp determine_subtask_status(subtask) do
    case determine_subtask_format(subtask) do
      :checkbox ->
        # For checkbox format, use the explicit status if available
        # Otherwise assume status based on completion state
        subtask.status || "Planned"

      :numbered ->
        # For traditional format, use explicit status or extract from content
        subtask.status || extract_status_from_content(subtask.content || [])
    end
  end

  # Determines the format of a subtask (checkbox vs numbered)
  defp determine_subtask_format(subtask) do
    cond do
      # Check ID pattern for numbered subtasks
      String.match?(subtask.id, ~r/^[A-Z]{2,4}\d{3,4}-\d+$/) ->
        :numbered

      # Check ID pattern for letter subtasks (checkbox format)
      String.match?(subtask.id, ~r/^[A-Z]{2,4}\d{3,4}[a-z]$/) ->
        :checkbox

      # Check for custom dash format numbered subtasks
      String.match?(subtask.id, ~r/^[A-Z]{2,4}-\d{3,4}-\d+$/) ->
        :numbered

      true ->
        # Default to numbered format
        :numbered
    end
  end

  # Extracts status from subtask content
  defp extract_status_from_content(content) do
    status_line =
      Enum.find(content, fn line ->
        String.starts_with?(line, "**Status**")
      end)

    if status_line do
      status_line
      |> String.replace("**Status**:", "")
      |> String.replace("**Status**", "")
      |> String.trim()
    else
      "MISSING"
    end
  end

  # Validates the format of review ratings
  defp validate_rating_format(subtask_id, rating, config) do
    rating_regex = Map.get(config, :rating_regex, Config.get(:rating_regex))

    if Regex.match?(rating_regex, rating) do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_review_rating,
        message:
          "Invalid review rating '#{rating}' for subtask '#{subtask_id}'. Expected format: N.N (1.0-5.0) with optional (partial) suffix",
        task_id: subtask_id,
        severity: :error,
        context: %{
          invalid_rating: rating,
          expected_pattern: inspect(rating_regex),
          examples: ["4.5", "3.0", "5.0 (partial)"]
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

  # Extracts the prefix from a task ID
  defp extract_prefix(task_id) do
    cond do
      # Handle standard format: SSH001 -> SSH
      String.match?(task_id, ~r/^([A-Z]{2,4})\d/) ->
        [_, prefix] = Regex.run(~r/^([A-Z]{2,4})\d/, task_id)
        prefix

      # Handle custom dash format: PROJ-001 -> PROJ
      String.match?(task_id, ~r/^([A-Z]{2,4})-\d/) ->
        [_, prefix] = Regex.run(~r/^([A-Z]{2,4})-\d/, task_id)
        prefix

      true ->
        "UNKNOWN"
    end
  end
end
