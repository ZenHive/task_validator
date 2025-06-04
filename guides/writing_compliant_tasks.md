# Writing Compliant Task Lists

This guide explains how to create task lists that comply with the enhanced `TaskValidator` specifications for Elixir/Phoenix projects.

## Enhanced Task List Structure

A compliant task list has two main sections with enhanced features:

```markdown
## Current Tasks

| ID      | Description                    | Status      | Priority | Assignee | Review Rating |
| ------- | ------------------------------ | ----------- | -------- | -------- | ------------- |
| PHX101  | User authentication LiveView   | In Progress | High     | @alice   | -             |
| OTP001  | TaskWorker GenServer           | Planned     | Critical | @bob     | -             |
| DB301   | User schema design             | Planned     | High     | @charlie | -             |

## Completed Tasks

| ID      | Description        | Status    | Completed By | Review Rating |
| ------- | ------------------ | --------- | ------------ | ------------- |
| PHX105  | Phoenix setup      | Completed | @alice       | 4.8           |
| OTP005  | Application setup  | Completed | @bob         | 4.9           |
```

## Enhanced Task ID Format

### Traditional Format (Still Supported)
- 2-4 uppercase letters as a prefix (representing a component or module)
- 3-4 digits as a sequential number
- Examples: `SSH001`, `VAL0004`, `PROJ-001`

### Semantic Prefixes (Recommended for Elixir/Phoenix)
Use meaningful semantic prefixes that automatically map to categories:

- **OTP001-099**: OTP/GenServer tasks (`OTP`, `GEN`, `SUP`, `APP`)
- **PHX100-199**: Phoenix Web tasks (`PHX`, `WEB`, `LV`, `LVC`) 
- **CTX200-299**: Business Logic tasks (`CTX`, `BIZ`, `DOM`)
- **DB300-399**: Data Layer tasks (`DB`, `ECT`, `MIG`, `SCH`)
- **INF400-499**: Infrastructure tasks (`INF`, `DEP`, `ENV`, `REL`)
- **TST500-599**: Testing tasks (`TST`, `TES`, `INT`, `E2E`)
- Optional suffix for subtasks:
  - Numeric: `-1`, `-2` (e.g., SSH0001-1)
  - Letter: `a`, `b`, `c` for checkbox style (e.g., SSH0001a)

Examples:

- `PHX101` - Phoenix LiveView authentication task
- `OTP001` - GenServer implementation task
- `DB301` - Database schema design task
- `TST501` - Integration testing task
- `PHX101-1` - First subtask of PHX101 (numeric style)
- `OTP001a` - First subtask of OTP001 (checkbox style)

### Elixir/Phoenix Task Categories

Tasks are organized into Elixir/Phoenix-specific categories with enforced number ranges:

- **OTP/GenServer (1-99)**: GenServers, Supervisors, Applications
- **Phoenix Web (100-199)**: Controllers, LiveView, Templates, Routes
- **Business Logic (200-299)**: Contexts, Domain Logic, APIs
- **Data Layer (300-399)**: Ecto Schemas, Migrations, Queries
- **Infrastructure (400-499)**: Deployment, Configuration, Monitoring
- **Testing (500-599)**: Unit Tests, Integration Tests, Property Tests

Each category has specific required sections and validation rules (see Category-Specific Requirements below).

### Semantic Prefix Benefits

- **Automatic categorization**: Prefixes map to appropriate categories
- **Clear organization**: Easy to identify task types at a glance
- **Validation assistance**: Helpful warnings for prefix-category mismatches
- **Team clarity**: Semantic meaning improves team communication

## Error Handling Requirements

Main tasks and subtasks have different error handling documentation requirements.

### Main Tasks Error Handling Format

Main tasks must include comprehensive error handling sections that follow this format:

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

### Subtasks Error Handling Format

Subtasks have a simplified error handling format:

```markdown
**Error Handling**
**Task-Specific Approach**
- Error pattern for this task
**Error Reporting**
- Monitoring approach
```

These sections ensure consistent error handling practices across the project while providing appropriate level of detail for each task type. Tasks without proper error handling sections will fail validation.

## Detailed Task Entries

Each task needs a detailed entry with the following format:

