defmodule Mix.Tasks.ValidateTasklist do
  @moduledoc """
  Validates the format and structure of a TaskList.md file.

  Validates that task lists follow the required format:
  - Task IDs must follow a consistent pattern: 2-4 uppercase letters followed by 3-4 digits
  - Subtasks must use the same prefix as their parent task
  - Required sections are present for each task
  - Tasks marked as "In Progress" have at least one subtask
  - Completed subtasks have a valid review rating

  ## Usage

      mix validate_tasklist [OPTIONS]

  ## Options

      --path  Specify a non-default path to the TaskList.md file

  ## Example

      mix validate_tasklist
      mix validate_tasklist --path ./custom/path/TaskList.md
  """

  use Mix.Task

  def run(args) do
    {options, _, _} = OptionParser.parse(args, strict: [path: :string])
    path = options[:path] || "docs/TaskList.md"

    Mix.shell().info("Validating #{path}...")

    # Check if the file exists
    if !File.exists?(path) do
      Mix.shell().error("Error: File #{path} not found!")
      exit({:shutdown, 1})
    end

    # Use the TaskValidator module
    case TaskValidator.validate_file(path) do
      {:ok, message} ->
        Mix.shell().info(message)
        Mix.shell().info("✅ TaskList validation successful!")
        :ok

      {:error, reason} ->
        Mix.shell().error(reason)
        Mix.shell().error("❌ TaskList validation failed!")
        exit({:shutdown, 1})
    end
  end
end
