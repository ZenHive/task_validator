# Comprehensive Elixir/Phoenix TaskList Example

This example demonstrates all the new Elixir/Phoenix-specific features added during the refactoring:

## Features Demonstrated

### 1. Semantic Task Prefixes
- **OTP001**: OTP/GenServer category task (1-99 range)
- **PHX101**: Phoenix Web category task (100-199 range)
- **CTX201**: Business Logic/Context category task (200-299 range)
- **ECT301**: Data Layer/Ecto category task (300-399 range)

### 2. Category-Specific Required Sections
Each task includes sections specific to its category:
- **OTP/GenServer**: Process Design, State Management, Supervision Strategy
- **Phoenix Web**: Route Design, Context Integration, Template/Component Strategy
- **Business Logic**: API Design, Data Access, Validation Strategy
- **Data Layer**: Schema Design, Migration Strategy, Query Optimization

### 3. Enhanced Error Handling Templates
Different error handling approaches for each category:
- `{{otp-error-handling}}` - OTP principles like "let it crash"
- `{{phoenix-error-handling}}` - Phoenix-specific patterns
- `{{context-error-handling}}` - Context layer error patterns
- `{{ecto-error-handling}}` - Database and migration error handling

### 4. Elixir-Specific KPIs
Tailored code quality metrics:
- `{{otp-kpis}}` - Includes GenServer state complexity
- `{{phoenix-kpis}}` - Includes Phoenix context boundaries
- `{{business-logic-kpis}}` - Context API surface metrics
- `{{ecto-kpis}}` - Query complexity and index usage

### 5. Reference System
The example uses the reference system extensively to:
- Reduce file size by ~60-70%
- Ensure consistency across tasks
- Make updates easier (change once, apply everywhere)

## Usage

This TaskList can be used as a template for new Elixir/Phoenix projects:

1. Copy the file to your project
2. Update task IDs and descriptions for your needs
3. Modify the reference definitions if needed
4. Run validation: `mix validate_tasklist --path your_tasklist.md`

## Validation

To validate this example:
```bash
mix validate_tasklist --path test/fixtures/elixir_phoenix_example.md
```

The validator will check:
- Task ID formats and semantic prefixes
- Category-specific required sections
- Error handling references
- KPI values and limits
- Dependencies between tasks
- Overall task list structure