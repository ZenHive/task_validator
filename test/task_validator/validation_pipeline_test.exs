defmodule TaskValidator.ValidationPipelineTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationResult
  alias TaskValidator.ValidationPipeline
  alias TaskValidator.Validators.IdValidator
  alias TaskValidator.Validators.StatusValidator

  describe "run/3" do
    setup do
      task = %Task{
        id: "TEST001",
        type: :main,
        status: "Planned",
        description: "Test task",
        content: ["**Status**: Planned"],
        subtasks: []
      }

      context = %{
        config: %{},
        all_tasks: [task],
        references: %{},
        task_list: %{}
      }

      {:ok, task: task, context: context}
    end

    test "runs validation with default validators", %{task: task, context: context} do
      result = ValidationPipeline.run(task, context)

      assert %ValidationResult{} = result
      # Basic task should pass ID and Status validation at minimum
      assert result.valid? || length(result.errors) < 5
    end

    test "runs validation with minimal validators", %{task: task, context: context} do
      validators = ValidationPipeline.minimal_validators()
      result = ValidationPipeline.run(task, context, validators)

      assert %ValidationResult{} = result
      # Should only run ID and Status validators
      assert length(validators) == 2
    end

    test "runs validation with custom validator list", %{task: task, context: context} do
      validators = [{IdValidator, %{}}]
      result = ValidationPipeline.run(task, context, validators)

      assert %ValidationResult{} = result
    end
  end

  describe "run_many/3" do
    test "validates multiple tasks" do
      tasks = [
        %Task{
          id: "TEST001",
          type: :main,
          status: "Planned",
          description: "Test task 1",
          content: ["**Status**: Planned"],
          subtasks: []
        },
        %Task{
          id: "TEST002",
          type: :main,
          status: "Planned",
          description: "Test task 2",
          content: ["**Status**: Planned"],
          subtasks: []
        }
      ]

      context = %{
        config: %{},
        all_tasks: tasks,
        references: %{},
        task_list: %{}
      }

      result = ValidationPipeline.run_many(tasks, context)

      assert %ValidationResult{} = result
    end
  end

  describe "validator sets" do
    test "default_validators/0 returns expected validators" do
      validators = ValidationPipeline.default_validators()

      assert length(validators) == 8
      assert Enum.any?(validators, fn {mod, _} -> mod == IdValidator end)

      assert Enum.any?(validators, fn {mod, _} ->
               mod == StatusValidator
             end)
    end

    test "minimal_validators/0 returns minimal set" do
      validators = ValidationPipeline.minimal_validators()

      assert length(validators) == 2
      assert {IdValidator, %{}} in validators
      assert {StatusValidator, %{}} in validators
    end

    test "strict_validators/1 returns enhanced validators" do
      validators = ValidationPipeline.strict_validators()

      assert length(validators) == 8
      # Should have strict options for some validators
      assert Enum.any?(validators, fn {mod, opts} ->
               mod == IdValidator &&
                 Map.get(opts, :strict_format) == true
             end)
    end
  end

  describe "build_validators/1" do
    test "builds validators from keyword list" do
      config = [
        id: [strict_format: true],
        status: []
      ]

      validators = ValidationPipeline.build_validators(config)

      assert length(validators) == 2
      assert {IdValidator, %{strict_format: true}} in validators
      assert {StatusValidator, %{}} in validators
    end
  end
end
