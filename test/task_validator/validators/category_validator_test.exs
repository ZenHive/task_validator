defmodule TaskValidator.Validators.CategoryValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Validators.CategoryValidator
  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}
  alias TaskValidator.Config

  describe "validate/2" do
    test "validates core category task with required sections" do
      task = %Task{
        # Core category (001-099)
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Architecture Notes**",
          "System architecture considerations",
          "**Complexity Assessment**",
          "Assessment of implementation complexity"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates features category task with required sections" do
      task = %Task{
        # Features category (100-199)
        id: "SSH101",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Abstraction Evaluation**",
          "Analysis of abstraction layers",
          "**Simplicity Progression Plan**",
          "Plan for maintaining simplicity"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates documentation category task with required sections" do
      task = %Task{
        # Documentation category (200-299)
        id: "SSH201",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Content Strategy**",
          "Strategy for content organization",
          "**Audience Analysis**",
          "Target audience and their needs"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates testing category task with required sections" do
      task = %Task{
        # Testing category (300-399)
        id: "SSH301",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Test Strategy**",
          "Overall testing approach",
          "**Coverage Requirements**",
          "Required test coverage metrics"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates custom dash format task IDs" do
      task = %Task{
        # Core category with dash format
        id: "PROJ-001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Architecture Notes**",
          "System architecture considerations",
          "**Complexity Assessment**",
          "Assessment of implementation complexity"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates subtask inherits parent category" do
      task = %Task{
        # Subtask of core category
        id: "SSH001-1",
        type: :subtask,
        content: [
          "**Description**",
          "Subtask description",
          "**Architecture Notes**",
          "System architecture considerations",
          "**Complexity Assessment**",
          "Assessment of implementation complexity"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates letter subtask inherits parent category" do
      task = %Task{
        # Letter subtask of core category
        id: "SSH001a",
        type: :subtask,
        content: [
          "**Description**",
          "Subtask description",
          "**Architecture Notes**",
          "System architecture considerations",
          "**Complexity Assessment**",
          "Assessment of implementation complexity"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "fails task with number outside category ranges" do
      task = %Task{
        # Outside any defined range (1200+ is undefined)
        id: "SSH1500",
        type: :main,
        content: [
          "**Description**",
          "Test task description"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_category_range
      assert error.task_id == "SSH1500"
      assert String.contains?(error.message, "doesn't fit any defined category range")
    end

    test "fails core category task missing required sections" do
      task = %Task{
        # Core category
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Architecture Notes**",
          "System architecture considerations"
          # Missing **Complexity Assessment**
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_category_sections
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "missing required sections")
      assert String.contains?(error.message, "**Complexity Assessment**")
    end

    test "fails features category task missing required sections" do
      task = %Task{
        # Features category
        id: "SSH101",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Abstraction Evaluation**",
          "Analysis of abstraction layers"
          # Missing **Simplicity Progression Plan**
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_category_sections
      assert error.task_id == "SSH101"
      assert String.contains?(error.message, "missing required sections")
      assert String.contains?(error.message, "**Simplicity Progression Plan**")
    end

    test "fails task with invalid ID format for categorization" do
      task = %Task{
        # Cannot extract number
        id: "INVALID",
        type: :main,
        content: [
          "**Description**",
          "Test task description"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_id_for_categorization
      assert error.task_id == "INVALID"
      assert String.contains?(error.message, "Cannot categorize task")
    end

    test "validates with custom category configuration" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Custom Section**",
          "Custom content"
        ]
      }

      custom_config = %{
        category_ranges: [
          {"custom", {1, 50}},
          {"other", {51, 100}}
        ],
        category_sections: %{
          "custom" => ["**Custom Section**"],
          "other" => ["**Other Section**"]
        }
      }

      context = %{config: custom_config}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates category with no specific requirements" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description"
        ]
      }

      custom_config = %{
        category_ranges: [
          {"minimal", {1, 100}}
        ],
        category_sections: %{
          # No specific requirements
          "minimal" => []
        }
      }

      context = %{config: custom_config}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates 4-digit task IDs" do
      task = %Task{
        # 4-digit number, should be in undefined range
        id: "SSH2001",
        type: :main,
        content: [
          "**Description**",
          "Test task description"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      # Should fail because 2001 is outside defined ranges
      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_category_range
      assert error.task_id == "SSH2001"
    end

    test "validates custom dash subtask format" do
      task = %Task{
        # Custom dash subtask format
        id: "PROJ-001-1",
        type: :subtask,
        content: [
          "**Description**",
          "Subtask description",
          "**Architecture Notes**",
          "System architecture considerations",
          "**Complexity Assessment**",
          "Assessment of implementation complexity"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end
  end

  describe "priority/0" do
    test "returns low priority" do
      assert CategoryValidator.priority() == 35
    end
  end

  describe "Elixir/Phoenix categories" do
    test "validates otp_genserver category task with required sections" do
      task = %Task{
        # OTP/GenServer category (601-699)
        id: "OTP601",
        type: :main,
        content: [
          "**Description**",
          "Test GenServer task",
          "**Process Design**",
          "GenServer vs Agent vs Task choice and rationale",
          "**State Management**",
          "State structure and transition patterns",
          "**Supervision Strategy**",
          "Restart policies and escalation paths"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates phoenix_web category task with required sections" do
      task = %Task{
        # Phoenix Web category (701-799)
        id: "PHX701",
        type: :main,
        content: [
          "**Description**",
          "Test Phoenix controller task",
          "**Route Design**",
          "RESTful patterns and path helpers",
          "**Context Integration**",
          "How it fits with business logic",
          "**Template/Component Strategy**",
          "Reusable components and patterns"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates business_logic category task with required sections" do
      task = %Task{
        # Business Logic category (801-899)
        id: "CTX801",
        type: :main,
        content: [
          "**Description**",
          "Test context module task",
          "**API Design**",
          "Clear function contracts with docs",
          "**Data Access**",
          "Proper Repo usage and query optimization",
          "**Validation Strategy**",
          "Comprehensive changeset validation"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates data_layer category task with required sections" do
      task = %Task{
        # Data Layer category (901-999)
        id: "SCH901",
        type: :main,
        content: [
          "**Description**",
          "Test schema design task",
          "**Schema Design**",
          "Well-normalized schema with proper constraints",
          "**Migration Strategy**",
          "Rollback-safe migrations with data integrity checks",
          "**Query Optimization**",
          "Strategic indexes and performance monitoring"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates infrastructure category task with required sections" do
      task = %Task{
        # Infrastructure category (1001-1099)
        id: "INF1001",
        type: :main,
        content: [
          "**Description**",
          "Test deployment task",
          "**Release Configuration**",
          "Elixir release with proper runtime configuration",
          "**Environment Variables**",
          "Secure configuration management with runtime.exs",
          "**Deployment Strategy**",
          "Blue-green deployment with health checks"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates elixir_testing category task with required sections" do
      task = %Task{
        # Elixir Testing category (1101-1199)
        id: "TST1101",
        type: :main,
        content: [
          "**Description**",
          "Test property-based testing task",
          "**Test Strategy**",
          "Overall testing approach with StreamData",
          "**Coverage Requirements**",
          "Required test coverage metrics",
          "**Property-Based Testing**",
          "StreamData usage for property tests"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "fails otp_genserver category task missing required sections" do
      task = %Task{
        # OTP/GenServer category
        id: "OTP601",
        type: :main,
        content: [
          "**Description**",
          "Test GenServer task",
          "**Process Design**",
          "GenServer vs Agent vs Task choice and rationale",
          "**State Management**",
          "State structure and transition patterns"
          # Missing **Supervision Strategy**
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_category_sections
      assert error.task_id == "OTP601"
      assert String.contains?(error.message, "missing required sections")
      assert String.contains?(error.message, "**Supervision Strategy**")
    end
  end
end
