# Task List Examples

This directory contains example task lists for different project categories. Each example demonstrates the proper format and structure required by the TaskValidator, including how to properly format subtasks.

## Available Examples

### 1. OTP GenServer (`otp_genserver_example.md`)
Example tasks for OTP/GenServer development including:
- GenServer implementation with proper callbacks
- Supervision tree setup
- State management patterns
- Demonstrates numbered subtasks with full sections

### 2. Phoenix Web (`phoenix_web_example.md`)
Example tasks for Phoenix web development including:
- LiveView component implementation
- RESTful controller development
- Route design and context integration
- Shows both numbered subtasks and checkbox format

### 3. Business Logic (`business_logic_example.md`)
Example tasks for Phoenix contexts and business logic:
- Context module implementation
- Business rule enforcement
- API boundary design
- Demonstrates numbered subtasks with error handling

### 4. Data Layer (`data_layer_example.md`)
Example tasks for Ecto schemas and database design:
- Schema design with migrations
- Changeset validations
- Query optimization
- Shows both numbered subtasks and checkbox format for minor items

### 5. Infrastructure (`infrastructure_example.md`)
Example tasks for deployment and infrastructure:
- Elixir release configuration
- Runtime configuration management
- Deployment strategies
- Demonstrates numbered subtasks for deployment steps

### 6. Testing (`testing_example.md`)
Example tasks for comprehensive testing strategies:
- Test architecture design
- Unit and integration testing
- Property-based testing
- Multiple tasks showing variety in task management

## Key Features Demonstrated

### Subtask Formats

Each example shows proper subtask formatting:

1. **Numbered Subtasks** (Full format for significant subtasks):
   ```markdown
   #### 1. Description (TASK-ID-1)
   **Description**
   Detailed description of the subtask
   
   **Status**
   Planned
   
   {{error-handling-subtask}}
   ```

2. **Checkbox Subtasks** (Simplified format for minor items):
   ```markdown
   **Subtasks** (Simplified checkbox format for minor items)
   - [ ] Minor task description [TASKIDa]
   - [ ] Another minor task [TASKIDb]
   ```

### Task States

- Tasks with subtasks use "In Progress" status
- Completed tasks include all required sections (Implementation Notes, Complexity Assessment, etc.)
- Proper use of review ratings for completed tasks

### Reference System

All examples use the reference system (e.g., `{{error-handling}}`) to reduce file size while maintaining consistency. The validator checks that references exist but doesn't expand them.

## Using These Examples

1. **As Templates**: Copy an example that matches your project type and customize it
2. **As Reference**: Use these to understand the expected format when writing your own task lists
3. **For Validation Testing**: Run `mix validate_tasklist --path docs/examples/[filename]` to see validation in action

## Generating Fresh Templates

You can generate fresh templates using the Mix task:

```bash
# Generate with default prefix (PRJ)
mix task_validator.create_template --category phoenix_web

# Generate with custom prefix
mix task_validator.create_template --prefix SSH --category otp_genserver

# Generate with semantic prefix
mix task_validator.create_template --semantic --category data_layer

# Specify output path
mix task_validator.create_template --path my_tasks.md --category testing
```

## Semantic Prefixes

When using `--semantic`, the following prefixes are used:
- OTP GenServer: `OTP`
- Phoenix Web: `PHX`
- Business Logic: `CTX`
- Data Layer: `DB`
- Infrastructure: `INF`
- Testing: `TST`

## Notes

- All examples in this directory pass validation
- Examples use placeholder content - replace with your actual project details
- The reference definitions at the bottom of each file are required for validation
- Subtasks are required when a task status is "In Progress"