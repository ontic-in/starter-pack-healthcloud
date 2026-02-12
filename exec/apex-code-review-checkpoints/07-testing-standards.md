# Checkpoint: Testing Standards

## Priority
MEDIUM

## Objective
Validate that Apex test classes meet Salesforce testing requirements including minimum code coverage, proper test data setup, and assertion quality.

## Scope
This checkpoint examines test classes (@IsTest) to ensure they follow testing best practices and provide meaningful validation.

## Review Standards
From **RFC_SALESFORCE_PRACTICES.md**:

**Test Coverage Requirements:**
- Minimum 75% code coverage for deployment
- Target 85%+ coverage for quality code
- All trigger handlers must have 100% coverage

**Test Quality Standards:**
- Use @IsTest annotation (not @isTest)
- No SeeAllData=true (creates brittle tests)
- Proper test data setup in each test method
- Meaningful assertions (not just coverage)
- Test positive, negative, and bulk scenarios
- Use System.assert(), Assert.areEqual(), Assert.isTrue()

**Test Structure:**
- Arrange → Act → Assert pattern
- One logical assertion per test method
- Descriptive test method names

## Input Requirements
```json
{
  "files": ["array of .cls file paths to analyze"],
  "file_contents": ["array of file content strings matching the files array"],
  "test_coverage_data": "optional coverage percentage per class"
}
```

## Task

Analyze test classes for compliance with testing standards.

### Step 1: Test Class Detection

**Identify Test Classes:**
```apex
// Test class markers
@IsTest
public class LeadServiceTest { }

// Old style (still valid but discouraged)
@isTest
private class LeadServiceTest { }
```

### Step 2: SeeAllData Detection

**Flag SeeAllData=true:**
```apex
// VIOLATION
@IsTest(SeeAllData=true)
public class LeadServiceTest { }

// VIOLATION
@IsTest
static void testMethod() {
    Test.startTest();
    // ...
}

// Even if only one method uses it
@IsTest
public class LeadServiceTest {
    @IsTest(SeeAllData=true) // VIOLATION in method
    static void testWithOrgData() { }
}

// GOOD
@IsTest
public class LeadServiceTest {
    @IsTest
    static void testWithTestData() {
        // Create test data
        Lead l = new Lead(LastName='Test');
        insert l;
    }
}
```

### Step 3: Assertion Quality Check

**Count Assertions:**
```apex
// VIOLATION - No assertions (just coverage)
@IsTest
static void testProcessLeads() {
    List<Lead> leads = new List<Lead>();
    LeadService.processLeads(leads); // No assertion!
}

// GOOD - Meaningful assertions
@IsTest
static void testProcessLeads() {
    List<Lead> leads = new List<Lead>{
        new Lead(LastName='Test', Status='New')
    };

    Test.startTest();
    LeadService.processLeads(leads);
    Test.stopTest();

    // Assertion validates behavior
    List<Lead> processedLeads = [SELECT Status FROM Lead];
    Assert.areEqual('Processed', processedLeads[0].Status,
        'Lead status should be updated to Processed');
}
```

**Check Assertion Types:**
```apex
// WEAK - System.assert(true)
Assert.isTrue(true); // Always passes - meaningless

// GOOD - Actual validation
Assert.areEqual(expected, actual, 'Message');
Assert.isTrue(condition, 'Message');
Assert.isFalse(condition, 'Message');
Assert.isNotNull(value, 'Message');
```

### Step 4: Test Data Setup

**Check for Test Data Creation:**
```apex
// GOOD - Test data setup
@IsTest
static void testLeadConversion() {
    // Arrange - Setup test data
    Lead testLead = new Lead(
        LastName = 'Test',
        Company = 'Test Corp',
        Status = 'Open'
    );
    insert testLead;

    // Act - Execute test
    Test.startTest();
    Database.LeadConvert lc = new Database.LeadConvert();
    lc.setLeadId(testLead.Id);
    lc.setConvertedStatus('Converted');
    Database.convertLead(lc);
    Test.stopTest();

    // Assert - Validate results
    Lead convertedLead = [SELECT IsConverted FROM Lead WHERE Id = :testLead.Id];
    Assert.isTrue(convertedLead.IsConverted, 'Lead should be converted');
}
```

### Step 5: Bulk Testing

**Check for Bulk Test Methods:**
```apex
// GOOD - Tests bulkification (200 records)
@IsTest
static void testBulkProcessing() {
    List<Lead> leads = new List<Lead>();
    for (Integer i = 0; i < 200; i++) {
        leads.add(new Lead(
            LastName = 'Test' + i,
            Company = 'Test Corp'
        ));
    }
    insert leads;

    Test.startTest();
    LeadService.processLeads(leads);
    Test.stopTest();

    List<Lead> processed = [SELECT Id FROM Lead WHERE Status = 'Processed'];
    Assert.areEqual(200, processed.size(), 'All 200 leads should be processed');
}
```

### Step 6: Test Method Naming

