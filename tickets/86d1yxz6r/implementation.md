# [US-1.3.1] Provider Directory

- **Ticket**: https://app.clickup.com/t/86d1yxz6r
- **Branch**: clickup-86d1yxz6r
- **Epic**: 1.3 Provider Management | Phase: 1 MVP
- **Depends On**: None (first ticket in Epic 1.3)

## Acceptance Criteria

- [x] Directory showing: name, specialty, facility, MCR number, availability
- [x] Search/filter by specialty, facility, language
- [x] Shows current patient load and next available slot
- [x] Accepting patients filter toggle
- [x] Table and card view toggle
- [x] Permission set controls read-only access to provider data
- [x] Navigate to provider record from directory

## Architecture

```
providerDirectory (LWC - App/Record/Home/Tab Page)
  ├── Search bar with debounced text input
  ├── Filter panel: specialty, facility, language (dual-listbox) + accepting checkbox
  ├── Toolbar: result count + table/card view toggle
  ├── Table view: 8-column sortable table
  └── Card view: responsive grid cards

Apex Layer:
  ProviderDirectoryController.cls (thin @AuraEnabled controller)
    └── ProviderDirectoryService.cls (business logic + SOQL)
          ├── searchProviders(SearchCriteria) → ProviderSearchResult[]
          ├── getSpecialtyPicklistValues() → PicklistOption[]
          ├── getFacilityPicklistValues() → PicklistOption[]
          └── getProviderDetail(Id) → ProviderDetail

Standard HC Objects:
  HealthcareProvider ──┬── HealthcareProviderTaxonomy → CareTaxonomy (specialties)
                       └── HealthcarePractitionerFacility → Account (facilities)
  CareSpecialty (specialty definitions)
```

## Data Model

### Custom Fields on HealthcareProvider (5 new)

| Field | API Name | Type | Purpose |
|---|---|---|---|
| MCR Number | MCR_Number__c | Text(10), Unique, ExternalId | Singapore Medical Council Registration |
| Languages | Languages__c | MultiselectPicklist | English;Mandarin;Malay;Tamil;Hindi;Bengali;Cantonese;Hokkien;Teochew;Other |
| Current Patient Load | Current_Patient_Load__c | Number(3,0) | Active patient count |
| Next Available Slot | Next_Available_Slot__c | DateTime | Next available appointment |
| Accepting Patients | Is_Accepting_Patients__c | Checkbox (default true) | Accepting new patients |

### Key Design Decisions

1. **Separate pre-queries** for specialty/facility filtering instead of subqueries to avoid HC child relationship name dependency
2. **Dynamic SOQL** with bind variables and `WITH SECURITY_ENFORCED` for FLS enforcement
3. **INCLUDES operator** for multi-select picklist language filtering
4. **`cacheable=true`** on all controller methods (read-only directory data)
5. **300ms debounce** on search input to avoid excessive Apex calls

## Files Created/Modified

### Metadata (5 files)
- `objects/HealthcareProvider/fields/MCR_Number__c.field-meta.xml`
- `objects/HealthcareProvider/fields/Languages__c.field-meta.xml`
- `objects/HealthcareProvider/fields/Current_Patient_Load__c.field-meta.xml`
- `objects/HealthcareProvider/fields/Next_Available_Slot__c.field-meta.xml`
- `objects/HealthcareProvider/fields/Is_Accepting_Patients__c.field-meta.xml`

### Apex (6 files)
- `classes/ProviderDirectoryService.cls` + `.cls-meta.xml`
- `classes/ProviderDirectoryController.cls` + `.cls-meta.xml`
- `classes/ProviderDirectoryServiceTest.cls` + `.cls-meta.xml`
- `classes/ProviderDirectoryControllerTest.cls` + `.cls-meta.xml`

### LWC (4 files)
- `lwc/providerDirectory/providerDirectory.js`
- `lwc/providerDirectory/providerDirectory.html`
- `lwc/providerDirectory/providerDirectory.css`
- `lwc/providerDirectory/providerDirectory.js-meta.xml`

### Permission Set (1 file)
- `permissionsets/Provider_Directory_Access.permissionset-meta.xml`

### Modified (1 file)
- `classes/TestDataFactory.cls` - Added 6 factory methods for provider test data

## Test Coverage

### ProviderDirectoryServiceTest (12 tests)
- Search with no filters, by name, by specialty, by facility, by language
- Accepting patients only filter
- Combined filters
- No results scenario
- Specialty and facility picklist retrieval
- Provider detail success and not-found error

### ProviderDirectoryControllerTest (7 tests)
- Search with valid JSON criteria
- Empty/blank criteria handling
- Specialty and facility options delegation
- Provider detail success and invalid ID error
- Malformed JSON error handling

### TestDataFactory additions (6 methods)
- `createHealthcareProvider()` - provider with practitioner link
- `createCareSpecialty()` - specialty record
- `createCareTaxonomy()` - taxonomy record
- `createProviderTaxonomy()` - provider-taxonomy junction
- `createFacilityAccount()` - account for facility
- `createPractitionerFacility()` - practitioner-facility junction

## Deployment Notes

1. Deploy custom fields first (metadata depends on them)
2. Deploy Apex classes and test classes
3. Deploy LWC component
4. Deploy permission set
5. Assign permission set to care coordinator profiles
6. Add `providerDirectory` LWC to relevant App/Home pages via Lightning App Builder
