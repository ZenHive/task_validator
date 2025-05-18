defmodule TaskValidator do
  @moduledoc """
  Validates TaskList.md format compliance according to project guidelines.

  The `TaskValidator` ensures that task documents follow a consistent structure,
  making it easier to track and manage work across multiple project components.

  ## Validation Checks

  * ID format compliance (like SSH0001, SCP0001, ERR001, etc.)
  * Unique task IDs across the document
  * Required sections and fields present in each task, including Error Handling Guidelines
  * Proper subtask structure with consistent prefixes
  * Valid status values from the allowed list
  * Proper review rating format for completed tasks
  * Error handling patterns and conventions

  ## Usage Example

      case TaskValidator.validate_file("path/to/TaskList.md") do
        {:ok, message} ->
          # Task list validation succeeded
          IO.puts("Validation passed: " <> message)
        {:error, reason} ->
          # Task list validation failed
          IO.puts("Validation failed: " <> reason)
      end
  """

  @valid_statuses ["Planned", "In Progress", "Review", "Completed", "Blocked"]
  @valid_priorities ["Critical", "High", "Medium", "Low"]
  # Support various prefixes (2-4 uppercase letters) followed by digits
  @id_regex ~r/^[A-Z]{2,4}\d{3,4}(-\d+)?$/
  @rating_regex ~r/^([1-5](\.\d)?)\s*(\(partial\))?$/

  # Required sections for error handling - machine-readable, token-optimized format
  @error_handling_sections [
    "**Error Handling**",
    "**Core Principles**",
    "- Pass raw errors",
    "- Use {:ok, result} | {:error, reason}",
    "- Let it crash",
    "**Error Implementation**",
    "- No wrapping",
    "- Minimal rescue",
    "- function/1 & /! versions",
    "**Error Examples**",
    "- Raw error passthrough",
    "- Simple rescue case",
    "- Supervisor handling"
  ]

  # Add new required sections for completed tasks
  @completed_task_sections [
    "**Implementation Notes**",
    "**Complexity Assessment**",
    "**Maintenance Impact**",
    "**Error Handling Implementation**"
  ]

  @doc """
  Validates a TaskList.md file against the specified format requirements.

  Returns `:ok` if validation passes, or `{:error, reason}` if it fails.
  """
  @spec validate_file(String.t()) :: :ok | {:error, String.t()}
  def validate_file(file_path) do
    with {:ok, content} <- File.read(file_path),
         {:ok, lines} <- {:ok, String.split(content, "\n")},
         {:ok, tasks} <- extract_tasks(lines),
         :ok <- validate_task_ids(tasks),
         :ok <- validate_task_details(lines, tasks) do
      {:ok, "TaskList.md validation passed!"}
    end
  end

  @doc """
  Extracts tasks from the TaskList.md content.
  """
  @spec extract_tasks(list(String.t())) :: {:ok, list(map())} | {:error, String.t()}
  def extract_tasks(lines) do
    # Extract tasks from the "Current Tasks" and "Completed Tasks" tables
    current_tasks = extract_tasks_from_table(lines, "## Current Tasks")
    completed_tasks = extract_tasks_from_table(lines, "## Completed Tasks")

    # Add status information to each task
    current_tasks = add_status_to_tasks(current_tasks, "active")
    completed_tasks = add_status_to_tasks(completed_tasks, "completed")

    # Combine tasks
    tasks = current_tasks ++ completed_tasks

    # Check if we found any tasks
    if tasks == [] do
      {:error, "No tasks found in the document"}
    else
      {:ok, tasks}
    end
  end

  defp add_status_to_tasks(tasks, status) do
    Enum.map(tasks, fn task -> Map.put(task, :status, status) end)
  end

  defp extract_tasks_from_table(lines, section_header) do
    # Find the section
    section_index = Enum.find_index(lines, &(&1 == section_header))

    if section_index do
      # Find table start (usually 2 lines after the header, after the table header row)
      # Skip header, table header, and separator line
      table_start = section_index + 3

      # Extract table rows until the next section or end of file
      Enum.reduce_while(Enum.with_index(Enum.drop(lines, table_start)), [], fn {line, idx}, acc ->
        actual_idx = table_start + idx

        cond do
          # Stop at the next section or if the line is empty
          String.starts_with?(line, "##") || line == "" ->
            {:halt, acc}

          # Skip table separator rows
          String.starts_with?(line, "|") &&
              line |> String.trim() |> String.replace(~r/[\|\-\s]/, "") == "" ->
            {:cont, acc}

          # Process table row
          String.starts_with?(line, "|") ->
            fields =
              line
              |> String.split("|", trim: true)
              |> Enum.map(&String.trim/1)

            if length(fields) >= 2 do
              [id | _rest] = fields
              # Extract status if available (usually the 3rd column)
              status = if length(fields) >= 3, do: Enum.at(fields, 2), else: ""
              {:cont, [%{id: id, line: actual_idx, raw_status: status} | acc]}
            else
              {:cont, acc}
            end

          true ->
            {:cont, acc}
        end
      end)
    else
      []
    end
  end

  defp validate_task_ids(tasks) do
    # Check for ID format compliance
    invalid_format_ids =
      Enum.filter(tasks, fn %{id: id} ->
        !Regex.match?(@id_regex, id)
      end)

    if invalid_format_ids == [] do
      # Check for duplicate IDs
      {_, duplicates} =
        tasks
        |> Enum.map(fn %{id: id} -> id end)
        |> Enum.reduce({MapSet.new(), MapSet.new()}, fn id, {seen, dupes} ->
          if MapSet.member?(seen, id) do
            {seen, MapSet.put(dupes, id)}
          else
            {MapSet.put(seen, id), dupes}
          end
        end)

      if MapSet.size(duplicates) > 0 do
        dupes_list = duplicates |> MapSet.to_list() |> Enum.join(", ")
        {:error, "Duplicate task IDs found: #{dupes_list}"}
      else
        :ok
      end
    else
      task_lines =
        Enum.map_join(invalid_format_ids, "\n", fn %{id: id, line: line} ->
          "  Line #{line}: #{id} (invalid format)"
        end)

      {:error, "Invalid task ID format:\n#{task_lines}"}
    end
  end

  defp validate_task_details(lines, tasks) do
    # Extract and validate detailed task sections
    detailed_tasks = extract_detailed_tasks(lines)

    # Check if all ACTIVE (non-completed) tasks have detailed entries
    # Only check tasks that aren't completed - completed tasks don't need detailed entries
    active_task_ids =
      tasks
      |> Enum.filter(fn %{status: status} -> status == "active" end)
      |> Enum.map(& &1.id)

    detailed_task_ids = Enum.map(detailed_tasks, & &1.id)

    missing_details =
      Enum.filter(active_task_ids, fn id ->
        # Only check main task IDs (without subtask suffix)
        base_id = if String.contains?(id, "-"), do: id |> String.split("-") |> hd(), else: id
        # Check if this active task has detailed entry
        has_details? =
          Enum.any?(detailed_task_ids, fn detailed_id -> detailed_id == base_id end)

        # Return true if it's an active task but missing details
        !has_details? && !String.contains?(id, "-")
      end)

    if missing_details == [] do
      validate_detailed_tasks(detailed_tasks)
    else
      {:error,
       "Non-completed tasks missing detailed entries: #{Enum.join(missing_details, ", ")}"}
    end
  end

  defp extract_detailed_tasks(lines) do
    # Find task detail sections (lines starting with "### " followed by ID format)
    task_indices =
      lines
      |> Enum.with_index()
      |> Enum.filter(fn {line, _} ->
        String.match?(line, ~r/^### [A-Z]{2,4}\d{3,4}:/)
      end)
      |> Enum.map(fn {line, idx} ->
        # Extract task ID from the line
        [_, id | _] = Regex.run(~r/### ([A-Z]{2,4}\d{3,4})/, line)
        %{id: id, start_line: idx}
      end)

    # Extract the content of each task section
    Enum.map(task_indices, fn %{id: id, start_line: start_line} ->
      # Find the end of this section (next section or end of file)
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

      # Extract section content
      content = Enum.slice(lines, start_line..end_line)
      # Extract subtasks if any
      subtasks = extract_subtasks(content)

      %{id: id, content: content, subtasks: subtasks}
    end)
  end

  defp extract_subtasks(task_content) do
    # Find lines starting with "#### "
    task_content
    |> Enum.with_index()
    |> Enum.filter(fn {line, _} ->
      String.match?(line, ~r/^#### \d+\./)
    end)
    |> Enum.map(fn {line, idx} ->
      # Extract subtask ID from the line (PREFIX####-#)
      case Regex.run(~r/\(([A-Z]{2,4}\d{3,4}-\d+)\)/, line) do
        [_, subtask_id] -> %{id: subtask_id, line: idx}
        _ -> %{id: "INVALID_FORMAT", line: idx}
      end
    end)
  end

  defp validate_detailed_tasks(detailed_tasks) do
    # Validate each detailed task
    Enum.reduce_while(detailed_tasks, :ok, fn task, _acc ->
      case validate_task_structure(task) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp validate_task_structure(task) do
    # First, check subtask prefix consistency
    subtask_prefix_result =
      if task.subtasks != [] do
        task_prefix =
          if String.match?(task.id, ~r/^[A-Z]{2,4}\d{3,4}$/) do
            Regex.run(~r/^([A-Z]{2,4})/, task.id) |> Enum.at(1)
          else
            nil
          end

        mismatched_subtask =
          Enum.find(task.subtasks, fn subtask ->
            if task_prefix != nil && String.match?(subtask.id, ~r/^[A-Z]{2,4}\d{3,4}-\d+$/) do
              subtask_prefix = Regex.run(~r/^([A-Z]{2,4})/, subtask.id) |> Enum.at(1)
              subtask_prefix != nil && subtask_prefix != task_prefix
            else
              false
            end
          end)

        if mismatched_subtask do
          {:error,
           "Subtask #{mismatched_subtask.id} has different prefix than parent task #{task.id}"}
        else
          :ok
        end
      else
        :ok
      end

    case subtask_prefix_result do
      {:error, reason} ->
        {:error, reason}

      :ok ->
        # Required sections
        required_sections = [
          "**Description**",
          "**Simplicity Progression Plan**",
          "**Simplicity Principle**",
          "**Abstraction Evaluation**",
          "**Requirements**",
          "**ExUnit Test Requirements**",
          "**Integration Test Scenarios**",
          "**Typespec Requirements**",
          "**TypeSpec Documentation**",
          "**TypeSpec Verification**",
          "**Status**",
          "**Priority**"
        ]

        # First check if all base required sections are present
        missing_sections =
          Enum.filter(required_sections, fn section ->
            !Enum.any?(task.content, fn line ->
              String.starts_with?(line, section)
            end)
          end)

        # Extract status to check if task is completed
        status_line =
          Enum.find(task.content, fn line -> String.starts_with?(line, "**Status**") end)

        status =
          if status_line do
            status_line
            |> String.replace("**Status**:", "")
            |> String.replace("**Status**", "")
            |> String.trim()
          else
            "MISSING"
          end

        # For completed tasks, check additional required sections
        missing_sections =
          if status == "Completed" do
            missing_completed_sections =
              Enum.filter(@completed_task_sections, fn section ->
                !Enum.any?(task.content, fn line ->
                  String.starts_with?(line, section)
                end)
              end)

            missing_sections ++ missing_completed_sections
          else
            missing_sections
          end

        # All tasks require error handling guidelines
        missing_error_handling_sections =
          Enum.filter(@error_handling_sections, fn section ->
            !Enum.any?(task.content, fn line ->
              String.starts_with?(line, section)
            end)
          end)

        missing_sections = missing_sections ++ missing_error_handling_sections

        if missing_sections == [] do
          # Extract status and validate
          status_line =
            Enum.find(task.content, fn line -> String.starts_with?(line, "**Status**") end)

          status =
            if status_line do
              status_line
              |> String.replace("**Status**:", "")
              |> String.replace("**Status**", "")
              |> String.trim()
            else
              "MISSING"
            end

          if status != "MISSING" && !Enum.member?(@valid_statuses, status) do
            {:error, "Task #{task.id} has invalid status: #{status}"}
          else
            # Extract priority and validate
            priority_line =
              Enum.find(task.content, fn line -> String.starts_with?(line, "**Priority**") end)

            priority =
              if priority_line do
                priority_line
                |> String.replace("**Priority**:", "")
                |> String.replace("**Priority**", "")
                |> String.trim()
              else
                "MISSING"
              end

            if priority != "MISSING" && !Enum.member?(@valid_priorities, priority) do
              {:error, "Task #{task.id} has invalid priority: #{priority}"}
            else
              # Validate subtasks if task is "In Progress"
              if status == "In Progress" && task.subtasks == [] do
                {:error, "Task #{task.id} is in progress but has no subtasks"}
              else
                validate_subtasks(task)
              end
            end
          end
        else
          {:error,
           "Task #{task.id} is missing required sections: #{Enum.join(missing_sections, ", ")}"}
        end
    end
  end

  defp validate_subtasks(task) do
    # Get the task prefix for checking subtask consistency
    task_prefix =
      if String.match?(task.id, ~r/^[A-Z]{2,4}\d{3,4}$/) do
        Regex.run(~r/^([A-Z]{2,4})/, task.id) |> Enum.at(1)
      else
        nil
      end

    # Validate each subtask
    Enum.reduce_while(task.subtasks, :ok, fn subtask, _acc ->
      # Check subtask ID prefix consistency with parent task
      if task_prefix != nil do
        subtask_prefix =
          if String.match?(subtask.id, ~r/^[A-Z]{2,4}\d{3,4}-\d+$/) do
            Regex.run(~r/^([A-Z]{2,4})/, subtask.id) |> Enum.at(1)
          else
            nil
          end

        if subtask_prefix != nil && subtask_prefix != task_prefix do
          return =
            {:halt,
             {:error, "Subtask #{subtask.id} has different prefix than parent task #{task.id}"}}

          # Early return on prefix mismatch
          return
        end
      end

      # For completed subtasks, check rating
      subtask_content =
        task.content
        |> Enum.slice(subtask.line..length(task.content))
        |> Enum.take_while(fn line ->
          !String.match?(line, ~r/^####/) || line == Enum.at(task.content, subtask.line)
        end)

      # Check if subtask has required sections, including error handling
      # Add error handling sections to subtask requirements
      required_subtask_sections =
        [
          "**Status**"
        ] ++ @error_handling_sections

      missing_sections =
        Enum.filter(required_subtask_sections, fn section ->
          !Enum.any?(subtask_content, fn line ->
            String.starts_with?(line, section)
          end)
        end)

      if missing_sections == [] do
        # Extract status
        status_line =
          Enum.find(subtask_content, fn line -> String.starts_with?(line, "**Status**") end)

        status =
          if status_line do
            status_line
            |> String.replace("**Status**:", "")
            |> String.replace("**Status**", "")
            |> String.trim()
          else
            "MISSING"
          end

        if status != "MISSING" && !Enum.member?(@valid_statuses, status) do
          {:halt, {:error, "Subtask #{subtask.id} has invalid status: #{status}"}}
        else
          # If completed, check review rating
          if status == "Completed" do
            rating_line =
              Enum.find(subtask_content, fn line ->
                String.starts_with?(line, "**Review Rating**")
              end)

            if rating_line do
              rating =
                rating_line
                |> String.replace("**Review Rating**:", "")
                |> String.replace("**Review Rating**", "")
                |> String.trim()

              if Regex.match?(@rating_regex, rating) do
                {:cont, :ok}
              else
                {:halt,
                 {:error, "Subtask #{subtask.id} has invalid review rating format: #{rating}"}}
              end
            else
              {:halt, {:error, "Completed subtask #{subtask.id} is missing review rating"}}
            end
          else
            {:cont, :ok}
          end
        end
      else
        {:halt,
         {:error,
          "Subtask #{subtask.id} is missing required sections: #{Enum.join(missing_sections, ", ")}"}}
      end
    end)
  end
end