```markdown
### SSH0001: Implement SSH authentication module

**Description**
Develop the SSH authentication module supporting key-based and password authentication.

**Simplicity Progression Plan**

1. Start with basic password auth
2. Add key-based auth
3. Refine error handling

**Simplicity Principle**
Progressive enhancement

**Abstraction Evaluation**
Medium - abstracts authentication but maintains clear interfaces

**Requirements**

- Support for password auth
- Support for public key auth
- Configurability of allowed auth methods

**ExUnit Test Requirements**

- Test both auth methods
- Test failure scenarios
- Mock SSH server for integration tests

**Integration Test Scenarios**

- Auth with valid/invalid password
- Auth with valid/invalid key
- Auth with disabled methods

**Typespec Requirements**

- Define types for credentials
- Define auth result types

**TypeSpec Documentation**
All types should be documented clearly

**TypeSpec Verification**
Use Dialyzer to verify type correctness

**Status**
In Progress

**Priority**
High

**Dependencies**
- ERR001 (Error handling framework must be complete)
- AUTH005 (Authentication interface design)

**Code Quality KPIs**
- Functions per module: 4
- Lines per function: 12
- Call depth: 2

**Subtasks**
- [x] Implement password authentication [SSH0001-1]
- [ ] Add key-based authentication [SSH0001-2]  
- [ ] Implement host verification [SSH0001-3]

#### 1. Implement password authentication (SSH0001-1)

**Description**
Initial implementation of password-based authentication.

**Error Handling**
**Task-Specific Approach**
- Handle invalid credentials with specific error tuples
- Use clean separation for auth failures vs. connection failures
**Error Reporting**
- Log auth attempts with appropriate level (info/warn)
- Track failed attempts for rate limiting

**Status**
Completed

**Review Rating**
4.5

#### 2. Add key-based authentication (SSH0001-2)

**Description**
Support for RSA and ED25519 keys with proper validation.

**Error Handling**
**Task-Specific Approach**
- Return descriptive error for invalid key formats
- Handle key verification timeout with custom error
**Error Reporting**
- Log key verification attempts
- Report metrics on key type usage

**Status**
In Progress
```

## Status Values

Valid status values are:

- `Planned`
- `In Progress`
- `Review`
- `Completed`
- `Blocked`

## Priority Values

Valid priority values are:

- `Critical`
- `High`
- `Medium`
- `Low`

## Review Ratings

For completed tasks, include a review rating:

- Scale of 1-5 with optional decimal (e.g., `4.5`)
- Can include `(partial)` suffix for partially meeting requirements

## Required Sections for Completed Tasks

When a task is marked as "Completed", it must include these additional sections:

**Implementation Notes**
Describe the implementation approach and patterns used.

**Complexity Assessment**
Assess the final complexity level (High/Medium/Low) and explain why.

**Maintenance Impact**
Evaluate the maintenance burden and any special considerations.

Example:
```markdown
**Implementation Notes**
Elegant indirection pattern using Registry for PID resolution

**Complexity Assessment**
Low - Used built-in Registry with minimal custom code

**Maintenance Impact**
Low - Self-contained solution with clear interface
```

## Dependencies Field

Tasks should specify their dependencies on other tasks:

```markdown
**Dependencies**
- SSH0001 (Authentication must be complete)
- ERR001 (Error handling framework required)
- None (for tasks with no dependencies)
```

The validator ensures all referenced task IDs exist in the task list.

## Code Quality KPIs

All tasks must include code quality metrics:

```markdown
**Code Quality KPIs**
- Functions per module: 3
- Lines per function: 10
- Call depth: 2
```

These metrics must adhere to the following limits:
- Maximum functions per module: 8
- Maximum lines per function: 15
- Maximum call depth: 3

### Complexity-Based KPI Limits

For complex tasks, you can specify a complexity assessment to allow higher KPI limits:

```markdown
**Complexity Assessment**: Complex
Rationale: Extensive test scenarios and mock setups require more functions.

**Code Quality KPIs**
- Functions per module: 16  # Complex: 2x base limit
- Lines per function: 30    # Complex: 2x base limit
- Call depth: 6             # Complex: 2x base limit
```

Complexity levels and their multipliers:
- **Simple**: 1x base limits (default)
- **Medium**: 1.5x base limits
- **Complex**: 2x base limits
- **Critical**: 3x base limits

Categories have default complexity levels:
- **Testing tasks (500-599)**: Complex (many test scenarios)
- **Infrastructure tasks (400-499)**: Complex (deployment complexity)
- **OTP/GenServer tasks (1-99)**: Medium (state management)
- **Phoenix Web tasks (100-199)**: Simple (thin controllers)
- **Business Logic tasks (200-299)**: Medium (domain complexity)
- **Data Layer tasks (300-399)**: Simple (straightforward schemas)

## Subtask Formats

### Checkbox Format (Recommended)

The checkbox format provides better visual tracking of subtask progress:

```markdown
**Subtasks**
- [x] Implement password authentication [SSH0001-1]
- [ ] Add key-based authentication [SSH0001-2]
- [ ] Implement host verification [SSH0001-3]
```

