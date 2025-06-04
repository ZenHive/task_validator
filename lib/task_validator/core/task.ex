defmodule TaskValidator.Core.Task do
  @moduledoc """
  Core domain model representing a task in the task list.

  This struct encapsulates all task-related data and provides a clear
  contract for working with tasks throughout the validation system.
  """

  @type task_type :: :main | :subtask

  @type t :: %__MODULE__{
          id: String.t(),
          description: String.t(),
          status: String.t(),
          priority: String.t(),
          content: [String.t()],
          subtasks: [t()],
          line_number: non_neg_integer(),
          type: task_type(),
          prefix: String.t() | nil,
          category: atom() | nil,
          parent_id: String.t() | nil,
          review_rating: String.t() | nil
        }

  defstruct [
    :id,
    :description,
    :status,
    :priority,
    :content,
    :subtasks,
    :line_number,
    :type,
    :prefix,
    :category,
    :parent_id,
    :review_rating
  ]

  @doc """
  Creates a new main task.
  """
  @spec new_main_task(
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          [String.t()],
          non_neg_integer()
        ) :: t()
  def new_main_task(id, description, status, priority, content, line_number) do
    %__MODULE__{
      id: id,
      description: description,
      status: status,
      priority: priority,
      content: content || [],
      subtasks: [],
      line_number: line_number,
      type: :main,
      prefix: extract_prefix(id),
      category: determine_category(id),
      parent_id: nil,
      review_rating: nil
    }
  end

  @doc """
  Creates a new subtask.
  """
  @spec new_subtask(
          String.t(),
          String.t(),
          String.t(),
          [String.t()],
          non_neg_integer(),
          String.t()
        ) :: t()
  def new_subtask(id, description, status, content, line_number, parent_id) do
    %__MODULE__{
      id: id,
      description: description,
      status: status,
      priority: nil,
      content: content || [],
      subtasks: [],
      line_number: line_number,
      type: :subtask,
      prefix: extract_prefix(id),
      category: determine_category(id),
      parent_id: parent_id,
      review_rating: nil
    }
  end

  @doc """
  Extracts the prefix from a task ID (e.g., "SSH" from "SSH0001").
  """
  @spec extract_prefix(String.t()) :: String.t() | nil
  def extract_prefix(id) when is_binary(id) do
    case Regex.run(~r/^([A-Z]{2,4})\d/, id) do
      [_, prefix] -> prefix
      _ -> nil
    end
  end

  @doc """
  Determines the category based on the task ID number.
  """
  @spec determine_category(String.t()) :: atom() | nil
  def determine_category(id) when is_binary(id) do
    case Regex.run(~r/\d{3,4}/, id) do
      [number_str] ->
        number = String.to_integer(number_str)

        cond do
          number >= 1 && number <= 99 -> :otp_genserver
          number >= 100 && number <= 199 -> :phoenix_web
          number >= 200 && number <= 299 -> :business_logic
          number >= 300 && number <= 399 -> :data_layer
          number >= 400 && number <= 499 -> :infrastructure
          number >= 500 && number <= 599 -> :testing
          true -> :other
        end

      _ ->
        nil
    end
  end

  @doc """
  Checks if the task is a main task.
  """
  @spec main_task?(t()) :: boolean()
  def main_task?(%__MODULE__{type: :main}), do: true
  def main_task?(_), do: false

  @doc """
  Checks if the task is a subtask.
  """
  @spec subtask?(t()) :: boolean()
  def subtask?(%__MODULE__{type: :subtask}), do: true
  def subtask?(_), do: false

  @doc """
  Checks if the task is completed.
  """
  @spec completed?(t()) :: boolean()
  def completed?(%__MODULE__{status: "Completed"}), do: true
  def completed?(_), do: false

  @doc """
  Checks if the task is in progress.
  """
  @spec in_progress?(t()) :: boolean()
  def in_progress?(%__MODULE__{status: "In Progress"}), do: true
  def in_progress?(_), do: false

  @doc """
  Adds a subtask to the task.
  """
  @spec add_subtask(t(), t()) :: t()
  def add_subtask(%__MODULE__{subtasks: subtasks} = task, subtask) do
    %{task | subtasks: subtasks ++ [subtask]}
  end

  @doc """
  Gets the parent task ID for a subtask.
  """
  @spec get_parent_id(String.t()) :: String.t() | nil
  def get_parent_id(subtask_id) when is_binary(subtask_id) do
    case Regex.run(~r/^([A-Z]{2,4}\d{3,4})/, subtask_id) do
      [_, parent_id] -> parent_id
      _ -> nil
    end
  end
end
