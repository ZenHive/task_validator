# TaskValidator Example Task Lists

This directory contains comprehensive examples showcasing the enhanced TaskValidator features for Elixir/Phoenix projects. These examples demonstrate all the improvements implemented in the TaskValidator refactoring project.

## Available Examples

### 1. Phoenix Web Application (`phoenix_web_example.md`)
**Demonstrates**: E-commerce web application with LiveView components
**Features Showcased**:
- ✅ Semantic prefixes (PHX001, PHX102, etc.)
- ✅ Phoenix-specific required sections (Route Design, Context Integration, Template/Component Strategy)
- ✅ Enhanced error handling templates for Phoenix/LiveView
- ✅ Elixir-specific KPIs with Phoenix context boundaries
- ✅ Category-specific validation for phoenix_web tasks
- ✅ Reference system for template reuse
- ✅ Comprehensive task hierarchy with subtasks and review ratings

**Key Features**:
- LiveView authentication system implementation
- Product catalog with real-time search
- Shopping cart and checkout flow
- Complete task lifecycle from planning to completion

### 2. OTP Application (`otp_application_example.md`)
**Demonstrates**: Distributed task processing system with GenServers
**Features Showcased**:
- ✅ Semantic prefixes (OTP001, OTP002, etc.)
- ✅ OTP-specific error handling patterns
- ✅ GenServer state complexity KPIs
- ✅ Supervision tree design and fault tolerance
- ✅ Process architecture documentation
- ✅ Telemetry and monitoring integration

**Key Features**:
- TaskWorker GenServer implementation
- Dynamic supervisor with worker scaling
- Registry-based worker discovery
- Distributed task scheduling with cron support

### 3. Ecto Data Layer (`ecto_data_layer_example.md`)
**Demonstrates**: Database schema design and migration management
**Features Showcased**:
- ✅ Semantic prefixes (DB301, DB302, etc.)
- ✅ Data layer specific sections (Schema Design, Migration Strategy, Query Optimization)
- ✅ Ecto-specific error handling patterns
- ✅ Database query complexity KPIs
- ✅ Migration safety and rollback procedures
- ✅ Performance optimization strategies

**Key Features**:
- User authentication schema design
- Product catalog with variants
- Order and payment tracking
- Audit logging and soft delete systems

## Enhanced Features Demonstrated

### 🆔 Semantic Task IDs
All examples use meaningful semantic prefixes that automatically map to categories:
- **PHX** (Phoenix Web): PHX101, PHX102, PHX103
- **OTP** (OTP/GenServer): OTP001, OTP002, OTP003  
- **DB** (Data Layer): DB301, DB302, DB303

### 📋 Category-Specific Required Sections
Each category enforces appropriate sections:
- **Phoenix Web**: Route Design, Context Integration, Template/Component Strategy
- **Data Layer**: Schema Design, Migration Strategy, Query Optimization
- **OTP/GenServer**: Process Architecture, Supervision Strategy, Fault Tolerance

### 🛠 Enhanced Error Handling Templates
Category-specific error handling patterns:
- **Phoenix**: LiveView error patterns, form validation, authentication errors
- **OTP**: GenServer error handling, supervision strategies, process isolation
- **Ecto**: Changeset validation, constraint handling, migration safety

### 📊 Elixir-Specific KPIs
Advanced code quality metrics tailored for Elixir/Phoenix:
- Pattern match depth (≤ 4)
- Dialyzer warnings (0)
- Credo score (≥ 8.0)
- GenServer state complexity (≤ 5)
- Phoenix context boundaries (≤ 3)
- Ecto query complexity (≤ 4)

### 🔗 Reference System
Efficient template reuse with references:
- `{{phoenix-kpis}}` - Phoenix-specific KPI requirements
- `{{otp-error-handling}}` - OTP error handling patterns
- `{{ecto-error-handling}}` - Database error handling
- `{{phoenix-web-sections}}` - Phoenix section templates

