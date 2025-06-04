defmodule TaskValidator.Parsers.ReferenceResolver do
  @moduledoc """
  Handles reference resolution and validation in TaskList documents.

  References allow for content reuse and reduce file size by 60-70%.
  This module validates reference integrity without expanding them,
  as the TaskValidator only checks that references exist.
  """

  alias TaskValidator.Core.TaskList
  alias TaskValidator.Core.ValidationError
  alias TaskValidator.Core.ValidationResult

  @doc """
  Validates that all reference placeholders have corresponding definitions.

  This function does NOT expand references - it only validates that every
  \\{\\{reference-name\\}\\} placeholder has a matching ## #\\{\\{reference-name\\}\\} definition.
  """
  @spec validate_references(TaskList.t()) :: ValidationResult.t()
  def validate_references(%TaskList{} = task_list) do
    # Convert TaskList content back to lines for reference validation
    lines = extract_lines_from_task_list(task_list)

    missing_refs = find_missing_references(lines, task_list.references)

    if missing_refs == [] do
      ValidationResult.success()
    else
      errors = Enum.map(missing_refs, &create_missing_reference_error/1)
      ValidationResult.failure(errors)
    end
  end

  @doc """
  Extracts reference definitions from markdown lines.

  Reference definitions follow the format:
  ## \\{\\{reference-name\\}\\} or ## #\\{\\{reference-name\\}\\}

  Returns a map where keys are reference names and values are the content lines.
  """
  @spec extract_references(list(String.t())) :: {:ok, map()}
  def extract_references(lines) when is_list(lines) do
    references =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, idx}, acc ->
        case parse_reference_header(line) do
          {:ok, ref_name} ->
            content = extract_reference_content(lines, idx + 1)
            Map.put(acc, ref_name, content)

          :error ->
            acc
        end
      end)

    {:ok, references}
  end

  @doc """
  Finds all reference placeholders used in the content.

  Returns a list of {reference_name, line_number} tuples for all
  \\{\\{reference-name\\}\\} placeholders found in the document.
  """
  @spec find_reference_usages(list(String.t())) :: list({String.t(), integer()})
  def find_reference_usages(lines) when is_list(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, line_num} ->
      ~r/\{\{([^}]+)\}\}/
      |> Regex.scan(line)
      |> Enum.map(fn [_full_match, ref_name] ->
        {ref_name, line_num + 1}
      end)
    end)
  end

  @doc """
  Validates reference integrity for a TaskList.

  This is the main validation function that ensures all used references
  have corresponding definitions.
  """
  @spec validate_reference_integrity(list(String.t()), map()) ::
          :ok | {:error, String.t()}
  def validate_reference_integrity(lines, references) when is_list(lines) and is_map(references) do
    missing_refs = find_missing_references(lines, references)

    if missing_refs == [] do
      :ok
    else
      missing_list =
        Enum.map_join(missing_refs, "\n", fn {ref, line} -> "  - '{{#{ref}}}' at line #{line}" end)

      {:error, "Missing reference definitions:\n#{missing_list}"}
    end
  end

  @doc """
  Expands a single reference placeholder with its definition.

  This function is provided for completeness but is not used by the
  TaskValidator, which only validates reference existence.
  """
  @spec expand_reference(String.t(), map()) :: String.t()
  def expand_reference(content, references) when is_binary(content) and is_map(references) do
    Regex.replace(~r/\{\{([^}]+)\}\}/, content, fn _full_match, ref_name ->
      case Map.get(references, ref_name) do
        # Keep placeholder if reference not found
        nil -> "{{#{ref_name}}}"
        ref_content when is_list(ref_content) -> Enum.join(ref_content, "\n")
        ref_content -> to_string(ref_content)
      end
    end)
  end

  @doc """
  Gets statistics about reference usage in a TaskList.
  """
  @spec reference_stats(TaskList.t()) :: map()
  def reference_stats(%TaskList{} = task_list) do
    lines = extract_lines_from_task_list(task_list)
    usages = find_reference_usages(lines)

    usage_counts =
      usages
      |> Enum.group_by(fn {ref_name, _line} -> ref_name end)
      |> Map.new(fn {ref_name, occurrences} -> {ref_name, length(occurrences)} end)

    %{
      total_references: map_size(task_list.references),
      total_usages: length(usages),
      usage_counts: usage_counts,
      unused_references: find_unused_references(task_list.references, usage_counts),
      most_used: find_most_used_reference(usage_counts)
    }
  end

  # Private functions

  defp parse_reference_header(line) do
    case Regex.run(~r/^## #?\{\{([^}]+)\}\}$/, line) do
      [_, ref_name] -> {:ok, ref_name}
      _ -> :error
    end
  end

  defp extract_reference_content(lines, start_idx) do
    lines
    |> Enum.drop(start_idx)
    |> Enum.take_while(fn line ->
      !String.starts_with?(line, "## ")
    end)
  end

  defp find_missing_references(lines, references) do
    lines
    |> find_reference_usages()
    |> Enum.reject(fn {ref_name, _line} ->
      Map.has_key?(references, ref_name)
    end)
    |> Enum.uniq()
  end

  defp create_missing_reference_error({ref_name, line_number}) do
    %ValidationError{
      type: :missing_reference,
      message: "Missing reference definition: '{{#{ref_name}}}'",
      task_id: nil,
      line_number: line_number,
      severity: :error,
      section: nil,
      context: %{reference_name: ref_name}
    }
  end

  defp extract_lines_from_task_list(%TaskList{tasks: tasks}) do
    # This is a simplified extraction - in a real implementation,
    # we'd reconstruct the original markdown structure
    Enum.flat_map(tasks, fn task -> task.content end)
  end

  defp find_unused_references(references, usage_counts) do
    references
    |> Map.keys()
    |> Enum.reject(fn ref_name -> Map.has_key?(usage_counts, ref_name) end)
  end

  defp find_most_used_reference(usage_counts) do
    case Enum.max_by(usage_counts, fn {_ref, count} -> count end, fn -> nil end) do
      nil -> nil
      {ref_name, count} -> %{name: ref_name, count: count}
    end
  end
end
