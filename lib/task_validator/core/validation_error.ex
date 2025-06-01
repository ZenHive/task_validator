defmodule TaskValidator.Core.ValidationError do
  @moduledoc """
  Represents a validation error with structured information.

  This struct provides a consistent format for validation errors
  throughout the system, including error type, message, context,
  and location information.
  """

  @type error_type ::
          :invalid_id_format
          | :invalid_status
          | :invalid_priority
          | :missing_section
          | :missing_error_handling
          | :incomplete_error_handling
          | :missing_subtasks
          | :invalid_subtask_prefix
          | :missing_review_rating
          | :invalid_dependency
          | :kpi_violation
          | :invalid_category
          | :missing_category_section
          | :missing_completion_details
          | :missing_reference
          | :duplicate_task_id
          | :invalid_table_format
          | :unknown_error

  @type severity :: :error | :warning

  @type t :: %__MODULE__{
          type: error_type(),
          message: String.t(),
          task_id: String.t() | nil,
          line_number: non_neg_integer() | nil,
          section: String.t() | nil,
          severity: severity(),
          context: map()
        }

  defstruct [
    :type,
    :message,
    :task_id,
    :line_number,
    :section,
    :severity,
    :context
  ]

  @doc """
  Creates a new validation error.
  """
  @spec new(error_type(), String.t(), keyword()) :: t()
  def new(type, message, opts \\ []) do
    %__MODULE__{
      type: type,
      message: message,
      task_id: Keyword.get(opts, :task_id),
      line_number: Keyword.get(opts, :line_number),
      section: Keyword.get(opts, :section),
      severity: Keyword.get(opts, :severity, :error),
      context: Keyword.get(opts, :context, %{})
    }
  end

  @doc """
  Creates an error for invalid task ID format.
  """
  @spec invalid_id_format(String.t(), keyword()) :: t()
  def invalid_id_format(task_id, opts \\ []) do
    message =
      "Invalid task ID format: #{task_id}. Expected format: [A-Z]{2,4}\\d{3,4}(-\\d+|[a-z])?"

    new(:invalid_id_format, message, Keyword.put(opts, :task_id, task_id))
  end

  @doc """
  Creates an error for invalid status value.
  """
  @spec invalid_status(String.t(), String.t(), keyword()) :: t()
  def invalid_status(task_id, status, opts \\ []) do
    valid_statuses = ["Planned", "In Progress", "Review", "Completed", "Blocked"]

    message =
      "Invalid status '#{status}' for task #{task_id}. Valid statuses: #{Enum.join(valid_statuses, ", ")}"

    new(:invalid_status, message, Keyword.put(opts, :task_id, task_id))
  end

  @doc """
  Creates an error for invalid priority value.
  """
  @spec invalid_priority(String.t(), String.t(), keyword()) :: t()
  def invalid_priority(task_id, priority, opts \\ []) do
    valid_priorities = ["Critical", "High", "Medium", "Low"]

    message =
      "Invalid priority '#{priority}' for task #{task_id}. Valid priorities: #{Enum.join(valid_priorities, ", ")}"

    new(:invalid_priority, message, Keyword.put(opts, :task_id, task_id))
  end

  @doc """
  Creates an error for missing required section.
  """
  @spec missing_section(String.t(), String.t(), keyword()) :: t()
  def missing_section(task_id, section_name, opts \\ []) do
    message = "Missing required section '#{section_name}' in task #{task_id}"

    new(
      :missing_section,
      message,
      opts
      |> Keyword.put(:task_id, task_id)
      |> Keyword.put(:section, section_name)
    )
  end

  @doc """
  Creates an error for missing error handling documentation.
  """
  @spec missing_error_handling(String.t(), keyword()) :: t()
  def missing_error_handling(task_id, opts \\ []) do
    message = "Missing error handling documentation for task #{task_id}"
    new(:missing_error_handling, message, Keyword.put(opts, :task_id, task_id))
  end

  @doc """
  Creates an error for incomplete error handling documentation.
  """
  @spec incomplete_error_handling(String.t(), [String.t()], keyword()) :: t()
  def incomplete_error_handling(task_id, missing_sections, opts \\ []) do
    message =
      "Incomplete error handling documentation for task #{task_id}. Missing: #{Enum.join(missing_sections, ", ")}"

    new(
      :incomplete_error_handling,
      message,
      opts
      |> Keyword.put(:task_id, task_id)
      |> Keyword.put(:context, %{missing_sections: missing_sections})
    )
  end

  @doc """
  Creates an error for missing subtasks in "In Progress" task.
  """
  @spec missing_subtasks(String.t(), keyword()) :: t()
  def missing_subtasks(task_id, opts \\ []) do
    message = "Task #{task_id} is 'In Progress' but has no subtasks defined"
    new(:missing_subtasks, message, Keyword.put(opts, :task_id, task_id))
  end

  @doc """
  Creates an error for invalid subtask prefix.
  """
  @spec invalid_subtask_prefix(String.t(), String.t(), String.t(), keyword()) :: t()
  def invalid_subtask_prefix(subtask_id, expected_prefix, actual_prefix, opts \\ []) do
    message =
      "Subtask #{subtask_id} has prefix '#{actual_prefix}' but should have '#{expected_prefix}'"

    new(
      :invalid_subtask_prefix,
      message,
      opts
      |> Keyword.put(:task_id, subtask_id)
      |> Keyword.put(:context, %{expected_prefix: expected_prefix, actual_prefix: actual_prefix})
    )
  end

  @doc """
  Creates an error for missing review rating in completed subtask.
  """
  @spec missing_review_rating(String.t(), keyword()) :: t()
  def missing_review_rating(task_id, opts \\ []) do
    message = "Completed subtask #{task_id} is missing review rating"
    new(:missing_review_rating, message, Keyword.put(opts, :task_id, task_id))
  end

  @doc """
  Creates an error for invalid dependency reference.
  """
  @spec invalid_dependency(String.t(), String.t(), keyword()) :: t()
  def invalid_dependency(task_id, dependency_id, opts \\ []) do
    message = "Task #{task_id} references non-existent dependency: #{dependency_id}"

    new(
      :invalid_dependency,
      message,
      opts
      |> Keyword.put(:task_id, task_id)
      |> Keyword.put(:context, %{dependency_id: dependency_id})
    )
  end

  @doc """
  Creates an error for KPI violation.
  """
  @spec kpi_violation(String.t(), String.t(), any(), any(), keyword()) :: t()
  def kpi_violation(task_id, kpi_name, actual_value, max_value, opts \\ []) do
    message =
      "Task #{task_id} violates #{kpi_name} KPI: #{actual_value} exceeds maximum of #{max_value}"

    new(
      :kpi_violation,
      message,
      opts
      |> Keyword.put(:task_id, task_id)
      |> Keyword.put(:context, %{
        kpi_name: kpi_name,
        actual_value: actual_value,
        max_value: max_value
      })
    )
  end

  @doc """
  Creates an error for missing reference definition.
  """
  @spec missing_reference(String.t(), keyword()) :: t()
  def missing_reference(reference_name, opts \\ []) do
    message = "Reference '#{reference_name}' is used but not defined"

    new(
      :missing_reference,
      message,
      opts
      |> Keyword.put(:context, %{reference_name: reference_name})
    )
  end

  @doc """
  Creates an error for duplicate task ID.
  """
  @spec duplicate_task_id(String.t(), keyword()) :: t()
  def duplicate_task_id(task_id, opts \\ []) do
    message = "Duplicate task ID found: #{task_id}"
    new(:duplicate_task_id, message, Keyword.put(opts, :task_id, task_id))
  end

  @doc """
  Formats the error for display.
  """
  @spec format(t()) :: String.t()
  def format(%__MODULE__{} = error) do
    location =
      case {error.task_id, error.line_number} do
        {nil, nil} -> ""
        {task_id, nil} -> " (#{task_id})"
        {nil, line_number} -> " (line #{line_number})"
        {task_id, line_number} -> " (#{task_id}, line #{line_number})"
      end

    severity_prefix =
      case error.severity do
        :error -> "ERROR"
        :warning -> "WARNING"
      end

    "#{severity_prefix}#{location}: #{error.message}"
  end
end
