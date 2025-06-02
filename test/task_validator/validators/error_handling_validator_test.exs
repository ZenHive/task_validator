defmodule TaskValidator.Validators.ErrorHandlingValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Validators.ErrorHandlingValidator
  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}

  describe "validate/2" do
    test "validates main task with explicit error handling sections" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Planned",
        content: [
          "**Description**",
          "Test task description",
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
        ]
      }

      context = %{references: %{}}
      result = ErrorHandlingValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates main task with error handling reference" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Planned",
        content: [
          "**Description**",
          "Test task description",
          "{{error-handling}}"
        ]
      }

      context = %{references: %{"error-handling" => ["content"]}}
      result = ErrorHandlingValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "fails main task missing error handling" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Planned",
        content: [
          "**Description**",
          "Test task description"
        ]
      }

      context = %{references: %{}}
      result = ErrorHandlingValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_error_handling
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "missing error handling section")
    end

    test "fails main task with incomplete error handling sections" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Planned",
        content: [
          "**Description**",
          "Test task description",
          "**Error Handling**",
          "**Core Principles**",
          "- Pass raw errors"
          # Missing other required sections
        ]
      }

      context = %{references: %{}}
      result = ErrorHandlingValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :incomplete_error_handling
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "incomplete error handling")
    end

    test "validates subtask with explicit error handling sections" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "Planned",
        content: [
          "**Error Handling**",
          "**Task-Specific Approach**",
          "- Error pattern for this task",
          "**Error Reporting**",
          "- Monitoring approach"
        ]
      }

      context = %{references: %{}}
      result = ErrorHandlingValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates subtask with error handling reference" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "Planned",
        content: [
          "**Description**",
          "Subtask description",
          "{{error-handling-subtask}}"
        ]
      }

      context = %{references: %{"error-handling-subtask" => ["content"]}}
      result = ErrorHandlingValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "fails subtask missing error handling" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "Planned",
        content: [
          "**Description**",
          "Subtask description"
        ]
      }

      context = %{references: %{}}
      result = ErrorHandlingValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_error_handling
      assert error.task_id == "SSH001-1"
      assert String.contains?(error.message, "missing error handling section")
    end

    test "validates completed task with error handling implementation" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Completed",
        content: [
          "**Description**",
          "Test task description",
          "{{error-handling}}",
          "**Error Handling Implementation**",
          "Documented actual error handling patterns used"
        ]
      }

      context = %{references: %{"error-handling" => ["content"]}}
      result = ErrorHandlingValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "fails completed task missing error handling implementation" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Completed",
        content: [
          "**Description**",
          "Test task description",
          "{{error-handling}}"
        ]
      }

      context = %{references: %{"error-handling" => ["content"]}}
      result = ErrorHandlingValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_error_implementation
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "missing **Error Handling Implementation**")
    end

    test "fails when referenced error handling doesn't exist" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Planned",
        content: [
          "**Description**",
          "Test task description",
          "{{error-handling}}"
        ]
      }

      # No references available
      context = %{references: %{}}
      result = ErrorHandlingValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_error_handling
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "undefined error handling")
    end

    test "supports multiple error handling reference formats" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Planned",
        content: [
          "**Description**",
          "Test task description",
          "{{def-error-handling}}"
        ]
      }

      context = %{references: %{"def-error-handling" => ["content"]}}
      result = ErrorHandlingValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end
  end

  describe "priority/0" do
    test "returns medium priority" do
      assert ErrorHandlingValidator.priority() == 55
    end
  end
end
