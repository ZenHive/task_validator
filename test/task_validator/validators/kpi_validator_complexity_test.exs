defmodule TaskValidator.Validators.KpiValidatorComplexityTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationResult
  alias TaskValidator.Validators.KpiValidator

  describe "complexity-based KPI validation" do
    test "applies complexity multiplier for explicit complexity assessment" do
      task = %Task{
        id: "TST501",
        type: :main,
        description: "Complex test task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Complex testing task",
          "**Complexity Assessment**: Complex",
          "Testing requires extensive scenarios",
          "**Code Quality KPIs**",
          "- Functions per module: 16",
          "- Lines per function: 30",
          "- Call depth: 6"
        ],
        subtasks: [],
        line_number: 1,
        prefix: "TST",
        category: :testing,
        parent_id: nil,
        review_rating: nil
      }

      context = %{
        config: %{
          max_functions_per_module: 8,
          max_lines_per_function: 15,
          max_call_depth: 3
        }
      }

      result = KpiValidator.validate(task, context)

      # Should pass with complex multiplier (2x)
      assert %ValidationResult{valid?: true} = result
    end

    test "uses category defaults when no explicit complexity" do
      task = %Task{
        id: "TST502",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Testing task without explicit complexity",
          "**Code Quality KPIs**",
          "- Functions per module: 16",
          "- Lines per function: 30",
          "- Call depth: 6"
        ],
        subtasks: [],
        line_number: 1,
        prefix: "TST",
        # Testing category defaults to complex
        category: :testing,
        parent_id: nil,
        review_rating: nil
      }

      context = %{
        config: %{
          max_functions_per_module: 8,
          max_lines_per_function: 15,
          max_call_depth: 3
        }
      }

      result = KpiValidator.validate(task, context)

      # Should pass with testing category default (complex = 2x)
      assert %ValidationResult{valid?: true} = result
    end

    test "fails when values exceed even complex limits" do
      task = %Task{
        id: "TST503",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Testing task with excessive KPIs",
          "**Complexity Assessment**: Complex",
          "**Code Quality KPIs**",
          # Too high even for complex (max 16)
          "- Functions per module: 50",
          "- Lines per function: 15",
          "- Call depth: 3"
        ],
        subtasks: [],
        line_number: 1,
        prefix: "TST",
        category: :testing,
        parent_id: nil,
        review_rating: nil
      }

      context = %{
        config: %{
          max_functions_per_module: 8,
          max_lines_per_function: 15,
          max_call_depth: 3
        }
      }

      result = KpiValidator.validate(task, context)

      # Should fail - 50 exceeds even complex limit (8 * 2 = 16)
      assert %ValidationResult{valid?: false} = result
      assert length(result.errors) > 0
    end

    test "simple tasks use base limits" do
      task = %Task{
        id: "PHX101",
        type: :main,
        description: "Phoenix task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Simple Phoenix controller",
          "**Complexity Assessment**: Simple",
          "**Code Quality KPIs**",
          # Exceeds base limit of 8
          "- Functions per module: 9",
          "- Lines per function: 15",
          "- Call depth: 3"
        ],
        subtasks: [],
        line_number: 1,
        prefix: "PHX",
        category: :phoenix_web,
        parent_id: nil,
        review_rating: nil
      }

      context = %{
        config: %{
          max_functions_per_module: 8,
          max_lines_per_function: 15,
          max_call_depth: 3
        }
      }

      result = KpiValidator.validate(task, context)

      # Should fail - simple complexity uses base limit
      assert %ValidationResult{valid?: false} = result
      assert length(result.errors) > 0
    end

    test "critical complexity allows 3x multiplier" do
      task = %Task{
        id: "INF401",
        type: :main,
        description: "Critical infrastructure",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Critical system component",
          "**Complexity Assessment**: Critical",
          "**Code Quality KPIs**",
          # 3x base of 8
          "- Functions per module: 24",
          # 3x base of 15
          "- Lines per function: 45",
          # 3x base of 3
          "- Call depth: 9"
        ],
        subtasks: [],
        line_number: 1,
        prefix: "INF",
        category: :infrastructure,
        parent_id: nil,
        review_rating: nil
      }

      context = %{
        config: %{
          max_functions_per_module: 8,
          max_lines_per_function: 15,
          max_call_depth: 3
        }
      }

      result = KpiValidator.validate(task, context)

      # Should pass with critical multiplier (3x)
      assert %ValidationResult{valid?: true} = result
    end
  end
end
