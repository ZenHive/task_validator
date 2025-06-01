defmodule TaskValidator.Core.TaskList do
  @moduledoc """
  Represents a complete task list with all its tasks and metadata.

  This aggregate encapsulates a collection of tasks along with
  validation metadata and reference definitions.
  """

  alias TaskValidator.Core.Task

  @type t :: %__MODULE__{
          tasks: [Task.t()],
          references: map(),
          file_path: String.t() | nil,
          total_lines: non_neg_integer(),
          parsed_at: DateTime.t()
        }

  defstruct [
    :tasks,
    :references,
    :file_path,
    :total_lines,
    :parsed_at
  ]

  @doc """
  Creates a new task list.
  """
  @spec new([Task.t()], map(), keyword()) :: t()
  def new(tasks, references, opts \\ []) do
    %__MODULE__{
      tasks: tasks,
      references: references,
      file_path: Keyword.get(opts, :file_path),
      total_lines: Keyword.get(opts, :total_lines, 0),
      parsed_at: DateTime.utc_now()
    }
  end

  @doc """
  Gets all main tasks from the task list.
  """
  @spec main_tasks(t()) :: [Task.t()]
  def main_tasks(%__MODULE__{tasks: tasks}) do
    Enum.filter(tasks, &Task.main_task?/1)
  end

  @doc """
  Gets all subtasks from the task list.
  """
  @spec subtasks(t()) :: [Task.t()]
  def subtasks(%__MODULE__{tasks: tasks}) do
    Enum.filter(tasks, &Task.subtask?/1)
  end

  @doc """
  Gets tasks by status.
  """
  @spec tasks_by_status(t(), String.t()) :: [Task.t()]
  def tasks_by_status(%__MODULE__{tasks: tasks}, status) do
    Enum.filter(tasks, &(&1.status == status))
  end

  @doc """
  Gets tasks by category.
  """
  @spec tasks_by_category(t(), atom()) :: [Task.t()]
  def tasks_by_category(%__MODULE__{tasks: tasks}, category) do
    Enum.filter(tasks, &(&1.category == category))
  end

  @doc """
  Finds a task by ID.
  """
  @spec find_task(t(), String.t()) :: Task.t() | nil
  def find_task(%__MODULE__{tasks: tasks}, task_id) do
    Enum.find(tasks, &(&1.id == task_id))
  end

  @doc """
  Checks if a task ID exists in the task list.
  """
  @spec task_exists?(t(), String.t()) :: boolean()
  def task_exists?(%__MODULE__{} = task_list, task_id) do
    find_task(task_list, task_id) != nil
  end

  @doc """
  Gets all task IDs from the task list.
  """
  @spec task_ids(t()) :: [String.t()]
  def task_ids(%__MODULE__{tasks: tasks}) do
    Enum.map(tasks, & &1.id)
  end

  @doc """
  Checks if a reference exists in the task list.
  """
  @spec reference_exists?(t(), String.t()) :: boolean()
  def reference_exists?(%__MODULE__{references: references}, reference_name) do
    Map.has_key?(references, reference_name)
  end

  @doc """
  Gets the total number of tasks.
  """
  @spec task_count(t()) :: non_neg_integer()
  def task_count(%__MODULE__{tasks: tasks}) do
    length(tasks)
  end

  @doc """
  Gets statistics about the task list.
  """
  @spec stats(t()) :: map()
  def stats(%__MODULE__{} = task_list) do
    main_tasks = main_tasks(task_list)
    subtasks = subtasks(task_list)

    %{
      total_tasks: task_count(task_list),
      main_tasks: length(main_tasks),
      subtasks: length(subtasks),
      completed_tasks: length(tasks_by_status(task_list, "Completed")),
      in_progress_tasks: length(tasks_by_status(task_list, "In Progress")),
      planned_tasks: length(tasks_by_status(task_list, "Planned")),
      references: map_size(task_list.references),
      categories: task_list.tasks |> Enum.map(& &1.category) |> Enum.uniq() |> Enum.count()
    }
  end
end