**Check Naming Conventions:**
```apex
// GOOD - Descriptive names
@IsTest
static void testLeadConversion_WithValidData_ShouldSucceed() { }

@IsTest
static void testLeadConversion_WithMissingCompany_ShouldThrowException() { }

// POOR - Vague names
@IsTest
static void test1() { }

@IsTest
static void testMethod() { }
```

### Step 7: Coverage Analysis

**If test_coverage_data provided:**
- Check if class meets 75% minimum
- Flag if < 75% (blocks deployment)
- Recommend 85%+ for quality

## Violation Rules

**HIGH Violations:**
- Test coverage < 75% (blocks deployment)
- SeeAllData=true usage
- Test methods with no assertions

**MEDIUM Violations:**
- Test methods with weak assertions (Assert.isTrue(true))
- No bulk testing (only single record tests)
- Poor test method naming

**LOW Violations:**
- Using @isTest instead of @IsTest
- Missing Test.startTest()/stopTest()
- No negative test cases

## Output Format
```json
{
  "checkpoint_name": "testing-standards",
  "checkpoint_priority": "MEDIUM",
  "status": "pass|fail|warning",
  "files_analyzed": ["array of test class paths"],
  "violations": [
    {
      "severity": "high",
      "category": "Testing: SeeAllData",
      "file": "[path]",
      "line": "[line number]",
      "issue": "Test class uses SeeAllData=true - creates brittle tests dependent on org data",
      "evidence": "@IsTest(SeeAllData=true)",
      "fix_guidance": "Remove SeeAllData and create test data:\n@IsTest\npublic class Test {\n    @IsTest\n    static void test() {\n        Lead l = new Lead(LastName='Test');\n        insert l;\n    }\n}",
      "confidence": 0.6
    },
    {
      "severity": "high",
      "category": "Testing: Assertions",
      "file": "[path]",
      "line": "[line number]",
      "issue": "Test method has no assertions - provides coverage but no validation",
      "evidence": "No System.assert() or Assert.* calls found",
      "fix_guidance": "Add assertions to validate behavior:\nAssert.areEqual(expected, actual, 'Description');",
      "confidence": 0.6
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "high_count": "[SeeAllData + no assertions]",
    "medium_count": "[weak assertions + no bulk tests]",
    "low_count": "[naming + missing start/stop]",
    "test_classes_analyzed": "[number]",
    "classes_with_seealldata": "[number]",
    "methods_without_assertions": "[number]",
    "methods_with_bulk_tests": "[number]",
    "average_assertions_per_method": "[number]",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "pass"` if no violations
- `status: "fail"` if coverage < 75% OR SeeAllData=true
- `status: "warning"` if only medium/low violations

## Success Criteria
- All test classes have @IsTest annotation
- No SeeAllData=true usage
- All test methods have assertions
- Bulk testing present (200 records)
- Coverage ≥ 75% (if data available)
- Confidence = 0.6 (subjective quality assessment)

## Failure Handling
**CONTINUE** - Testing violations should not block review.
However, coverage < 75% blocks Salesforce deployment.

## Cross-References
- **RFC_SALESFORCE_PRACTICES.md** - Testing requirements
- **Salesforce Testing:** [Apex Testing Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing.htm)
- **Best Practices:** [Unit Test Best Practices](https://developer.salesforce.com/blogs/2013/03/testing-best-practices.html)

## Confidence Scoring
**All testing violations: 0.6 confidence**

Rationale:
- Test quality is subjective
- Some SeeAllData usage may be justified (rare)
- Assertion count doesn't equal test quality
- Manual review recommended for test effectiveness

## Examples

**Example 1: Good Test Class**
```apex
@IsTest
public class LeadServiceTest {
    @IsTest
    static void testProcessLeads_WithValidLeads_ShouldUpdateStatus() {
        // Arrange
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                LastName = 'Test' + i,
                Company = 'Test Corp',
                Status = 'New'
            ));
        }
        insert leads;

        // Act
        Test.startTest();
        LeadService service = new LeadService(new LeadRepository());
        service.processLeads(leads);
        Test.stopTest();

        // Assert
        List<Lead> processed = [SELECT Status FROM Lead WHERE Status = 'Processed'];
        Assert.areEqual(200, processed.size(),
            'All 200 leads should have status updated to Processed');
    }

    @IsTest
    static void testProcessLeads_WithNullList_ShouldThrowException() {
        // Arrange
        LeadService service = new LeadService(new LeadRepository());

        // Act & Assert
        try {
            Test.startTest();
            service.processLeads(null);
            Test.stopTest();
            Assert.fail('Expected IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('null'),
                'Exception should mention null input');
        }
    }
}
```

**Example 2: Poor Test Class (Multiple Violations)**
```apex
// VIOLATIONS
@IsTest(SeeAllData=true) // HIGH - SeeAllData
public class LeadServiceTest {
    @isTest // LOW - Should be @IsTest
    static void test1() { // MEDIUM - Poor naming
        LeadService.processLeads(null); // HIGH - No assertion!
        // No Test.startTest()/stopTest()
    }

    @IsTest
    static void test2() { // MEDIUM - Only tests single record (no bulk)
        Lead l = new Lead(LastName='Test');
        LeadService.processLead(l); // HIGH - No assertion!
    }
}
```
