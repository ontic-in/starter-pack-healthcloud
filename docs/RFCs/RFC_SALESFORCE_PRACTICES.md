# RFC: Salesforce Apex Development Practices

## Stub file for testing

This file is referenced by checkpoint prompts for Salesforce best practices.

## Security Requirements
- Explicit sharing keywords (with sharing, without sharing, inherited sharing)
- CRUD/FLS checks before SOQL/DML operations
- Use Security.stripInaccessible() for field-level security

## Architecture Patterns
- Instance-based design with dependency injection
- Interface-based services
- Separation of concerns (Controller → Service → Repository)

## Code Standards
- Naming conventions: PascalCase for classes, camelCase for methods
- Bulkification: No SOQL/DML in loops
- Governor limit awareness

## Testing Standards
- Minimum 75% code coverage
- No SeeAllData=true
- Proper assertions in all test methods
