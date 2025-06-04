defmodule TaskValidator.Validators.IdValidatorTest do
  use ExUnit.Case, async: true

  alias TaskValidator.Core.Task
  alias TaskValidator.Core.ValidationResult
  alias TaskValidator.Validators.IdValidator

  describe "validate/2" do
    test "validates valid main task ID" do
      task = %Task{
        id: "SSH001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      assert %ValidationResult{valid?: true} = IdValidator.validate(task, context)
    end

    test "validates custom dash format main task ID" do
      task = %Task{
        id: "PROJ-001",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      assert %ValidationResult{valid?: true} = IdValidator.validate(task, context)
    end

    test "validates valid numbered subtask ID" do
      main_task = %Task{
        id: "SSH001",
        type: :main,
        description: "Main task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Subtask",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [main_task, subtask],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      assert %ValidationResult{valid?: true} = IdValidator.validate(subtask, context)
    end

    test "validates valid lettered subtask ID" do
      main_task = %Task{
        id: "SSH001",
        type: :main,
        description: "Main task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      subtask = %Task{
        id: "SSH001a",
        type: :subtask,
        description: "Subtask",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [main_task, subtask],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      assert %ValidationResult{valid?: true} = IdValidator.validate(subtask, context)
    end

    test "fails validation for invalid main task ID format" do
      task = %Task{
        id: "invalid123",
        type: :main,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_id_format
      assert String.contains?(error.message, "invalid123")
    end

    test "fails validation for invalid subtask ID format" do
      task = %Task{
        id: "SSH-invalid",
        type: :subtask,
        description: "Test task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: false} = result
      # Enhanced validation may find multiple ID issues - check for format error
      assert length(result.errors) >= 1

      format_error = Enum.find(result.errors, &(&1.type == :invalid_id_format))
      assert format_error != nil
      assert String.contains?(format_error.message, "SSH-invalid")
    end

    test "fails validation for duplicate task IDs" do
      task1 = %Task{
        id: "SSH001",
        type: :main,
        description: "First task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      task2 = %Task{
        id: "SSH001",
        type: :main,
        description: "Duplicate task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task1, task2],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(task1, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :duplicate_task_id
      assert String.contains?(error.message, "SSH001")
    end

    test "fails validation for subtask with non-existent parent" do
      subtask = %Task{
        id: "SSH001-1",
        type: :subtask,
        description: "Orphan subtask",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [subtask],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(subtask, context)
      assert %ValidationResult{valid?: false, errors: [error]} = result
      assert error.type == :invalid_subtask_id
      assert String.contains?(error.message, "SSH001")
    end

    test "warns about mixed prefixes" do
      task1 = %Task{
        id: "SSH001",
        type: :main,
        description: "SSH task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      task2 = %Task{
        id: "VAL001",
        type: :main,
        description: "VAL task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task1, task2],
        config: %{id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/}
      }

      result = IdValidator.validate(task1, context)
      assert %ValidationResult{valid?: true, warnings: [warning]} = result
      assert warning.type == :mixed_prefixes
      assert String.contains?(warning.message, "SSH, VAL")
    end
  end

  describe "validate/2 - semantic prefixes" do
    test "validates OTP task with correct category" do
      task = %Task{
        id: "OTP001",
        type: :main,
        category: :otp_genserver,
        description: "OTP task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{
          id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/,
          enable_semantic_prefixes: true,
          semantic_prefixes: %{
            "OTP" => :otp_genserver,
            "PHX" => :phoenix_web,
            "CTX" => :business_logic,
            "DB" => :data_layer
          }
        }
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: true} = result
      assert Enum.empty?(result.warnings)
    end

    test "warns about semantic prefix category mismatch" do
      task = %Task{
        id: "OTP001",
        type: :main,
        # Wrong category for OTP prefix
        category: :phoenix_web,
        description: "OTP task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{
          id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/,
          enable_semantic_prefixes: true,
          semantic_prefixes: %{
            "OTP" => :otp_genserver,
            "PHX" => :phoenix_web
          }
        }
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: true} = result
      assert length(result.warnings) == 1

      warning = hd(result.warnings)
      assert warning.type == :semantic_prefix_mismatch
      assert String.contains?(warning.message, "OTP")
      assert String.contains?(warning.message, "otp_genserver")
      assert String.contains?(warning.message, "phoenix_web")
    end

    test "warns about missing category for semantic prefix" do
      task = %Task{
        id: "PHX101",
        type: :main,
        # No category assigned
        category: nil,
        description: "Phoenix task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{
          id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/,
          enable_semantic_prefixes: true,
          semantic_prefixes: %{
            "PHX" => :phoenix_web,
            "OTP" => :otp_genserver
          }
        }
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: true} = result
      assert length(result.warnings) == 1

      warning = hd(result.warnings)
      assert warning.type == :semantic_prefix_mismatch
      assert String.contains?(warning.message, "PHX")
      assert String.contains?(warning.message, "phoenix_web")
      assert String.contains?(warning.message, "no category assigned")
    end

    test "warns about unrecognized semantic prefix" do
      task = %Task{
        id: "NEW001",
        type: :main,
        category: :testing,
        description: "New semantic prefix",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{
          id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/,
          enable_semantic_prefixes: true,
          semantic_prefixes: %{
            "OTP" => :otp_genserver,
            "PHX" => :phoenix_web
          }
        }
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: true} = result
      assert length(result.warnings) == 1

      warning = hd(result.warnings)
      assert warning.type == :unrecognized_semantic_prefix
      assert String.contains?(warning.message, "NEW")
      assert String.contains?(warning.message, "not recognized")
    end

    test "skips semantic validation when disabled" do
      task = %Task{
        id: "OTP001",
        type: :main,
        # Wrong category, but validation disabled
        category: :phoenix_web,
        description: "OTP task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task],
        config: %{
          id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/,
          enable_semantic_prefixes: false,
          semantic_prefixes: %{
            "OTP" => :otp_genserver
          }
        }
      }

      result = IdValidator.validate(task, context)
      assert %ValidationResult{valid?: true} = result
      assert Enum.empty?(result.warnings)
    end

    test "validates multiple semantic prefixes" do
      task1 = %Task{
        id: "OTP001",
        type: :main,
        category: :otp_genserver,
        description: "OTP task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      task2 = %Task{
        id: "PHX101",
        type: :main,
        category: :phoenix_web,
        description: "Phoenix task",
        status: "Planned",
        priority: "High",
        content: [],
        subtasks: []
      }

      context = %{
        all_tasks: [task1, task2],
        config: %{
          id_regex: ~r/^[A-Z]{2,4}\d{3,4}(-\d+|[a-z])?$/,
          enable_semantic_prefixes: true,
          semantic_prefixes: %{
            "OTP" => :otp_genserver,
            "PHX" => :phoenix_web,
            "CTX" => :business_logic,
            "DB" => :data_layer
          }
        }
      }

      result1 = IdValidator.validate(task1, context)
      assert %ValidationResult{valid?: true} = result1
      # Note: Will have mixed_prefixes warning since we're using OTP and PHX together
      # mixed_prefix_warnings = Enum.filter(result1.warnings, &(&1.type == :mixed_prefixes))

      semantic_warnings =
        Enum.filter(
          result1.warnings,
          &(&1.type in [:semantic_prefix_mismatch, :unrecognized_semantic_prefix])
        )

      assert Enum.empty?(semantic_warnings)

      result2 = IdValidator.validate(task2, context)
      assert %ValidationResult{valid?: true} = result2
      # Should not have semantic prefix warnings
      semantic_warnings2 =
        Enum.filter(
          result2.warnings,
          &(&1.type in [:semantic_prefix_mismatch, :unrecognized_semantic_prefix])
        )

      assert Enum.empty?(semantic_warnings2)
    end
  end

  describe "priority/0" do
    test "returns high priority" do
      assert IdValidator.priority() == 90
    end
  end
end
