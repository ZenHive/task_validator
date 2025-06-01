defmodule TaskValidator.Validators.IdValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Validators.IdValidator
  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}

  describe "validate/2" do
    test "validates valid main task ID" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      assert %ValidationResult{valid?: true} = IdValidator.validate(task, context)
    end

    test "validates custom dash format main task ID" do
      task = %Task{
        id: "PROJ-001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      assert %ValidationResult{valid?: true} = IdValidator.validate(task, context)
    end

    test "validates valid numbered subtask ID" do
      main_task = %Task{
        id: "SSH001",
        type: :main,
        description: "Main task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Subtask",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [main_task, subtask],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      assert %ValidationResult{valid?: true} = IdValidator.validate(subtask, context)
    end

    test "validates valid lettered subtask ID" do
      main_task = %Task{
        id: "SSH001",
        type: :main,
        description: "Main task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      subtask = %Task{
        id: "SSH001a",
        type: :subtask,
        description: "Subtask",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [main_task, subtask],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      assert %ValidationResult{valid?: true} = IdValidator.validate(subtask, context)
    end

    test "fails validation for invalid main task ID format" do
      task = %Task{
        id: "invalid123",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_id_format
      assert String.contains?(error.message, "invalid123")
    end

    test "fails validation for invalid subtask ID format" do
      task = %Task{
        id: "SSH-invalid",
        type: :subtask,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_id_format
      assert String.contains?(error.message, "SSH-invalid")
    end

    test "fails validation for duplicate task IDs" do
      task1 = %Task{
        id: "SSH001",
        type: :main,
        description: "First task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      task2 = %Task{
        id: "SSH001",
        type: :main,
        description: "Duplicate task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task1, task2],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(task1, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :duplicate_task_id
      assert String.contains?(error.message, "SSH001")
    end

    test "fails validation for subtask with non-existent parent" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Orphan subtask",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [subtask],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(subtask, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_subtask_id
      assert String.contains?(error.message, "SSH001")
    end

    test "warns about mixed prefixes" do
      task1 = %Task{
        id: "SSH001",
        type: :main,
        description: "SSH task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      task2 = %Task{
        id: "VAL001",
        type: :main,
        description: "VAL task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task1, task2],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(task1, context)
      assert %ValidationResult{valid?: true, warnings: [warning]} = result
      assert warning.type == :mixed_prefixes
      assert String.contains?(warning.message, "SSH, VAL")
    end
  end

  describe "priority/0" do
    test "returns high priority" do
      assert IdValidator.priority() == 90
    end
  end
end
