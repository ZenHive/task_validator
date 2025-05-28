defmodule TaskValidator.Config do
  @moduledoc """
  Configuration module for TaskValidator.

  Provides a centralized way to access and validate configuration options
  for the TaskValidator library. All configuration is read from the
  Application environment under the :task_validator key.

  ## Configuration Options

  ### Validation Rules

    * `:valid_statuses` - List of valid task statuses. 
      Default: `["Planned", "In Progress", "Review", "Completed", "Blocked"]`
      
    * `:valid_priorities` - List of valid task priorities.
      Default: `["Critical", "High", "Medium", "Low"]`
      
    * `:id_regex` - Regular expression for validating task IDs.
      Default: `~r/^[A-Z]{2,4}\\d{3,4}(-\\d+|[a-z])?$/`
      
    * `:rating_regex` - Regular expression for validating review ratings.
      Default: `~r/^([1-5](\\.\d)?)\s*(\(partial\))?$/`

  ### Code Quality KPIs

    * `:max_functions_per_module` - Maximum allowed functions per module.
      Default: `5`
      
    * `:max_lines_per_function` - Maximum allowed lines per function.
      Default: `15`
      
    * `:max_call_depth` - Maximum allowed call depth.
      Default: `2`

  ### Task Categories

    * `:category_ranges` - Map of category names to number ranges.
      Default:
      ```
      %{
        "core" => {1, 99},
        "features" => {100, 199},
        "documentation" => {200, 299},
        "testing" => {300, 399}
      }
      ```

  ## Example Configuration

      # config/config.exs
      config :task_validator,
        valid_statuses: ["Planning", "Active", "Done", "Paused"],
        max_functions_per_module: 7,
        category_ranges: %{
          "infrastructure" => {1, 50},
          "business_logic" => {51, 150},
          "ui" => {151, 250},
          "testing" => {251, 350}
        }
  """

  # Default configuration values - note: regex patterns are defined in functions
  # due to Elixir compilation constraints

  @doc """
  Gets a configuration value with validation.

  Returns the configured value or the default if not set.
  Validates the configuration value matches expected type and constraints.

  ## Examples

      iex> TaskValidator.Config.get(:valid_statuses)
      ["Planned", "In Progress", "Review", "Completed", "Blocked"]
      
      iex> TaskValidator.Config.get(:max_functions_per_module)
      5
  """
  @spec get(atom()) :: any()
  def get(key) when is_atom(key) do
    default = get_default(key)
    value = Application.get_env(:task_validator, key, default)

    case validate_config_value(key, value) do
      :ok ->
        value

      {:error, reason} ->
        raise ArgumentError, "Invalid configuration for #{key}: #{reason}"
    end
  end

  # Get default value for a configuration key
  defp get_default(:valid_statuses),
    do: ["Planned", "In Progress", "Review", "Completed", "Blocked"]

  defp get_default(:valid_priorities), do: ["Critical", "High", "Medium", "Low"]
  defp get_default(:id_regex), do: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/
  defp get_default(:rating_regex), do: ~r/^([1-5](\.\d)?)\s*(\(partial\))?$/
  defp get_default(:max_functions_per_module), do: 5
  defp get_default(:max_lines_per_function), do: 15
  defp get_default(:max_call_depth), do: 2

  defp get_default(:category_ranges) do
    %{
      "core" => {1, 99},
      "features" => {100, 199},
      "documentation" => {200, 299},
      "testing" => {300, 399}
    }
  end

  defp get_default(_), do: nil

  @doc """
  Gets all configuration as a map.

  Returns a map with all configuration values, using defaults for any
  unconfigured options.
  """
  @spec get_all() :: map()
  def get_all do
    [
      :valid_statuses,
      :valid_priorities,
      :id_regex,
      :rating_regex,
      :max_functions_per_module,
      :max_lines_per_function,
      :max_call_depth,
      :category_ranges
    ]
    |> Enum.map(fn key -> {key, get(key)} end)
    |> Enum.into(%{})
  end

  @doc """
  Validates a configuration value.

  Returns `:ok` if valid, or `{:error, reason}` if invalid.
  """
  @spec validate_config_value(atom(), any()) :: :ok | {:error, String.t()}
  def validate_config_value(:valid_statuses, value) when is_list(value) do
    if Enum.all?(value, &is_binary/1) do
      :ok
    else
      {:error, "must be a list of strings"}
    end
  end

  def validate_config_value(:valid_priorities, value) when is_list(value) do
    if Enum.all?(value, &is_binary/1) do
      :ok
    else
      {:error, "must be a list of strings"}
    end
  end

  def validate_config_value(:id_regex, %Regex{} = _value), do: :ok
  def validate_config_value(:id_regex, _), do: {:error, "must be a regex"}

  def validate_config_value(:rating_regex, %Regex{} = _value), do: :ok
  def validate_config_value(:rating_regex, _), do: {:error, "must be a regex"}

  def validate_config_value(:max_functions_per_module, value)
      when is_integer(value) and value > 0,
      do: :ok

  def validate_config_value(:max_functions_per_module, _),
    do: {:error, "must be a positive integer"}

  def validate_config_value(:max_lines_per_function, value) when is_integer(value) and value > 0,
    do: :ok

  def validate_config_value(:max_lines_per_function, _),
    do: {:error, "must be a positive integer"}

  def validate_config_value(:max_call_depth, value) when is_integer(value) and value > 0, do: :ok
  def validate_config_value(:max_call_depth, _), do: {:error, "must be a positive integer"}

  def validate_config_value(:category_ranges, value) when is_map(value) do
    if Enum.all?(value, fn
         {k, {min, max}} when is_binary(k) and is_integer(min) and is_integer(max) ->
           min <= max

         _ ->
           false
       end) do
      :ok
    else
      {:error, "must be a map of string keys to {min, max} integer tuples"}
    end
  end

  def validate_config_value(:category_ranges, _), do: {:error, "must be a map"}

  def validate_config_value(key, _value) do
    {:error, "unknown configuration key: #{key}"}
  end
end
