defmodule TaskValidator.ValidationPipeline do
  @moduledoc """
  Simple validation pipeline for running validators in priority order.

  Provides a clean, straightforward way to validate tasks using a configurable
  list of validators without the complexity of a full rule engine.

  ## Usage

      # Use default validators
      result = ValidationPipeline.run(task, context)
      
      # Use custom validator list
      validators = [
        {TaskValidator.Validators.IdValidator, %{}},
        {TaskValidator.Validators.StatusValidator, %{}}
      ]
      result = ValidationPipeline.run(task, context, validators)
      
      # Validate multiple tasks
      results = ValidationPipeline.run_many(tasks, context, validators)
  """

  alias TaskValidator.Core.{Task, ValidationResult}
  alias TaskValidator.Validators

  @type validator_spec :: {module(), map()}
  @type validation_context :: map()

  @doc """
  Runs validation pipeline on a single task.

  ## Parameters
  - `task` - The task to validate
  - `context` - Validation context (config, references, etc.)
  - `validators` - List of {validator_module, options} tuples (optional)

  ## Returns
  Combined ValidationResult from all validators
  """
  @spec run(Task.t(), validation_context(), [validator_spec()]) :: ValidationResult.t()
  def run(%Task{} = task, context, validators \\ nil) do
    validators = validators || default_validators()

    validators
    |> Enum.sort_by(&get_validator_priority/1, :desc)
    |> Enum.reduce(ValidationResult.success(), fn {validator_module, options}, acc ->
      if acc.valid? do
        validator_context = Map.merge(context, %{validator_options: options})
        result = validator_module.validate(task, validator_context)
        ValidationResult.combine([acc, result])
      else
        acc
      end
    end)
  end

  @doc """
  Runs validation pipeline on multiple tasks.

  ## Parameters
  - `tasks` - List of tasks to validate
  - `context` - Validation context
  - `validators` - List of validator specs (optional)

  ## Returns
  Combined ValidationResult from all task validations
  """
  @spec run_many([Task.t()], validation_context(), [validator_spec()]) :: ValidationResult.t()
  def run_many(tasks, context, validators \\ nil) when is_list(tasks) do
    tasks
    |> Enum.map(fn task -> run(task, context, validators) end)
    |> ValidationResult.combine()
  end

  @doc """
  Returns the default set of validators in priority order.
  """
  @spec default_validators() :: [validator_spec()]
  def default_validators do
    [
      {Validators.IdValidator, %{}},
      {Validators.StatusValidator, %{}},
      {Validators.ErrorHandlingValidator, %{}},
      {Validators.SectionValidator, %{}},
      {Validators.SubtaskValidator, %{}},
      {Validators.DependencyValidator, %{}},
      {Validators.CategoryValidator, %{}},
      {Validators.KpiValidator, %{}}
    ]
  end

  @doc """
  Returns a minimal validator set for basic validation.
  """
  @spec minimal_validators() :: [validator_spec()]
  def minimal_validators do
    [
      {Validators.IdValidator, %{}},
      {Validators.StatusValidator, %{}}
    ]
  end

  @doc """
  Returns a strict validator set with enhanced checking.
  """
  @spec strict_validators(map()) :: [validator_spec()]
  def strict_validators(options \\ %{}) do
    strict_kpi_options =
      Map.merge(
        %{
          max_functions_per_module: 5,
          max_lines_per_function: 10,
          max_call_depth: 3
        },
        options
      )

    [
      {Validators.IdValidator, %{strict_format: true}},
      {Validators.StatusValidator, %{strict_transitions: true}},
      {Validators.ErrorHandlingValidator, %{require_comprehensive: true}},
      {Validators.SectionValidator, %{enforce_all_sections: true}},
      {Validators.SubtaskValidator, %{strict_formatting: true}},
      {Validators.DependencyValidator, %{validate_existence: true}},
      {Validators.CategoryValidator, %{enforce_categories: true}},
      {Validators.KpiValidator, strict_kpi_options}
    ]
  end

  @doc """
  Creates a custom validator set from a keyword list.

  ## Example

      validators = ValidationPipeline.build_validators([
        id: [strict_format: true],
        status: [],
        custom: [MyCustomValidator, [option: value]]
      ])
  """
  @spec build_validators(keyword()) :: [validator_spec()]
  def build_validators(validator_configs) do
    Enum.map(validator_configs, fn
      {validator_name, options} when is_atom(validator_name) ->
        validator_module = resolve_validator_module(validator_name)
        {validator_module, Enum.into(options, %{})}

      {validator_module, options} when is_atom(validator_module) ->
        {validator_module, Enum.into(options, %{})}
    end)
  end

  # Private functions

  defp get_validator_priority({validator_module, _options}) do
    if function_exported?(validator_module, :priority, 0) do
      validator_module.priority()
    else
      # Default priority
      50
    end
  end

  defp resolve_validator_module(:id), do: Validators.IdValidator
  defp resolve_validator_module(:status), do: Validators.StatusValidator
  defp resolve_validator_module(:error_handling), do: Validators.ErrorHandlingValidator
  defp resolve_validator_module(:section), do: Validators.SectionValidator
  defp resolve_validator_module(:subtask), do: Validators.SubtaskValidator
  defp resolve_validator_module(:dependency), do: Validators.DependencyValidator
  defp resolve_validator_module(:category), do: Validators.CategoryValidator
  defp resolve_validator_module(:kpi), do: Validators.KpiValidator
  defp resolve_validator_module(module) when is_atom(module), do: module
end
