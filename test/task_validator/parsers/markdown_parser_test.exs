defmodule TaskValidator.Parsers.MarkdownParserTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Core.TaskList
  alias TaskValidator.Parsers.MarkdownParser

  describe "parse/1" do
    test "parses a simple markdown task list" do
      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority | Assignee | Review Rating |
      | --- | --- | --- | --- | --- | --- |
      | TST001 | Test task | Planned | High | - | - |

      ## Task Details

      ### TST001: Test task
      **Description**
      A simple test task

      **Status**
      Planned

      **Priority**
      High
      """

      assert {:ok, %TaskList{} = task_list} = MarkdownParser.parse(content)
      assert length(task_list.tasks) == 1

      task = hd(task_list.tasks)
      assert task.id == "TST001"
      # Description comes from detailed section
      assert task.description == "A simple test task"
      assert task.status == "Planned"
      assert task.priority == "High"
      assert task.type == :main
    end

    test "parses tasks with subtasks" do
      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority | Assignee | Review Rating |
      | --- | --- | --- | --- | --- | --- |
      | TST001 | Main task | In Progress | High | - | - |

      ## Task Details

      ### TST001: Main task
      **Description**
      Main task with subtasks

      **Status**
      In Progress

      #### 1. Subtask one (TST001-1)
      **Description**
      First subtask

      **Status**
      Completed

      - [x] Checkbox subtask [TST001a]
      - [ ] Another checkbox subtask [TST001b]
      """

      assert {:ok, %TaskList{} = task_list} = MarkdownParser.parse(content)
      assert length(task_list.tasks) == 1

      task = hd(task_list.tasks)
      assert task.id == "TST001"
      assert length(task.subtasks) == 3

      # Check numbered subtask
      numbered_subtask = Enum.find(task.subtasks, &(&1.id == "TST001-1"))
      assert numbered_subtask.type == :subtask
      assert numbered_subtask.status == "Completed"

      # Check checkbox subtasks
      checkbox_subtask_a = Enum.find(task.subtasks, &(&1.id == "TST001a"))
      assert checkbox_subtask_a.type == :subtask
      assert checkbox_subtask_a.status == "Completed"

      checkbox_subtask_b = Enum.find(task.subtasks, &(&1.id == "TST001b"))
      assert checkbox_subtask_b.type == :subtask
      assert checkbox_subtask_b.status == "Planned"
    end

    test "extracts references" do
      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority |
      | --- | --- | --- | --- |
      | TST001 | Task with reference | Planned | High |

      Task content with \{\{test-reference\}\}

      ## #\{\{test-reference\}\}
      This is a test reference
      """

      assert {:ok, %TaskList{} = task_list} = MarkdownParser.parse(content)
      assert Map.has_key?(task_list.references, "test-reference")
      assert task_list.references["test-reference"] == ["This is a test reference", ""]
    end

    test "validates references" do
      lines = ["Line with \{\{valid-ref\}\}", "Line with \{\{invalid-ref\}\}"]
      references = %{"valid-ref" => ["content"]}

      assert {:error, error_msg} = MarkdownParser.validate_references(lines, references)
      assert String.contains?(error_msg, "invalid-ref")
    end
  end

  describe "extract_references/1" do
    test "extracts reference definitions" do
      lines = [
        "# Title",
        "## #\{\{test-ref\}\}",
        "Reference content line 1",
        "Reference content line 2",
        "## #\{\{another-ref\}\}",
        "Another reference content"
      ]

      assert {:ok, references} = MarkdownParser.extract_references(lines)
      assert Map.has_key?(references, "test-ref")
      assert Map.has_key?(references, "another-ref")
      assert references["test-ref"] == ["Reference content line 1", "Reference content line 2"]
      assert references["another-ref"] == ["Another reference content"]
    end
  end

  describe "extract_tasks/1" do
    test "extracts tasks from tables and detailed sections" do
      lines = [
        "## Current Tasks",
        "| ID | Description | Status | Priority |",
        "| --- | --- | --- | --- |",
        "| TST001 | Test task | Planned | High |",
        "",
        "## Task Details",
        "### TST001: Test task",
        "**Description**",
        "Detailed description"
      ]

      assert {:ok, tasks} = MarkdownParser.extract_tasks(lines)
      assert length(tasks) == 1

      task = hd(tasks)
      assert task.id == "TST001"
      # From detailed section
      assert task.description == "Detailed description"
      assert task.status == "Planned"
      assert task.priority == "High"
      assert length(task.content) > 0
    end

    test "handles custom ID formats" do
      lines = [
        "## Current Tasks",
        "| ID | Description | Status | Priority |",
        "| --- | --- | --- | --- |",
        "| PROJ-0001 | Custom ID task | Planned | High |",
        "",
        "## Task Details",
        "### PROJ-0001: Custom ID task",
        "**Description**",
        "Custom ID format task"
      ]

      assert {:ok, tasks} = MarkdownParser.extract_tasks(lines)
      assert length(tasks) == 1

      task = hd(tasks)
      assert task.id == "PROJ-0001"
      assert task.type == :main
      assert task.prefix == "PROJ"
    end

    test "returns error when no tasks found" do
      lines = ["# Empty task list"]

      assert {:error, "No tasks found in the document"} = MarkdownParser.extract_tasks(lines)
    end

    test "extracts subtask content correctly" do
      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority |
      | --- | --- | --- | --- |
      | TST002 | Task with detailed subtasks | In Progress | High |

      ## Task Details

      ### TST002: Task with detailed subtasks
      **Description**
      Testing subtask content extraction

      **Status**
      In Progress

      #### 1. First subtask (TST002-1)
      **Description**
      First subtask with content

      **Status**
      In Progress

      **Error Handling**
      {{error-handling-subtask}}

      #### 2. Second subtask (TST002-2)
      **Description**
      Second subtask

      **Status**
      Planned

      **Error Handling**
      Custom error handling for this subtask

      #### 3. Last subtask (TST002-3)
      **Description**
      Last subtask to test edge case

      **Status**
      Completed
      """

      assert {:ok, %TaskList{} = task_list} = MarkdownParser.parse(content)
      task = hd(task_list.tasks)
      assert length(task.subtasks) == 3

      # Check first subtask content
      first_subtask = Enum.find(task.subtasks, &(&1.id == "TST002-1"))
      assert first_subtask.status == "In Progress"
      assert "**Description**" in first_subtask.content
      assert "First subtask with content" in first_subtask.content
      assert "{{error-handling-subtask}}" in first_subtask.content

      # Check second subtask content
      second_subtask = Enum.find(task.subtasks, &(&1.id == "TST002-2"))
      assert second_subtask.status == "Planned"
      assert "Custom error handling for this subtask" in second_subtask.content

      # Check last subtask (edge case)
      last_subtask = Enum.find(task.subtasks, &(&1.id == "TST002-3"))
      assert last_subtask.status == "Completed"
      assert "Last subtask to test edge case" in last_subtask.content
    end

    test "handles edge cases for subtask content extraction" do
      content = """
      # Task List

      ## Current Tasks
      | ID | Description | Status | Priority |
      | --- | --- | --- | --- |
      | TST003 | Edge case testing | In Progress | High |

      ## Task Details

      ### TST003: Edge case testing
      **Description**
      Testing edge cases

      #### 1. Empty subtask (TST003-1)
      #### 2. Subtask with only status (TST003-2)
      **Status**
      Completed

      #### 3. Mixed content subtask (TST003-3)
      Some text here
      **Status**
      In Progress
      More text
      **Error Handling**
      Error info

      - [x] Checkbox in between [TST003a]
      - [ ] Another checkbox [TST003b]

      #### 4. Last subtask before end (TST003-4)
      **Status**
      Planned
      This is the last numbered subtask
      """

      assert {:ok, %TaskList{} = task_list} = MarkdownParser.parse(content)
      task = hd(task_list.tasks)
      # 4 numbered + 2 checkbox
      assert length(task.subtasks) == 6

      # Empty subtask
      empty_subtask = Enum.find(task.subtasks, &(&1.id == "TST003-1"))
      assert empty_subtask.content == []
      # Default when no status found
      assert empty_subtask.status == "Planned"

      # Subtask with only status
      status_only = Enum.find(task.subtasks, &(&1.id == "TST003-2"))
      assert status_only.status == "Completed"
      assert length(status_only.content) > 0

      # Mixed content subtask
      mixed_subtask = Enum.find(task.subtasks, &(&1.id == "TST003-3"))
      assert mixed_subtask.status == "In Progress"
      assert "Some text here" in mixed_subtask.content
      assert "More text" in mixed_subtask.content
      assert "Error info" in mixed_subtask.content
      # Should not include checkbox lines
      refute Enum.any?(mixed_subtask.content, &String.contains?(&1, "[TST003a]"))

      # Last subtask
      last_subtask = Enum.find(task.subtasks, &(&1.id == "TST003-4"))
      assert last_subtask.status == "Planned"
      assert "This is the last numbered subtask" in last_subtask.content
    end
  end
end
