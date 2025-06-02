defmodule TaskValidator.Validators.KpiValidator do
  @moduledoc """
  Validates code quality KPIs (Key Performance Indicators) for tasks.

  This validator ensures that tasks have appropriate code quality metrics
  defined and that these metrics meet the configured standards. It supports
  both explicit KPI definitions and reference-based KPI specifications.

  ## Validation Rules

  1. **Required KPIs**: Tasks must have code quality KPIs section or reference
     - **Code Quality KPIs** section with specific metrics
     - Can use `{{standard-kpis}}` reference instead

  2. **Standard KPI Metrics**:
     - Functions per module: Maximum number of functions in a module
     - Lines per function: Maximum lines of code per function
     - Call depth: Maximum nested function call depth
     - Additional metrics can be configured

  3. **KPI Value Validation**:
     - All KPI values must be numeric and within configured limits
     - Values should reflect realistic coding standards
     - Metrics must be measurable and enforceable

  4. **Reference Support**:
     - Supports standard KPI references like `{{standard-kpis}}`
     - Validates reference existence in reference map
     - Allows flexible KPI specification via references

  ## Error Types

  - `:missing_kpi_section` - No Code Quality KPIs section or reference found
  - `:missing_kpi_metrics` - Required KPI metrics not specified
  - `:invalid_kpi_value` - KPI value exceeds configured limits
  - `:invalid_kpi_format` - KPI not properly formatted
  - `:missing_kpi_reference` - Referenced KPI definition not found

  ## Examples

      # Valid explicit KPIs
      **Code Quality KPIs**
      - Functions per module: 8
      - Lines per function: 15
      - Call depth: 3

      # Valid with reference
      {{standard-kpis}}

      # Valid custom KPIs
      **Code Quality KPIs**
      - Functions per module: 10
      - Lines per function: 20
      - Call depth: 4
      - Cyclomatic complexity: 8

      # Invalid - exceeds limits
      **Code Quality KPIs**  
      - Functions per module: 25  # Too high
      - Lines per function: 100   # Too high
      - Call depth: 10           # Too deep
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}
  alias TaskValidator.Config

  # Standard KPI metric definitions
  @required_kpis [
    :functions_per_module,
    :lines_per_function,
    :call_depth
  ]

  @kpi_patterns %{
    functions_per_module: ~r/functions per module:\s*(\d+)/i,
    lines_per_function: ~r/lines per function:\s*(\d+)/i,
    call_depth: ~r/call depth:\s*(\d+)/i,
    cyclomatic_complexity: ~r/cyclomatic complexity:\s*(\d+)/i
  }

  @kpi_names %{
    functions_per_module: "Functions per module",
    lines_per_function: "Lines per function",
    call_depth: "Call depth",
    cyclomatic_complexity: "Cyclomatic complexity"
  }

  @doc """
  Validates code quality KPIs according to configured standards.

  ## Context Requirements
  - `:config` - TaskValidator configuration (optional, uses defaults)
  - `:references` - Available references for validation (optional)

  ## Returns
  - Success if all KPI validations pass
  - Failure with specific error details for each validation issue
  """
  @impl true
  def validate(%Task{} = task, context) do
    config = Map.get(context, :config, Config.get_all())
    references = Map.get(context, :references, %{})

    validators = [
      &validate_kpi_section/3,
      &validate_kpi_metrics/3,
      &validate_kpi_values/3
    ]

    validators
    |> Enum.map(fn validator -> validator.(task, config, references) end)
    |> ValidationResult.combine()
  end

  @doc """
  Returns low priority (30) since KPI validation is important for
  code quality but not critical for basic task structure.
  """
  @impl true
  def priority, do: 30

  # Validates that task has a Code Quality KPIs section or reference
  defp validate_kpi_section(%Task{content: content, id: id}, _config, references) do
    has_kpi_section = has_section?(content, "**Code Quality KPIs**")
    has_kpi_reference = has_kpi_reference?(content, references)

    if has_kpi_section or has_kpi_reference do
      if has_kpi_reference do
        # Validate that the reference actually exists
        validate_kpi_references(content, references, id)
      else
        ValidationResult.success()
      end
    else
      error = %ValidationError{
        type: :missing_kpi_section,
        message:
          "Task '#{id}' is missing **Code Quality KPIs** section. All tasks must declare code quality metrics or use {{standard-kpis}} reference.",
        task_id: id,
        severity: :error,
        context: %{
          available_references: Map.keys(references),
          expected_section: "**Code Quality KPIs**"
        }
      }

      ValidationResult.failure(error)
    end
  end

  # Validates that required KPI metrics are present
  defp validate_kpi_metrics(%Task{content: content, id: id}, _config, references) do
    if has_kpi_reference?(content, references) do
      # Using reference, assume it contains required metrics
      ValidationResult.success()
    else
      # Check explicit KPI section for required metrics
      kpi_content = extract_kpi_content(content)
      parsed_kpis = parse_kpi_metrics(kpi_content)

      missing_kpis =
        Enum.reject(@required_kpis, fn kpi ->
          Map.has_key?(parsed_kpis, kpi) and not is_nil(parsed_kpis[kpi])
        end)

      if Enum.empty?(missing_kpis) do
        ValidationResult.success()
      else
        missing_names = Enum.map(missing_kpis, fn kpi -> @kpi_names[kpi] end)

        error = %ValidationError{
          type: :missing_kpi_metrics,
          message:
            "Task '#{id}' is missing required KPI metrics: #{Enum.join(missing_names, ", ")}",
          task_id: id,
          severity: :error,
          context: %{
            missing_metrics: missing_kpis,
            required_metrics: @required_kpis,
            available_metrics: Map.keys(parsed_kpis)
          }
        }

        ValidationResult.failure(error)
      end
    end
  end

  # Validates that KPI values are within configured limits
  defp validate_kpi_values(%Task{content: content, id: id}, config, references) do
    if has_kpi_reference?(content, references) do
      # Using reference, assume values are valid
      ValidationResult.success()
    else
      # Check explicit KPI values
      kpi_content = extract_kpi_content(content)
      parsed_kpis = parse_kpi_metrics(kpi_content)

      validation_results = [
        validate_kpi_limit(id, :functions_per_module, parsed_kpis, config),
        validate_kpi_limit(id, :lines_per_function, parsed_kpis, config),
        validate_kpi_limit(id, :call_depth, parsed_kpis, config)
      ]

      validation_results
      |> Enum.reject(&is_nil/1)
      |> ValidationResult.combine()
    end
  end

  # Validates a specific KPI against its configured limit
  defp validate_kpi_limit(task_id, kpi_key, parsed_kpis, config) do
    value = Map.get(parsed_kpis, kpi_key)

    if value do
      limit = get_kpi_limit(kpi_key, config)

      if value <= limit do
        ValidationResult.success()
      else
        kpi_name = @kpi_names[kpi_key]

        error = %ValidationError{
          type: :invalid_kpi_value,
          message: "Task '#{task_id}' exceeds #{kpi_name} limit: #{value} > #{limit}",
          task_id: task_id,
          severity: :error,
          context: %{
            kpi_metric: kpi_key,
            actual_value: value,
            limit_value: limit,
            kpi_name: kpi_name
          }
        }

        ValidationResult.failure(error)
      end
    else
      # Missing value, but that's handled in validate_kpi_metrics
      ValidationResult.success()
    end
  end

  # Validates KPI references exist
  defp validate_kpi_references(content, references, task_id) do
    referenced_names = extract_kpi_references(content)

    missing_references =
      Enum.reject(referenced_names, fn ref -> Map.has_key?(references, ref) end)

    if Enum.empty?(missing_references) do
      ValidationResult.success()
    else
      error = %ValidationError{
        type: :missing_kpi_reference,
        message:
          "Task '#{task_id}' references undefined KPI definitions: #{Enum.join(missing_references, ", ")}",
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

  # Extracts KPI content from task content
  defp extract_kpi_content(content) do
    kpi_section_start =
      Enum.find_index(content, fn line ->
        String.starts_with?(line, "**Code Quality KPIs**")
      end)

    if kpi_section_start do
      content
      |> Enum.drop(kpi_section_start + 1)
      |> Enum.take_while(fn line ->
        # Stop at next section or empty line
        !String.match?(line, ~r/^\*\*[^*]+\*\*/) and String.trim(line) != ""
      end)
      |> Enum.reject(&(String.trim(&1) == ""))
    else
      []
    end
  end

  # Parses KPI metrics from content lines
  defp parse_kpi_metrics(kpi_lines) do
    Enum.reduce(@kpi_patterns, %{}, fn {kpi_key, pattern}, acc ->
      value = extract_kpi_value(kpi_lines, pattern)
      if value, do: Map.put(acc, kpi_key, value), else: acc
    end)
  end

  # Extracts a KPI value using regex pattern
  defp extract_kpi_value(content, regex) do
    Enum.find_value(content, fn line ->
      case Regex.run(regex, line) do
        [_, value] -> String.to_integer(value)
        _ -> nil
      end
    end)
  end

  # Gets the configured limit for a KPI metric
  defp get_kpi_limit(kpi_key, config) do
    case kpi_key do
      :functions_per_module ->
        Map.get(config, :max_functions_per_module, Config.get(:max_functions_per_module))

      :lines_per_function ->
        Map.get(config, :max_lines_per_function, Config.get(:max_lines_per_function))

      :call_depth ->
        Map.get(config, :max_call_depth, Config.get(:max_call_depth))

      _ ->
        # For unknown metrics, use a reasonable default
        100
    end
  end

  # Checks if content has a specific section
  defp has_section?(content, section_header) do
    Enum.any?(content, fn line ->
      String.starts_with?(line, section_header)
    end)
  end

  # Checks if content has KPI references
  defp has_kpi_reference?(content, references) do
    kpi_refs = ["standard-kpis", "def-standard-kpis", "kpi-requirements"]

    Enum.any?(content, fn line ->
      Enum.any?(kpi_refs, fn ref ->
        String.contains?(line, "{{#{ref}}}") and Map.has_key?(references, ref)
      end)
    end)
  end

  # Extracts KPI reference names from content
  defp extract_kpi_references(content) do
    content
    |> Enum.flat_map(fn line ->
      Regex.scan(~r/\{\{(standard-kpis|def-standard-kpis|kpi-requirements)\}\}/, line)
      |> Enum.map(fn [_, ref] -> ref end)
    end)
    |> Enum.uniq()
  end
end
