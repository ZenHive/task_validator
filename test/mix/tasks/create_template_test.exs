defmodule Mix.Tasks.TaskValidator.CreateTemplateTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.TaskValidator.CreateTemplate

  setup do
    # Ensure we start with the default shell
    Mix.shell(Mix.Shell.IO)
    :ok
  end

  @tag :tmp_dir
  test "creates a valid task list with default prefix", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "default_prefix.md")

    # Run the task with otp_genserver category for expected numbers
    CreateTemplate.run(["--path", path, "--category", "otp_genserver"])

    # Verify file was created
    assert File.exists?(path)

    # Read the content and verify default prefix
    content = File.read!(path)
    assert content =~ "PRJ0001"
    assert content =~ "PRJ0002"
    assert content =~ "PRJ0003"

    # Verify template passes validation
    assert {:ok, _} = TaskValidator.validate_file(path)
  end

  @tag :tmp_dir
  test "creates a valid task list with custom prefix", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "custom_prefix.md")

    # Run the task with custom prefix and otp_genserver category
    CreateTemplate.run(["--path", path, "--prefix", "TST", "--category", "otp_genserver"])

    # Verify file was created
    assert File.exists?(path)

    # Read the content and verify custom prefix
    content = File.read!(path)
    assert content =~ "TST0001"
    assert content =~ "TST0002"
    assert content =~ "TST0003"

    # Verify template passes validation
    assert {:ok, _} = TaskValidator.validate_file(path)
  end

  @tag :tmp_dir
  test "handles existing file with overwrite confirmation", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "existing.md")

    # Create initial file
    File.write!(path, "Original content")

    # Mock Mix.shell()
    Mix.shell(Mix.Shell.Process)
    send(self(), {:mix_shell_input, :yes?, true})

    # Run the task with otp_genserver category
    CreateTemplate.run(["--path", path, "--category", "otp_genserver"])

    # Verify file was overwritten
    content = File.read!(path)
    assert content =~ "Project Task List"
    assert {:ok, _} = TaskValidator.validate_file(path)

    # Reset shell
    Mix.shell(Mix.Shell.IO)
  end

  @tag :tmp_dir
  test "respects no to overwrite prompt", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "no_overwrite.md")
    original = "Original content"

    # Create initial file
    File.write!(path, original)

    # Mock Mix.shell()
    Mix.shell(Mix.Shell.Process)
    send(self(), {:mix_shell_input, :yes?, false})

    # Run the task - should exit normally
    catch_exit(CreateTemplate.run(["--path", path]))

    # Verify file was not changed
    assert File.read!(path) == original

    # Reset shell
    Mix.shell(Mix.Shell.IO)
  end

  @tag :tmp_dir
  test "validates generated template structure", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "structure.md")

    # Run the task with otp_genserver category
    CreateTemplate.run(["--path", path, "--category", "otp_genserver"])

    # Read the content
    content = File.read!(path)

    # Verify required sections
    assert content =~ "## Current Tasks"
    assert content =~ "## Completed Tasks"
    assert content =~ "## Active Task Details"

    # Verify task details format
    assert content =~ "**Description**"
    assert content =~ "**Simplicity Progression Plan**"
    assert content =~ "**Status**"
    assert content =~ "**Priority**"

    # Verify OTP-specific sections
    assert content =~ "**Process Design**"
    assert content =~ "**State Management**"
    assert content =~ "**Supervision Strategy**"
    assert content =~ "{{otp-error-handling}}"
  end

  @tag :tmp_dir
  test "handles invalid path", %{tmp_dir: tmp_dir} do
    path = Path.join([tmp_dir, "invalid", "nonexistent", "path.md"])

    # Run the task with invalid path - should exit with error
    assert catch_exit(CreateTemplate.run(["--path", path])) == {:shutdown, 1}
  end
end
