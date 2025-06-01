defmodule TaskValidator.Validators.ValidatorBehaviour do
  @moduledoc """
  Defines the behaviour for TaskValidator validators.

  This behaviour ensures all validators follow a consistent interface for
  validating tasks. Each validator should implement the `validate/2` function
  that takes a task and context, returning a validation result.

  ## Example Implementation

      defmodule TaskValidator.Validators.ExampleValidator do
        @behaviour TaskValidator.Validators.ValidatorBehaviour
        
        alias TaskValidator.Core.{ValidationResult, ValidationError}
        
        def validate(task, context) do
          if valid?(task, context) do
            ValidationResult.success()
          else
            error = %ValidationError{
              type: :example_validation_error,
              message: "Task failed example validation",
              task_id: task.id,
              line_number: task.line_number
            }
            ValidationResult.failure(error)
          end
        end
        
        defp valid?(task, context), do: # validation logic
      end

  ## Context

  The context parameter provides additional information that validators might need:
  - `:config` - TaskValidator configuration
  - `:all_tasks` - List of all tasks for cross-task validation
  - `:references` - Available references in the document
  - `:task_list` - The complete TaskList struct

  ## Error Handling

  Validators should return structured ValidationError structs with:
  - `:type` - Atom identifying the error type
  - `:message` - Human-readable error description
  - `:task_id` - ID of the task being validated
  - `:line_number` - Location in the source document (if available)
  - `:details` - Additional error-specific information (optional)
  """

  alias TaskValidator.Core.{Task, ValidationResult}

  @doc """
  Validates a single task according to the validator's rules.

  ## Parameters
    - `task` - The Task struct to validate
    - `context` - Map containing validation context (config, all_tasks, etc.)

  ## Returns
    - `ValidationResult.t()` - Success or failure with error details
  """
  @callback validate(task :: Task.t(), context :: map()) :: ValidationResult.t()

  @doc """
  Optional callback to specify the validation priority.

  Validators with higher priority values run first. This allows
  critical validations (like ID format) to run before more complex
  validations that might depend on basic task structure.

  Default priority is 50 if not implemented.

  ## Returns
    - `non_neg_integer()` - Priority value (higher runs first)
  """
  @callback priority() :: non_neg_integer()

  @optional_callbacks priority: 0

  @doc """
  Gets the priority for a validator module.

  If the module implements the priority/0 callback, uses that value.
  Otherwise returns the default priority of 50.
  """
  @spec get_priority(module()) :: non_neg_integer()
  def get_priority(validator_module) do
    if function_exported?(validator_module, :priority, 0) do
      validator_module.priority()
    else
      50
    end
  end
end
