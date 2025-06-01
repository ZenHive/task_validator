defmodule TaskValidator.Core.ValidationResult do
  @moduledoc """
  Represents the result of a validation operation.

  This struct aggregates validation errors and warnings, providing
  a consistent interface for handling validation outcomes throughout
  the system.
  """

  alias TaskValidator.Core.ValidationError

  @type t :: %__MODULE__{
          valid?: boolean(),
          errors: [ValidationError.t()],
          warnings: [ValidationError.t()],
          task_count: non_neg_integer(),
          validated_at: DateTime.t()
        }

  defstruct [
    :valid?,
    :errors,
    :warnings,
    :task_count,
    :validated_at
  ]

  @doc """
  Creates a successful validation result.
  """
  @spec success(keyword()) :: t()
  def success(opts \\ []) do
    %__MODULE__{
      valid?: true,
      errors: [],
      warnings: Keyword.get(opts, :warnings, []),
      task_count: Keyword.get(opts, :task_count, 0),
      validated_at: DateTime.utc_now()
    }
  end

  @doc """
  Creates a failed validation result.
  """
  @spec failure([ValidationError.t()] | ValidationError.t(), keyword()) :: t()
  def failure(errors, opts \\ []) when is_list(errors) or is_struct(errors, ValidationError) do
    error_list = List.wrap(errors)

    %__MODULE__{
      valid?: false,
      errors: error_list,
      warnings: Keyword.get(opts, :warnings, []),
      task_count: Keyword.get(opts, :task_count, 0),
      validated_at: DateTime.utc_now()
    }
  end

  @doc """
  Creates a validation result with both errors and warnings.
  """
  @spec new([ValidationError.t()], [ValidationError.t()], keyword()) :: t()
  def new(errors, warnings, opts \\ []) do
    %__MODULE__{
      valid?: Enum.empty?(errors),
      errors: errors,
      warnings: warnings,
      task_count: Keyword.get(opts, :task_count, 0),
      validated_at: DateTime.utc_now()
    }
  end

  @doc """
  Combines multiple validation results into a single result.

  The combined result is valid only if all input results are valid.
  All errors and warnings are aggregated.
  """
  @spec combine([t()]) :: t()
  def combine([]), do: success()
  def combine([single_result]), do: single_result

  def combine(results) when is_list(results) do
    all_errors = results |> Enum.flat_map(& &1.errors)
    all_warnings = results |> Enum.flat_map(& &1.warnings)
    total_task_count = results |> Enum.map(&(&1.task_count || 0)) |> Enum.sum()

    %__MODULE__{
      valid?: Enum.empty?(all_errors),
      errors: all_errors,
      warnings: all_warnings,
      task_count: total_task_count,
      validated_at: DateTime.utc_now()
    }
  end

  @doc """
  Adds an error to the validation result.
  """
  @spec add_error(t(), ValidationError.t()) :: t()
  def add_error(%__MODULE__{} = result, %ValidationError{} = error) do
    %{result | valid?: false, errors: result.errors ++ [error]}
  end

  @doc """
  Adds multiple errors to the validation result.
  """
  @spec add_errors(t(), [ValidationError.t()]) :: t()
  def add_errors(%__MODULE__{} = result, errors) when is_list(errors) do
    %{result | valid?: false, errors: result.errors ++ errors}
  end

  @doc """
  Adds a warning to the validation result.
  """
  @spec add_warning(t(), ValidationError.t()) :: t()
  def add_warning(%__MODULE__{} = result, %ValidationError{severity: :warning} = warning) do
    %{result | warnings: result.warnings ++ [warning]}
  end

  @doc """
  Adds multiple warnings to the validation result.
  """
  @spec add_warnings(t(), [ValidationError.t()]) :: t()
  def add_warnings(%__MODULE__{} = result, warnings) when is_list(warnings) do
    %{result | warnings: result.warnings ++ warnings}
  end

  @doc """
  Gets the total number of issues (errors + warnings).
  """
  @spec issue_count(t()) :: non_neg_integer()
  def issue_count(%__MODULE__{errors: errors, warnings: warnings}) do
    length(errors) + length(warnings)
  end

  @doc """
  Gets the number of errors.
  """
  @spec error_count(t()) :: non_neg_integer()
  def error_count(%__MODULE__{errors: errors}) do
    length(errors)
  end

  @doc """
  Gets the number of warnings.
  """
  @spec warning_count(t()) :: non_neg_integer()
  def warning_count(%__MODULE__{warnings: warnings}) do
    length(warnings)
  end

  @doc """
  Checks if the result has any issues (errors or warnings).
  """
  @spec has_issues?(t()) :: boolean()
  def has_issues?(%__MODULE__{} = result) do
    issue_count(result) > 0
  end

  @doc """
  Formats the validation result for display.
  """
  @spec format(t()) :: String.t()
  def format(%__MODULE__{valid?: true, task_count: task_count, warnings: warnings})
      when length(warnings) == 0 do
    "✓ TaskList validation passed! (#{task_count} tasks validated)"
  end

  def format(%__MODULE__{valid?: true, task_count: task_count, warnings: warnings}) do
    warning_count = length(warnings)

    formatted_warnings =
      warnings
      |> Enum.map(&ValidationError.format/1)
      |> Enum.join("\n")

    "✓ TaskList validation passed with #{warning_count} warning(s)! (#{task_count} tasks validated)\n\nWarnings:\n#{formatted_warnings}"
  end

  def format(%__MODULE__{
        valid?: false,
        errors: errors,
        warnings: warnings,
        task_count: task_count
      }) do
    error_count = length(errors)
    warning_count = length(warnings)

    formatted_errors =
      errors
      |> Enum.map(&ValidationError.format/1)
      |> Enum.join("\n")

    result = "✗ TaskList validation failed with #{error_count} error(s)"

    result =
      if warning_count > 0 do
        result <> " and #{warning_count} warning(s)"
      else
        result
      end

    result = result <> " (#{task_count} tasks processed)\n\nErrors:\n#{formatted_errors}"

    if warning_count > 0 do
      formatted_warnings =
        warnings
        |> Enum.map(&ValidationError.format/1)
        |> Enum.join("\n")

      result <> "\n\nWarnings:\n#{formatted_warnings}"
    else
      result
    end
  end

  @doc """
  Groups errors by type for analysis.
  """
  @spec group_errors_by_type(t()) :: %{ValidationError.error_type() => [ValidationError.t()]}
  def group_errors_by_type(%__MODULE__{errors: errors}) do
    Enum.group_by(errors, & &1.type)
  end

  @doc """
  Gets errors for a specific task ID.
  """
  @spec errors_for_task(t(), String.t()) :: [ValidationError.t()]
  def errors_for_task(%__MODULE__{errors: errors}, task_id) do
    Enum.filter(errors, &(&1.task_id == task_id))
  end

  @doc """
  Checks if a specific error type exists in the result.
  """
  @spec has_error_type?(t(), ValidationError.error_type()) :: boolean()
  def has_error_type?(%__MODULE__{errors: errors}, error_type) do
    Enum.any?(errors, &(&1.type == error_type))
  end
end
