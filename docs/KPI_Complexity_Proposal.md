# KPI Complexity-Based Validation Proposal

## Problem Statement

Current KPI validation applies uniform limits regardless of task complexity:
- Lines per function: 15 (too strict for complex tests)
- Functions per module: 8 (too strict for test modules)
- Call depth: 3 (too strict for integration tests)

## Proposed Solution

### 1. Complexity Levels

Define complexity levels in task content:
```markdown
**Complexity Assessment**: Simple | Medium | Complex | Critical
```

### 2. Complexity-Based KPI Multipliers

| Complexity | Functions/Module | Lines/Function | Call Depth | Rationale |
|------------|------------------|----------------|------------|-----------|
| Simple | 1x (8) | 1x (15) | 1x (3) | Basic CRUD, utilities |
| Medium | 1.5x (12) | 1.5x (22) | 1.5x (4) | Standard business logic |
| Complex | 2x (16) | 2x (30) | 2x (6) | Complex algorithms, integration |
| Critical | 3x (24) | 3x (45) | 3x (9) | System critical, test suites |

### 3. Category-Specific Defaults

Different categories have different complexity defaults:
- OTP/GenServer: Medium (state machines are inherently complex)
- Phoenix Web: Simple (controllers should be thin)
- Business Logic: Medium (domain complexity varies)
- Data Layer: Simple (schemas should be straightforward)
- Infrastructure: Complex (deployment/monitoring is complex)
- Testing: Complex (test modules often have many scenarios)

### 4. Implementation Options

#### Option A: Explicit Complexity Declaration
```elixir
# In task content
**Complexity Assessment**: Complex

**Code Quality KPIs**
- Functions per module: 16  # Allowed due to Complex
- Lines per function: 30    # Allowed due to Complex
```

#### Option B: Auto-detect from Task Status/Type
```elixir
# Integration tests automatically get Complex multiplier
# Unit tests get Medium multiplier
# Completed tasks use actual measured complexity
```

#### Option C: KPI Override Syntax
```markdown
**Code Quality KPIs**
- Functions per module: 20 (complex: integration test suite)
- Lines per function: 35 (complex: multi-step workflow)
```

### 5. Validation Logic Changes

```elixir
defp validate_kpi_limit(task_id, kpi_key, parsed_kpis, config, task) do
  base_limit = get_kpi_limit(kpi_key, config)
  complexity_multiplier = get_complexity_multiplier(task)
  adjusted_limit = round(base_limit * complexity_multiplier)
  
  # Validate against adjusted limit
end

defp get_complexity_multiplier(task) do
  case get_task_complexity(task) do
    :simple -> 1.0
    :medium -> 1.5
    :complex -> 2.0
    :critical -> 3.0
  end
end
```

### 6. Benefits

1. **Realistic Limits**: Complex tasks get appropriate limits
2. **Maintains Standards**: Simple tasks still have strict limits
3. **Flexibility**: Can adjust per task or category
4. **Documentation**: Complexity assessment documents architectural decisions

### 7. Migration Path

1. Add complexity detection without changing limits (warning only)
2. Update examples to show complexity usage
3. Enable complexity-based limits with override flag
4. Make complexity-based limits default in next major version

## Recommendation

Implement **Option A** (Explicit Complexity Declaration) because:
- Clear documentation of complexity reasoning
- No magic auto-detection that might surprise users
- Easy to implement and understand
- Can be added as optional enhancement

## Example Usage

```markdown
### TST501: Unit tests for accounts context

**Description**
Comprehensive unit tests with property-based testing.

**Complexity Assessment**: Complex
Rationale: Extensive test scenarios, property-based testing generators, 
mock setup complexity, and multiple assertion helpers required.

**Code Quality KPIs**
- Functions per module: 20  # Complex: 2x base of 10
- Lines per function: 25    # Complex: ~2x base of 15
- Call depth: 5             # Complex: ~2x base of 3
```

This approach provides the flexibility needed while maintaining code quality standards appropriate to each task's complexity.