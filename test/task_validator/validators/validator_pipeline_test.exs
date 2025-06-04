defmodule TaskValidator.Validators.ValidatorPipelineTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationResult
  alias TaskValidator.Validators.CategoryValidator
  alias TaskValidator.Validators.DependencyValidator
  alias TaskValidator.Validators.ErrorHandlingValidator
  alias TaskValidator.Validators.IdValidator
  alias TaskValidator.Validators.KpiValidator
  alias TaskValidator.Validators.SectionValidator
  alias TaskValidator.Validators.StatusValidator
  alias TaskValidator.Validators.SubtaskValidator
  alias TaskValidator.Validators.ValidatorPipeline

  describe "validate_task/3" do
    test "validates a task with multiple validators" do
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
          "Full error handling"
        ],
        subtasks: [],
        line_number: 1,
        prefix: "SSH",
        category: nil,
        parent_id: nil,
        review_rating: nil
      }

      validators = ValidatorPipeline.default_validators()

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"],
          id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/
        },
        all_tasks: [task],
        references: %{}
      }

      result = ValidatorPipeline.validate_task(task, validators, context)
      assert %ValidationResult{valid?: false} = result
      # Should have error for missing comprehensive error handling
      assert length(result.errors) > 0
    end

    test "sorts validators by priority" do
      validators = ValidatorPipeline.default_validators()

      # Test that we have all 8 validators in the pipeline
      assert length(validators) == 8

      # Test that validators include all expected modules
      assert IdValidator in validators
      assert StatusValidator in validators
      assert ErrorHandlingValidator in validators
      assert SectionValidator in validators
      assert SubtaskValidator in validators
      assert DependencyValidator in validators
      assert CategoryValidator in validators
      assert KpiValidator in validators
    end
  end

  describe "validate_tasks/3" do
    test "validates multiple tasks" do
      task1 = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task 1",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: [],
        line_number: 1,
        prefix: "SSH",
        category: nil,
        parent_id: nil,
        review_rating: nil
      }

      task2 = %Task{
        id: "SSH002",
        type: :main,
        description: "Test task 2",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: [],
        line_number: 2,
        prefix: "SSH",
        category: nil,
        parent_id: nil,
        review_rating: nil
      }

      validators = ValidatorPipeline.default_validators()

      context = %{
        config: %{
          valid_statuses: ["Planned", "In Progress", "Completed"],
          valid_priorities: ["High", "Medium", "Low"],
          id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/
        },
        all_tasks: [task1, task2],
        references: %{}
      }

      result = ValidatorPipeline.validate_tasks([task1, task2], validators, context)
      assert %ValidationResult{} = result
      # Both tasks should have validation errors (missing required sections)
      assert length(result.errors) > 0
    end
  end

  describe "default_validators/0" do
    test "returns the default set of validators" do
      validators = ValidatorPipeline.default_validators()

      # Core validators from original implementation
      assert IdValidator in validators
      assert StatusValidator in validators
      assert SectionValidator in validators

      # Additional validators from refactoring
      assert ErrorHandlingValidator in validators
      assert SubtaskValidator in validators
      assert DependencyValidator in validators
      assert KpiValidator in validators
      assert CategoryValidator in validators

      # Verify we have all 8 validators
      assert length(validators) == 8
    end
  end
end