This format:
- Uses standard markdown checkboxes `- [x]` for completed, `- [ ]` for pending
- Includes descriptive task names followed by task ID in brackets
- Makes progress immediately visible in the rendered markdown

### Numbered Format (Alternative)

Subtasks can also be documented as numbered entries with full details:

```markdown
#### 1. Implement password authentication (SSH0001-1)

**Description**
Initial implementation of password-based authentication.

**Error Handling**
**Task-Specific Approach**
- Handle invalid credentials with specific error tuples
**Error Reporting**  
- Log auth attempts with appropriate level

**Status**
Completed

**Review Rating**
4.5
```

Note: Both formats are valid. The checkbox format is recommended for better visual tracking.

## Category-Specific Requirements

Different task categories require different sections:

### Core Infrastructure Tasks (1-99)
Required sections:
- Architecture Decision
- System Impact
- Dependency Analysis

### Feature Tasks (100-199)
Required sections:
- Feature Specification
- User Impact
- Integration Points

### Documentation Tasks (200-299)
Required sections:
- Documentation Scope
- Target Audience
- Related Documents

### Testing Tasks (300-399)
Required sections:
- Test Coverage
- Test Categories
- Performance Impact

## Using References (Content Placeholders)

References are a powerful feature to reduce repetition and maintain consistency across your task lists. They work as content placeholders that the validator recognizes but doesn't expand - that's left to AI tools when editing files.

### How References Work

1. **Define references** at the end of your task list using the format `## #{{reference-name}}`:
```markdown
## References

## #{{error-handling}}
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

## #{{standard-kpis}}
**Code Quality KPIs**
- Functions per module: ≤ 10
- Lines per function: ≤ 20
- Call depth: ≤ 3
- Test coverage: ≥ 90%
- Documentation coverage: 100%
```

2. **Use references** in tasks with the format `{{reference-name}}`:
```markdown
### SSH0001: Implement SSH connection module

**Description**: Create core SSH connection module
**Simplicity Progression Plan**: Start basic, add features progressively
**Simplicity Principle**: Keep connection logic separate from auth
**Abstraction Evaluation**: Hide protocol details behind simple API
**Requirements**: TCP connection, SSH handshake, session init
{{test-requirements}}
{{typespec-requirements}}
{{def-no-dependencies}}
{{standard-kpis}}
{{error-handling}}
**Status**: In Progress
**Priority**: High
```

### Key Benefits

1. **Reduces file size by 60-70%** - Common sections defined once
2. **Ensures consistency** - Same content across all tasks
3. **Easier maintenance** - Update reference definition once
4. **AI-friendly** - Tools expand references when editing
5. **Validation support** - Validator checks reference existence

### Common Reference Patterns

#### Required Section References
```markdown
## #{{error-handling}}           # Main task error handling
## #{{error-handling-subtask}}   # Subtask error handling
## #{{test-requirements}}        # All test-related sections
## #{{typespec-requirements}}    # All TypeSpec sections
## #{{standard-kpis}}           # Code quality metrics
## #{{def-no-dependencies}}     # Standard "None" for dependencies
```

#### Category-Specific References
```markdown
## #{{core-architecture}}        # Architecture sections for core tasks
## #{{feature-sections}}         # Feature specification sections
## #{{doc-sections}}            # Documentation task sections
## #{{test-sections}}           # Testing task sections
```

### Important Notes

1. **Reference format is strict**:
   - Definition: `## #{{reference-name}}`
   - Usage: `{{reference-name}}`
   - The `#` is only in the definition, not the usage

2. **References can replace entire sections**:
   - `{{test-requirements}}` can include ExUnit, Integration, and TypeSpec sections
   - `{{error-handling}}` includes all error handling subsections

3. **The validator only checks existence**:
   - It doesn't expand references
   - It ensures all used references are defined
   - AI tools are expected to expand when editing

4. **References work for any repeated content**:
   - Required sections
   - Common patterns
   - Shared specifications

### Complete Example

See `/docs/example_tasklist_with_references.md` for a complete working example that demonstrates:
- Proper reference definitions
- Reference usage in tasks
- Multiple task states with references
- Category-specific sections with references

## Common Validation Errors

