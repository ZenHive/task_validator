defmodule TaskValidator.Validators.ValidatorPipeline do
  @moduledoc """
  Provides a pipeline for running multiple validators on tasks in priority order.

  This module coordinates the execution of validator modules, ensuring they run
  in the correct order based on their priority values and providing aggregated
  validation results.

  ## Usage

      validators = [
        TaskValidator.Validators.IdValidator,
        TaskValidator.Validators.StatusValidator,
        TaskValidator.Validators.SectionValidator
      ]
      
      context = %{
        config: TaskValidator.Config.get_all(),
        all_tasks: task_list.tasks,
        references: task_list.references
      }
      
      result = ValidatorPipeline.validate_task(task, validators, context)

  ## Priority Ordering

  Validators are automatically sorted by priority (highest first) before execution.
  This ensures that fundamental validations (like ID format) run before more
  complex validations that might depend on basic task structure.

  ## Error Aggregation

  All validation errors and warnings from all validators are collected and
  returned in a single ValidationResult. This provides complete feedback
  about all validation issues rather than stopping at the first error.

  ## Early Exit

  If a validator returns a critical error (severity: :critical), the pipeline
  stops execution and returns immediately. This prevents cascading failures
  when fundamental validation fails.
  """

  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}
  alias TaskValidator.Validators.ValidatorBehaviour

  @doc """
  Validates a task using multiple validators in priority order.

  ## Parameters
    - `task` - The Task struct to validate
    - `validators` - List of validator modules that implement ValidatorBehaviour
    - `context` - Map containing validation context (config, all_tasks, etc.)

  ## Returns
    - `ValidationResult.t()` - Aggregated results from all validators
  """
  @spec validate_task(Task.t(), [module()], map()) :: ValidationResult.t()
  def validate_task(%Task{} = task, validators, context) when is_list(validators) do
    validators
    |> sort_validators_by_priority()
    |> Enum.reduce_while(ValidationResult.success(), fn validator, acc_result ->
      # Run the validator
      result = validator.validate(task, context)

      # Combine results
      combined = ValidationResult.combine([acc_result, result])

      # Check for critical errors that should stop the pipeline
      if has_critical_errors?(result) do
        {:halt, combined}
      else
        {:cont, combined}
      end
    end)
  end

  @doc """
  Validates multiple tasks using the same set of validators.

  This is a convenience function for validating all tasks in a task list
  with the same validator configuration.

  ## Parameters
    - `tasks` - List of Task structs to validate
    - `validators` - List of validator modules
    - `context` - Map containing validation context

  ## Returns
    - `ValidationResult.t()` - Aggregated results from all task validations
  """
  @spec validate_tasks([Task.t()], [module()], map()) :: ValidationResult.t()
  def validate_tasks(tasks, validators, context) when is_list(tasks) do
    tasks
    |> Enum.map(fn task ->
      validate_task(task, validators, context)
    end)
    |> ValidationResult.combine()
  end

  @doc """
  Gets the default set of validators for task validation.

  Returns the core validators that should be run for most validation scenarios.
  """
  @spec default_validators() :: [module()]
  def default_validators do
    [
      TaskValidator.Validators.IdValidator,
      TaskValidator.Validators.StatusValidator,
      TaskValidator.Validators.SectionValidator
    ]
  end

  # Sorts validators by priority (highest first)
  defp sort_validators_by_priority(validators) do
    validators
    |> Enum.map(fn validator ->
      priority = ValidatorBehaviour.get_priority(validator)
      {validator, priority}
    end)
    |> Enum.sort_by(fn {_validator, priority} -> priority end, :desc)
    |> Enum.map(fn {validator, _priority} -> validator end)
  end

  # Checks if the result contains any critical errors
  defp has_critical_errors?(%ValidationResult{errors: errors}) do
    Enum.any?(errors, fn
      %ValidationError{severity: :critical} -> true
      _ -> false
    end)
  end
end
