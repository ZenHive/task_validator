defmodule TaskValidatorConfigurationTest do
  use ExUnit.Case

  @temp_dir "test/fixtures/temp"

  setup do
    File.mkdir_p!(@temp_dir)

    # Store original config
    original_config = Application.get_all_env(:task_validator)

    # Clear all task_validator configuration before each test
    for {key, _value} <- Application.get_all_env(:task_validator) do
      Application.delete_env(:task_validator, key)
    end

    on_exit(fn ->
      File.rm_rf!(@temp_dir)

      # Clear any test configuration
      for {key, _value} <- Application.get_all_env(:task_validator) do
        Application.delete_env(:task_validator, key)
      end

      # Restore original config
      Enum.each(original_config, fn {key, value} ->
        Application.put_env(:task_validator, key, value)
      end)
    end)

    :ok
  end

  describe "custom status configuration" do
    test "validates against custom valid_statuses" do
      # Set custom configuration
      Application.put_env(:task_validator, :valid_statuses, ["Todo", "Doing", "Done"])

      tasklist_path = "#{@temp_dir}/custom_status.md"

      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority | Assignee | Review Rating |
      | --- | --- | --- | --- | --- | --- |
      | TS0001 | Custom status task | Todo | High | - | - |

      ## Task Details

      ### TS0001: Custom status task
      **Description**
      A task using custom status values

      **Simplicity Progression Plan**
      1. Simple step

      **Simplicity Principle**
      Keep it simple

      **Abstraction Evaluation**
      Low abstraction

      **Requirements**
      - Basic requirement

      \{\{test-requirements\}\}
      \{\{typespec-requirements\}\}
      \{\{standard-kpis\}\}

      **Architecture Notes**
      Simple architecture

      **Complexity Assessment**
      Low complexity

      **Status**
      Todo

      **Priority**
      High

      **Dependencies**
      \{\{def-no-dependencies\}\}

      \{\{error-handling\}\}

      ## #\{\{test-requirements\}\}
      **ExUnit Test Requirements**:
      - Unit tests
      **Integration Test Scenarios**:
      - Basic tests

      ## #\{\{typespec-requirements\}\}
      **Typespec Requirements**:
      - Type specs
      **TypeSpec Documentation**:
      - Documentation
      **TypeSpec Verification**:
      - Verification

      ## #\{\{standard-kpis\}\}
      - Functions per module: 5 maximum
      - Lines per function: 15 maximum
      - Call depth: 2 maximum

      ## #\{\{def-no-dependencies\}\}
      None

      ## #\{\{error-handling\}\}
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
      """

      File.write!(tasklist_path, content)

      # Should pass with custom status
      assert {:ok, _} = TaskValidator.validate_file(tasklist_path)

      # Now change to invalid status
      invalid_content = String.replace(content, "Todo", "InvalidStatus")
      File.write!(tasklist_path, invalid_content)

      assert {:error, message} = TaskValidator.validate_file(tasklist_path)
      assert message =~ "invalid status"
    end
  end

  describe "custom priority configuration" do
    test "validates against custom valid_priorities" do
      Application.put_env(:task_validator, :valid_priorities, ["P0", "P1", "P2", "P3"])

      tasklist_path = "#{@temp_dir}/custom_priority.md"

      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority | Assignee | Review Rating |
      | --- | --- | --- | --- | --- | --- |
      | TS0001 | Custom priority task | Planned | P0 | - | - |

      ## Task Details

      ### TS0001: Custom priority task
      **Description**
      A task using custom priority values

      **Simplicity Progression Plan**
      1. Simple step

      **Simplicity Principle**
      Keep it simple

      **Abstraction Evaluation**
      Low abstraction

      **Requirements**
      - Basic requirement

      \{\{test-requirements\}\}
      \{\{typespec-requirements\}\}
      \{\{standard-kpis\}\}

      **Architecture Notes**
      Simple architecture

      **Complexity Assessment**
      Low complexity

      **Status**
      Planned

      **Priority**
      P0

      **Dependencies**
      None

      \{\{error-handling\}\}

      ## #\{\{test-requirements\}\}
      **ExUnit Test Requirements**:
      - Unit tests
      **Integration Test Scenarios**:
      - Basic tests

      ## #\{\{typespec-requirements\}\}
      **Typespec Requirements**:
      - Type specs
      **TypeSpec Documentation**:
      - Documentation
      **TypeSpec Verification**:
      - Verification

      ## #\{\{standard-kpis\}\}
      - Functions per module: 5 maximum
      - Lines per function: 15 maximum
      - Call depth: 2 maximum

      ## #\{\{error-handling\}\}
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
      """

      File.write!(tasklist_path, content)

      # Should pass with custom priority
      assert {:ok, _} = TaskValidator.validate_file(tasklist_path)

      # Now change to invalid priority
      invalid_content = String.replace(content, "P0", "InvalidPriority")
      File.write!(tasklist_path, invalid_content)

      assert {:error, message} = TaskValidator.validate_file(tasklist_path)
      assert message =~ "invalid priority"
    end
  end

  describe "custom KPI limits" do
    test "validates against custom KPI limits" do
      Application.put_env(:task_validator, :max_functions_per_module, 3)
      Application.put_env(:task_validator, :max_lines_per_function, 10)
      Application.put_env(:task_validator, :max_call_depth, 1)

      tasklist_path = "#{@temp_dir}/custom_kpis.md"

      # Content with KPIs that would pass default but fail custom limits
      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority | Assignee | Review Rating |
      | --- | --- | --- | --- | --- | --- |
      | TS0001 | KPI test task | Planned | High | - | - |

      ## Task Details

      ### TS0001: KPI test task
      **Description**
      Testing custom KPI limits

      **Simplicity Progression Plan**
      1. Simple step

      **Simplicity Principle**
      Keep it simple

      **Abstraction Evaluation**
      Low abstraction

      **Requirements**
      - Basic requirement

      \{\{test-requirements\}\}
      \{\{typespec-requirements\}\}

      **Code Quality KPIs**
      - Functions per module: 4 maximum
      - Lines per function: 12 maximum
      - Call depth: 2 maximum

      **Architecture Notes**
      Simple architecture

      **Complexity Assessment**
      Low complexity

      **Status**
      Planned

      **Priority**
      High

      **Dependencies**
      None

      \{\{error-handling\}\}

      ## #\{\{test-requirements\}\}
      **ExUnit Test Requirements**:
      - Unit tests
      **Integration Test Scenarios**:
      - Basic tests

      ## #\{\{typespec-requirements\}\}
      **Typespec Requirements**:
      - Type specs
      **TypeSpec Documentation**:
      - Documentation
      **TypeSpec Verification**:
      - Verification

      ## #\{\{error-handling\}\}
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
      """

      File.write!(tasklist_path, content)

      # Should fail with custom limits
      assert {:error, message} = TaskValidator.validate_file(tasklist_path)
      assert message =~ "exceeds max functions per module"

      # Fix the KPIs to pass custom limits
      fixed_content =
        content
        |> String.replace("Functions per module: 4", "Functions per module: 3")
        |> String.replace("Lines per function: 12", "Lines per function: 10")
        |> String.replace("Call depth: 2", "Call depth: 1")

      File.write!(tasklist_path, fixed_content)

      assert {:ok, _} = TaskValidator.validate_file(tasklist_path)
    end
  end

  describe "custom ID regex" do
    test "validates against custom ID pattern" do
      # Custom pattern: PROJ-NNNN format
      Application.put_env(:task_validator, :id_regex, ~r/^PROJ-\d{4}(-\d+)?$/)

      tasklist_path = "#{@temp_dir}/custom_id.md"

      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority | Assignee | Review Rating |
      | --- | --- | --- | --- | --- | --- |
      | PROJ-0001 | Custom ID task | Planned | High | - | - |

      ## Task Details

      ### PROJ-0001: Custom ID task
      **Description**
      Task with custom ID format

      **Simplicity Progression Plan**
      1. Simple step

      **Simplicity Principle**
      Keep it simple

      **Abstraction Evaluation**
      Low abstraction

      **Requirements**
      - Basic requirement

      \{\{test-requirements\}\}
      \{\{typespec-requirements\}\}
      \{\{standard-kpis\}\}

      **Architecture Notes**
      Simple architecture

      **Complexity Assessment**
      Low complexity

      **Status**
      Planned

      **Priority**
      High

      **Dependencies**
      None

      \{\{error-handling\}\}

      ## #\{\{test-requirements\}\}
      **ExUnit Test Requirements**:
      - Unit tests
      **Integration Test Scenarios**:
      - Basic tests

      ## #\{\{typespec-requirements\}\}
      **Typespec Requirements**:
      - Type specs
      **TypeSpec Documentation**:
      - Documentation
      **TypeSpec Verification**:
      - Verification

      ## #\{\{standard-kpis\}\}
      - Functions per module: 5 maximum
      - Lines per function: 15 maximum
      - Call depth: 2 maximum

      ## #\{\{error-handling\}\}
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
      """

      File.write!(tasklist_path, content)

      # Should pass with custom ID format
      assert {:ok, _} = TaskValidator.validate_file(tasklist_path)

      # Try with default format (should fail)
      invalid_content = String.replace(content, "PROJ-0001", "TSK0001")
      File.write!(tasklist_path, invalid_content)

      assert {:error, message} = TaskValidator.validate_file(tasklist_path)
      assert message =~ "Invalid task ID format"
    end
  end

  describe "custom category ranges" do
    test "validates against custom category ranges" do
      Application.put_env(:task_validator, :category_ranges, %{
        "backend" => {1000, 1999},
        "frontend" => {2000, 2999},
        "devops" => {3000, 3999}
      })

      tasklist_path = "#{@temp_dir}/custom_categories.md"

      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority | Assignee | Review Rating |
      | --- | --- | --- | --- | --- | --- |
      | API1001 | Backend task | Planned | High | - | - |

      ## Task Details

      ### API1001: Backend task
      **Description**
      Task in custom category range

      **Simplicity Progression Plan**
      1. Simple step

      **Simplicity Principle**
      Keep it simple

      **Abstraction Evaluation**
      Low abstraction

      **Requirements**
      - Basic requirement

      \{\{test-requirements\}\}
      \{\{typespec-requirements\}\}
      \{\{standard-kpis\}\}

      **Architecture Notes**
      Backend architecture

      **Complexity Assessment**
      Low complexity

      **Status**
      Planned

      **Priority**
      High

      **Dependencies**
      None

      \{\{error-handling\}\}

      ## #\{\{test-requirements\}\}
      **ExUnit Test Requirements**:
      - Unit tests
      **Integration Test Scenarios**:
      - Basic tests

      ## #\{\{typespec-requirements\}\}
      **Typespec Requirements**:
      - Type specs
      **TypeSpec Documentation**:
      - Documentation
      **TypeSpec Verification**:
      - Verification

      ## #\{\{standard-kpis\}\}
      - Functions per module: 5 maximum
      - Lines per function: 15 maximum
      - Call depth: 2 maximum

      ## #\{\{error-handling\}\}
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
      """

      File.write!(tasklist_path, content)

      # Should pass - task number 1001 is in backend range
      assert {:ok, _} = TaskValidator.validate_file(tasklist_path)

      # Try with number outside all ranges
      invalid_content = String.replace(content, "API1001", "API9999")
      File.write!(tasklist_path, invalid_content)

      assert {:error, message} = TaskValidator.validate_file(tasklist_path)
      assert message =~ "doesn't fit any defined category range"
    end
  end
end
