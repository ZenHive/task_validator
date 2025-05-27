defmodule TaskValidatorTest do
  use ExUnit.Case, async: true
  alias TaskValidator

  @temp_dir "test/fixtures/temp"

  setup do
    File.mkdir_p!(@temp_dir)
    on_exit(fn -> File.rm_rf!(@temp_dir) end)
    :ok
  end

  test "validate_file/1 with valid tasklist" do
    tasklist_path = "#{@temp_dir}/valid_tasklist.md"
    File.write!(tasklist_path, valid_tasklist_content())

    assert {:ok, _message} = TaskValidator.validate_file(tasklist_path)
  end

  test "validate_file/1 with checkbox subtasks" do
    assert {:ok, _message} = TaskValidator.validate_file("test/fixtures/checkbox_subtasks.md")
  end

  test "validate_file/1 with task dependencies" do
    assert {:ok, _message} = TaskValidator.validate_file("test/fixtures/task_dependencies.md")
  end

  test "validate_file/1 with invalid dependencies" do
    assert {:error, "Task TSK0001 has invalid dependencies: TSK9999"} =
             TaskValidator.validate_file("test/fixtures/invalid_dependencies.md")
  end

  test "validate_file/1 with reference definitions" do
    assert {:ok, _message} = TaskValidator.validate_file("test/fixtures/reference_test.md")
  end

  test "validate_file/1 with missing references" do
    assert {:error, message} = TaskValidator.validate_file("test/fixtures/missing_references.md")
    assert message =~ "Missing reference definitions"
    assert message =~ "non-existent-reference"
    assert message =~ "another-missing-ref"
  end

  test "validate_file/1 accepts reference placeholders as valid content" do
    assert {:ok, _message} = TaskValidator.validate_file("test/fixtures/full_references.md")
  end

  test "validate_file/1 validates reference definition format" do
    # Test that reference definitions must start with ## {{
    tasklist_path = "#{@temp_dir}/invalid_ref_format.md"

    content = """
    # Task List

    ## Current Tasks
    | ID | Description | Status | Priority |
    | --- | --- | --- | --- |
    | TST0001 | Test task | Planned | High |

    ## Task Details

    ### TST0001: Test task
    **Description**: Test
    **Simplicity Progression Plan**: Plan
    **Simplicity Principle**: Simple
    **Abstraction Evaluation**: Low
    **Requirements**: Test
    {{test-requirements}}
    {{error-handling}}
    {{standard-kpis}}
    {{def-no-dependencies}}
    **Status**: Planned
    **Priority**: High

    # Invalid reference definition (should be ##)
    # {{test-requirements}}
    Test content

    ## {{error-handling}}
    **Error Handling**
    **Core Principles**
    - Pass raw errors

    ## {{standard-kpis}}
    - Functions per module: 5

    ## {{def-no-dependencies}}
    None
    """

    File.write!(tasklist_path, content)

    assert {:error, message} = TaskValidator.validate_file(tasklist_path)
    assert message =~ "Missing reference definitions"
    assert message =~ "test-requirements"
  end

  test "validate_file/1 accepts multiple reference formats" do
    # Test various valid reference formats like {{name}} and {{def-name}}
    tasklist_path = "#{@temp_dir}/multi_ref_formats.md"

    content = """
    # Task List

    ## Current Tasks
    | ID | Description | Status | Priority |
    | --- | --- | --- | --- |
    | TST0001 | Test task | In Progress | High |

    ## Task Details

    ### TST0001: Test task with multiple reference formats
    **Description**: Test various reference formats
    **Simplicity Progression Plan**: Plan
    **Simplicity Principle**: Simple
    **Abstraction Evaluation**: Low
    **Requirements**: Test
    {{test-requirements}}
    {{typespec-requirements}}
    {{def-error-handling}}
    {{standard-kpis}}
    {{DEF:no-dependencies}}
    **Architecture Notes**: Simple architecture
    **Complexity Assessment**: Low complexity
    **Status**: In Progress
    **Priority**: High

    #### 1. Subtask (TST0001-1)
    **Description**: Test subtask
    {{error-handling}}
    **Status**: In Progress

    ## {{test-requirements}}
    **ExUnit Test Requirements**: Tests
    **Integration Test Scenarios**: Scenarios

    ## {{def-error-handling}}
    **Error Handling**
    **Core Principles**
    - Errors
    **Error Implementation**
    - Implementation
    **Error Examples**
    - Examples
    **GenServer Specifics**
    - GenServer
    **Task-Specific Approach**
    - Task approach
    **Error Reporting**
    - Reporting

    ## {{error-handling}}
    **Error Handling**
    **Task-Specific Approach**
    - Subtask approach
    **Error Reporting**
    - Subtask reporting

    ## {{typespec-requirements}}
    **Typespec Requirements**: Specs
    **TypeSpec Documentation**: Docs
    **TypeSpec Verification**: Verify

    ## {{standard-kpis}}
    - Functions per module: 5

    ## {{DEF:no-dependencies}}
    None
    """

    File.write!(tasklist_path, content)

    assert {:ok, _message} = TaskValidator.validate_file(tasklist_path)
  end

  test "validate_file/1 handles reference placeholders in required sections" do
    # Test that validator accepts references in place of required content
    tasklist_path = "#{@temp_dir}/ref_in_sections.md"

    content = """
    # Task List

    ## Current Tasks
    | ID | Description | Status | Priority |
    | --- | --- | --- | --- |
    | TST0001 | Test task | Planned | High |

    ## Task Details

    ### TST0001: Test references in sections
    **Description**: Test references replacing entire sections
    **Simplicity Progression Plan**: Plan
    **Simplicity Principle**: Simple
    **Abstraction Evaluation**: Low
    **Requirements**: Test
    {{test-requirements}}
    {{typespec-requirements}}
    {{error-handling}}
    {{standard-kpis}}
    {{def-no-dependencies}}
    **Architecture Notes**: Simple architecture
    **Complexity Assessment**: Low complexity
    **Status**: Planned
    **Priority**: High

    ## {{test-requirements}}
    **ExUnit Test Requirements**: Unit tests
    **Integration Test Scenarios**: Integration tests

    ## {{typespec-requirements}}
    **Typespec Requirements**: Specs
    **TypeSpec Documentation**: Docs
    **TypeSpec Verification**: Verify

    ## {{error-handling}}
    **Error Handling**
    **Core Principles**
    - Pass raw errors
    **Error Implementation**
    - No wrapping
    **Error Examples**
    - Examples
    **GenServer Specifics**
    - GenServer

    ## {{standard-kpis}}
    - Functions per module: 5
    - Lines per function: 15
    - Call depth: 2

    ## {{def-no-dependencies}}
    None
    """

    File.write!(tasklist_path, content)

    assert {:ok, _message} = TaskValidator.validate_file(tasklist_path)
  end

  test "validate_file/1 validates reference usage consistency" do
    # Test that used references must have corresponding definitions
    tasklist_path = "#{@temp_dir}/ref_consistency.md"

    content = """
    # Task List

    ## Current Tasks
    | ID | Description | Status | Priority |
    | --- | --- | --- | --- |
    | TST0001 | Test task | Planned | High |

    ## Task Details

    ### TST0001: Test reference consistency
    **Description**: Test
    **Simplicity Progression Plan**: Plan
    **Simplicity Principle**: Simple
    **Abstraction Evaluation**: Low
    **Requirements**: Test
    {{test-requirements}}
    {{error-handling}}
    {{standard-kpis}}
    {{undefined-ref}}
    {{another-undefined}}
    **Status**: Planned
    **Priority**: High

    ## {{test-requirements}}
    **ExUnit Test Requirements**: Tests
    **Integration Test Scenarios**: Tests

    ## {{error-handling}}
    **Error Handling**
    **Core Principles**
    - Errors
    **Error Implementation**
    - Implementation
    **Error Examples**
    - Examples
    **GenServer Specifics**
    - GenServer

    ## {{standard-kpis}}
    - Functions per module: 5
    """

    File.write!(tasklist_path, content)

    assert {:error, message} = TaskValidator.validate_file(tasklist_path)
    assert message =~ "Missing reference definitions"
    assert message =~ "undefined-ref"
    assert message =~ "another-undefined"
  end

  test "validate_file/1 handles nested reference placeholders correctly" do
    # Test references within task and subtask content
    tasklist_path = "#{@temp_dir}/nested_refs.md"

    content = """
    # Task List

    ## Current Tasks
    | ID | Description | Status | Priority |
    | --- | --- | --- | --- |
    | TST0001 | Test nested refs | In Progress | High |

    ## Task Details

    ### TST0001: Test nested references
    **Description**: Test references in various locations
    **Simplicity Progression Plan**: {{simple-plan}}
    **Simplicity Principle**: {{simple-principle}}
    **Abstraction Evaluation**: Low
    **Requirements**: {{requirements}}
    {{test-requirements}}
    {{typespec-requirements}}
    {{error-handling}}
    {{standard-kpis}}
    {{def-no-dependencies}}
    **Architecture Notes**: Simple architecture
    **Complexity Assessment**: Low complexity
    **Status**: In Progress
    **Priority**: High

    #### 1. Subtask with refs (TST0001-1)
    **Description**: {{subtask-desc}}
    {{error-handling-subtask}}
    **Status**: In Progress

    ## {{simple-plan}}
    Progressive simplicity plan

    ## {{simple-principle}}
    Keep it simple principle

    ## {{requirements}}
    - Requirement 1
    - Requirement 2

    ## {{subtask-desc}}
    Subtask description content

    ## {{test-requirements}}
    **ExUnit Test Requirements**: Tests
    **Integration Test Scenarios**: Scenarios

    ## {{error-handling}}
    **Error Handling**
    **Core Principles**
    - Pass raw errors
    **Error Implementation**
    - No wrapping
    **Error Examples**
    - Examples
    **GenServer Specifics**
    - GenServer

    ## {{error-handling-subtask}}
    **Error Handling**
    **Task-Specific Approach**
    - Approach
    **Error Reporting**
    - Reporting

    ## {{typespec-requirements}}
    **Typespec Requirements**: Specs
    **TypeSpec Documentation**: Docs
    **TypeSpec Verification**: Verify

    ## {{standard-kpis}}
    - Functions per module: 5

    ## {{def-no-dependencies}}
    None
    """

    File.write!(tasklist_path, content)

    assert {:ok, _message} = TaskValidator.validate_file(tasklist_path)
  end

  test "validate_file/1 with missing task details" do
    tasklist_path = "#{@temp_dir}/missing_details.md"

    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Task with no details | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "missing detailed entries"
  end

  test "validate_file/1 with invalid task ID format" do
    tasklist_path = "#{@temp_dir}/invalid_id.md"

    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | INVALID | Task with invalid ID | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "Invalid task ID format"
  end

  test "validate_file/1 with duplicate task IDs" do
    tasklist_path = "#{@temp_dir}/duplicate_ids.md"

    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | First task | In Progress | High | - | - |
    | SSH0001 | Duplicate ID | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "Duplicate task IDs found"
  end

  test "validate_file/1 with missing required sections" do
    tasklist_path = "#{@temp_dir}/missing_sections.md"

    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Task missing sections | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |

    ## Active Task Details

    ### SSH0001: Task missing sections
    **Description**: This task is missing required sections
    **Status**: In Progress
    **Priority**: High
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "missing required sections"
  end

  test "validate_file/1 with invalid status value" do
    tasklist_path = "#{@temp_dir}/invalid_status.md"

    # Copy the valid content but change the status to an invalid value
    content =
      valid_tasklist_content()
      |> String.replace("**Status**: In Progress", "**Status**: Invalid Status")

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "invalid status"
  end

  test "validate_file/1 with 'In Progress' task but no subtasks" do
    tasklist_path = "#{@temp_dir}/no_subtasks.md"

    # Create a valid task with In Progress status but no subtasks
    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Task with no subtasks | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |

    ## Active Task Details

    ### SSH0001: Task with no subtasks
    **Description**: This task has no subtasks
    **Simplicity Progression Plan**: Progressive simplicity plan
    **Simplicity Principle**: Design this project with simplicity as the guiding principle. Identify and eliminate unnecessary features, workflows, and dependencies. Focus on core functionality that delivers maximum value with minimal complexity. Optimize for maintainability by reducing moving parts rather than adding layers.
    **Abstraction Evaluation**: Abstraction justification
    **Requirements**: Functional requirements
    **ExUnit Test Requirements**: Unit test requirements
    **Integration Test Scenarios**: Integration test requirements
    **Typespec Requirements**: Type specifications for public functions
    **TypeSpec Documentation**: Documentation for type specifications
    **TypeSpec Verification**: Verification approach for typespecs
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
    **Dependencies**: None
    **Code Quality KPIs**
    - Functions per module: 3
    - Lines per function: 12
    - Call depth: 2
    **Architecture Notes**: Simple task implementation
    **Complexity Assessment**: Low - Basic task structure
    **Status**: In Progress
    **Priority**: High
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "in progress but has no subtasks"
  end

  test "validate_file/1 with subtask missing required sections" do
    tasklist_path = "#{@temp_dir}/subtask_missing_sections.md"

    # Create task with subtask missing status
    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Task with subtask missing sections | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |

    ## Active Task Details

    ### SSH0001: Task with subtask missing sections
    **Description**: This task has a subtask missing sections
    **Simplicity Progression Plan**: Progressive simplicity plan
    **Simplicity Principle**: Design this project with simplicity as the guiding principle. Identify and eliminate unnecessary features, workflows, and dependencies. Focus on core functionality that delivers maximum value with minimal complexity. Optimize for maintainability by reducing moving parts rather than adding layers.
    **Abstraction Evaluation**: Abstraction justification
    **Requirements**: Functional requirements
    **ExUnit Test Requirements**: Unit test requirements
    **Integration Test Scenarios**: Integration test requirements
    **Typespec Requirements**: Type specifications for public functions
    **TypeSpec Documentation**: Documentation for type specifications
    **TypeSpec Verification**: Verification approach for typespecs
    **Status**: In Progress
    **Priority**: High
    **Code Quality KPIs**
    - Functions per module: 3
    - Lines per function: 12
    - Call depth: 2
    **Dependencies**
    - None

    #### 1. First subtask (SSH0001-1)
    **Test-First Approach**: Test first
    **Simplicity Constraints**: Keep it simple
    **Implementation**: Implement it
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "missing required sections"
  end

  test "validate_file/1 with completed subtask missing review rating" do
    tasklist_path = "#{@temp_dir}/missing_rating.md"

    # Create task with completed subtask missing review rating
    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Task with completed subtask missing rating | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |

    ## Active Task Details

    ### SSH0001: Task with completed subtask missing rating
    **Description**: This task has a completed subtask missing review rating
    **Simplicity Progression Plan**: Progressive simplicity plan
    **Simplicity Principle**: Design this project with simplicity as the guiding principle. Identify and eliminate unnecessary features, workflows, and dependencies. Focus on core functionality that delivers maximum value with minimal complexity. Optimize for maintainability by reducing moving parts rather than adding layers.
    **Abstraction Evaluation**: Abstraction justification
    **Requirements**: Functional requirements
    **ExUnit Test Requirements**: Unit test requirements
    **Integration Test Scenarios**: Integration test requirements
    **Typespec Requirements**: Type specifications for public functions
    **TypeSpec Documentation**: Documentation for type specifications
    **TypeSpec Verification**: Verification approach for typespecs
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
    **Dependencies**: None
    **Code Quality KPIs**
    - Functions per module: 3
    - Lines per function: 12
    - Call depth: 2
    **Architecture Notes**: Simple task implementation
    **Complexity Assessment**: Low - Basic task structure
    **Status**: In Progress
    **Priority**: High

    #### 1. First subtask (SSH0001-1)
    **Test-First Approach**: Test first
    **Simplicity Constraints**: Keep it simple
    **Implementation**: Implement it
    **Error Handling**
    **Task-Specific Approach**
    - Error pattern for this task
    **Error Reporting**
    - Monitoring approach
    **Status**: Completed
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "missing review rating"
  end

  test "validate_file/1 with invalid review rating format" do
    tasklist_path = "#{@temp_dir}/invalid_rating.md"

    # Create task with completed subtask having invalid rating format
    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Task with invalid rating format | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |

    ## Active Task Details

    ### SSH0001: Task with invalid rating format
    **Description**: This task has a completed subtask with invalid rating format
    **Simplicity Progression Plan**: Progressive simplicity plan
    **Simplicity Principle**: Design this project with simplicity as the guiding principle. Identify and eliminate unnecessary features, workflows, and dependencies. Focus on core functionality that delivers maximum value with minimal complexity. Optimize for maintainability by reducing moving parts rather than adding layers.
    **Abstraction Evaluation**: Abstraction justification
    **Requirements**: Functional requirements
    **ExUnit Test Requirements**: Unit test requirements
    **Integration Test Scenarios**: Integration test requirements
    **Typespec Requirements**: Type specifications for public functions
    **TypeSpec Documentation**: Documentation for type specifications
    **TypeSpec Verification**: Verification approach for typespecs
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
    **Code Quality KPIs**
    - Functions per module: 3
    - Lines per function: 12
    - Call depth: 2
    **Dependencies**
    - None
    **Architecture Notes**
    Core system architecture implementation
    **Complexity Assessment**
    Medium - Requires careful design
    **Status**: In Progress
    **Priority**: High

    #### 1. First subtask (SSH0001-1)
    **Test-First Approach**: Test first
    **Simplicity Constraints**: Keep it simple
    **Implementation**: Implement it
    **Error Handling**
    **Task-Specific Approach**
    - Error pattern for this task
    **Error Reporting**
    - Monitoring approach
    **Status**: Completed
    **Review Rating**: 6.0
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "invalid review rating format"
  end

  test "validate_file/1 with new task error handling format" do
    tasklist_path = "#{@temp_dir}/new_error_handling_format.md"

    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Main task with new format | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |

    ## Active Task Details

    ### SSH0001: Main task with new format

    **Description**: Test task for new error handling format
    **Simplicity Progression Plan**: Simple plan
    **Simplicity Principle**: Keep it simple
    **Abstraction Evaluation**: Low
    **Requirements**: Testing requirements
    **ExUnit Test Requirements**: Unit tests
    **Integration Test Scenarios**: Integration tests
    **Typespec Requirements**: Type specs
    **TypeSpec Documentation**: Documentation
    **TypeSpec Verification**: Verification
    **Dependencies**: None
    **Code Quality KPIs**
    - Functions per module: 3
    - Lines per function: 12
    - Call depth: 2
    **Architecture Notes**: Simple task implementation
    **Complexity Assessment**: Low - Basic task structure
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
    **Status**: In Progress
    **Priority**: High

    #### 1. First subtask (SSH0001-1)

    **Description**: First subtask
    **Error Handling**
    **Task-Specific Approach**
    - Error pattern for this task
    **Error Reporting**
    - Monitoring approach
    **Status**: In Progress
    """

    File.write!(tasklist_path, content)

    assert {:ok, _message} = TaskValidator.validate_file(tasklist_path)
  end

  test "validate_file/1 fails with main task using subtask error format" do
    tasklist_path = "#{@temp_dir}/main_task_wrong_format.md"

    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Main task with wrong format | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |

    ## Active Task Details

    ### SSH0001: Main task with wrong format

    **Description**: Test task with wrong error handling format
    **Simplicity Progression Plan**: Simple plan
    **Simplicity Principle**: Keep it simple
    **Abstraction Evaluation**: Low
    **Requirements**: Testing requirements
    **ExUnit Test Requirements**: Unit tests
    **Integration Test Scenarios**: Integration tests
    **Typespec Requirements**: Type specs
    **TypeSpec Documentation**: Documentation
    **TypeSpec Verification**: Verification
    **Error Handling**
    **Task-Specific Approach**
    - Error pattern for this task
    **Error Reporting**
    - Monitoring approach
    **Status**: In Progress
    **Priority**: High
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "missing required sections"
  end

  test "validate_file/1 fails with subtask using main task error format" do
    tasklist_path = "#{@temp_dir}/subtask_wrong_format.md"

    content = """
    # SSHForge Task List

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Main task with subtask using wrong format | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |

    ## Active Task Details

    ### SSH0001: Main task with subtask using wrong format

    **Description**: Test task for subtask with wrong format
    **Simplicity Progression Plan**: Simple plan
    **Simplicity Principle**: Keep it simple
    **Abstraction Evaluation**: Low
    **Requirements**: Testing requirements
    **ExUnit Test Requirements**: Unit tests
    **Integration Test Scenarios**: Integration tests
    **Typespec Requirements**: Type specs
    **TypeSpec Documentation**: Documentation
    **TypeSpec Verification**: Verification
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
    **Status**: In Progress
    **Priority**: High

    #### 1. First subtask (SSH0001-1)

    **Description**: Subtask with wrong format
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
    **Status**: In Progress
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "missing required sections"
  end

  test "all valid fixture files pass validation" do
    # Get all fixture files that should be valid (not starting with "invalid_", ending with "_mismatch", or containing "missing_")
    fixture_dir = "test/fixtures"
    
    valid_fixtures = 
      File.ls!(fixture_dir)
      |> Enum.filter(&String.ends_with?(&1, ".md"))
      |> Enum.reject(&String.starts_with?(&1, "invalid_"))
      |> Enum.reject(&String.ends_with?(&1, "_mismatch.md"))
      |> Enum.reject(&String.contains?(&1, "missing_"))
      |> Enum.map(&Path.join(fixture_dir, &1))
    
    # Ensure we have some valid fixtures to test
    assert length(valid_fixtures) > 0, "No valid fixture files found"
    
    # Test each valid fixture file
    for fixture_path <- valid_fixtures do
      case TaskValidator.validate_file(fixture_path) do
        {:ok, _message} -> 
          # Test passed, continue
          :ok
        {:error, error_message} ->
          flunk("Valid fixture file #{fixture_path} failed validation: #{error_message}")
      end
    end
  end

  defp valid_tasklist_content do
    """
    # SSHForge Task List

    ## Integration Test Setup Notes
    Brief integration testing reminders

    ## Simplicity Guidelines for All Tasks
    Simplicity principles and requirements

    ## Current Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0001 | Valid task | In Progress | High | - | - |

    ## Completed Tasks
    | ID | Description | Status | Priority | Assignee | Review Rating |
    | --- | --- | --- | --- | --- | --- |
    | SSH0002 | Completed task | Completed | Medium | - | 4.5 |

    ## Active Task Details

    ### SSH0001: Valid task
    **Description**: This is a valid task description
    **Simplicity Progression Plan**: Progressive simplicity plan
    **Simplicity Principle**: Design this project with simplicity as the guiding principle. Identify and eliminate unnecessary features, workflows, and dependencies. Focus on core functionality that delivers maximum value with minimal complexity. Optimize for maintainability by reducing moving parts rather than adding layers.
    **Abstraction Evaluation**: Abstraction justification
    **Requirements**: Functional requirements
    **ExUnit Test Requirements**: Unit test requirements
    **Integration Test Scenarios**: Integration test requirements
    **Typespec Requirements**: Type specifications for public functions
    **TypeSpec Documentation**: Documentation for type specifications
    **TypeSpec Verification**: Verification approach for typespecs
    **Dependencies**
    - None
    **Code Quality KPIs**
    - Functions per module: 3
    - Lines per function: 12
    - Call depth: 2
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
    **Status**: In Progress
    **Priority**: High
    **Architecture Notes**
    Core authentication system design
    **Complexity Assessment**
    Medium - Multi-method authentication

    #### 1. First subtask (SSH0001-1)
    **Test-First Approach**: Test first
    **Simplicity Constraints**: Keep it simple
    **Implementation**: Implement it
    **Error Handling**
    **Task-Specific Approach**
    - Error pattern for this task
    **Error Reporting**
    - Monitoring approach
    **Status**: In Progress

    ## Completed Task Details

    ### SSH0002: Completed task
    **Description**: This is a completed task
    **Simplicity Progression Plan**: Simple plan
    **Simplicity Principle**: Keep it simple
    **Abstraction Evaluation**: Low abstraction
    **Requirements**: Basic requirements
    **ExUnit Test Requirements**: Unit tests
    **Integration Test Scenarios**: Integration tests
    **Typespec Requirements**: Type specs
    **TypeSpec Documentation**: Type documentation
    **TypeSpec Verification**: Type verification
    **Status**: Completed
    **Priority**: Medium
    **Dependencies**: None
    **Code Quality KPIs**
    - Functions per module: 2
    - Lines per function: 10
    - Call depth: 1
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
    **Architecture Notes**
    Simple implementation
    **Complexity Assessment**
    Low - Basic structure
    **Error Handling Implementation**
    Standard error handling
    **Implementation Notes**
    Basic implementation complete
    **Maintenance Impact**
    Minimal
    **Review Rating**: 4.5
    """
  end
end
