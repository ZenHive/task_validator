defmodule TaskValidator.Validators.CategoryValidator do
  @moduledoc """
  Validates task category assignment based on task ID numbers.

  This validator ensures that tasks are properly categorized based on their
  task ID numbers. It supports both standard categories and custom
  category configurations. Category-specific section validation is handled
  by the SectionValidator.

  ## Validation Rules

  1. **Category Assignment**: Tasks are categorized based on ID number ranges (Elixir/Phoenix-specific)
     - OTP/GenServer (001-099): Supervision trees, GenServers, Agents
     - Phoenix Web (100-199): Controllers, views, LiveView, channels
     - Business Logic (200-299): Contexts, schemas, core logic
     - Data Layer (300-399): Ecto schemas, migrations, repos
     - Infrastructure (400-499): Releases, deployment, monitoring
     - Testing (500-599): Unit, integration, property-based tests

  2. **ID Format Support**: Handles multiple ID formats
     - Standard format: SSH001, VAL0004 (extracts number for categorization)
     - Custom format: PROJ-001, CORE-123 (extracts number after dash)

  3. **Configurable Categories**: Category ranges configurable
     - Default ranges can be overridden in configuration
     - Custom categories can be defined with specific ranges

  ## Error Types

  - `:invalid_category_range` - Task ID number doesn't fit any category
  - `:invalid_id_for_categorization` - Cannot extract number for categorization

  ## Examples

      # Task ID OTP001 -> Category :otp_genserver (range 1-99)
      # Task ID PHX101 -> Category :phoenix_web (range 100-199)
      # Task ID CTX201 -> Category :business_logic (range 200-299)
      # Task ID DB301 -> Category :data_layer (range 300-399)
      # Task ID INF401 -> Category :infrastructure (range 400-499)
      # Task ID TST501 -> Category :testing (range 500-599)

      # Also supports custom formats:
      # Task ID PROJ-001 -> Category :otp_genserver
      # Task ID CORE-123 -> Category :phoenix_web
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Config
  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationError
  alias TaskValidator.Core.ValidationResult

  @doc """
  Validates task category assignment and category-specific requirements.

  ## Context Requirements
  - `:config` - TaskValidator configuration (optional, uses defaults)

  ## Returns
  - Success if all category validations pass
  - Failure with specific error details for each validation issue
  """
  @impl true
  def validate(%Task{} = task, context) do
    config = Map.get(context, :config, Config.get_all())

    validators = [
      &validate_category_assignment/2
    ]

    validators
    |> Enum.map(fn validator -> validator.(task, config) end)
    |> ValidationResult.combine()
  end

  @doc """
  Returns low priority (35) since category validation is useful for
  organization but not critical for basic task functionality.
  """
  @impl true
  def priority, do: 35

  # Validates that task ID fits into a defined category range
  defp validate_category_assignment(%Task{id: id}, config) do
    case extract_task_number(id) do
      {:ok, number} ->
        category_ranges = Map.get(config, :category_ranges, Config.get(:category_ranges))

        case find_category_for_number(number, category_ranges) do
          {_category_name, _range} ->
            # Store category in task for later validation
            ValidationResult.success()

          nil ->
            error = %ValidationError{
              type: :invalid_category_range,
              message:
                "Task '#{id}' number #{number} doesn't fit any defined category range. Available ranges: #{format_category_ranges(category_ranges)}",
              task_id: id,
              severity: :error,
              context: %{
                task_number: number,
                available_ranges: category_ranges,
                extracted_id: id
              }
            }

            ValidationResult.failure(error)
        end

      {:error, reason} ->
        error = %ValidationError{
          type: :invalid_id_for_categorization,
          message: "Cannot categorize task '#{id}': #{reason}",
          task_id: id,
          severity: :error,
          context: %{
            categorization_error: reason,
            task_id: id
          }
        }

        ValidationResult.failure(error)
    end
  end

  # Extracts the numeric part from a task ID for categorization
  defp extract_task_number(task_id) do
    cond do
      # Standard format: SSH001, VAL0004
      String.match?(task_id, ~r/^[A-Z]{2,4}(\d{3,4})/) ->
        [_, number_str] = Regex.run(~r/^[A-Z]{2,4}(\d{3,4})/, task_id)
        {:ok, String.to_integer(number_str)}

      # Custom dash format: PROJ-001, CORE-123
      String.match?(task_id, ~r/^[A-Z]{2,4}-(\d{3,4})/) ->
        [_, number_str] = Regex.run(~r/^[A-Z]{2,4}-(\d{3,4})/, task_id)
        {:ok, String.to_integer(number_str)}

      # Subtask format: SSH001-1 (use parent number)
      String.match?(task_id, ~r/^[A-Z]{2,4}(\d{3,4})-\d+/) ->
        [_, number_str] = Regex.run(~r/^[A-Z]{2,4}(\d{3,4})-\d+/, task_id)
        {:ok, String.to_integer(number_str)}

      # Custom subtask format: PROJ-001-1 (use parent number)
      String.match?(task_id, ~r/^[A-Z]{2,4}-(\d{3,4})-\d+/) ->
        [_, number_str] = Regex.run(~r/^[A-Z]{2,4}-(\d{3,4})-\d+/, task_id)
        {:ok, String.to_integer(number_str)}

      # Letter subtask format: SSH001a (use parent number)
      String.match?(task_id, ~r/^[A-Z]{2,4}(\d{3,4})[a-z]/) ->
        [_, number_str] = Regex.run(~r/^[A-Z]{2,4}(\d{3,4})[a-z]/, task_id)
        {:ok, String.to_integer(number_str)}

      true ->
        {:error, "Task ID format not recognized for categorization"}
    end
  end

  # Finds the category for a given task number
  defp find_category_for_number(number, category_ranges) do
    Enum.find(category_ranges, fn {_category, {min, max}} ->
      number >= min and number <= max
    end)
  end

  # Formats category ranges for error messages
  defp format_category_ranges(category_ranges) do
    Enum.map_join(category_ranges, ", ", fn {category, {min, max}} ->
      "#{category} (#{min}-#{max})"
    end)
  end
end
