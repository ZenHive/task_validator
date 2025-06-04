defmodule TaskValidator.Validators.SubtaskValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Config
  alias TaskValidator.Core.Task
  alias TaskValidator.Validators.SubtaskValidator

  describe "validate/2" do
    test "validates main task with no subtasks" do
      task = %Task{
        id: "SSH001",
        type: :main,
        status: "Planned",
        subtasks: []
      }

      context = %{config: Config.get_all(), references: %{}}
      result = SubtaskValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates main task with valid numbered subtasks" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "In Progress",
        line_number: 10,
        content: [
          "**Status**: In Progress",
          "{{error-handling-subtask}}"
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{
        config: Config.get_all(),
        references: %{"error-handling-subtask" => ["content"]}
      }

      result = SubtaskValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates main task with valid checkbox subtasks" do
      subtask = %Task{
        id: "SSH001a",
        type: :subtask,
        status: "Completed",
        line_number: 10
        # Checkbox format doesn't use explicit checked field in struct
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = SubtaskValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates completed numbered subtask with review rating" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "Completed",
        review_rating: "4.5",
        line_number: 10,
        content: [
          "**Status**: Completed",
          "{{error-handling-subtask}}"
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{
        config: Config.get_all(),
        references: %{"error-handling-subtask" => ["content"]}
      }

      result = SubtaskValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "fails subtask with invalid status" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "InvalidStatus",
        line_number: 10,
        content: [
          "**Status**: InvalidStatus",
          "{{error-handling-subtask}}"
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{
        config: Config.get_all(),
        references: %{"error-handling-subtask" => ["content"]}
      }

      result = SubtaskValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_subtask_status
      assert error.task_id == "SSH001-1"
      assert String.contains?(error.message, "invalid status")
    end

    test "fails numbered subtask missing required sections" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "In Progress",
        line_number: 10,
        content: [
          "**Description**",
          "Missing status and error handling"
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = SubtaskValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_subtask_sections
      assert error.task_id == "SSH001-1"
      assert String.contains?(error.message, "missing required sections")
    end

    test "fails completed numbered subtask missing review rating" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "Completed",
        review_rating: nil,
        line_number: 10,
        content: [
          "**Status**: Completed",
          "{{error-handling-subtask}}"
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{
        config: Config.get_all(),
        references: %{"error-handling-subtask" => ["content"]}
      }

      result = SubtaskValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :missing_review_rating
      assert error.task_id == "SSH001-1"
      assert String.contains?(error.message, "missing review rating")
    end

    test "fails subtask with invalid review rating format" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "Completed",
        review_rating: "invalid",
        line_number: 10,
        content: [
          "**Status**: Completed",
          "{{error-handling-subtask}}"
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{
        config: Config.get_all(),
        references: %{"error-handling-subtask" => ["content"]}
      }

      result = SubtaskValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_review_rating
      assert error.task_id == "SSH001-1"
      assert String.contains?(error.message, "Invalid review rating")
    end

    test "fails subtask with inconsistent prefix" do
      subtask = %Task{
        # Different prefix than parent
        id: "VAL001-1",
        type: :subtask,
        status: "In Progress",
        line_number: 10,
        content: [
          "**Status**: In Progress",
          "{{error-handling-subtask}}"
        ]
      }

      task = %Task{
        # SSH prefix
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{
        config: Config.get_all(),
        references: %{"error-handling-subtask" => ["content"]}
      }

      result = SubtaskValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :inconsistent_subtask_prefix
      assert error.task_id == "VAL001-1"
      assert String.contains?(error.message, "doesn't match parent task")
    end

    test "skips validation for subtask type tasks" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        status: "Planned"
      }

      context = %{config: Config.get_all(), references: %{}}
      result = SubtaskValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates checkbox subtasks don't need additional sections" do
      subtask = %Task{
        id: "SSH001a",
        type: :subtask,
        status: "Planned",
        line_number: 10
        # Checkbox format doesn't require additional sections
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{config: Config.get_all(), references: %{}}
      result = SubtaskValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates custom dash format task IDs" do
      subtask = %Task{
        id: "PROJ-001-1",
        type: :subtask,
        status: "In Progress",
        line_number: 10,
        content: [
          "**Status**: In Progress",
          "{{error-handling-subtask}}"
        ]
      }

      task = %Task{
        id: "PROJ-001",
        type: :main,
        status: "In Progress",
        subtasks: [subtask]
      }

      context = %{
        config: Config.get_all(),
        references: %{"error-handling-subtask" => ["content"]}
      }

      result = SubtaskValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end
  end

  describe "priority/0" do
    test "returns medium priority" do
      assert SubtaskValidator.priority() == 45
    end
  end
end
