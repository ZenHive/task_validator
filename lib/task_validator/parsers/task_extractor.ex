defmodule TaskValidator.Parsers.TaskExtractor do
  @moduledoc """
  Extracts tasks from markdown table and detailed sections.

  This module specializes in parsing different task formats found in TaskList
  documents, including table rows and detailed task sections with subtasks.
  """

  alias TaskValidator.Core.Task

  @doc """
  Extracts tasks from a markdown table section.

  ## Parameters
  - `lines`: List of markdown lines
  - `section_header`: The header to look for (e.g., "## Current Tasks")
  - `default_status`: Default status to assign to tasks from this section

  ## Returns
  `{:ok, list(Task.t())}` with extracted tasks or `{:error, reason}`
  """
  @spec extract_from_table(list(String.t()), String.t(), atom()) ::
          {:ok, list(Task.t())} | {:error, String.t()}
  def extract_from_table(lines, section_header, default_status \\ :planned) do
    case find_table_section(lines, section_header) do
      {:error, reason} ->
        {:error, reason}

      {:ok, {start_idx, table_lines}} ->
        tasks = parse_table_rows(table_lines, start_idx, default_status)
        {:ok, tasks}
    end
  end

  @doc """
  Extracts detailed task sections from markdown content.

  Looks for sections that start with "### TASKID:" and extracts all
  content and subtasks for each task.
  """
  @spec extract_detailed_tasks(list(String.t())) :: {:ok, list(map())}
  def extract_detailed_tasks(lines) when is_list(lines) do
    task_sections = find_task_sections(lines)
    detailed_tasks = Enum.map(task_sections, &parse_task_section(&1, lines))
    {:ok, detailed_tasks}
  end

  @doc """
  Extracts subtasks from a task content section.

  Supports both numbered subtasks (#### 1. Description (TASK001-1))
  and checkbox subtasks (- [x] Description [TASK001a]).
  """
  @spec extract_subtasks(list(String.t())) :: list(Task.t())
  def extract_subtasks(task_content) when is_list(task_content) do
    task_content
    |> Enum.with_index()
    |> Enum.filter(&is_subtask_line?/1)
    |> Enum.map(&parse_subtask_line/1)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Merges table tasks with their detailed task information.

  Table tasks provide basic metadata while detailed tasks provide
  full content, subtasks, and additional fields.
  """
  @spec merge_table_with_details(list(Task.t()), list(map())) :: list(Task.t())
  def merge_table_with_details(table_tasks, detailed_tasks) do
    detailed_map = Enum.into(detailed_tasks, %{}, fn task -> {task.id, task} end)

    merged_tasks =
      Enum.map(table_tasks, fn task ->
        case Map.get(detailed_map, task.id) do
          nil -> task
          detailed -> merge_task_with_details(task, detailed)
        end
      end)

    # Add detailed tasks that weren't in tables
    detailed_only = find_detailed_only_tasks(detailed_tasks, table_tasks)

    merged_tasks ++ detailed_only
  end

  # Private functions

  defp find_table_section(lines, section_header) do
    case Enum.find_index(lines, &(&1 == section_header)) do
      nil ->
        {:error, "Section '#{section_header}' not found"}

      section_index ->
        table_start = section_index + 3
        table_lines = extract_table_lines(lines, table_start)
        {:ok, {table_start, table_lines}}
    end
  end

  defp extract_table_lines(lines, start_idx) do
    lines
    |> Enum.drop(start_idx)
    |> Enum.with_index(start_idx)
    |> Enum.take_while(fn {line, _idx} ->
      !String.starts_with?(line, "##") && line != ""
    end)
    |> Enum.reject(fn {line, _idx} ->
      is_table_separator?(line)
    end)
    |> Enum.filter(fn {line, _idx} ->
      String.starts_with?(line, "|")
    end)
  end

  defp is_table_separator?(line) do
    String.starts_with?(line, "|") &&
      line |> String.trim() |> String.replace(~r/[\|\-\s]/, "") == ""
  end

  defp parse_table_rows(table_lines, _base_idx, default_status) do
    table_lines
    |> Enum.map(fn {line, idx} ->
      parse_table_row(line, idx, default_status)
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_table_row(line, line_number, default_status) do
    fields =
      line
      |> String.split("|", trim: true)
      |> Enum.map(&String.trim/1)

    if length(fields) >= 2 do
      [id | rest] = fields

      # Skip subtask IDs in tables - subtasks should only be in detailed sections
      # Subtask IDs have format: PREFIX###-# (like SSH001-1)
      # Main task IDs with dashes have different formats (like PROJ-001)
      if is_subtask_id?(id) do
        nil
      else
        description = if length(rest) >= 1, do: hd(rest), else: ""
        table_status = if length(fields) >= 3, do: Enum.at(fields, 2), else: ""
        priority = if length(fields) >= 4, do: Enum.at(fields, 3), else: ""

        %Task{
          id: id,
          description: description,
          status: determine_status(default_status, table_status),
          priority: priority,
          line_number: line_number,
          content: [],
          subtasks: [],
          type: determine_task_type(id),
          prefix: extract_prefix(id),
          category: nil,
          parent_id: extract_parent_id(id),
          review_rating: extract_review_rating(fields)
        }
      end
    else
      nil
    end
  end

  defp find_task_sections(lines) do
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
  end

  defp parse_task_section(%{id: id, start_line: start_line}, lines) do
    end_line = find_section_end(lines, start_line)
    content = Enum.slice(lines, start_line..end_line)
    subtasks = extract_subtasks(content)

    %{
      id: id,
      content: content,
      subtasks: subtasks,
      description: extract_field_from_content(content, "**Description**"),
      status: extract_field_from_content(content, "**Status**"),
      priority: extract_field_from_content(content, "**Priority**")
    }
  end

  defp find_section_end(lines, start_line) do
    lines
    |> Enum.drop(start_line + 1)
    |> Enum.with_index()
    |> Enum.find(fn {line, _} ->
      String.match?(line, ~r/^###\s/)
    end)
    |> case do
      nil -> length(lines) - 1
      {_, idx} -> start_line + idx
    end
  end

  defp is_subtask_line?({line, _idx}) do
    String.match?(line, ~r/^#### \d+\./) || String.match?(line, ~r/^- \[[x\s]\]/)
  end

  defp parse_subtask_line({line, idx}) do
    cond do
      String.match?(line, ~r/^#### \d+\./) ->
        parse_numbered_subtask(line, idx)

      String.match?(line, ~r/^- \[[x\s]\]/) ->
        parse_checkbox_subtask(line, idx)

      true ->
        nil
    end
  end

  defp parse_numbered_subtask(line, idx) do
    case Regex.run(~r/\(([A-Z]{2,4}\d{3,4}-\d+)\)/, line) do
      [_, subtask_id] ->
        %Task{
          id: subtask_id,
          line_number: idx,
          type: :subtask,
          prefix: extract_prefix(subtask_id),
          parent_id: extract_parent_id(subtask_id),
          description: extract_numbered_description(line),
          status: "Planned",
          priority: "",
          content: [],
          subtasks: [],
          category: nil,
          review_rating: nil
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
          category: nil,
          review_rating: nil
        }
    end
  end

  defp parse_checkbox_subtask(line, idx) do
    subtask_id = extract_checkbox_id(line)
    checked = String.contains?(line, "[x]")

    %Task{
      id: subtask_id,
      line_number: idx,
      type: :subtask,
      prefix: extract_prefix(subtask_id),
      parent_id: extract_parent_id(subtask_id),
      description: extract_checkbox_description(line),
      status: if(checked, do: "Completed", else: "Planned"),
      priority: "",
      content: [],
      subtasks: [],
      category: nil,
      review_rating: nil
    }
  end

  defp extract_checkbox_id(line) do
    case Regex.run(~r/\[([A-Z]{2,4}\d{3,4}[a-z]?)\]$/, line) do
      [_, id] ->
        id

      _ ->
        case Regex.run(~r/\*\*([A-Z]{2,4}\d{3,4}[a-z]?)\*\*/, line) do
          [_, id] -> id
          _ -> "INVALID_FORMAT"
        end
    end
  end

  defp merge_task_with_details(task, detailed) do
    %Task{
      task
      | content: detailed.content,
        subtasks: detailed.subtasks,
        description: detailed.description || task.description,
        status: detailed.status || task.status,
        priority: detailed.priority || task.priority
    }
  end

  defp find_detailed_only_tasks(detailed_tasks, table_tasks) do
    table_ids = MapSet.new(table_tasks, & &1.id)

    detailed_tasks
    |> Enum.reject(fn detailed -> MapSet.member?(table_ids, detailed.id) end)
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
        prefix: extract_prefix(detailed.id),
        category: nil,
        parent_id: extract_parent_id(detailed.id),
        review_rating: nil
      }
    end)
  end

  # Helper functions for extracting task attributes

  defp determine_status(:completed, _), do: "Completed"
  defp determine_status(:active, table_status) when table_status != "", do: table_status
  defp determine_status(:active, _), do: "Planned"
  defp determine_status(_, table_status) when table_status != "", do: table_status
  defp determine_status(_, _), do: "Planned"

  defp determine_task_type(id) do
    if is_subtask_id?(id) do
      :subtask
    else
      :main
    end
  end

  defp extract_prefix(id) do
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

  defp extract_field_from_content(content, field_name) do
    case Enum.find(content, &String.starts_with?(&1, field_name)) do
      nil ->
        nil

      field_line ->
        if String.contains?(field_line, ":") do
          field_line |> String.split(":", parts: 2) |> List.last() |> String.trim()
        else
          field_idx = Enum.find_index(content, &(&1 == field_line))

          if field_idx && field_idx + 1 < length(content) do
            Enum.at(content, field_idx + 1) |> String.trim()
          else
            nil
          end
        end
    end
  end

  defp extract_numbered_description(line) do
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

  # Helper function to distinguish subtask IDs from main task IDs with dashes
  defp is_subtask_id?(id) do
    # Subtask IDs follow the pattern: PREFIX###-# (e.g., SSH001-1, VAL0004-2)
    # Main task IDs with dashes have different patterns (e.g., PROJ-001, CORE-123)
    String.match?(id, ~r/^[A-Z]{2,4}\d{3,4}-\d+$/)
  end

  # Extract review rating from table row (usually the last column for completed tasks)
  defp extract_review_rating(fields) do
    if length(fields) >= 6 do
      rating = List.last(fields)
      if rating != "-" && rating != "", do: rating, else: nil
    else
      nil
    end
  end
end
