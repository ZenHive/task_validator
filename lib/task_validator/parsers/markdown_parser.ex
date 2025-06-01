defmodule TaskValidator.Parsers.MarkdownParser do
  @moduledoc """
  Parses Markdown content for task validation.

  This module handles the core parsing of Markdown files, extracting structured
  data that can be validated by the TaskValidator system. It separates parsing
  concerns from validation logic.
  """

  alias TaskValidator.Core.{Task, TaskList}

  @doc """
  Parses markdown content into a structured TaskList.

  Returns a TaskList struct containing all parsed tasks and metadata.
  """
  @spec parse(String.t()) :: {:ok, TaskList.t()} | {:error, String.t()}
  def parse(content) when is_binary(content) do
    lines = String.split(content, "\n")

    with {:ok, references} <- extract_references(lines),
         {:ok, tasks} <- extract_tasks(lines) do
      task_list = %TaskList{
        tasks: tasks,
        references: references,
        parsed_at: DateTime.utc_now()
      }

      {:ok, task_list}
    end
  end

  @doc """
  Extracts reference definitions from markdown content.

  Reference definitions follow the format:
  ## \\{\\{reference-name\\}\\} or ## #\\{\\{reference-name\\}\\}
  """
  @spec extract_references(list(String.t())) :: {:ok, map()}
  def extract_references(lines) when is_list(lines) do
    references =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, idx}, acc ->
        case Regex.run(~r/^## #?\{\{([^}]+)\}\}$/, line) do
          [_, ref_name] ->
            content = extract_reference_content(lines, idx + 1)
            Map.put(acc, ref_name, content)

          _ ->
            acc
        end
      end)

    {:ok, references}
  end

  @doc """
  Extracts tasks from markdown content.

  Looks for tasks in both "Current Tasks" and "Completed Tasks" sections.
  """
  @spec extract_tasks(list(String.t())) :: {:ok, list(Task.t())} | {:error, String.t()}
  def extract_tasks(lines) when is_list(lines) do
    # Extract detailed task sections first
    detailed_tasks = extract_detailed_tasks(lines)

    # Extract table tasks and merge with detailed tasks
    current_tasks = extract_tasks_from_table(lines, "## Current Tasks", :active)
    completed_tasks = extract_tasks_from_table(lines, "## Completed Tasks", :completed)

    # Combine all tasks
    table_tasks = current_tasks ++ completed_tasks

    # Merge table tasks with detailed tasks
    tasks = merge_tasks_with_details(table_tasks, detailed_tasks)

    if tasks == [] do
      {:error, "No tasks found in the document"}
    else
      {:ok, tasks}
    end
  end

  @doc """
  Validates that all reference placeholders have corresponding definitions.
  """
  @spec validate_references(list(String.t()), map()) :: :ok | {:error, String.t()}
  def validate_references(lines, references) when is_list(lines) and is_map(references) do
    missing_refs =
      lines
      |> Enum.with_index()
      |> Enum.reduce([], fn {line, line_num}, acc ->
        refs = Regex.scan(~r/\{\{([^}]+)\}\}/, line)

        Enum.reduce(refs, acc, fn [_full_match, ref_name], inner_acc ->
          if Map.has_key?(references, ref_name) do
            inner_acc
          else
            [{ref_name, line_num + 1} | inner_acc]
          end
        end)
      end)
      |> Enum.reverse()

    if missing_refs == [] do
      :ok
    else
      missing_list =
        missing_refs
        |> Enum.map(fn {ref, line} -> "  - '{{#{ref}}}' at line #{line}" end)
        |> Enum.join("\n")

      {:error, "Missing reference definitions:\n#{missing_list}"}
    end
  end

  # Private functions

  defp extract_reference_content(lines, start_idx) do
    lines
    |> Enum.drop(start_idx)
    |> Enum.take_while(fn line ->
      !String.starts_with?(line, "## ")
    end)
  end

  defp extract_tasks_from_table(lines, section_header, status) do
    section_index = Enum.find_index(lines, &(&1 == section_header))

    if section_index do
      table_start = section_index + 3

      Enum.reduce_while(Enum.with_index(Enum.drop(lines, table_start)), [], fn {line, idx}, acc ->
        actual_idx = table_start + idx

        cond do
          String.starts_with?(line, "##") || line == "" ->
            {:halt, acc}

          String.starts_with?(line, "|") &&
              line |> String.trim() |> String.replace(~r/[\|\-\s]/, "") == "" ->
            {:cont, acc}

          String.starts_with?(line, "|") ->
            fields =
              line
              |> String.split("|", trim: true)
              |> Enum.map(&String.trim/1)

            if length(fields) >= 2 do
              [id | rest] = fields
              table_status = if length(fields) >= 3, do: Enum.at(fields, 2), else: ""
              description = if length(rest) >= 1, do: hd(rest), else: ""
              priority = if length(fields) >= 4, do: Enum.at(fields, 3), else: ""

              task = %Task{
                id: id,
                description: description,
                status: determine_task_status(status, table_status),
                priority: priority,
                line_number: actual_idx,
                content: [],
                subtasks: [],
                type: determine_task_type(id),
                prefix: extract_task_prefix(id),
                category: nil,
                parent_id: extract_parent_id(id)
              }

              {:cont, [task | acc]}
            else
              {:cont, acc}
            end

          true ->
            {:cont, acc}
        end
      end)
      |> Enum.reverse()
    else
      []
    end
  end

  defp extract_detailed_tasks(lines) do
    task_indices =
      lines
      |> Enum.with_index()
      |> Enum.filter(fn {line, _} ->
        # Match both traditional format (SSH0001) and dash format (PROJ-0001)
        String.match?(line, ~r/^### [A-Z-]{2,9}\d{3,4}:/)
      end)
      |> Enum.map(fn {line, idx} ->
        # Extract ID from various formats: SSH0001, PROJ-0001, etc.
        [_, id | _] = Regex.run(~r/### ([A-Z-]{2,9}\d{3,4})/, line)
        %{id: id, start_line: idx}
      end)

    Enum.map(task_indices, fn %{id: id, start_line: start_line} ->
      end_line =
        lines
        |> Enum.drop(start_line + 1)
        |> Enum.with_index()
        |> Enum.find(fn {line, _} ->
          String.match?(line, ~r/^###\s/)
        end)
        |> case do
          nil -> length(lines)
          {_, idx} -> start_line + 1 + idx
        end

      content = Enum.slice(lines, start_line..end_line)
      subtasks = extract_subtasks(content)

      %{
        id: id,
        content: content,
        subtasks: subtasks,
        description: extract_description_from_content(content),
        status: extract_status_from_content(content),
        priority: extract_priority_from_content(content)
      }
    end)
  end

  defp extract_subtasks(task_content) do
    task_content
    |> Enum.with_index()
    |> Enum.filter(fn {line, _} ->
      String.match?(line, ~r/^#### \d+\./) || String.match?(line, ~r/^- \[[x\s]\]/)
    end)
    |> Enum.map(fn {line, idx} ->
      cond do
        String.match?(line, ~r/^#### \d+\./) ->
          case Regex.run(~r/\(([A-Z]{2,4}\d{3,4}-\d+)\)/, line) do
            [_, subtask_id] ->
              %Task{
                id: subtask_id,
                line_number: idx,
                type: :subtask,
                prefix: extract_task_prefix(subtask_id),
                parent_id: extract_parent_id(subtask_id),
                description: extract_subtask_description(line),
                status: "Planned",
                priority: "",
                content: [],
                subtasks: [],
                category: nil
              }

            _ ->
              %Task{
                id: "INVALID_FORMAT",
                line_number: idx,
                type: :subtask,
                prefix: nil,
                parent_id: nil,
                description: line,
                status: "Planned",
                priority: "",
                content: [],
                subtasks: [],
                category: nil
              }
          end

        String.match?(line, ~r/^- \[[x\s]\]/) ->
          subtask_id =
            case Regex.run(~r/\[([A-Z]{2,4}\d{3,4}[a-z]?)\]$/, line) do
              [_, id] ->
                id

              _ ->
                case Regex.run(~r/\*\*([A-Z]{2,4}\d{3,4}[a-z]?)\*\*/, line) do
                  [_, id] -> id
                  _ -> "INVALID_FORMAT"
                end
            end

          checked = String.contains?(line, "[x]")

          %Task{
            id: subtask_id,
            line_number: idx,
            type: :subtask,
            prefix: extract_task_prefix(subtask_id),
            parent_id: extract_parent_id(subtask_id),
            description: extract_checkbox_description(line),
            status: if(checked, do: "Completed", else: "Planned"),
            priority: "",
            content: [],
            subtasks: [],
            category: nil
          }
      end
    end)
  end

  defp merge_tasks_with_details(table_tasks, detailed_tasks) do
    # Create a map of detailed tasks for easy lookup
    detailed_map = Enum.into(detailed_tasks, %{}, fn task -> {task.id, task} end)

    # Merge table tasks with their detailed information
    merged_tasks =
      Enum.map(table_tasks, fn task ->
        case Map.get(detailed_map, task.id) do
          nil ->
            task

          detailed ->
            %Task{
              task
              | content: detailed.content,
                subtasks: detailed.subtasks,
                description: detailed.description || task.description,
                status: detailed.status || task.status,
                priority: detailed.priority || task.priority
            }
        end
      end)

    # Add any detailed tasks that weren't in the tables
    detailed_only =
      detailed_tasks
      |> Enum.reject(fn detailed -> Enum.any?(table_tasks, &(&1.id == detailed.id)) end)
      |> Enum.map(fn detailed ->
        %Task{
          id: detailed.id,
          description: detailed.description,
          status: detailed.status || "Planned",
          priority: detailed.priority || "Medium",
          content: detailed.content,
          subtasks: detailed.subtasks,
          line_number: 0,
          type: determine_task_type(detailed.id),
          prefix: extract_task_prefix(detailed.id),
          category: nil,
          parent_id: extract_parent_id(detailed.id)
        }
      end)

    merged_tasks ++ detailed_only
  end

  # Helper functions for task attribute extraction

  defp determine_task_status(:active, table_status) when table_status != "",
    do: table_status

  defp determine_task_status(:active, _), do: "Planned"
  defp determine_task_status(:completed, _), do: "Completed"

  defp determine_task_type(id) do
    if is_subtask_id?(id) do
      :subtask
    else
      :main
    end
  end

  # Helper function to distinguish subtask IDs from main task IDs with dashes
  defp is_subtask_id?(id) do
    # Subtask IDs follow the pattern: PREFIX###-# (e.g., SSH001-1, VAL0004-2)
    # Main task IDs with dashes have different patterns (e.g., PROJ-001, CORE-123)
    String.match?(id, ~r/^[A-Z]{2,4}\d{3,4}-\d+$/)
  end

  defp extract_task_prefix(id) do
    case Regex.run(~r/^([A-Z]{2,4})/, id) do
      [_, prefix] -> prefix
      _ -> nil
    end
  end

  defp extract_parent_id(id) do
    case Regex.run(~r/^([A-Z]{2,4}\d{3,4})-\d+$/, id) do
      [_, parent_id] -> parent_id
      _ -> nil
    end
  end

  defp extract_description_from_content(content) do
    case Enum.find(content, &String.starts_with?(&1, "**Description**")) do
      nil ->
        ""

      desc_line ->
        if String.contains?(desc_line, ":") do
          desc_line |> String.split(":", parts: 2) |> List.last() |> String.trim()
        else
          # Description is on the next line
          desc_idx = Enum.find_index(content, &(&1 == desc_line))

          if desc_idx && desc_idx + 1 < length(content) do
            Enum.at(content, desc_idx + 1) |> String.trim()
          else
            ""
          end
        end
    end
  end

  defp extract_status_from_content(content) do
    case Enum.find(content, &String.starts_with?(&1, "**Status**")) do
      nil ->
        nil

      status_line ->
        if String.contains?(status_line, ":") do
          status_line |> String.split(":", parts: 2) |> List.last() |> String.trim()
        else
          status_idx = Enum.find_index(content, &(&1 == status_line))

          if status_idx && status_idx + 1 < length(content) do
            Enum.at(content, status_idx + 1) |> String.trim()
          else
            nil
          end
        end
    end
  end

  defp extract_priority_from_content(content) do
    case Enum.find(content, &String.starts_with?(&1, "**Priority**")) do
      nil ->
        nil

      priority_line ->
        if String.contains?(priority_line, ":") do
          priority_line |> String.split(":", parts: 2) |> List.last() |> String.trim()
        else
          priority_idx = Enum.find_index(content, &(&1 == priority_line))

          if priority_idx && priority_idx + 1 < length(content) do
            Enum.at(content, priority_idx + 1) |> String.trim()
          else
            nil
          end
        end
    end
  end

  defp extract_subtask_description(line) do
    case Regex.run(~r/^#### \d+\.\s*(.+?)(?:\s*\([A-Z]{2,4}\d{3,4}-\d+\))?$/, line) do
      [_, desc] -> String.trim(desc)
      _ -> String.trim(line)
    end
  end

  defp extract_checkbox_description(line) do
    line
    |> String.replace(~r/^- \[[x\s]\]\s*/, "")
    |> String.replace(~r/\s*\[[A-Z]{2,4}\d{3,4}[a-z]?\]$/, "")
    |> String.replace(~r/\*\*[A-Z]{2,4}\d{3,4}[a-z]?\*\*:?\s*/, "")
    |> String.trim()
  end
end
