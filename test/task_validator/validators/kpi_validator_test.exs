defmodule TaskValidator.Validators.KpiValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Validators.KpiValidator
  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}
  alias TaskValidator.Config

  describe "validate/2" do
    test "validates task with explicit KPI section" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          "- Functions per module: 8",
          "- Lines per function: 15",
          "- Call depth: 3"
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates task with KPI reference" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "{{standard-kpis}}"
        ]
      }

      context = %{
        config: Config.get_all(),
        references: %{"standard-kpis" => ["- Functions per module: 8"]}
      }

      result = KpiValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates task with custom KPI values within limits" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          "- Functions per module: 10",
          "- Lines per function: 20",
          "- Call depth: 4",
          "- Cyclomatic complexity: 8"
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "fails task missing KPI section" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description"
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_kpi_section
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "missing **Code Quality KPIs** section")
    end

    test "fails task missing required KPI metrics" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          "- Functions per module: 8"
          # Missing lines per function and call depth
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_kpi_metrics
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "missing required KPI metrics")
    end

    test "fails task with KPI value exceeding functions per module limit" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          # Exceeds default limit of 15
          "- Functions per module: 25",
          "- Lines per function: 15",
          "- Call depth: 3"
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_kpi_value
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "exceeds Functions per module limit")
    end

    test "fails task with KPI value exceeding lines per function limit" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          "- Functions per module: 8",
          # Exceeds default limit of 25
          "- Lines per function: 50",
          "- Call depth: 3"
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_kpi_value
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "exceeds Lines per function limit")
    end

    test "fails task with KPI value exceeding call depth limit" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          "- Functions per module: 8",
          "- Lines per function: 15",
          # Exceeds default limit of 5
          "- Call depth: 10"
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_kpi_value
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "exceeds Call depth limit")
    end

    test "fails task with missing KPI reference" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "{{undefined-kpis}}"
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_kpi_reference
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "undefined KPI definitions")
    end

    test "validates alternative KPI reference formats" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "{{def-standard-kpis}}"
        ]
      }

      context = %{
        config: Config.get_all(),
        references: %{"def-standard-kpis" => ["- Functions per module: 8"]}
      }

      result = KpiValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates case-insensitive KPI pattern matching" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          "- FUNCTIONS PER MODULE: 8",
          "- Lines Per Function: 15",
          "- call depth: 3"
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates KPI section with extra whitespace and formatting" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          "  - Functions per module:   8  ",
          "  - Lines per function:     15",
          "  - Call depth:             3 "
        ]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = KpiValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates with custom configuration limits" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Code Quality KPIs**",
          "- Functions per module: 20",
          "- Lines per function: 30",
          "- Call depth: 6"
        ]
      }

      custom_config = %{
        max_functions_per_module: 25,
        max_lines_per_function: 35,
        max_call_depth: 8
      }

      context = %{config: custom_config, references: %{}}
      result = KpiValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end
  end

  describe "priority/0" do
    test "returns low priority" do
      assert KpiValidator.priority() == 30
    end
  end
end
