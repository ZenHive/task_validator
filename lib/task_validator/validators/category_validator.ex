defmodule TaskValidator.Validators.CategoryValidator do
  @moduledoc """
  Validates task categories and category-specific requirements.

  This validator ensures that tasks are properly categorized based on their
  task ID numbers and that they include the required sections for their
  specific category. It supports both standard categories and custom
  category configurations.

  ## Validation Rules

  1. **Category Assignment**: Tasks are categorized based on ID number ranges
     - Core (001-099): Architecture, system design, fundamental components
     - Features (100-199): User-facing functionality, feature development
     - Documentation (200-299): Documentation, guides, API docs
     - Testing (300-399): Test implementation, test infrastructure

  2. **Category-Specific Sections**: Each category has required sections
     - Core: **Architecture Notes**, **Complexity Assessment**
     - Features: **Abstraction Evaluation**, **Simplicity Progression Plan**
     - Documentation: **Content Strategy**, **Audience Analysis**
     - Testing: **Test Strategy**, **Coverage Requirements**

  3. **ID Format Support**: Handles multiple ID formats
     - Standard format: SSH001, VAL0004 (extracts number for categorization)
     - Custom format: PROJ-001, CORE-123 (extracts number after dash)

  4. **Configurable Categories**: Category ranges and requirements configurable
     - Default ranges can be overridden in configuration
     - Custom categories can be defined with specific requirements

  ## Error Types

  - `:invalid_category_range` - Task ID number doesn't fit any category
  - `:missing_category_sections` - Required category sections missing
  - `:invalid_id_for_categorization` - Cannot extract number for categorization
  - `:unknown_category` - Category not defined in configuration

  ## Examples

      # Valid core task (SSH001)
      **Architecture Notes**
      Details about system architecture considerations...
      
      **Complexity Assessment**  
      Assessment of implementation complexity...

      # Valid features task (SSH101)
      **Abstraction Evaluation**
      Analysis of abstraction layers...
      
      **Simplicity Progression Plan**
      Plan for maintaining simplicity...

      # Valid documentation task (SSH201)
      **Content Strategy**
      Strategy for content organization...
      
      **Audience Analysis**
      Target audience and their needs...

      # Valid testing task (SSH301)
      **Test Strategy**
      Overall testing approach...
      
      **Coverage Requirements**
      Required test coverage metrics...
  """

  @behaviour TaskValidator.Validators.ValidatorBehaviour

  alias TaskValidator.Core.{Task, ValidationResult, ValidationError}
  alias TaskValidator.Config

  # Default category-specific required sections
  @category_sections %{
    # Original generic categories (preserve backward compatibility)
    "core" => ["**Architecture Notes**", "**Complexity Assessment**"],
    "features" => ["**Abstraction Evaluation**", "**Simplicity Progression Plan**"],
    "documentation" => ["**Content Strategy**", "**Audience Analysis**"],
    "testing" => ["**Test Strategy**", "**Coverage Requirements**"],
    # New Elixir/Phoenix-specific categories
    "otp_genserver" => [
      "**Process Design**",
      "**State Management**",
      "**Supervision Strategy**"
    ],
    "phoenix_web" => [
      "**Route Design**",
      "**Context Integration**",
      "**Template/Component Strategy**"
    ],
    "business_logic" => [
      "**API Design**",
      "**Data Access**",
      "**Validation Strategy**"
    ],
    "data_layer" => [
      "**Schema Design**",
      "**Migration Strategy**",
      "**Query Optimization**"
    ],
    "infrastructure" => [
      "**Release Configuration**",
      "**Environment Variables**",
      "**Deployment Strategy**"
    ],
    "elixir_testing" => [
      "**Test Strategy**",
      "**Coverage Requirements**",
      "**Property-Based Testing**"
    ]
  }

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
      &validate_category_assignment/2,
      &validate_category_sections/2
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

  # Validates that task has required sections for its category
  defp validate_category_sections(%Task{id: id, content: content}, config) do
    case extract_task_number(id) do
      {:ok, number} ->
        category_ranges = Map.get(config, :category_ranges, Config.get(:category_ranges))

        case find_category_for_number(number, category_ranges) do
          {category_name, _range} ->
            validate_sections_for_category(id, content, category_name, config)

          nil ->
            # Category assignment error, already handled in validate_category_assignment
            ValidationResult.success()
        end

      {:error, _reason} ->
        # ID format error, already handled in validate_category_assignment
        ValidationResult.success()
    end
  end

  # Validates that all required sections for a category are present
  defp validate_sections_for_category(task_id, content, category_name, config) do
    # Get category sections from config or use defaults
    all_category_sections = Map.get(config, :category_sections, @category_sections)
    required_sections = Map.get(all_category_sections, category_name, [])

    if Enum.empty?(required_sections) do
      # No specific requirements for this category
      ValidationResult.success()
    else
      missing_sections = find_missing_sections(content, required_sections)

      if Enum.empty?(missing_sections) do
        ValidationResult.success()
      else
        error = %ValidationError{
          type: :missing_category_sections,
          message:
            "Task '#{task_id}' (#{category_name} category) is missing required sections: #{Enum.join(missing_sections, ", ")}",
          task_id: task_id,
          severity: :error,
          context: %{
            category: category_name,
            missing_sections: missing_sections,
            required_sections: required_sections
          }
        }

        ValidationResult.failure(error)
      end
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

  # Finds sections that are missing from the content
  defp find_missing_sections(content, required_sections) do
    Enum.reject(required_sections, fn section ->
      Enum.any?(content, fn line ->
        String.starts_with?(line, section)
      end)
    end)
  end

  # Formats category ranges for error messages
  defp format_category_ranges(category_ranges) do
    category_ranges
    |> Enum.map(fn {category, {min, max}} ->
      "#{category} (#{min}-#{max})"
    end)
    |> Enum.join(", ")
  end
end
