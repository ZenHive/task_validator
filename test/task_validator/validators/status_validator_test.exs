defmodule TaskValidator.Validators.StatusValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Validators.StatusValidator
  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}

  describe "validate/2" do
    test "validates valid status and priority" do
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
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"]
        }
      }

      assert %ValidationResult{valid?: true} = StatusValidator.validate(task, context)
    end

    test "fails validation for invalid status" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "InvalidStatus",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"]
        }
      }

      result = StatusValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_status
      assert String.contains?(error.message, "InvalidStatus")
    end

    test "fails validation for invalid priority" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "InvalidPriority",
        content: [],
        subtasks: []
      }

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"]
        }
      }

      result = StatusValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_priority
      assert String.contains?(error.message, "InvalidPriority")
    end

    test "fails validation for In Progress main task without subtasks" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "In Progress",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"]
        }
      }

      result = StatusValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :missing_subtasks_for_in_progress
      assert String.contains?(error.message, "In Progress")
    end

    test "passes validation for In Progress main task with subtasks" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Subtask",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "In Progress",
        priority: "High",
        content: [],
        subtasks: [subtask]
      }

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"]
        }
      }

      assert %ValidationResult{valid?: true} = StatusValidator.validate(task, context)
    end

    test "fails validation for completed subtask without review rating" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Completed subtask",
        status: "Completed",
        priority: "High",
        review_rating: nil,
        content: [],
        subtasks: []
      }

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"],
          rating_regex: ~r/^([1-5](\.\d)?)\s*(\(partial\))?$/
        }
      }

      result = StatusValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :missing_review_rating
      assert String.contains?(error.message, "SSH001-1")
    end

    test "validates completed subtask with valid review rating" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Completed subtask",
        status: "Completed",
        priority: "High",
        review_rating: "4.5",
        content: [],
        subtasks: []
      }

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"],
          rating_regex: ~r/^([1-5](\.\d)?)\s*(\(partial\))?$/
        }
      }

      assert %ValidationResult{valid?: true} = StatusValidator.validate(task, context)
    end

    test "fails validation for completed subtask with invalid review rating format" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Completed subtask",
        status: "Completed",
        priority: "High",
        review_rating: "invalid_rating",
        content: [],
        subtasks: []
      }

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"],
          rating_regex: ~r/^([1-5](\.\d)?)\s*(\(partial\))?$/
        }
      }

      result = StatusValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_review_rating
      assert String.contains?(error.message, "invalid_rating")
    end

    test "validates partial review rating format" do
      task = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Completed subtask",
        status: "Completed",
        priority: "High",
        review_rating: "4.5 (partial)",
        content: [],
        subtasks: []
      }

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"],
          rating_regex: ~r/^([1-5](\.\d)?)\s*(\(partial\))?$/
        }
      }

      assert %ValidationResult{valid?: true} = StatusValidator.validate(task, context)
    end
  end

  describe "priority/0" do
    test "returns medium priority" do
      assert StatusValidator.priority() == 60
    end
  end
end
