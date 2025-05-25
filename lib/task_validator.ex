defmodule TaskValidator do
  @moduledoc """
  Validates TaskList.md format compliance according to project guidelines.

  The `TaskValidator` ensures that task documents follow a consistent structure,
  making it easier to track and manage work across multiple project components,
  with a strong focus on error handling practices.

  ## Validation Checks

  * ID format compliance (like SSH0001, SCP0001, ERR001, etc.)
  * Unique task IDs across the document
  * Required sections and fields present in each task, including Error Handling Guidelines
  * Different error handling requirements for main tasks and subtasks:
    - Main tasks: Comprehensive error handling documentation with GenServer-specific examples
    - Subtasks: Simplified error handling focused on task-specific approaches
  * Proper subtask structure with consistent prefixes
  * Valid status values from the allowed list
  * Proper review rating format for completed tasks
  * Error handling patterns and conventions

  ## Error Handling Requirements

  Main tasks must include comprehensive error handling sections:

  ```markdown
  **Error Handling**
  **Core Principles**
  - Pass raw errors
  - Use {:ok, result} | {:error, reason}
  - Let it crash
  **Error Implementation**
  - No wrapping
  - Minimal rescue
  - function/1 & /! versions
  **Error Examples**
  - Raw error passthrough
  - Simple rescue case
  - Supervisor handling
  **GenServer Specifics**
  - Handle_call/3 error pattern
  - Terminate/2 proper usage
  - Process linking considerations
  ```

  Subtasks have a simplified error handling format:

  ```markdown
  **Error Handling**
  **Task-Specific Approach**
  - Error pattern for this task
  **Error Reporting**
  - Monitoring approach
  ```

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
  # Also support letter suffix for checkbox-style subtasks (e.g., WNX0019a)
  @id_regex ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/
  @rating_regex ~r/^([1-5](\.\d)?)\s*(\(partial\))?$/

  # Code quality KPI limits
  @max_functions_per_module 5
  @max_lines_per_function 15
  @max_call_depth 2

  # Task category ranges
  @category_ranges %{
    "core" => {1, 99},
    "features" => {100, 199},
    "documentation" => {200, 299},
    "testing" => {300, 399}
  }

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
    "- Supervisor handling",
    "**GenServer Specifics**",
    "- Handle_call/3 error pattern",
    "- Terminate/2 proper usage",
    "- Process linking considerations"
  ]

  # Required sections for error handling in subtasks - simplified format
  @subtask_error_handling_sections [
    "**Error Handling**",
    "**Task-Specific Approach**",
    "- Error pattern for this task",
    "**Error Reporting**",
    "- Monitoring approach"
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
         {:ok, references} <- extract_references(lines),
         :ok <- validate_references(lines, references),
         {:ok, tasks} <- extract_tasks(lines),
         :ok <- validate_task_ids(tasks),
         :ok <- validate_task_details(lines, tasks) do
      {:ok, "TaskList.md validation passed!"}
    end
  end

  @doc """
  Extracts reference definitions from the content.
  Reference definitions are in the format:
  ## {{reference-name}}
  Content for the reference
  ...
  """
  @spec extract_references(list(String.t())) :: {:ok, map()}
  def extract_references(lines) do
    # Find all lines that match ## {{reference-name}} pattern
    references =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, idx}, acc ->
        case Regex.run(~r/^## \{\{([^}]+)\}\}$/, line) do
          [_, ref_name] ->
            # Extract content until next ## header
            content = extract_reference_content(lines, idx + 1)
            Map.put(acc, ref_name, content)
          _ ->
            acc
        end
      end)

    {:ok, references}
  end

  defp extract_reference_content(lines, start_idx) do
    lines
    |> Enum.drop(start_idx)
    |> Enum.take_while(fn line ->
      # Stop at next ## header
      !String.starts_with?(line, "## ")
    end)
  end

  @doc """
  Validates that all {{ref-name}} placeholders in the content have corresponding definitions.
  Does NOT expand references - only validates they exist.
  """
  @spec validate_references(list(String.t()), map()) :: :ok | {:error, String.t()}
  def validate_references(lines, references) do
    # Find all {{reference}} placeholders in the content
    missing_refs =
      lines
      |> Enum.with_index()
      |> Enum.reduce([], fn {line, line_num}, acc ->
        # Find all references in this line
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
    # Find lines starting with "#### " or checkbox format "- [ ]"
    task_content
    |> Enum.with_index()
    |> Enum.filter(fn {line, _} ->
      String.match?(line, ~r/^#### \d+\./) || String.match?(line, ~r/^- \[[x\s]\]/)
    end)
    |> Enum.map(fn {line, idx} ->
      cond do
        # Traditional numbered subtask format
        String.match?(line, ~r/^#### \d+\./) ->
          case Regex.run(~r/\(([A-Z]{2,4}\d{3,4}-\d+)\)/, line) do
            [_, subtask_id] -> %{id: subtask_id, line: idx, format: :numbered}
            _ -> %{id: "INVALID_FORMAT", line: idx, format: :numbered}
          end

        # Checkbox subtask format
        String.match?(line, ~r/^- \[[x\s]\]/) ->
          # Extract subtask ID from checkbox line
          # Support both formats: "- [ ] Description [CHK0001a]" and "- [ ] **CHK0001a**: Description"
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

          # Determine if checkbox is checked
          checked = String.contains?(line, "[x]")
          %{id: subtask_id, line: idx, format: :checkbox, checked: checked}
      end
    end)
  end

  defp validate_detailed_tasks(detailed_tasks) do
    # First, collect all valid task IDs for dependency validation
    all_task_ids =
      detailed_tasks
      |> Enum.flat_map(fn task ->
        [task.id | Enum.map(task.subtasks, & &1.id)]
      end)
      |> MapSet.new()

    # Validate each detailed task
    Enum.reduce_while(detailed_tasks, :ok, fn task, _acc ->
      case validate_task_structure(task, all_task_ids) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp validate_task_structure(task, all_task_ids) do
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
          "**Code Quality KPIs**",
          "**Status**",
          "**Priority**",
          "**Dependencies**"
        ]

        # First check if all base required sections are present
        # Some sections can be replaced by references
        section_to_reference = %{
          "**ExUnit Test Requirements**" => "test-requirements",
          "**Integration Test Scenarios**" => "test-requirements", 
          "**Typespec Requirements**" => "typespec-requirements",
          "**TypeSpec Documentation**" => "typespec-requirements",
          "**TypeSpec Verification**" => "typespec-requirements",
          "**Code Quality KPIs**" => "standard-kpis",
          "**Dependencies**" => "def-no-dependencies"
        }

        missing_sections =
          Enum.filter(required_sections, fn section ->
            # Check if section is present directly
            has_section? = Enum.any?(task.content, fn line ->
              String.starts_with?(line, section)
            end)

            # If not present, check if it has a reference placeholder
            if !has_section? && Map.has_key?(section_to_reference, section) do
              ref_name = Map.get(section_to_reference, section)
              Enum.any?(task.content, fn line ->
                String.contains?(line, "{{#{ref_name}}}")
              end) == false
            else
              !has_section?
            end
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
        # Check if task has error handling reference placeholder
        has_error_handling_reference? =
          Enum.any?(task.content, fn line ->
            String.contains?(line, "{{error-handling") ||
            String.contains?(line, "{{def-error-handling")
          end)

        missing_error_handling_sections =
          if has_error_handling_reference? do
            # If task uses error handling reference, accept it as valid
            []
          else
            # Otherwise check for all required sections
            Enum.filter(@error_handling_sections, fn section ->
              !Enum.any?(task.content, fn line ->
                String.starts_with?(line, section)
              end)
            end)
          end

        missing_sections = missing_sections ++ missing_error_handling_sections

        if missing_sections == [] do
          # Extract status and validate
          status_idx =
            Enum.find_index(task.content, fn line -> String.starts_with?(line, "**Status**") end)

          status =
            cond do
              is_nil(status_idx) ->
                "MISSING"

              # Check if status is on the same line (e.g., "**Status**: In Progress")
              String.contains?(Enum.at(task.content, status_idx), ":") ->
                Enum.at(task.content, status_idx)
                |> String.replace("**Status**:", "")
                |> String.replace("**Status**", "")
                |> String.trim()

              # Status is on the next line
              status_idx + 1 < length(task.content) ->
                Enum.at(task.content, status_idx + 1)
                |> String.trim()

              true ->
                "MISSING"
            end

          if status != "MISSING" && !Enum.member?(@valid_statuses, status) do
            {:error, "Task #{task.id} has invalid status: #{status}"}
          else
            # Extract priority and validate
            priority_idx =
              Enum.find_index(task.content, fn line ->
                String.starts_with?(line, "**Priority**")
              end)

            priority =
              cond do
                is_nil(priority_idx) ->
                  "MISSING"

                # Check if priority is on the same line
                String.contains?(Enum.at(task.content, priority_idx), ":") ->
                  Enum.at(task.content, priority_idx)
                  |> String.replace("**Priority**:", "")
                  |> String.replace("**Priority**", "")
                  |> String.trim()

                # Priority is on the next line
                priority_idx + 1 < length(task.content) ->
                  Enum.at(task.content, priority_idx + 1)
                  |> String.trim()

                true ->
                  "MISSING"
              end

            if priority != "MISSING" && !Enum.member?(@valid_priorities, priority) do
              {:error, "Task #{task.id} has invalid priority: #{priority}"}
            else
              # Extract and validate dependencies
              dependencies_line =
                Enum.find(task.content, fn line ->
                  String.starts_with?(line, "**Dependencies**")
                end)

              dependencies =
                if dependencies_line do
                  dependencies_line
                  |> String.replace("**Dependencies**:", "")
                  |> String.replace("**Dependencies**", "")
                  |> String.trim()
                else
                  "MISSING"
                end

              # Validate dependencies if not "None" or missing
              dependency_validation =
                if dependencies != "MISSING" && dependencies != "None" do
                  # Parse dependencies (comma-separated task IDs)
                  dep_ids =
                    dependencies
                    |> String.split(",")
                    |> Enum.map(&String.trim/1)
                    |> Enum.reject(&(&1 == ""))

                  # Check if all dependencies exist
                  invalid_deps =
                    Enum.reject(dep_ids, fn dep_id ->
                      MapSet.member?(all_task_ids, dep_id)
                    end)

                  if invalid_deps == [] do
                    :ok
                  else
                    {:error,
                     "Task #{task.id} has invalid dependencies: #{Enum.join(invalid_deps, ", ")}"}
                  end
                else
                  :ok
                end

              case dependency_validation do
                {:error, reason} ->
                  {:error, reason}

                :ok ->
                  # Validate Code Quality KPIs section
                  kpi_validation = validate_code_quality_kpis(task)

                  case kpi_validation do
                    {:error, reason} ->
                      {:error, reason}

                    :ok ->
                      # Validate task category
                      category_validation = validate_task_category(task)

                      case category_validation do
                        {:error, reason} ->
                          {:error, reason}

                        :ok ->
                          # Validate subtasks if task is "In Progress"
                          if status == "In Progress" && task.subtasks == [] do
                            {:error, "Task #{task.id} is in progress but has no subtasks"}
                          else
                            validate_subtasks(task)
                          end
                      end
                  end
              end
            end
          end
        else
          {:error,
           "Task #{task.id} is missing required sections: #{Enum.join(missing_sections, ", ")}"}
        end
    end
  end

  defp validate_task_category(task) do
    # Extract numeric part from task ID to determine category
    case Regex.run(~r/^[A-Z]{2,4}(\d{3,4})/, task.id) do
      [_, number_str] ->
        number = String.to_integer(number_str)

        # Find which category this number belongs to
        category =
          Enum.find(@category_ranges, fn {_category, {min, max}} ->
            number >= min && number <= max
          end)

        case category do
          {category_name, _range} ->
            # Validate that the task has appropriate sections for its category
            validate_category_specific_sections(task, category_name)

          nil ->
            {:error, "Task #{task.id} number #{number} doesn't fit any defined category range"}
        end

      nil ->
        {:error, "Task #{task.id} has invalid ID format for category validation"}
    end
  end

  defp validate_category_specific_sections(task, category_name) do
    # Define category-specific required sections
    category_sections =
      case category_name do
        "core" ->
          ["**Architecture Notes**", "**Complexity Assessment**"]

        "features" ->
          ["**Abstraction Evaluation**", "**Simplicity Progression Plan**"]

        "documentation" ->
          ["**Content Strategy**", "**Audience Analysis**"]

        "testing" ->
          ["**Test Strategy**", "**Coverage Requirements**"]

        _ ->
          []
      end

    # Check if all category-specific sections are present
    missing_sections =
      Enum.filter(category_sections, fn section ->
        !Enum.any?(task.content, fn line ->
          String.starts_with?(line, section)
        end)
      end)

    if missing_sections == [] do
      :ok
    else
      {:error,
       "Task #{task.id} (#{category_name} category) missing required sections: #{Enum.join(missing_sections, ", ")}"}
    end
  end

  defp validate_code_quality_kpis(task) do
    # Check if task uses KPI reference placeholder
    has_kpi_reference? =
      Enum.any?(task.content, fn line ->
        String.contains?(line, "{{standard-kpis}}")
      end)

    if has_kpi_reference? do
      # If task uses KPI reference, accept it as valid
      :ok
    else
      # Otherwise, find the Code Quality KPIs section
      kpi_section_start =
        Enum.find_index(task.content, fn line ->
          String.starts_with?(line, "**Code Quality KPIs**")
        end)

      if kpi_section_start == nil do
        {:error, "Task #{task.id} is missing Code Quality KPIs section"}
      else
        # Extract the KPI section content
        kpi_content =
          task.content
          |> Enum.drop(kpi_section_start + 1)
          |> Enum.take_while(fn line ->
            !String.match?(line, ~r/^\*\*[^*]+\*\*/) && String.trim(line) != ""
          end)
          |> Enum.reject(&(String.trim(&1) == ""))

      # Parse KPI values
      kpis = %{
        functions_per_module: extract_kpi_value(kpi_content, ~r/functions per module:\s*(\d+)/i),
        lines_per_function: extract_kpi_value(kpi_content, ~r/lines per function:\s*(\d+)/i),
        call_depth: extract_kpi_value(kpi_content, ~r/call depth:\s*(\d+)/i)
      }

      # Check all KPIs are present
      missing_kpis =
        [:functions_per_module, :lines_per_function, :call_depth]
        |> Enum.filter(fn key -> is_nil(kpis[key]) end)
        |> Enum.map(fn
          :functions_per_module -> "Functions per module"
          :lines_per_function -> "Lines per function"
          :call_depth -> "Call depth"
        end)

      if missing_kpis != [] do
        {:error, "Task #{task.id} missing KPIs: #{Enum.join(missing_kpis, ", ")}"}
      else
        # Validate KPI values are within limits
        cond do
          kpis.functions_per_module > @max_functions_per_module ->
            {:error,
             "Task #{task.id} exceeds max functions per module: #{kpis.functions_per_module} > #{@max_functions_per_module}"}

          kpis.lines_per_function > @max_lines_per_function ->
            {:error,
             "Task #{task.id} exceeds max lines per function: #{kpis.lines_per_function} > #{@max_lines_per_function}"}

          kpis.call_depth > @max_call_depth ->
            {:error,
             "Task #{task.id} exceeds max call depth: #{kpis.call_depth} > #{@max_call_depth}"}

          true ->
            :ok
        end
      end
    end
    end
  end

  defp extract_kpi_value(content, regex) do
    Enum.find_value(content, fn line ->
      case Regex.run(regex, line) do
        [_, value] -> String.to_integer(value)
        _ -> nil
      end
    end)
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
          cond do
            # Traditional numbered format (SSH0001-1)
            String.match?(subtask.id, ~r/^[A-Z]{2,4}\d{3,4}-\d+$/) ->
              Regex.run(~r/^([A-Z]{2,4})/, subtask.id) |> Enum.at(1)

            # Checkbox format (WNX0019a)
            String.match?(subtask.id, ~r/^[A-Z]{2,4}\d{3,4}[a-z]$/) ->
              Regex.run(~r/^([A-Z]{2,4})/, subtask.id) |> Enum.at(1)

            true ->
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
        if Map.get(subtask, :format) == :checkbox do
          # For checkbox format, content is usually on the same line or immediately following
          # Take the checkbox line and any following lines until next checkbox or section
          task.content
          |> Enum.slice(subtask.line..length(task.content))
          |> Enum.take_while(fn line ->
            (!String.match?(line, ~r/^####/) && !String.match?(line, ~r/^- \[[x\s]\]/)) ||
              line == Enum.at(task.content, subtask.line)
          end)
        else
          # Traditional numbered format
          task.content
          |> Enum.slice(subtask.line..length(task.content))
          |> Enum.take_while(fn line ->
            !String.match?(line, ~r/^####/) || line == Enum.at(task.content, subtask.line)
          end)
        end

      # Extract status first
      status =
        if Map.get(subtask, :format) == :checkbox do
          # For checkbox format, checked means completed
          if Map.get(subtask, :checked, false) do
            "Completed"
          else
            "Planned"
          end
        else
          # Traditional format uses Status field
          status_idx =
            Enum.find_index(subtask_content, fn line ->
              String.starts_with?(line, "**Status**")
            end)

          cond do
            is_nil(status_idx) ->
              "MISSING"

            # Check if status is on the same line
            String.contains?(Enum.at(subtask_content, status_idx), ":") ->
              Enum.at(subtask_content, status_idx)
              |> String.replace("**Status**:", "")
              |> String.replace("**Status**", "")
              |> String.trim()

            # Status is on the next line
            status_idx + 1 < length(subtask_content) ->
              Enum.at(subtask_content, status_idx + 1)
              |> String.trim()

            true ->
              "MISSING"
          end
        end

      # Check if status is valid
      if status != "MISSING" && !Enum.member?(@valid_statuses, status) do
        {:halt, {:error, "Subtask #{subtask.id} has invalid status: #{status}"}}
      else
        # Check if subtask has required sections
        missing_sections =
          if Map.get(subtask, :format) == :checkbox do
            # Checkbox format subtasks don't require separate sections
            # They're typically one-line items
            []
          else
            # Traditional format requires status and error handling sections
            # Check if subtask has error handling reference placeholder
            has_error_handling_reference? =
              Enum.any?(subtask_content, fn line ->
                String.contains?(line, "{{error-handling") ||
                String.contains?(line, "{{def-error-handling")
              end)

            required_subtask_sections =
              if has_error_handling_reference? do
                # If subtask uses error handling reference, only require Status
                ["**Status**"]
              else
                # Otherwise require all sections
                ["**Status**"] ++ @subtask_error_handling_sections
              end

            Enum.filter(required_subtask_sections, fn section ->
              !Enum.any?(subtask_content, fn line ->
                String.starts_with?(line, section)
              end)
            end)
          end

        if missing_sections == [] do
          # If completed, check review rating (only for traditional format)
          if status == "Completed" && Map.get(subtask, :format) != :checkbox do
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
        else
          {:halt,
           {:error,
            "Subtask #{subtask.id} is missing required sections: #{Enum.join(missing_sections, ", ")}"}}
        end
      end
    end)
  end
end