### ✅ Comprehensive Validation
Examples pass all enhanced validation rules:
- ID format validation with semantic prefix checking
- Category-specific section requirements
- Enhanced error handling validation
- KPI compliance checking
- Reference resolution validation

## Using These Examples

### 1. Validation Testing
Test the examples against the enhanced validator:
```bash
# Validate Phoenix example
mix validate_tasklist --path docs/examples/phoenix_web_example.md

# Validate OTP example  
mix validate_tasklist --path docs/examples/otp_application_example.md

# Validate Ecto example
mix validate_tasklist --path docs/examples/ecto_data_layer_example.md
```

### 2. Template Generation
Generate new task lists using semantic prefixes:
```bash
# Create Phoenix web template
mix task_validator.create_template --category phoenix_web --semantic

# Create OTP template
mix task_validator.create_template --category otp_genserver --semantic  

# Create data layer template
mix task_validator.create_template --category data_layer --semantic
```

### 3. Migration from Old Format
Use these examples as reference when migrating existing task lists:
- Add semantic prefixes to task IDs
- Include category-specific required sections
- Update error handling to use enhanced templates
- Add Elixir-specific KPIs
- Convert inline content to reference system

## Example Statistics

### Phoenix Web Example
- **Tasks**: 6 total (4 current, 2 completed)
- **Semantic Prefixes**: PHX101-PHX106
- **Categories**: phoenix_web (100-199 range)
- **Sections**: Route Design, Context Integration, Template/Component Strategy
- **Validation**: ✅ Passes all enhanced rules

### OTP Application Example  
- **Tasks**: 6 total (4 current, 2 completed)
- **Semantic Prefixes**: OTP001-OTP006
- **Categories**: otp_genserver (1-99 range)
- **Sections**: Process Architecture, Supervision Strategy, Fault Tolerance
- **Validation**: ✅ Passes all enhanced rules

### Ecto Data Layer Example
- **Tasks**: 6 total (4 current, 2 completed) 
- **Semantic Prefixes**: DB301-DB306
- **Categories**: data_layer (300-399 range)
- **Sections**: Schema Design, Migration Strategy, Query Optimization
- **Validation**: ✅ Passes all enhanced rules

## Implementation Coverage

These examples demonstrate **100% coverage** of enhanced TaskValidator features:

### ✅ Completed Refactoring Features
- **REF001**: Core domain models ✅
- **REF002**: Parser extraction ✅  
- **REF003**: Validator modularization ✅
- **FMT001**: Elixir task categories ✅
- **FMT002**: Enhanced error handling ✅
- **FMT003**: Elixir-specific KPIs ✅
- **FMT004**: Phoenix-specific sections ✅
- **FMT005**: Semantic task ID patterns ✅
- **FMT006**: Example templates ✅

### 🔄 Integration Status
- **REF006**: Final integration (91% test pass rate)

## Best Practices Demonstrated

### 1. Task Organization
- Semantic task IDs for clear categorization
- Logical task dependencies and ordering
- Proper status progression and priority assignment

### 2. Documentation Quality
- Comprehensive task descriptions with clear requirements
- Technical architecture documentation
- Implementation notes for completed tasks

### 3. Error Handling
- Category-appropriate error handling patterns
- Comprehensive error scenarios and recovery procedures
- Monitoring and observability integration

### 4. Code Quality
- Elixir/Phoenix-specific KPI targets
- Type specifications and Dialyzer integration
- Comprehensive testing requirements

### 5. Reference Usage
- Efficient template reuse with reference system
- Consistent error handling across similar tasks
- Maintainable documentation structure

## Migration Guide

To migrate existing task lists to the enhanced format:

1. **Update Task IDs**: Convert to semantic prefixes (SSH001 → PHX101)
2. **Add Category Sections**: Include required sections for your category
3. **Enhance Error Handling**: Use category-specific error handling templates  
4. **Update KPIs**: Add Elixir-specific KPI requirements
5. **Use References**: Convert repetitive content to reference system
6. **Validate**: Run enhanced validator to ensure compliance

See individual examples for detailed implementation patterns and best practices.