1. **Missing error handling sections** - All tasks and subtasks must include complete error handling documentation
2. **Incomplete error handling documentation** - All three error handling subsections (Core Principles, Implementation, Examples) are required
3. **Missing detailed entries** - All non-completed tasks need detailed entries
4. **Missing required sections** - Ensure all required sections are present
5. **Missing completion details** - Completed tasks must include implementation notes, complexity assessment and maintenance impact
6. **Inconsistent subtask prefixes** - Subtasks must use same prefix as parent
7. **In Progress tasks without subtasks** - Any "In Progress" task needs subtasks
8. **Invalid status values** - Must be one of the valid status values
9. **Missing review ratings** - Completed subtasks need review ratings
10. **Invalid dependencies** - Referenced task IDs must exist
11. **KPI violations** - Code quality metrics exceed maximum limits
12. **Invalid task category** - Task number doesn't match prefix category
13. **Missing category-specific sections** - Required sections based on task category are missing

## Enhanced Features for Elixir/Phoenix Projects

### Category-Specific Required Sections

Different task categories require specific sections to ensure proper documentation:

#### Phoenix Web Tasks (PHX, WEB, LV, LVC)
```markdown
**Route Design**
RESTful routes with proper HTTP verbs and path helpers

**Context Integration**  
Clean integration with Phoenix contexts following domain boundaries

**Template/Component Strategy**
LiveView components or templates with proper separation of concerns
```

#### Data Layer Tasks (DB, ECT, MIG, SCH)
```markdown
**Schema Design**
Well-normalized schemas with proper constraints and relationships

**Migration Strategy**
Rollback-safe migrations with zero-downtime considerations

**Query Optimization**
Efficient query patterns with proper indexing
```

#### Business Logic Tasks (CTX, BIZ, DOM)
```markdown
**Context Boundaries**
Clear domain boundaries with focused contexts

**Business Rules**
Explicit business rule validation and enforcement
```

### Enhanced Error Handling Templates

Category-specific error handling patterns are available:

#### Phoenix Error Handling
```markdown
{{phoenix-error-handling}}
```
Expands to Phoenix-specific patterns including LiveView errors, form validation, and authentication handling.

#### OTP Error Handling
```markdown
{{otp-error-handling}}
```
Expands to OTP patterns including GenServer error handling, supervision strategies, and process isolation.

#### Ecto Error Handling
```markdown
{{ecto-error-handling}}
```
Expands to database patterns including changeset validation, constraint handling, and migration safety.

### Elixir-Specific Code Quality KPIs

Enhanced KPI metrics tailored for Elixir/Phoenix:

```markdown
**Code Quality KPIs**
- Functions per module: 8
- Lines per function: 15
- Call depth: 3
- Pattern match depth: 4
- Dialyzer warnings: 0
- Credo score: 8.0
- GenServer state complexity: 5    # OTP tasks only
- Phoenix context boundaries: 3    # Phoenix tasks only
- Ecto query complexity: 4         # Data layer tasks only
```

### Reference System

Use references for efficient template reuse:

```markdown
{{phoenix-kpis}}           # Phoenix-specific KPIs
{{otp-kpis}}              # OTP-specific KPIs
{{ecto-kpis}}             # Ecto-specific KPIs
{{phoenix-web-sections}}   # Phoenix required sections
{{data-layer-sections}}    # Data layer required sections
{{business-logic-sections}} # Business logic required sections
```

### Template Generation with Semantic Prefixes

Generate new task lists with semantic prefixes:

```bash
# Create Phoenix web template
mix task_validator.create_template --category phoenix_web --semantic

# Create OTP template  
mix task_validator.create_template --category otp_genserver --semantic

# Create data layer template
mix task_validator.create_template --category data_layer --semantic
```

### Migration from Legacy Format

To migrate existing task lists:

1. **Update Task IDs**: Convert to semantic prefixes
   - `SSH001` → `OTP001` (if it's a GenServer)
   - `WEB001` → `PHX101` (if it's Phoenix web)

2. **Add Category Sections**: Include required sections for your category
   - Phoenix tasks need Route Design, Context Integration, Template/Component Strategy
   - Data layer tasks need Schema Design, Migration Strategy, Query Optimization

3. **Enhance Error Handling**: Use category-specific templates
   - Replace generic error handling with `{{phoenix-error-handling}}`
   - Use `{{otp-error-handling}}` for GenServer tasks

4. **Update KPIs**: Add Elixir-specific metrics
   - Include pattern match depth, Dialyzer warnings, Credo score
   - Add category-specific KPIs (GenServer state complexity, etc.)

5. **Use References**: Convert repetitive content to reference system
   - Replace repeated KPI sections with `{{phoenix-kpis}}`
   - Use section references for common patterns

## Examples

See comprehensive examples in `docs/examples/`:
- `phoenix_web_example.md` - Complete Phoenix LiveView application
- `otp_application_example.md` - Distributed OTP system
- `ecto_data_layer_example.md` - Database schema and migrations
