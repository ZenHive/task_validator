defmodule TaskValidator.ConfigTest do
  use ExUnit.Case

  alias TaskValidator.Config

  setup do
    # Clear all task_validator configuration before each test
    for {key, _value} <- Application.get_all_env(:task_validator) do
      Application.delete_env(:task_validator, key)
    end

    :ok
  end

  describe "get/1" do
    test "returns default values when no configuration is set" do
      assert Config.get(:valid_statuses) == [
               "Planned",
               "In Progress",
               "Review",
               "Completed",
               "Blocked"
             ]

      assert Config.get(:valid_priorities) == ["Critical", "High", "Medium", "Low"]
      assert Config.get(:max_functions_per_module) == 8
      assert Config.get(:max_lines_per_function) == 15
      assert Config.get(:max_call_depth) == 3
    end

    test "returns default regex patterns" do
      assert %Regex{} = Config.get(:id_regex)
      assert %Regex{} = Config.get(:rating_regex)
    end

    test "returns default category ranges" do
      ranges = Config.get(:category_ranges)
      assert ranges["otp_genserver"] == {1, 99}
      assert ranges["phoenix_web"] == {100, 199}
      assert ranges["business_logic"] == {200, 299}
      assert ranges["data_layer"] == {300, 399}
      assert ranges["infrastructure"] == {400, 499}
      assert ranges["testing"] == {500, 599}
    end

    test "raises for unknown configuration key" do
      assert_raise ArgumentError, ~r/Invalid configuration for unknown_key/, fn ->
        Config.get(:unknown_key)
      end
    end
  end

  describe "get_all/0" do
    test "returns all configuration values as a map" do
      config = Config.get_all()

      assert is_map(config)
      assert Map.has_key?(config, :valid_statuses)
      assert Map.has_key?(config, :valid_priorities)
      assert Map.has_key?(config, :id_regex)
      assert Map.has_key?(config, :rating_regex)
      assert Map.has_key?(config, :max_functions_per_module)
      assert Map.has_key?(config, :max_lines_per_function)
      assert Map.has_key?(config, :max_call_depth)
      assert Map.has_key?(config, :category_ranges)
    end
  end

  describe "validate_config_value/2" do
    test "validates valid_statuses" do
      assert :ok == Config.validate_config_value(:valid_statuses, ["A", "B", "C"])
      assert {:error, _} = Config.validate_config_value(:valid_statuses, ["A", 123])
      assert {:error, _} = Config.validate_config_value(:valid_statuses, "not a list")
    end

    test "validates valid_priorities" do
      assert :ok == Config.validate_config_value(:valid_priorities, ["P0", "P1", "P2"])
      assert {:error, _} = Config.validate_config_value(:valid_priorities, [1, 2, 3])
      assert {:error, _} = Config.validate_config_value(:valid_priorities, %{})
    end

    test "validates id_regex" do
      assert :ok == Config.validate_config_value(:id_regex, ~r/test/)
      assert {:error, _} = Config.validate_config_value(:id_regex, "not a regex")
    end

    test "validates rating_regex" do
      assert :ok == Config.validate_config_value(:rating_regex, ~r/\d+/)
      assert {:error, _} = Config.validate_config_value(:rating_regex, 123)
    end

    test "validates max_functions_per_module" do
      assert :ok == Config.validate_config_value(:max_functions_per_module, 10)
      assert {:error, _} = Config.validate_config_value(:max_functions_per_module, 0)
      assert {:error, _} = Config.validate_config_value(:max_functions_per_module, -5)
      assert {:error, _} = Config.validate_config_value(:max_functions_per_module, "five")
    end

    test "validates max_lines_per_function" do
      assert :ok == Config.validate_config_value(:max_lines_per_function, 20)
      assert {:error, _} = Config.validate_config_value(:max_lines_per_function, 0)
      assert {:error, _} = Config.validate_config_value(:max_lines_per_function, 1.5)
    end

    test "validates max_call_depth" do
      assert :ok == Config.validate_config_value(:max_call_depth, 3)
      assert {:error, _} = Config.validate_config_value(:max_call_depth, -1)
      assert {:error, _} = Config.validate_config_value(:max_call_depth, [])
    end

    test "validates category_ranges" do
      valid_ranges = %{
        "cat1" => {1, 50},
        "cat2" => {51, 100}
      }

      assert :ok == Config.validate_config_value(:category_ranges, valid_ranges)

      # Invalid: non-string keys
      assert {:error, _} = Config.validate_config_value(:category_ranges, %{cat1: {1, 50}})

      # Invalid: non-tuple values
      assert {:error, _} = Config.validate_config_value(:category_ranges, %{"cat1" => [1, 50]})

      # Invalid: min > max
      assert {:error, _} = Config.validate_config_value(:category_ranges, %{"cat1" => {50, 1}})

      # Invalid: non-integer bounds
      assert {:error, _} = Config.validate_config_value(:category_ranges, %{"cat1" => {1.5, 50}})

      # Invalid: not a map
      assert {:error, _} = Config.validate_config_value(:category_ranges, [])
    end

    test "returns error for unknown configuration key" do
      assert {:error, "unknown configuration key: bogus_key"} =
               Config.validate_config_value(:bogus_key, "value")
    end
  end
end
