defmodule TaskValidator.Validators.DependencyValidator do
  @moduledoc """
  Validates task dependencies and dependency relationships.

  This validator ensures that task dependencies are properly formatted,
  reference valid tasks, and don't create circular dependency chains.
  It supports both explicit dependencies and reference-based dependency
  specifications.

  ## Validation Rules

  1. **Dependency Format**:
     - **Dependencies**: None (for tasks with no dependencies)
     - **Dependencies**: TASK001, TASK002 (comma-separated list)
     - Can use `{{def-no-dependencies}}` or `{{no-dependencies}}` references

  2. **Dependency Existence**:
     - All referenced task IDs must exist in the task list
     - Dependencies can reference both main tasks and subtasks
     - Case-sensitive task ID matching

  3. **Circular Dependency Detection**:
     - Tasks cannot depend on themselves (direct circular dependency)
     - Tasks cannot create dependency loops (indirect circular dependency)
     - Validates entire dependency chain for cycles

  4. **Reference Support**:
     - Supports standard dependency references
     - Validates reference existence in reference map
     - Allows flexible dependency specification

  ## Error Types

  - `:missing_dependencies_section` - No Dependencies section found
  - `:invalid_dependency_reference` - Referenced task does not exist
  - `:circular_dependency` - Dependency creates a circular reference
  - `:invalid_dependency_format` - Dependencies not properly formatted
  - `:missing_dependency_reference` - Referenced dependency definition not found

  ## Examples

      # Valid no dependencies
      **Dependencies**: None
      
      # Valid with reference
      {{def-no-dependencies}}
      
      # Valid explicit dependencies
      **Dependencies**: SSH001, VAL0004-1, CORE-123
      
      # Valid alternative reference
      {{no-dependencies}}

      # Invalid - non-existent task
      **Dependencies**: SSH999, INVALID001
      
      # Invalid - circular dependency
      Task A depends on Task B, Task B depends on Task A
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationError
  alias TaskValidator.Core.ValidationResult

  @doc """
  Validates task dependencies according to format and existence rules.

  ## Context Requirements
  - `:all_tasks` - List of all tasks for dependency validation
  - `:references` - Available references for validation (optional)

  ## Returns
  - Success if all dependency validations pass
  - Failure with specific error details for each validation issue
  """
  @impl true
  def validate(%Task{} = task, context) do
    all_tasks = Map.get(context, :all_tasks, [])
    references = Map.get(context, :references, %{})

    validators = [
      &validate_dependencies_section/3,
      &validate_dependency_existence/3,
      &validate_circular_dependencies/3
    ]

    validators
    |> Enum.map(fn validator -> validator.(task, all_tasks, references) end)
    |> ValidationResult.combine()
  end

  @doc """
  Returns medium priority (40) since dependency validation depends on
  task structure but is less critical than ID or status validation.
  """
  @impl true
  def priority, do: 40

  # Validates that task has a Dependencies section or reference
  defp validate_dependencies_section(%Task{content: content, id: id}, _all_tasks, references) do
    if is_nil(content) or not is_list(content) do
      error = %ValidationError{
        type: :missing_dependencies_section,
        message: "Task '#{id}' has invalid or missing content. Tasks must have content with dependency information.",
        task_id: id,
        severity: :error,
        context: %{content_type: inspect(content)}
      }

      ValidationResult.failure(error)
    else
      has_dependencies_section = has_section?(content, "**Dependencies**")
      has_dependencies_reference = has_dependencies_reference?(content, references)

      if has_dependencies_section or has_dependencies_reference do
        if has_dependencies_reference do
          # Validate that the reference actually exists
          validate_dependency_references(content, references, id)
        else
          ValidationResult.success()
        end
      else
        error = %ValidationError{
          type: :missing_dependencies_section,
          message:
            "Task '#{id}' is missing **Dependencies** section. All tasks must declare their dependencies or use {{def-no-dependencies}} reference.",
          task_id: id,
          severity: :error,
          context: %{
            available_references: Map.keys(references),
            expected_section: "**Dependencies**"
          }
        }

        ValidationResult.failure(error)
      end
    end
  end

  # Validates that all referenced dependencies exist
  defp validate_dependency_existence(%Task{content: content, id: id}, all_tasks, references) do
    if is_nil(content) or not is_list(content) do
      # Already handled in validate_dependencies_section
      ValidationResult.success()
    else
      dependencies = extract_dependencies(content, references)

      case dependencies do
        :none ->
          # No dependencies, which is valid
          ValidationResult.success()

        :reference ->
          # Using reference, already validated in previous step
          ValidationResult.success()

        deps when is_list(deps) ->
          # Validate each dependency exists
          validate_dependency_list(deps, all_tasks, id)

        :error ->
          # Could not parse dependencies
          error = %ValidationError{
            type: :invalid_dependency_format,
            message:
              "Task '#{id}' has invalid dependency format. Dependencies should be 'None' or comma-separated task IDs.",
            task_id: id,
            severity: :error,
            context: %{
              expected_formats: ["None", "TASK001, TASK002", "{{def-no-dependencies}}"]
            }
          }

          ValidationResult.failure(error)
      end
    end
  end

  # Validates that dependencies don't create circular references
  defp validate_circular_dependencies(%Task{id: id, content: content}, all_tasks, references) do
    if is_nil(content) or not is_list(content) do
      # Already handled in validate_dependencies_section
      ValidationResult.success()
    else
      dependencies = extract_dependencies(content, references)

      case dependencies do
        deps when is_list(deps) ->
          # Check for direct circular dependency (task depends on itself)
          if id in deps do
            error = %ValidationError{
              type: :circular_dependency,
              message: "Task '#{id}' has a circular dependency on itself.",
              task_id: id,
              severity: :error,
              context: %{
                dependency_type: :direct,
                circular_task: id
              }
            }

            ValidationResult.failure(error)
          else
            # Check for indirect circular dependencies
            validate_dependency_cycles(id, deps, all_tasks, references, [id])
          end

        _ ->
          # No dependencies or using reference, no circular dependency possible
          ValidationResult.success()
      end
    end
  end

  # Validates a list of dependencies exist in the task list
  defp validate_dependency_list(dependencies, all_tasks, task_id) do
    all_task_ids = extract_all_task_ids(all_tasks)
    invalid_deps = Enum.reject(dependencies, fn dep_id -> dep_id in all_task_ids end)

    if Enum.empty?(invalid_deps) do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :invalid_dependency_reference,
        message: "Task '#{task_id}' references non-existent dependencies: #{Enum.join(invalid_deps, ", ")}",
        task_id: task_id,
        severity: :error,
        context: %{
          invalid_dependencies: invalid_deps,
          valid_task_ids: all_task_ids
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates dependency references exist
  defp validate_dependency_references(content, references, task_id) do
    referenced_names = extract_dependency_references(content)

    missing_references =
      Enum.reject(referenced_names, fn ref -> Map.has_key?(references, ref) end)

    if Enum.empty?(missing_references) do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_dependency_reference,
        message: "Task '#{task_id}' references undefined dependency definitions: #{Enum.join(missing_references, ", ")}",
        task_id: task_id,
        severity: :error,
        context: %{
          missing_references: missing_references,
          available_references: Map.keys(references)
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates that there are no cycles in the dependency chain
  defp validate_dependency_cycles(current_id, dependencies, all_tasks, references, visited) do
    Enum.reduce_while(dependencies, ValidationResult.success(), fn dep_id, _acc ->
      if dep_id in visited do
        # Found a cycle
        cycle_path = visited ++ [dep_id]

        error = %ValidationError{
          type: :circular_dependency,
          message: "Circular dependency detected: #{Enum.join(cycle_path, " -> ")}",
          task_id: current_id,
          severity: :error,
          context: %{
            dependency_type: :indirect,
            cycle_path: cycle_path,
            cycle_length: length(cycle_path)
          }
        }

        {:halt, ValidationResult.failure(error)}
      else
        # Continue checking this dependency's dependencies
        dep_task = Enum.find(all_tasks, fn task -> task.id == dep_id end)

        if dep_task do
          dep_dependencies = extract_dependencies(dep_task.content, references)

          case dep_dependencies do
            deps when is_list(deps) ->
              result =
                validate_dependency_cycles(
                  dep_id,
                  deps,
                  all_tasks,
                  references,
                  visited ++ [dep_id]
                )

              if result.valid? do
                {:cont, ValidationResult.success()}
              else
                {:halt, result}
              end

            _ ->
              # No dependencies, continue
              {:cont, ValidationResult.success()}
          end
        else
          # Dependency doesn't exist, but that's handled in validate_dependency_existence
          {:cont, ValidationResult.success()}
        end
      end
    end)
  end

  # Extracts dependencies from task content
  defp extract_dependencies(content, references) do
    # Look for Dependencies section
    deps_line =
      Enum.find(content, fn line ->
        String.starts_with?(line, "**Dependencies**")
      end)

    cond do
      deps_line ->
        # Extract dependencies from the line
        deps_content =
          deps_line
          |> String.replace("**Dependencies**:", "")
          |> String.replace("**Dependencies**", "")
          |> String.trim()

        parse_dependencies_content(deps_content)

      has_dependencies_reference?(content, references) ->
        # Using reference
        :reference

      true ->
        # No dependencies section found
        :error
    end
  end

  # Parses the dependencies content string
  defp parse_dependencies_content(content) do
    cond do
      content == "None" or content == "" ->
        :none

      String.contains?(content, ",") ->
        # Multiple dependencies
        content
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))

      String.trim(content) != "" ->
        # Single dependency
        [String.trim(content)]

      true ->
        :error
    end
  end

  # Extracts all task IDs from task list (including subtasks)
  defp extract_all_task_ids(all_tasks) do
    Enum.flat_map(all_tasks, fn task ->
      subtask_ids = if task.subtasks, do: Enum.map(task.subtasks, & &1.id), else: []
      [task.id | subtask_ids]
    end)
  end

  # Checks if content has a specific section
  defp has_section?(content, section_header) do
    Enum.any?(content, fn line ->
      String.starts_with?(line, section_header)
    end)
  end

  # Checks if content has dependency references
  defp has_dependencies_reference?(content, references) do
    dependency_refs = ["def-no-dependencies", "no-dependencies", "DEF:no-dependencies"]

    Enum.any?(content, fn line ->
      Enum.any?(dependency_refs, fn ref ->
        String.contains?(line, "{{#{ref}}}") and Map.has_key?(references, ref)
      end)
    end)
  end

  # Extracts dependency reference names from content
  defp extract_dependency_references(content) do
    content
    |> Enum.flat_map(fn line ->
      ~r/\{\{(def-no-dependencies|no-dependencies|DEF:no-dependencies)\}\}/
      |> Regex.scan(line)
      |> Enum.map(fn [_, ref] -> ref end)
    end)
    |> Enum.uniq()
  end
end
