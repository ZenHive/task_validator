defmodule TaskValidator.Validators.SectionValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Validators.SectionValidator
  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}

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
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :missing_required_section
      assert String.contains?(error.message, "**Status**")
      assert String.contains?(error.message, "**Priority**")
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

    test "fails validation for main task missing error handling" do
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
          # Missing error handling
        ],
        subtasks: []
      }

      context = %{references: %{}}

      result = SectionValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :missing_error_handling
      assert String.contains?(error.message, "comprehensive error handling")
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

    test "fails validation for incomplete inline error handling" do
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
          "- Pass raw errors"
          # Missing other required error handling sections
        ],
        subtasks: []
      }

      context = %{references: %{}}

      result = SectionValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_section_format
      assert String.contains?(error.message, "incomplete error handling")
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
          "**Error Handling**",
          "Full error handling content",
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

      context = %{references: %{}}

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

  describe "priority/0" do
    test "returns medium priority" do
      assert SectionValidator.priority() == 50
    end
  end
end
