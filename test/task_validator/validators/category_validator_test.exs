defmodule TaskValidator.Validators.CategoryValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Config
  alias TaskValidator.Core.Task
  alias TaskValidator.Validators.CategoryValidator

  describe "validate/2" do
    test "validates otp_genserver category task with required sections" do
      task = %Task{
        # OTP/GenServer category (001-099)
        id: "OTP001",
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
        # Phoenix Web category (100-199)
        id: "PHX101",
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
        # Business Logic category (200-299)
        id: "CTX201",
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

    test "validates testing category task with required sections" do
      task = %Task{
        # Testing category (500-599)
        id: "TST501",
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

    test "validates data_layer category task with required sections" do
      task = %Task{
        # Data Layer category (300-399)
        id: "SCH301",
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
        # Infrastructure category (400-499)
        id: "INF401",
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

    test "validates custom dash format task IDs" do
      task = %Task{
        # OTP/GenServer category with dash format
        id: "PROJ-001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
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

    test "validates subtask inherits parent category" do
      task = %Task{
        # Subtask of OTP/GenServer category
        id: "OTP001-1",
        type: :subtask,
        content: [
          "**Description**",
          "Subtask description",
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

    test "validates letter subtask inherits parent category" do
      task = %Task{
        # Letter subtask of OTP/GenServer category
        id: "OTP001a",
        type: :subtask,
        content: [
          "**Description**",
          "Subtask description",
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

    test "fails task with number outside category ranges" do
      task = %Task{
        # Outside any defined range (600+ is undefined)
        id: "SSH999",
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
      assert error.task_id == "SSH999"
      assert String.contains?(error.message, "doesn't fit any defined category range")
    end

    test "passes otp_genserver category task (section validation is done by SectionValidator)" do
      task = %Task{
        # OTP/GenServer category
        id: "OTP001",
        type: :main,
        category: :otp_genserver,
        content: [
          "**Description**",
          "Test GenServer task",
          "**Process Design**",
          "GenServer vs Agent vs Task choice and rationale",
          "**State Management**",
          "State structure and transition patterns"
          # Missing **Supervision Strategy** - but CategoryValidator doesn't check sections
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      # CategoryValidator only validates category assignment, not sections
      assert result.valid?
    end

    test "passes phoenix_web category task (section validation is done by SectionValidator)" do
      task = %Task{
        # Phoenix Web category
        id: "PHX101",
        type: :main,
        category: :phoenix_web,
        content: [
          "**Description**",
          "Test Phoenix controller task",
          "**Route Design**",
          "RESTful patterns and path helpers",
          "**Context Integration**",
          "How it fits with business logic"
          # Missing **Template/Component Strategy** - but CategoryValidator doesn't check sections
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      # CategoryValidator only validates category assignment, not sections
      assert result.valid?
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
        id: "SSH1001",
        type: :main,
        content: [
          "**Description**",
          "Test task description"
        ]
      }

      context = %{config: Config.get_all()}
      result = CategoryValidator.validate(task, context)

      # Should fail because 1001 is outside defined ranges (only 1-599)
      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_category_range
      assert error.task_id == "SSH1001"
    end

    test "validates custom dash subtask format" do
      task = %Task{
        # Custom dash subtask format (001 = OTP/GenServer category)
        id: "PROJ-001-1",
        type: :subtask,
        content: [
          "**Description**",
          "Subtask description",
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
  end

  describe "priority/0" do
    test "returns low priority" do
      assert CategoryValidator.priority() == 35
    end
  end
end
