defmodule TaskValidator.Validators.SectionValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationResult
  alias TaskValidator.Validators.SectionValidator

  describe "validate/2 - basic sections" do
    test "validates main task with all required sections" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High"
        ],
        subtasks: []
      }

      context = %{references: %{}}

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end

    test "fails validation for main task missing required sections" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test task description"
          # Missing Status and Priority sections
        ],
        subtasks: []
      }

      context = %{references: %{}}

      result = SectionValidator.validate(task, context)
      assert %ValidationResult{valid?: false} = result
      # Enhanced validation finds multiple issues - check for section-specific error
      assert length(result.errors) >= 1

      section_error = Enum.find(result.errors, &(&1.type == :missing_required_section))
      assert section_error != nil
      assert String.contains?(section_error.message, "**Status**")
      assert String.contains?(section_error.message, "**Priority**")
    end

    test "validates subtask with required sections" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Test subtask",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test subtask description",
          "**Status**",
          "Planned"
        ],
        subtasks: []
      }

      context = %{references: %{}}

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end

    test "fails validation for subtask missing required sections" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Test subtask",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test subtask description"
          # Missing Status section
        ],
        subtasks: []
      }

      context = %{references: %{}}

      result = SectionValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :missing_required_section
      assert String.contains?(error.message, "**Status**")
    end
  end

  describe "validate/2 - error handling" do
    test "validates main task with inline error handling" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High",
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
        ],
        subtasks: []
      }

      context = %{references: %{}}

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end

    test "validates main task with error handling reference" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High",
          "{{error-handling}}"
        ],
        subtasks: []
      }

      context = %{
        references: %{
          "error-handling" => [
            "**Error Handling**",
            "**Core Principles**",
            "- Pass raw errors"
          ]
        }
      }

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end

    test "validates subtask with error handling reference" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Test subtask",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test subtask description",
          "**Status**",
          "Planned",
          "{{error-handling-subtask}}"
        ],
        subtasks: []
      }

      context = %{
        references: %{
          "error-handling-subtask" => [
            "**Error Handling**",
            "**Task-Specific Approach**",
            "- Error pattern for this task"
          ]
        }
      }

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end
  end

  describe "validate/2 - completed task sections" do
    test "validates completed main task with all required sections" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Completed",
        priority: "High",
        content: [
          "**Description**",
          "Test task description",
          "**Status**",
          "Completed",
          "**Priority**",
          "High",
          "{{error-handling}}",
          "**Implementation Notes**",
          "How it was implemented",
          "**Complexity Assessment**",
          "Medium complexity",
          "**Maintenance Impact**",
          "Low maintenance",
          "**Error Handling Implementation**",
          "Actual error handling used"
        ],
        subtasks: []
      }

      context = %{references: %{"error-handling" => "Error handling content"}}

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end

    test "fails validation for completed task missing completion sections" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Completed",
        priority: "High",
        content: [
          "**Description**",
          "Test task description",
          "**Status**",
          "Completed",
          "**Priority**",
          "High",
          "**Error Handling**",
          "Full error handling content"
          # Missing completion sections
        ],
        subtasks: []
      }

      context = %{references: %{}}

      result = SectionValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :incomplete_completed_task
      assert String.contains?(error.message, "**Implementation Notes**")
      assert String.contains?(error.message, "**Complexity Assessment**")
    end

    test "non-completed tasks don't need completion sections" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High",
          "**Error Handling**",
          "Full error handling content"
          # No completion sections needed for non-completed tasks
        ],
        subtasks: []
      }

      context = %{references: %{}}

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end
  end

  describe "validate/2 - category-specific sections" do
    test "validates Phoenix Web task with required sections" do
      task = %Task{
        id: "PRJ101",
        type: :main,
        category: :phoenix_web,
        description: "Test Phoenix Web task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test Phoenix Web task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High",
          "**Route Design**",
          "RESTful routes with proper HTTP verbs",
          "**Context Integration**",
          "Clean integration with Phoenix contexts",
          "**Template/Component Strategy**",
          "LiveView components with proper separation",
          "**Error Handling**",
          "Full error handling content"
        ],
        subtasks: []
      }

      context = %{references: %{}}

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end

    test "fails validation for Phoenix Web task missing required sections" do
      task = %Task{
        id: "PRJ101",
        type: :main,
        category: :phoenix_web,
        description: "Test Phoenix Web task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test Phoenix Web task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High",
          "**Route Design**",
          "RESTful routes with proper HTTP verbs",
          # Missing Context Integration and Template/Component Strategy
          "**Error Handling**",
          "Full error handling content"
        ],
        subtasks: []
      }

      context = %{references: %{}}

      result = SectionValidator.validate(task, context)
      assert %ValidationResult{valid?: false} = result

      category_error = Enum.find(result.errors, &(&1.type == :missing_required_section))
      assert category_error != nil
      assert String.contains?(category_error.message, "phoenix_web sections")
      assert String.contains?(category_error.message, "**Context Integration**")
      assert String.contains?(category_error.message, "**Template/Component Strategy**")
    end

    test "validates Data Layer task with required sections" do
      task = %Task{
        id: "PRJ301",
        type: :main,
        category: :data_layer,
        description: "Test Data Layer task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test Data Layer task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High",
          "**Schema Design**",
          "Well-normalized Ecto schemas",
          "**Migration Strategy**",
          "Rollback-safe migrations",
          "**Query Optimization**",
          "Efficient query patterns",
          "**Error Handling**",
          "Full error handling content"
        ],
        subtasks: []
      }

      context = %{references: %{}}

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end

    test "validates Phoenix Web task with sections via reference" do
      task = %Task{
        id: "PRJ101",
        type: :main,
        category: :phoenix_web,
        description: "Test Phoenix Web task",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test Phoenix Web task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High",
          "{{phoenix-web-sections}}",
          "**Error Handling**",
          "Full error handling content"
        ],
        subtasks: []
      }

      context = %{
        references: %{
          "phoenix-web-sections" => [
            "**Route Design**",
            "RESTful routes with proper HTTP verbs",
            "**Context Integration**",
            "Clean integration with Phoenix contexts",
            "**Template/Component Strategy**",
            "LiveView components with proper separation"
          ]
        }
      }

      assert %ValidationResult{valid?: true} = SectionValidator.validate(task, context)
    end

    test "skips category validation for subtasks" do
      task = %Task{
        id: "PRJ101-1",
        type: :subtask,
        category: :phoenix_web,
        description: "Test subtask",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test subtask description",
          "**Status**",
          "Planned"
        ],
        subtasks: []
      }

      context = %{references: %{}}

      # Should pass because subtasks don't need category-specific sections
      result = SectionValidator.validate(task, context)
      # Note: might fail on error handling, but not on category sections
      category_errors =
        Enum.filter(
          result.errors,
          &(&1.type == :missing_required_section && String.contains?(&1.message, "phoenix_web"))
        )

      assert Enum.empty?(category_errors)
    end

    test "skips category validation for tasks without category" do
      task = %Task{
        id: "PRJ001",
        type: :main,
        category: nil,
        description: "Test task without category",
        status: "Planned",
        priority: "High",
        content: [
          "**Description**",
          "Test task description",
          "**Status**",
          "Planned",
          "**Priority**",
          "High",
          "**Error Handling**",
          "Full error handling content"
        ],
        subtasks: []
      }

      context = %{references: %{}}

      result = SectionValidator.validate(task, context)
      # Should not have category-specific errors
      category_errors =
        Enum.filter(
          result.errors,
          &(&1.type == :missing_required_section && String.contains?(&1.message, "sections"))
        )

      assert Enum.empty?(category_errors)
    end
  end

  describe "priority/0" do
    test "returns medium priority" do
      assert SectionValidator.priority() == 50
    end
  end
end
