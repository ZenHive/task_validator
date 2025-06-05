defmodule Mix.Tasks.TaskValidator do
  @shortdoc "Task validation utilities (run 'mix help task_validator' for commands)"

  @moduledoc """
  Task validation utilities for managing and validating structured task lists.

  TaskValidator provides tools for validating Markdown task lists against a structured 
  format specification, with enhanced support for Elixir/Phoenix projects.

  ## Available Commands

  ### Validation
      
      mix validate_tasklist [--path FILE]
      
  Validates a TaskList.md file against the format specification. 
  See `mix help validate_tasklist` for details.

  ### Template Generation

      mix task_validator.create_template [OPTIONS]
      
  Creates a new TaskList.md file with example tasks for different project categories.
  See `mix help task_validator.create_template` for details.

  ## Quick Start

      # Validate existing task list
      mix validate_tasklist
      
      # Create a new task list template
      mix task_validator.create_template
      
      # Create OTP-specific template with custom prefix
      mix task_validator.create_template --category otp_genserver --prefix GEN
      
      # Validate one of the example templates
      mix validate_tasklist --path docs/examples/phoenix_web_example.md

  ## Task List Format

  Task lists must include:
  - Current Tasks table
  - Completed Tasks table  
  - Detailed task sections with required fields
  - Proper subtask organization (numbered or checkbox format)
  - Error handling documentation
  - Code quality metrics

  ## Categories

  TaskValidator supports these project categories:
  - **otp_genserver** - OTP/GenServer development
  - **phoenix_web** - Phoenix web development  
  - **business_logic** - Phoenix contexts and domain logic
  - **data_layer** - Ecto schemas and database design
  - **infrastructure** - Deployment and DevOps
  - **testing** - Test implementation strategies

  ## Examples

  Complete working examples are available in `docs/examples/`:
  - `otp_genserver_example.md`
  - `phoenix_web_example.md`
  - `business_logic_example.md`
  - `data_layer_example.md`
  - `infrastructure_example.md`
  - `testing_example.md`

  ## Learn More

  - Run `mix help validate_tasklist` for validation details
  - Run `mix help task_validator.create_template` for template options
  - See `README.md` for comprehensive documentation
  - Check `docs/examples/README.md` for example explanations
  """

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info(@moduledoc)
  end
end
