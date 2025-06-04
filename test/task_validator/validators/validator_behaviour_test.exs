defmodule TaskValidator.Validators.ValidatorBehaviourTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Validators.ValidatorBehaviour

  defmodule TestValidator do
    @moduledoc false
    @behaviour ValidatorBehaviour

    alias TaskValidator.Core.ValidationResult

    def validate(_task, _context), do: ValidationResult.success()
  end

  defmodule TestValidatorWithPriority do
    @moduledoc false
    @behaviour ValidatorBehaviour

    alias TaskValidator.Core.ValidationResult

    def validate(_task, _context), do: ValidationResult.success()
    def priority, do: 80
  end

  describe "get_priority/1" do
    test "returns default priority when module doesn't implement priority/0" do
      assert ValidatorBehaviour.get_priority(TestValidator) == 50
    end

    test "returns module's priority when implemented" do
      assert ValidatorBehaviour.get_priority(TestValidatorWithPriority) == 80
    end
  end
end
