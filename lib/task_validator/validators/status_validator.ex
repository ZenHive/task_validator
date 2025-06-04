defmodule TaskValidator.Validators.StatusValidator do
  @moduledoc """
  Validates task status and priority values according to configured rules.

  This validator ensures that tasks have valid status and priority values,
  and enforces business rules about status transitions and requirements.

  ## Validation Rules

  1. **Valid Status Values**: Must be one of the configured valid statuses
     - Default: `["Planned", "In Progress", "Review", "Completed", "Blocked"]`
     - Case-sensitive validation

  2. **Valid Priority Values**: Must be one of the configured valid priorities  
     - Default: `["Critical", "High", "Medium", "Low"]`
     - Case-sensitive validation

  3. **Status-Dependent Requirements**:
     - "In Progress" main tasks must have at least one subtask
     - "Completed" tasks must have additional required sections
     - "Blocked" tasks should have blocking reason documentation

  4. **Review Ratings**: Completed subtasks must have valid review ratings
     - Format: `N.N` where N is 1-5, optional `(partial)` suffix
     - Examples: "4.5", "3.0", "5.0 (partial)"

  ## Error Types

  - `:invalid_status` - Status not in configured valid values
  - `:invalid_priority` - Priority not in configured valid values  
  - `:invalid_review_rating` - Review rating format incorrect
  - `:missing_subtasks_for_in_progress` - In Progress task without subtasks
  - `:missing_review_rating` - Completed subtask without rating

  ## Examples

      # Valid statuses (default)
      "Planned", "In Progress", "Review", "Completed", "Blocked"
      
      # Valid priorities (default)  
      "Critical", "High", "Medium", "Low"
      
      # Valid review ratings
      "4.5", "3.0", "5.0 (partial)", "1.0"
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Config
  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationError
  alias TaskValidator.Core.ValidationResult

  @doc """
  Validates task status, priority, and related business rules.

  ## Context Requirements
  - `:config` - TaskValidator configuration (optional, uses defaults)

  ## Returns
  - Success if all status/priority validations pass
  - Failure with specific error details for each validation issue
  """
  @impl true
  def validate(%Task{} = task, context) do
    config = Map.get(context, :config, Config.get_all())

    validators = [
      &validate_status/2,
      &validate_priority/2,
      &validate_status_requirements/2,
      &validate_review_rating/2
    ]

    validators
    |> Enum.map(fn validator -> validator.(task, config) end)
    |> ValidationResult.combine()
  end

  @doc """
  Returns medium priority (60) since status validation is important but
  not as fundamental as ID validation.
  """
  @impl true
  def priority, do: 60

  # Validates that status is in the configured list of valid statuses
  defp validate_status(%Task{status: status, id: id}, config) do
    valid_statuses = Map.get(config, :valid_statuses, Config.get(:valid_statuses))

    if status in valid_statuses do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_status,
        message: "Invalid status '#{status}' for task '#{id}'. Valid statuses: #{Enum.join(valid_statuses, ", ")}",
        task_id: id,
        severity: :error,
        context: %{
          invalid_status: status,
          valid_statuses: valid_statuses
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates that priority is in the configured list of valid priorities
  defp validate_priority(%Task{priority: priority, id: id}, config) do
    valid_priorities = Map.get(config, :valid_priorities, Config.get(:valid_priorities))

    if priority in valid_priorities do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_priority,
        message:
          "Invalid priority '#{priority}' for task '#{id}'. Valid priorities: #{Enum.join(valid_priorities, ", ")}",
        task_id: id,
        severity: :error,
        context: %{
          invalid_priority: priority,
          valid_priorities: valid_priorities
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates status-specific business rules
  defp validate_status_requirements(%Task{status: status, type: type, subtasks: subtasks, id: id}, _config) do
    case {status, type} do
      {"In Progress", :main} ->
        validate_in_progress_has_subtasks(id, subtasks)

      {"Completed", :subtask} ->
        # Additional validation for completed subtasks is handled in validate_review_rating
        ValidationResult.success()

      {"Blocked", _} ->
        # Could add validation for blocking reason documentation
        # For now, just pass
        ValidationResult.success()

      _ ->
        ValidationResult.success()
    end
  end

  # Validates that In Progress main tasks have subtasks
  defp validate_in_progress_has_subtasks(task_id, subtasks) do
    if length(subtasks) > 0 do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_subtasks_for_in_progress,
        message:
          "Task '#{task_id}' has status 'In Progress' but no subtasks. In Progress tasks should have defined subtasks to track progress.",
        task_id: task_id,
        severity: :error,
        context: %{
          status: "In Progress",
          subtask_count: 0
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates review ratings for completed subtasks
  defp validate_review_rating(%Task{type: :subtask, status: "Completed", review_rating: rating, id: id}, config) do
    if rating && rating != "-" && rating != "" do
      validate_rating_format(id, rating, config)
    else
      error = %ValidationError{
        type: :missing_review_rating,
        message: "Completed subtask '#{id}' is missing a review rating. Completed subtasks must have a review rating.",
        task_id: id,
        severity: :error,
        context: %{
          status: "Completed",
          type: :subtask,
          review_rating: rating
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Main tasks and non-completed subtasks don't need review rating validation
  defp validate_review_rating(%Task{}, _config) do
    ValidationResult.success()
  end

  # Validates the format of review ratings
  defp validate_rating_format(task_id, rating, config) do
    rating_regex = Map.get(config, :rating_regex, Config.get(:rating_regex))

    if Regex.match?(rating_regex, rating) do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_review_rating,
        message:
          "Invalid review rating '#{rating}' for task '#{task_id}'. Expected format: N.N (1.0-5.0) with optional (partial) suffix",
        task_id: task_id,
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
end
