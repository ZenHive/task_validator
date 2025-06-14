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
      Default: `8`
      
    * `:max_lines_per_function` - Maximum allowed lines per function.
      Default: `15`
      
    * `:max_call_depth` - Maximum allowed call depth.
      Default: `3`

  ### Elixir-Specific Code Quality KPIs

    * `:max_pattern_match_depth` - Maximum allowed pattern matching depth.
      Default: `4`
      
    * `:max_dialyzer_warnings` - Maximum allowed Dialyzer warnings.
      Default: `0`
      
    * `:min_credo_score` - Minimum required Credo score (out of 10).
      Default: `8.0`
      
    * `:max_genserver_state_complexity` - Maximum GenServer state fields.
      Default: `5`
      
    * `:max_phoenix_context_boundaries` - Maximum contexts per feature.
      Default: `3`
      
    * `:max_ecto_query_complexity` - Maximum Ecto query depth.
      Default: `4`

  ### Task Categories

    * `:category_ranges` - Map of category names to number ranges.
      Default (Elixir/Phoenix-specific):
      ```
      %{
        "otp_genserver" => {1, 99},
        "phoenix_web" => {100, 199},
        "business_logic" => {200, 299},
        "data_layer" => {300, 399},
        "infrastructure" => {400, 499},
        "testing" => {500, 599}
      }
      ```

  ## Example Configuration

      # config/config.exs
      config :task_validator,
        valid_statuses: ["Planning", "Active", "Done", "Paused"],
        max_functions_per_module: 7,
        category_ranges: %{
          "otp_genserver" => {1, 99},
          "phoenix_web" => {100, 199},
          "business_logic" => {200, 299},
          "data_layer" => {300, 399},
          "infrastructure" => {400, 499},
          "testing" => {500, 599}
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
  defp get_default(:valid_statuses), do: ["Planned", "In Progress", "Review", "Completed", "Blocked"]

  defp get_default(:valid_priorities), do: ["Critical", "High", "Medium", "Low"]
  defp get_default(:id_regex), do: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/
  defp get_default(:rating_regex), do: ~r/^([1-5](\.\d)?)\s*(\(partial\))?$/
  defp get_default(:max_functions_per_module), do: 8
  defp get_default(:max_lines_per_function), do: 15
  defp get_default(:max_call_depth), do: 3

  # Elixir-specific KPI defaults
  defp get_default(:max_pattern_match_depth), do: 4
  defp get_default(:max_dialyzer_warnings), do: 0
  defp get_default(:min_credo_score), do: 8.0
  defp get_default(:max_genserver_state_complexity), do: 5
  defp get_default(:max_phoenix_context_boundaries), do: 3
  defp get_default(:max_ecto_query_complexity), do: 4

  defp get_default(:category_ranges) do
    %{
      # Elixir/Phoenix-specific categories
      "otp_genserver" => {1, 99},
      "phoenix_web" => {100, 199},
      "business_logic" => {200, 299},
      "data_layer" => {300, 399},
      "infrastructure" => {400, 499},
      "testing" => {500, 599}
    }
  end

  # Phoenix/Ecto-specific section configuration
  defp get_default(:phoenix_web_sections) do
    ["**Route Design**", "**Context Integration**", "**Template/Component Strategy**"]
  end

  defp get_default(:data_layer_sections) do
    ["**Schema Design**", "**Migration Strategy**", "**Query Optimization**"]
  end

  defp get_default(:business_logic_sections) do
    ["**Context Boundaries**", "**Business Rules**"]
  end

  defp get_default(:enforce_category_sections), do: true

  # Enhanced task ID patterns for Elixir/Phoenix
  defp get_default(:semantic_prefixes) do
    %{
      # OTP/GenServer tasks (1-99)
      "OTP" => :otp_genserver,
      "GEN" => :otp_genserver,
      "SUP" => :otp_genserver,
      "APP" => :otp_genserver,

      # Phoenix Web tasks (100-199)
      "PHX" => :phoenix_web,
      "WEB" => :phoenix_web,
      "LV" => :phoenix_web,
      "LVC" => :phoenix_web,

      # Business Logic tasks (200-299)  
      "CTX" => :business_logic,
      "BIZ" => :business_logic,
      "DOM" => :business_logic,

      # Data Layer tasks (300-399)
      "DB" => :data_layer,
      "ECT" => :data_layer,
      "MIG" => :data_layer,
      "SCH" => :data_layer,

      # Infrastructure tasks (400-499)
      "INF" => :infrastructure,
      "DEP" => :infrastructure,
      "ENV" => :infrastructure,
      "REL" => :infrastructure,

      # Testing tasks (500-599)
      "TST" => :testing,
      "TES" => :testing,
      "INT" => :testing,
      "E2E" => :testing
    }
  end

  defp get_default(:enable_semantic_prefixes), do: true

  defp get_default(_), do: nil

  @doc """
  Gets all configuration as a map.

  Returns a map with all configuration values, using defaults for any
  unconfigured options.
  """
  @spec get_all() :: map()
  def get_all do
    Map.new(
      [
        :valid_statuses,
        :valid_priorities,
        :id_regex,
        :rating_regex,
        :max_functions_per_module,
        :max_lines_per_function,
        :max_call_depth,
        :max_pattern_match_depth,
        :max_dialyzer_warnings,
        :min_credo_score,
        :max_genserver_state_complexity,
        :max_phoenix_context_boundaries,
        :max_ecto_query_complexity,
        :category_ranges,
        :phoenix_web_sections,
        :data_layer_sections,
        :business_logic_sections,
        :enforce_category_sections,
        :semantic_prefixes,
        :enable_semantic_prefixes
      ],
      fn key -> {key, get(key)} end
    )
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

  def validate_config_value(:max_functions_per_module, value) when is_integer(value) and value > 0, do: :ok

  def validate_config_value(:max_functions_per_module, _), do: {:error, "must be a positive integer"}

  def validate_config_value(:max_lines_per_function, value) when is_integer(value) and value > 0, do: :ok

  def validate_config_value(:max_lines_per_function, _), do: {:error, "must be a positive integer"}

  def validate_config_value(:max_call_depth, value) when is_integer(value) and value > 0, do: :ok
  def validate_config_value(:max_call_depth, _), do: {:error, "must be a positive integer"}

  # Elixir-specific KPI validations
  def validate_config_value(:max_pattern_match_depth, value) when is_integer(value) and value > 0, do: :ok

  def validate_config_value(:max_pattern_match_depth, _), do: {:error, "must be a positive integer"}

  def validate_config_value(:max_dialyzer_warnings, value) when is_integer(value) and value >= 0, do: :ok

  def validate_config_value(:max_dialyzer_warnings, _), do: {:error, "must be a non-negative integer"}

  def validate_config_value(:min_credo_score, value) when is_number(value) and value >= 0.0 and value <= 10.0, do: :ok

  def validate_config_value(:min_credo_score, _), do: {:error, "must be a number between 0.0 and 10.0"}

  def validate_config_value(:max_genserver_state_complexity, value) when is_integer(value) and value > 0, do: :ok

  def validate_config_value(:max_genserver_state_complexity, _), do: {:error, "must be a positive integer"}

  def validate_config_value(:max_phoenix_context_boundaries, value) when is_integer(value) and value > 0, do: :ok

  def validate_config_value(:max_phoenix_context_boundaries, _), do: {:error, "must be a positive integer"}

  def validate_config_value(:max_ecto_query_complexity, value) when is_integer(value) and value > 0, do: :ok

  def validate_config_value(:max_ecto_query_complexity, _), do: {:error, "must be a positive integer"}

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

  # Phoenix/Ecto section configuration validations
  def validate_config_value(:phoenix_web_sections, value) when is_list(value) do
    if Enum.all?(value, &is_binary/1) do
      :ok
    else
      {:error, "must be a list of strings"}
    end
  end

  def validate_config_value(:phoenix_web_sections, _), do: {:error, "must be a list of strings"}

  def validate_config_value(:data_layer_sections, value) when is_list(value) do
    if Enum.all?(value, &is_binary/1) do
      :ok
    else
      {:error, "must be a list of strings"}
    end
  end

  def validate_config_value(:data_layer_sections, _), do: {:error, "must be a list of strings"}

  def validate_config_value(:business_logic_sections, value) when is_list(value) do
    if Enum.all?(value, &is_binary/1) do
      :ok
    else
      {:error, "must be a list of strings"}
    end
  end

  def validate_config_value(:business_logic_sections, _), do: {:error, "must be a list of strings"}

  def validate_config_value(:enforce_category_sections, value) when is_boolean(value), do: :ok
  def validate_config_value(:enforce_category_sections, _), do: {:error, "must be a boolean"}

  # Enhanced task ID pattern validations
  def validate_config_value(:semantic_prefixes, value) when is_map(value) do
    if Enum.all?(value, fn
         {k, v} when is_binary(k) and is_atom(v) -> true
         _ -> false
       end) do
      :ok
    else
      {:error, "must be a map of string prefixes to atom categories"}
    end
  end

  def validate_config_value(:semantic_prefixes, _), do: {:error, "must be a map of string prefixes to atom categories"}

  def validate_config_value(:enable_semantic_prefixes, value) when is_boolean(value), do: :ok
  def validate_config_value(:enable_semantic_prefixes, _), do: {:error, "must be a boolean"}

  def validate_config_value(key, _value) do
    {:error, "unknown configuration key: #{key}"}
  end
end
