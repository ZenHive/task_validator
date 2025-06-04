defmodule TaskValidator do
  @moduledoc """
  Validates TaskList.md format compliance according to project guidelines.

  The `TaskValidator` ensures that task documents follow a consistent structure,
  making it easier to track and manage work across multiple project components,
  with a strong focus on error handling practices.

  ## Validation Checks

  * ID format compliance (like SSH0001, SCP0001, ERR001, etc.)
  * Unique task IDs across the document
  * Required sections and fields present in each task, including Error Handling Guidelines
  * Different error handling requirements for main tasks and subtasks:
    - Main tasks: Comprehensive error handling documentation with GenServer-specific examples
    - Subtasks: Simplified error handling focused on task-specific approaches
  * Proper subtask structure with consistent prefixes
  * Valid status values from the allowed list
  * Proper review rating format for completed tasks
  * Error handling patterns and conventions

  ## Error Handling Requirements

  Main tasks must include comprehensive error handling sections:

  ```markdown
  **Error Handling**
  **Core Principles**
  - Pass raw errors
  - Use {:ok, result} | {:error, reason}
  - Let it crash
  **Error Implementation**
  - No wrapping
  - Minimal rescue
  - function/1 & /! versions
  **Error Examples**
  - Raw error passthrough
  - Simple rescue case
  - Supervisor handling
  **GenServer Specifics**
  - Handle_call/3 error pattern
  - Terminate/2 proper usage
  - Process linking considerations
  ```

  Subtasks have a simplified error handling format:

  ```markdown
  **Error Handling**
  **Task-Specific Approach**
  - Error pattern for this task
  **Error Reporting**
  - Monitoring approach
  ```

  ## Usage Example

      case TaskValidator.validate_file("path/to/TaskList.md") do
        {:ok, message} ->
          # Task list validation succeeded
          IO.puts("Validation passed: " <> message)
        {:error, reason} ->
          # Task list validation failed
          IO.puts("Validation failed: " <> reason)
      end
  """

  alias TaskValidator.Core.ValidationError
  alias TaskValidator.Core.ValidationResult
  alias TaskValidator.Parsers.MarkdownParser

  @doc """
  Validates a TaskList.md file for format compliance.

  This is the main validation entry point that uses the new modular architecture
  with dedicated parsers and individual validators.

  ## Parameters
  - `file_path`: Path to the TaskList.md file to validate

  ## Returns
  - `{:ok, message}` if validation passes
  - `{:error, error_message}` if validation fails

  ## Examples

      iex> TaskValidator.validate_file("docs/TaskList.md")
      {:ok, "TaskList.md validation passed!"}

      iex> TaskValidator.validate_file("invalid_tasklist.md")
      {:error, "Invalid task ID format for: INVALID. Expected pattern: ..."}
  """
  @spec validate_file(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_file(file_path) do
    with {:ok, content} <- File.read(file_path),
         {:ok, task_list} <- MarkdownParser.parse(content),
         :ok <- validate_references_new(task_list) do
      result = validate_tasks_with_new_validators(task_list)

      case result do
        %ValidationResult{valid?: true} ->
          {:ok, "TaskList.md validation passed!"}

        %ValidationResult{valid?: false, errors: errors} ->
          error_messages = Enum.map(errors, &ValidationError.format/1)
          {:error, Enum.join(error_messages, "\n")}
      end
    end
  end

  @doc """
  Validates a file using the new validation pipeline with options.

  This function provides more control over the validation process and
  returns detailed validation results.

  ## Parameters
  - `file_path`: Path to the TaskList.md file to validate
  - `options`: Keyword list of validation options (optional)

  ## Options
  - `:strict` - Enable strict validation mode (default: false)
  - `:validators` - List of specific validators to run (default: all)

  ## Returns
  - `{:ok, ValidationResult.t()}` with detailed validation information
  - `{:error, String.t()}` if file reading or parsing fails
  """
  @spec validate_file_with_pipeline(String.t(), keyword()) ::
          {:ok, ValidationResult.t()} | {:error, String.t()}
  def validate_file_with_pipeline(file_path, options \\ []) do
    with {:ok, content} <- File.read(file_path),
         {:ok, task_list} <- MarkdownParser.parse(content),
         :ok <- validate_references_new(task_list) do
      context = %{
        config: TaskValidator.Config.get_all(),
        all_tasks: task_list.tasks,
        references: task_list.references,
        task_list: task_list,
        options: options
      }

      result = TaskValidator.ValidationPipeline.run_many(task_list.tasks, context)
      {:ok, result}
    end
  end

  @doc """
  Alternative validation function that returns detailed ValidationResult.

  This provides more detailed validation information including warnings
  and structured error data for programmatic use.
  """
  @spec validate_file_detailed(String.t()) ::
          {:ok, ValidationResult.t()} | {:error, String.t()}
  def validate_file_detailed(file_path) do
    with {:ok, content} <- File.read(file_path),
         {:ok, task_list} <- MarkdownParser.parse(content),
         :ok <- validate_references_new(task_list) do
      result = validate_tasks_with_new_validators(task_list)
      {:ok, result}
    end
  end

  # New validation functions using the parser modules and validator pipeline

  defp validate_tasks_with_new_validators(task_list) do
    context = %{
      config: TaskValidator.Config.get_all(),
      all_tasks: task_list.tasks,
      references: task_list.references,
      task_list: task_list
    }

    # Use the new validation pipeline
    TaskValidator.ValidationPipeline.run_many(task_list.tasks, context)
  end

  # Validate that all referenced placeholders have corresponding definitions
  defp validate_references_new(task_list) do
    result = TaskValidator.Parsers.ReferenceResolver.validate_references(task_list)

    if result.valid? do
      :ok
    else
      error_messages = Enum.map(result.errors, &ValidationError.format/1)
      {:error, Enum.join(error_messages, "\n")}
    end
  end
end
