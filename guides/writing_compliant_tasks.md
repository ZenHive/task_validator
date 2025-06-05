# Writing Compliant Tasks Guide

This guide explains how to write task lists that comply with TaskValidator's format specifications.

## Task List Structure

Every task list must have three main sections:

1. **Current Tasks** - Table of active tasks
2. **Completed Tasks** - Table of finished tasks  
3. **Task Details** - Detailed descriptions for each task

## Task ID Format

Task IDs follow a specific pattern:

```
[PREFIX][NUMBER][-SUBTASK]
```

- **PREFIX**: 2-4 uppercase letters (e.g., SSH, OTP, PHX)
- **NUMBER**: 3-4 digits (e.g., 001, 0001)
- **SUBTASK**: Optional suffix for subtasks
  - Numbered: -1, -2, -3 (for detailed subtasks)
  - Lettered: a, b, c (for checkbox subtasks)

### Examples
- Main tasks: `SSH0001`, `PHX0101`, `DB0301`
- Numbered subtasks: `SSH0001-1`, `SSH0001-2`
- Checkbox subtasks: `SSH0001a`, `SSH0001b`

## Semantic Prefixes

For Elixir/Phoenix projects, use these semantic prefixes:

| Category | Prefix | Range | Description |
| --- | --- | --- | --- |
| OTP/GenServer | OTP | 0001-0099 | Process and supervision |
| Phoenix Web | PHX | 0100-0199 | Web layer tasks |
| Business Logic | CTX | 0200-0299 | Contexts and domain |
| Data Layer | DB | 0300-0399 | Ecto and database |
| Infrastructure | INF | 0400-0499 | Deployment and ops |
| Testing | TST | 0500-0599 | Test implementation |

## Required Sections

### Main Tasks

Every main task must include these sections:

```markdown
### TASK001: Task Title

**Description**
What this task accomplishes

**Status**
Planned | In Progress | Review | Completed | Blocked

**Priority**
Critical | High | Medium | Low

**Dependencies**
- TASK000 (or "None")

**Error Handling**
[Comprehensive error handling - see templates]

**ExUnit Test Requirements**
- Unit test requirements
- Test coverage goals

**Integration Test Scenarios**
- End-to-end test scenarios
- Performance requirements

**Typespec Requirements**
- Type specifications needed
- Documentation requirements

**TypeSpec Documentation**
- How types will be documented

**TypeSpec Verification**
- Dialyzer configuration
- Type checking approach

**Code Quality KPIs**
- Functions per module: 8
- Lines per function: 15
- Call depth: 3
```

### Category-Specific Sections

Different categories require additional sections:

#### OTP/GenServer Tasks
```markdown
**Process Design**
GenServer vs Task vs Agent decision

**State Management**
State structure and transitions

**Supervision Strategy**
Restart strategy and error escalation
```

#### Phoenix Web Tasks
```markdown
**Route Design**
RESTful routes and path helpers

**Context Integration**
How web layer integrates with contexts

**Template/Component Strategy**
LiveView vs traditional templates
```

#### Data Layer Tasks
```markdown
**Schema Design**
Ecto schema structure

**Migration Strategy**
Safe migration approach

**Query Optimization**
Performance considerations
```

## Status Rules

### In Progress
- **Must have subtasks** (either numbered or checkbox format)
- Shows active development

### Completed
Requires additional sections:
```markdown
**Implementation Notes**
How it was implemented

**Complexity Assessment**
Low | Medium | High - explanation

**Maintenance Impact**
Long-term maintenance considerations

**Error Handling Implementation**
How errors were actually handled

**Review Rating**
4.5 (1-5 scale)
```

## Subtask Formats

### Numbered Format (Major Subtasks)
Use for subtasks that need detailed tracking:

```markdown
#### 1. Subtask description (TASK001-1)
**Description**
Detailed description of what this subtask does

**Status**
Planned

**Error Handling**
**Task-Specific Approach**
- Error pattern for this task
**Error Reporting**
- Monitoring approach
```

### Checkbox Format (Minor Items)
Use for quick subtasks:

```markdown
**Subtasks**
- [x] Completed item [TASK001a]
- [ ] Pending item [TASK001b]
- [ ] Another item [TASK001c]
```

## Error Handling Requirements

### Main Tasks
Must use comprehensive format:
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

### Subtasks
Use simplified format:
```markdown
**Error Handling**
**Task-Specific Approach**
- Error pattern for this task
**Error Reporting**
- Monitoring approach
```

## Using References

To reduce file size and maintain consistency, use references:

### Define a Reference
```markdown
## #{{error-handling}}
**Error Handling**
[Full error handling content]
```

### Use a Reference
```markdown
{{error-handling}}
```

Common references:
- `{{error-handling}}` - Main task error handling
- `{{error-handling-subtask}}` - Subtask error handling
- `{{test-requirements}}` - Integration-first test sections
- `{{typespec-requirements}}` - TypeSpec sections
- `{{standard-kpis}}` - Code quality metrics

## Common Mistakes to Avoid

1. **Wrong Error Format** - Don't use main task error handling for subtasks
2. **Missing Subtasks** - "In Progress" tasks must have subtasks
3. **ID Mismatches** - Subtask prefixes must match parent
4. **Invalid Status** - Use only: Planned, In Progress, Review, Completed, Blocked
5. **Missing Sections** - All required sections must be present

## Validation Tips

1. Run validation frequently: `mix validate_tasklist`
2. Use templates as starting points: `mix task_validator.create_template`
3. Check examples in `docs/examples/`
4. Keep references defined at the bottom of the file
5. Maintain consistent formatting

## Best Practices

1. **Start with Templates** - Use category-specific templates
2. **Use Semantic Prefixes** - OTP, PHX, CTX, DB, INF, TST
3. **Progressive Detail** - Add sections as tasks progress
4. **Consistent IDs** - Follow the prefix convention strictly
5. **Reference Reuse** - Use references for common content

## Examples

See complete working examples in `docs/examples/`:
- `otp_genserver_example.md` - OTP/GenServer tasks
- `phoenix_web_example.md` - Phoenix web tasks
- `business_logic_example.md` - Context tasks
- `data_layer_example.md` - Ecto/database tasks
- `infrastructure_example.md` - DevOps tasks
- `testing_example.md` - Test implementation tasks