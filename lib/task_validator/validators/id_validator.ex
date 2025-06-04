defmodule TaskValidator.Validators.IdValidator do
  @moduledoc """
  Validates task IDs according to configured format rules.

  This validator ensures that task IDs conform to the expected format,
  handles both main task and subtask ID patterns, and validates that
  subtask IDs properly reference their parent tasks.

  ## Validation Rules

  1. **Main Task IDs**: Must match the configured ID regex pattern
     - Default pattern: `[A-Z]{2,4}\\d{3,4}` (e.g., SSH001, VAL0004)
     - Custom patterns: Can include dashes (e.g., PROJ-001, CORE-123)

  2. **Subtask IDs**: Must follow parent-child relationship patterns
     - Numbered subtasks: `PARENT-\\d+` (e.g., SSH001-1, VAL0004-2)
     - Letter subtasks: `PARENT[a-z]` (e.g., SSH001a, VAL0004b)

  3. **Prefix Consistency**: All tasks in a task list should use consistent prefixes
     - Mixed prefixes are allowed but flagged as warnings
     - Helps identify potential organizational issues

  4. **Duplicate Detection**: Ensures no duplicate task IDs exist

  ## Error Types

  - `:invalid_id_format` - ID doesn't match expected pattern
  - `:duplicate_task_id` - Multiple tasks with same ID
  - `:invalid_subtask_id` - Subtask ID doesn't reference valid parent
  - `:mixed_prefixes` - Multiple prefixes detected (warning only)

  ## Examples

      # Valid main task IDs
      "SSH001", "VAL0004", "PROJ-001", "CORE-123"
      
      # Valid subtask IDs
      "SSH001-1", "VAL0004-2", "SSH001a", "VAL0004b"
      
      # Invalid IDs
      "ssh001"      # lowercase
      "S001"        # too few letters
      "SUPER001"    # too many letters
      "SSH"         # missing numbers
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Config
  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationError
  alias TaskValidator.Core.ValidationResult

  @doc """
  Validates task ID format, uniqueness, and subtask relationships.

  ## Context Requirements
  - `:all_tasks` - List of all tasks for duplicate and parent validation
  - `:config` - TaskValidator configuration (optional, uses defaults)

  ## Returns
  - Success if all ID validations pass
  - Failure with specific error details for each validation issue
  """
  @impl true
  def validate(%Task{} = task, context) do
    config = Map.get(context, :config, Config.get_all())
    all_tasks = Map.get(context, :all_tasks, [])

    validators = [
      &validate_id_format/3,
      &validate_uniqueness/3,
      &validate_subtask_parent/3,
      &check_prefix_consistency/3,
      &validate_semantic_prefix/3
    ]

    validators
    |> Enum.map(fn validator -> validator.(task, all_tasks, config) end)
    |> ValidationResult.combine()
  end

  @doc """
  Returns high priority (90) since ID validation is fundamental.

  ID validation should run early as many other validators depend on
  valid task IDs for their logic.
  """
  @impl true
  def priority, do: 90

  # Validates that the task ID matches the configured regex pattern
  defp validate_id_format(%Task{id: id, type: type}, _all_tasks, config) do
    id_regex = Map.get(config, :id_regex, Config.get(:id_regex))

    case type do
      :main ->
        validate_main_task_id(id, id_regex)

      :subtask ->
        validate_subtask_id(id, id_regex)
    end
  end

  # Validates main task ID format
  defp validate_main_task_id(id, id_regex) do
    # For main tasks, check if ID matches the base pattern or is a custom format with dashes
    base_match = Regex.match?(id_regex, id)
    custom_dash_format = String.match?(id, ~r/^[A-Z]{2,4}-\d{3,4}$/)

    if base_match or custom_dash_format do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_id_format,
        message:
          "Task ID '#{id}' does not match expected format. Expected pattern: #{inspect(id_regex)} or XXXX-### format",
        task_id: id,
        severity: :error,
        context: %{pattern: inspect(id_regex), actual_id: id, task_type: :main}
      }

      ValidationResult.failure(error)
    end
  end

  # Validates subtask ID format
  defp validate_subtask_id(id, _id_regex) do
    # Subtasks can be:
    # 1. Numbered: PARENT-N (e.g., SSH001-1)
    # 2. Lettered: PARENTL (e.g., SSH001a)
    numbered_subtask = String.match?(id, ~r/^[A-Z]{2,4}\d{3,4}-\d+$/)
    lettered_subtask = String.match?(id, ~r/^[A-Z]{2,4}\d{3,4}[a-z]$/)
    custom_numbered = String.match?(id, ~r/^[A-Z]{2,4}-\d{3,4}-\d+$/)

    if numbered_subtask or lettered_subtask or custom_numbered do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_id_format,
        message: "Subtask ID '#{id}' does not match expected subtask format. Expected: PARENT-N or PARENTL",
        task_id: id,
        severity: :error,
        context: %{
          expected_patterns: ["PARENT-N", "PARENTL", "PARENT-###-N"],
          actual_id: id,
          task_type: :subtask
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates that task IDs are unique across the task list
  defp validate_uniqueness(%Task{id: id}, all_tasks, _config) do
    duplicates = Enum.count(all_tasks, fn task -> task.id == id end)

    if duplicates <= 1 do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :duplicate_task_id,
        message: "Duplicate task ID '#{id}' found #{duplicates} times",
        task_id: id,
        severity: :error,
        context: %{duplicate_count: duplicates}
      }

      ValidationResult.failure(error)
    end
  end

  # Validates that subtasks reference valid parent tasks
  defp validate_subtask_parent(%Task{id: id, type: :subtask}, all_tasks, _config) do
    parent_id = extract_parent_id(id)

    if parent_id do
      parent_exists =
        Enum.any?(all_tasks, fn task ->
          task.id == parent_id and task.type == :main
        end)

      if parent_exists do
        ValidationResult.success()
      else
        error = %ValidationError{
          type: :invalid_subtask_id,
          message: "Subtask '#{id}' references non-existent parent task '#{parent_id}'",
          task_id: id,
          severity: :error,
          context: %{parent_id: parent_id, subtask_id: id}
        }

        ValidationResult.failure(error)
      end
    else
      error = %ValidationError{
        type: :invalid_subtask_id,
        message: "Could not extract parent ID from subtask '#{id}'",
        task_id: id,
        severity: :error,
        context: %{subtask_id: id}
      }

      ValidationResult.failure(error)
    end
  end

  # Main tasks don't need parent validation
  defp validate_subtask_parent(%Task{type: :main}, _all_tasks, _config) do
    ValidationResult.success()
  end

  # Checks for mixed prefixes and issues warnings
  defp check_prefix_consistency(%Task{id: id}, all_tasks, _config) do
    current_prefix = extract_prefix(id)
    all_prefixes = all_tasks |> Enum.map(&extract_prefix(&1.id)) |> Enum.uniq()

    if length(all_prefixes) > 1 do
      # This is a warning, not a failure
      error = %ValidationError{
        type: :mixed_prefixes,
        message:
          "Multiple task prefixes detected: #{Enum.join(all_prefixes, ", ")}. Consider using consistent prefixes for better organization.",
        task_id: id,
        severity: :warning,
        context: %{
          current_prefix: current_prefix,
          all_prefixes: all_prefixes,
          prefix_count: length(all_prefixes)
        }
      }

      # Return as warning instead of failure
      ValidationResult.success(warnings: [error])
    else
      ValidationResult.success()
    end
  end

  # Extracts the parent task ID from a subtask ID
  defp extract_parent_id(subtask_id) do
    cond do
      # Handle numbered subtasks: SSH001-1 -> SSH001
      String.match?(subtask_id, ~r/^([A-Z]{2,4}\d{3,4})-\d+$/) ->
        [_, parent] = Regex.run(~r/^([A-Z]{2,4}\d{3,4})-\d+$/, subtask_id)
        parent

      # Handle lettered subtasks: SSH001a -> SSH001
      String.match?(subtask_id, ~r/^([A-Z]{2,4}\d{3,4})[a-z]$/) ->
        [_, parent] = Regex.run(~r/^([A-Z]{2,4}\d{3,4})[a-z]$/, subtask_id)
        parent

      # Handle custom format: PROJ-001-1 -> PROJ-001
      String.match?(subtask_id, ~r/^([A-Z]{2,4}-\d{3,4})-\d+$/) ->
        [_, parent] = Regex.run(~r/^([A-Z]{2,4}-\d{3,4})-\d+$/, subtask_id)
        parent

      true ->
        nil
    end
  end

  # Validates semantic prefix mapping and suggests appropriate category
  defp validate_semantic_prefix(%Task{id: task_id, category: task_category} = task, _all_tasks, config) do
    enable_semantic = Map.get(config, :enable_semantic_prefixes, true)
    semantic_prefixes = Map.get(config, :semantic_prefixes, %{})

    if enable_semantic and map_size(semantic_prefixes) > 0 do
      prefix = extract_prefix(task_id)
      suggested_category = Map.get(semantic_prefixes, prefix)

      cond do
        # If prefix maps to a category but task has wrong/no category
        suggested_category != nil and task_category != suggested_category ->
          create_category_mismatch_warning(task, prefix, suggested_category, task_category)

        # If prefix is semantic but not recognized
        suggested_category == nil and is_semantic_prefix?(prefix) ->
          create_unrecognized_prefix_warning(task, prefix)

        true ->
          ValidationResult.success()
      end
    else
      ValidationResult.success()
    end
  end

  # Creates warning for category mismatch
  defp create_category_mismatch_warning(task, prefix, suggested_category, current_category) do
    message =
      case current_category do
        nil ->
          "Task '#{task.id}' uses semantic prefix '#{prefix}' which suggests category '#{suggested_category}', but task has no category assigned"

        _ ->
          "Task '#{task.id}' uses semantic prefix '#{prefix}' which suggests category '#{suggested_category}', but task is categorized as '#{current_category}'"
      end

    warning = %ValidationError{
      type: :semantic_prefix_mismatch,
      message: message,
      task_id: task.id,
      severity: :warning,
      context: %{
        prefix: prefix,
        suggested_category: suggested_category,
        current_category: current_category
      }
    }

    ValidationResult.success(warnings: [warning])
  end

  # Creates warning for unrecognized semantic prefix
  defp create_unrecognized_prefix_warning(task, prefix) do
    warning = %ValidationError{
      type: :unrecognized_semantic_prefix,
      message:
        "Task '#{task.id}' uses prefix '#{prefix}' which appears to be semantic but is not recognized. Consider adding it to semantic_prefixes configuration.",
      task_id: task.id,
      severity: :warning,
      context: %{
        prefix: prefix,
        suggestion: "Add '#{prefix}' to semantic_prefixes configuration"
      }
    }

    ValidationResult.success(warnings: [warning])
  end

  # Checks if a prefix looks semantic (3+ characters, common patterns)
  defp is_semantic_prefix?(prefix) do
    semantic_patterns =
      ~w(OTP GEN SUP APP PHX WEB LV LVC CTX BIZ DOM DB ECT MIG SCH INF DEP ENV REL TST TES INT E2E)

    prefix in semantic_patterns or String.length(prefix) >= 3
  end

  # Extracts the prefix from a task ID
  defp extract_prefix(task_id) do
    cond do
      # Handle standard format: SSH001 -> SSH
      String.match?(task_id, ~r/^([A-Z]{2,4})\d/) ->
        [_, prefix] = Regex.run(~r/^([A-Z]{2,4})\d/, task_id)
        prefix

      # Handle custom dash format: PROJ-001 -> PROJ
      String.match?(task_id, ~r/^([A-Z]{2,4})-\d/) ->
        [_, prefix] = Regex.run(~r/^([A-Z]{2,4})-\d/, task_id)
        prefix

      true ->
        "UNKNOWN"
    end
  end
end
