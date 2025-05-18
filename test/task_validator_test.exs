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
    **Status**: In Progress
    **Priority**: High

    #### 1. First subtask (SSH0001-1)
    **Test-First Approach**: Test first
    **Simplicity Constraints**: Keep it simple
    **Implementation**: Implement it
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
    **Status**: In Progress
    **Priority**: High

    #### 1. First subtask (SSH0001-1)
    **Test-First Approach**: Test first
    **Simplicity Constraints**: Keep it simple
    **Implementation**: Implement it
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
    **Status**: Completed
    **Review Rating**: 6.0
    """

    File.write!(tasklist_path, content)

    assert {:error, error_message} = TaskValidator.validate_file(tasklist_path)
    assert error_message =~ "invalid review rating format"
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
    **Priority**: High

    #### 1. First subtask (SSH0001-1)
    **Test-First Approach**: Test first
    **Simplicity Constraints**: Keep it simple
    **Implementation**: Implement it
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
  end
end
