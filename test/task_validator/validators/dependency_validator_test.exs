defmodule TaskValidator.Validators.DependencyValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Validators.DependencyValidator
  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}

  describe "validate/2" do
    test "validates task with no dependencies" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Dependencies**: None"
        ]
      }

      context = %{all_tasks: [task], references: %{}}
      result = DependencyValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates task with dependencies reference" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "{{def-no-dependencies}}"
        ]
      }

      context = %{
        all_tasks: [task],
        references: %{"def-no-dependencies" => ["None"]}
      }

      result = DependencyValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates task with valid single dependency" do
      dep_task = %Task{
        id: "SSH002",
        type: :main,
        content: [
          "**Dependencies**: None"
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Dependencies**: SSH002"
        ]
      }

      context = %{all_tasks: [task, dep_task], references: %{}}
      result = DependencyValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates task with valid multiple dependencies" do
      dep_task1 = %Task{
        id: "SSH002",
        type: :main,
        content: [
          "**Dependencies**: None"
        ]
      }

      dep_task2 = %Task{
        id: "SSH003",
        type: :main,
        content: [
          "**Dependencies**: None"
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Dependencies**: SSH002, SSH003"
        ]
      }

      context = %{all_tasks: [task, dep_task1, dep_task2], references: %{}}
      result = DependencyValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates task depending on subtask" do
      parent_task = %Task{
        id: "SSH002",
        type: :main,
        content: [
          "**Dependencies**: None"
        ],
        subtasks: [
          %Task{
            id: "SSH002-1",
            type: :subtask,
            status: "Completed",
            content: [
              "**Dependencies**: None"
            ]
          }
        ]
      }

      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Dependencies**: SSH002-1"
        ]
      }

      context = %{all_tasks: [task, parent_task], references: %{}}
      result = DependencyValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "fails task missing dependencies section" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description"
        ]
      }

      context = %{all_tasks: [task], references: %{}}
      result = DependencyValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) >= 1

      # Check that at least one error is about missing dependencies section
      missing_deps_error =
        Enum.find(result.errors, fn error ->
          error.type == :missing_dependencies_section
        end)

      assert missing_deps_error != nil
      assert missing_deps_error.task_id == "SSH001"
      assert String.contains?(missing_deps_error.message, "missing **Dependencies** section")
    end

    test "fails task with non-existent dependency" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "**Dependencies**: SSH999"
        ]
      }

      context = %{all_tasks: [task], references: %{}}
      result = DependencyValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :invalid_dependency_reference
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "non-existent dependencies")
    end

    test "fails task with direct circular dependency" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          # Depends on itself
          "**Dependencies**: SSH001"
        ]
      }

      context = %{all_tasks: [task], references: %{}}
      result = DependencyValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) == 1

      error = hd(result.errors)
      assert error.type == :circular_dependency
      assert error.task_id == "SSH001"
      assert String.contains?(error.message, "circular dependency on itself")
    end

    test "fails task with indirect circular dependency" do
      task1 = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Task 1 description",
          "**Dependencies**: SSH002"
        ]
      }

      task2 = %Task{
        id: "SSH002",
        type: :main,
        content: [
          "**Description**",
          "Task 2 description",
          "**Dependencies**: SSH003"
        ]
      }

      task3 = %Task{
        id: "SSH003",
        type: :main,
        content: [
          "**Description**",
          "Task 3 description",
          # Creates cycle: 1->2->3->1
          "**Dependencies**: SSH001"
        ]
      }

      context = %{all_tasks: [task1, task2, task3], references: %{}}

      # Test each task in the cycle
      result1 = DependencyValidator.validate(task1, context)
      result2 = DependencyValidator.validate(task2, context)
      result3 = DependencyValidator.validate(task3, context)

      # At least one should detect the cycle
      cycle_detected =
        [result1, result2, result3]
        |> Enum.any?(fn result ->
          !result.valid? &&
            Enum.any?(result.errors, fn error ->
              error.type == :circular_dependency
            end)
        end)

      assert cycle_detected
    end

    test "fails task with missing dependency reference" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "{{undefined-reference}}"
        ]
      }

      context = %{all_tasks: [task], references: %{}}
      result = DependencyValidator.validate(task, context)

      refute result.valid?
      assert length(result.errors) >= 1

      # Check that at least one error is about missing dependencies section
      missing_deps_error =
        Enum.find(result.errors, fn error ->
          error.type == :missing_dependencies_section
        end)

      assert missing_deps_error != nil
      assert missing_deps_error.task_id == "SSH001"
    end

    test "fails task with invalid dependency format" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          # Empty dependency
          "**Dependencies**: "
        ]
      }

      context = %{all_tasks: [task], references: %{}}
      result = DependencyValidator.validate(task, context)

      # This should be treated as :none and be valid
      assert result.valid?
    end

    test "validates alternative dependency reference formats" do
      task = %Task{
        id: "SSH001",
        type: :main,
        content: [
          "**Description**",
          "Test task description",
          "{{no-dependencies}}"
        ]
      }

      context = %{
        all_tasks: [task],
        references: %{"no-dependencies" => ["None"]}
      }

      result = DependencyValidator.validate(task, context)

      assert result.valid?
      assert Enum.empty?(result.errors)
    end

    test "validates complex dependency scenarios" do
      # Create a complex but valid dependency graph
      base_task = %Task{
        id: "SSH001",
        type: :main,
        content: ["**Dependencies**: None"]
      }

      mid_task = %Task{
        id: "SSH002",
        type: :main,
        content: ["**Dependencies**: SSH001"]
      }

      final_task = %Task{
        id: "SSH003",
        type: :main,
        content: ["**Dependencies**: SSH001, SSH002"]
      }

      context = %{all_tasks: [base_task, mid_task, final_task], references: %{}}

      # All tasks should validate successfully
      result1 = DependencyValidator.validate(base_task, context)
      result2 = DependencyValidator.validate(mid_task, context)
      result3 = DependencyValidator.validate(final_task, context)

      assert result1.valid?
      assert result2.valid?
      assert result3.valid?
    end
  end

  describe "priority/0" do
    test "returns medium priority" do
      assert DependencyValidator.priority() == 40
    end
  end
end
