# SIM Query System - Complete Implementation Guide
## Intelligent Query Routing with Validation & Source Attribution

### Project Overview
**Ticket**: 86d0ffj9x - 📝 US-03: Website Content & Knowledge Article Integration
**Architecture**: Smart Flow Orchestration with Response Validation

---

## Business Requirements & Evidence

### SOW Evidence (Section 2.0 - Solution Design)
- **Line 114**: "Content will be sourced from existing website https://www.sim.edu.sg/ along with SIM's Knowledge base"
- **Line 174**: "Configure Data Cloud to ingest SIM Website data, using the Web Crawler Connector. Configure Data Cloud vector database to be appropriately indexed."
- **Line 178 (OUT OF SCOPE for US-03)**: "If identified as Students or Alumni the Agent will only then reference the Knowledge Base" - This persona-based routing will be addressed in separate ticket.

### Stakeholder Evidence - Knowledge Article Management

*Saurav Shah (Technical Lead, Project Kickoff 2025-09-22):*
> "You can continuously update your knowledge articles, as in when, whenever you want, right? It can be before the project, during the project, after the project. It actually doesn't change anything for us because we will just be picking up those knowledge articles."

*Technical Discussion (Project Kickoff 2025-09-22):*
> "There is a search index that is created for knowledge articles. If you update the knowledge articles, search index gets refreshed. And that way, that search index is used by the agent... It's mostly, basically, auto-updated."

**⚠️ Technical Reality Check (Salesforce Documentation 2025):**
Per Salesforce Data Cloud documentation, search indexes do NOT auto-refresh in real-time. Index updates require:
1. Manual rebuild triggers, OR
2. Scheduled periodic refreshes

**IMPLEMENTATION DECISION REQUIRED**: Clarify refresh mechanism (manual vs scheduled) and acceptable latency between article updates and chatbot availability during technical design phase.

*Student Services (Kickoff):*
> "We have about 1,000 questions in our current chatbot... having free text with AI technology will actually help them."

### Technical Configuration

**Web Crawler Refresh Frequency:**
- Current Implementation Plan: 10 hours
- SOW Line 194 Reference: "Content will be updated on an Hourly basis"
- **⚠️ BUSINESS DECISION REQUIRED**: 10-hour vs 1-hour frequency
  - Impact Analysis: Cost, infrastructure load, content freshness requirements
  - Stakeholder Decision: Product Owner to confirm acceptable latency

**Knowledge Article Index Refresh:**
- Mechanism: TBD during technical design (manual trigger vs scheduled)
- Acceptable Latency: TBD - business requirement for "how fresh must answers be?"

**Content Source Prioritization:**
- Implementation: Query intent classification (NLP-based routing)
- Fallback Strategy: TBD if intent classification fails

---

## PART 1: VISUAL FLOW ARCHITECTURE

### Main Flow Graph: SIM_Query_Intelligence_Flow

```
┌──────────────┐
│    START     │
│  User Query  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────┐
│   ANALYZE QUERY INTENT   │
│  Classify: Policy/Current│
│    Program/General       │
└──────────┬───────────────┘
           │
           ▼
    ┌──────────────┐
    │   DECISION   │
    │ Route Query  │
    └──────────────┘
           │
    ┌──────┴──────┬───────────┬──────────────┐
    │             │           │              │
    ▼             ▼           ▼              ▼
┌─────────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐
│ POLICY  │ │ CURRENT  │ │ PROGRAM  │ │  GENERAL   │
│  PATH   │ │INFO PATH │ │   PATH   │ │    PATH    │
└─────────┘ └──────────┘ └──────────┘ └────────────┘
    │             │           │              │
    ▼             ▼           ▼              ▼
┌─────────┐ ┌──────────┐ ┌──────────────────────────┐
│   KB    │ │   WEB    │ │     BOTH SOURCES         │
│  ONLY   │ │   ONLY   │ │   (Parallel Query)       │
└─────────┘ └──────────┘ └──────────────────────────┘
    │             │                    │
    ▼             ▼                    ▼
┌──────────────────────────────────────────────────┐
│            VALIDATION DECISION                   │
│   Check: Found = TRUE or FALSE                   │
└──────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ BOTH FOUND   │ │  ONE FOUND   │ │  NONE FOUND  │
│ (Prioritize) │ │ (Use Valid)  │ │  (Apologize) │
└──────────────┘ └──────────────┘ └──────────────┘
        │               │               │
        └───────────────┴───────────────┘
                        │
                        ▼
                ┌──────────────┐
                │  SYNTHESIZE  │
                │   RESPONSE   │
                │ WITH SOURCE  │
                └──────────────┘
                        │
                        ▼
                ┌──────────────┐
                │     END      │
                │ Return Reply │
                └──────────────┘
```

### Detailed Path Flows

#### Path 1: Policy Query (Knowledge Only)
```
Query → Intent: POLICY → KB Retriever → Found? 
  → YES: Return with "Source: Official Knowledge Base"
  → NO: Return Apology
```

#### Path 2: Current Info Query (Web Only)
```
Query → Intent: CURRENT → Web Retriever → Found?
  → YES: Return with "Source: SIM Website"
  → NO: Return Apology
```

#### Path 3: Program/General Query (Both Sources - Refined Logic)
```
Query → Intent: PROGRAM/GENERAL → Parallel:
  ├─ KB Retriever → Found: TRUE/FALSE
  └─ Web Retriever → Found: TRUE/FALSE

Validation Matrix (REFINED):
  KB=TRUE, Web=TRUE, SAME content     → Prioritize KB (official source)
  KB=TRUE, Web=TRUE, DIFFERENT content → Analyze query intent:
                                          - News/updates query → Use Web
                                          - Academic/policy query → Use KB
  KB=TRUE, Web=FALSE  → Use KB only
  KB=FALSE, Web=TRUE  → Use Web only
  KB=FALSE, Web=FALSE → Apologize
```

---

## PART 2: IMPLEMENTATION SEQUENCE & DEPENDENCIES

### 📋 IMPLEMENTATION SEQUENCE

#### STEP 1: PRE-REQUISITES SETUP
**Order**: Must be completed first  
**Dependencies**: None

##### Infrastructure Setup
```yaml
□ Verify Data Cloud License & Permissions
□ Verify Existing Retrievers (Knowledge Article & Web Crawler)
□ Set Up Development Environment
□ Create Named Credentials (DataCloud_API_Credential)
□ Configure Permission Sets
□ Set Up Custom Metadata for configuration
```

---

#### STEP 2: PROMPT BUILDER TEMPLATES
**Order**: Create before Flow development  
**Dependencies**: Step 1 complete  
**Critical**: Flows cannot be built without working prompts

##### 2.1: Knowledge Retriever Prompt
**Order**: Create FIRST  
**Why**: Foundation for all KB queries
**Template Type**: Flex Template (REQUIRED for Flow compatibility)

```yaml
□ Create Prompt Template: SIM_Knowledge_Retriever_With_Validation
    - Type: Flex Template (CRITICAL: Only Flex works with Flows)
    - Category: Search & Summarize
□ Configure Grounding (Data Cloud Connection)
□ Define Input Variables (UserQuery, UserType, MinConfidence)
□ Define Output Structure (ResponseContent, Found, Confidence, SourceInfo)
□ Test Prompt Individually
□ Validate Output Structure & Found Flag
□ Verify Flow Action Availability (should appear in Flow Action list)
```

##### 2.2: Web Crawler Retriever Prompt
**Order**: Create SECOND  
**Dependencies**: Knowledge prompt complete
**Template Type**: Flex Template (REQUIRED for Flow compatibility)

```yaml
□ Create Prompt Template: SIM_Web_Crawler_Retriever_With_Validation
    - Type: Flex Template (CRITICAL: Only Flex works with Flows)
    - Category: Search & Summarize
□ Configure Grounding with Exclusion Rules
□ Define Variables (Same structure as KB prompt)
□ Test Web Prompt Individually
□ Validate Exclusion Logic
□ Verify Flow Action Availability (should appear in Flow Action list)
```

##### 2.3: Response Synthesis Prompt
**Order**: Create THIRD  
**Dependencies**: Both retriever prompts complete
**Template Type**: Flex Template (REQUIRED for Flow compatibility)

```yaml
□ Create Synthesis Template: SIM_Response_Synthesis_With_Priority
    - Type: Flex Template (CRITICAL: Only Flex works with Flows)
    - Category: Generate
□ Define Input Variables for both sources
□ Define Output Variables with source attribution
□ Test Synthesis Logic (all 4 scenarios)
□ Validate Source Attribution appears correctly
□ Verify Flow Action Availability (should appear in Flow Action list)
```

---

#### STEP 3: FLOW DEVELOPMENT
**Order**: After all prompts are working  
**Dependencies**: All Prompt Templates complete  
**Critical**: Core system logic

##### 3.1: Create Subflow First
**Order**: BEFORE main flow  
**Why**: Main flow depends on this

```yaml
□ Create Parallel Subflow: SIM_Parallel_Retriever_Validation
□ Define Subflow Input/Output Variables
□ Build Parallel Branch Structure
□ Add Prompt Actions to Branches
□ Test Subflow in Isolation
```

##### 3.2: Create Main Orchestration Flow
**Order**: After subflow complete  
**Dependencies**: Subflow + all prompts ready

```yaml
□ Create Main Flow: SIM_Query_Intelligence_Flow
□ Define Main Flow Variables
□ Build Flow Elements in Sequence:
  1. START
  2. Analyze_Query_Intent (Assignment)
  3. Decision_Route_By_Intent
  4. Single source action paths
  5. Subflow call path
  6. Validation decisions
  7. Response synthesis
  8. Apology handler
  9. END elements
```

##### 3.3: Build Core Logic Elements
**Order**: Sequential within main flow

```yaml
□ Create Intent Classification Assignment
□ Create Routing Decision Logic
□ Create Single Source Actions (KB Only, Web Only)
□ Create Validation Decision Tree
□ Create Response Generation Actions
```

---

#### STEP 4: ERROR HANDLING & FAULT PATHS
**Order**: After core flow complete  
**Dependencies**: Working main flow

```yaml
□ Add Fault Connectors to all Action Elements
□ Create Fault Handler Elements
□ Create Error Response Assignment
□ Add Error Logging (Optional)
□ Set Action Timeouts
□ Configure Retry Logic
□ Test Timeout Scenarios
```

---

#### STEP 5: INTEGRATION & TESTING
**Order**: After complete flow with error handling  
**Dependencies**: Complete system

```yaml
□ Activate All Components
□ Create Flow Test Runner
□ Test Data Cloud Connections
□ Test All Query Intent Types
□ Test All Validation Scenarios
□ Test Edge Cases
□ Test Error Scenarios
□ Verify Source Attribution in All Responses
□ Validate Attribution Formats
□ Test Confidence Indicators
```

---

#### STEP 6: PERFORMANCE OPTIMIZATION
**Order**: After full system working  
**Dependencies**: Tested system

```yaml
□ Add Performance Logging
□ Set Performance Thresholds
□ Identify Bottlenecks
□ Implement Caching (If Needed)
□ Optimize Prompt Templates
□ Fine-tune Parallel Execution
```

---

#### STEP 7: USER INTERFACE & DEPLOYMENT
**Order**: After optimized system  
**Dependencies**: Performance-tuned system

```yaml
□ Build Screen Flow UI (If Needed)
□ Create Lightning Component (Alternative)
□ Add to Lightning App
□ Deploy to Production Org
□ Configure Production Settings
□ Create User Documentation
```

---

#### STEP 8: MONITORING & MAINTENANCE
**Order**: After production deployment  
**Dependencies**: Live system

```yaml
□ Create Monitoring Dashboard
□ Set Up Alerts
□ Regular Health Checks
```

---

### 🔄 DEPENDENCY DIAGRAM

```
Infrastructure Setup
         │
         ▼
Prompt Templates (KB → Web → Synthesis)
         │
         ▼
Flow Development (Subflow → Main Flow)
         │
         ▼
Error Handling
         │
         ▼
Integration & Testing
         │
         ▼
Performance Optimization
         │
         ▼
UI & Deployment
         │
         ▼
Monitoring & Maintenance
```

### ⚠️ CRITICAL SUCCESS FACTORS

1. **Use ONLY Flex Templates**: Standard/Advanced templates cannot be called from Flows
2. **Create Prompts First**: Flows cannot be built without working prompts
3. **Build Subflow Before Main Flow**: Main flow depends on subflow
4. **Test Each Component Individually**: Don't test the system until parts work
5. **Validate All 6 Scenarios**: The validation matrix is critical
6. **Source Attribution Must Work**: Every response needs proper attribution
7. **Error Handling is Essential**: Users must never see technical errors
8. **Verify Flow Actions**: Each Flex Template should appear in Flow Action picker

### 📊 BUILD ORDER SUMMARY

| Step | Component | Dependency |
|------|-----------|------------|
| 1 | Infrastructure | None |
| 2.1 | KB Prompt | Infrastructure |
| 2.2 | Web Prompt | KB Prompt |
| 2.3 | Synthesis Prompt | Both Retriever Prompts |
| 3.1 | Subflow | All Prompts |
| 3.2 | Main Flow | Subflow |
| 4 | Error Handling | Main Flow |
| 5 | Testing | Complete System |
| 6 | Optimization | Tested System |
| 7 | Deployment | Optimized System |
| 8 | Monitoring | Live System |

---

## PART 3: DETAILED FLOW SPECIFICATION

### Flow Variables with Validation

```yaml
Variables:
  # Input Variables
  var_UserQuery (Text) - User's question
  var_UserType (Text) - Student/Prospect/Alumni
  var_SessionId (Text) - For tracking
  
  # Query Analysis
  var_QueryIntent (Text) - POLICY/CURRENT/PROGRAM/GENERAL
  var_RequiresBothSources (Boolean) - Determines retriever usage
  
  # Retriever Results
  var_KnowledgeResults (Text) - KB query results
  var_KnowledgeFound (Boolean) - TRUE if KB found results
  var_KnowledgeConfidence (Number) - 0.0 to 1.0
  
  var_WebResults (Text) - Web query results  
  var_WebFound (Boolean) - TRUE if web found results
  var_WebConfidence (Number) - 0.0 to 1.0
  
  # Response Generation
  var_FinalResponse (Text) - Synthesized response
  var_SourceAttribution (Text) - Source description
  var_ResponseSuccess (Boolean) - Overall success flag
```

### Core Flow Elements

#### 1. Query Intent Analysis (Enhanced)
```yaml
Element: Analyze_Query_Intent
Type: Assignment
Description: Comprehensive query analysis

Assignments:
  1. var_QueryIntent = 
     IF(
       OR(
         CONTAINS(LOWER({!var_UserQuery}), "policy"),
         CONTAINS(LOWER({!var_UserQuery}), "requirement"),
         CONTAINS(LOWER({!var_UserQuery}), "regulation"),
         CONTAINS(LOWER({!var_UserQuery}), "guideline"),
         CONTAINS(LOWER({!var_UserQuery}), "rule")
       ),
       "POLICY",
       IF(
         OR(
           CONTAINS(LOWER({!var_UserQuery}), "latest"),
           CONTAINS(LOWER({!var_UserQuery}), "upcoming"),
           CONTAINS(LOWER({!var_UserQuery}), "event"),
           CONTAINS(LOWER({!var_UserQuery}), "news"),
           CONTAINS(LOWER({!var_UserQuery}), "today"),
           CONTAINS(LOWER({!var_UserQuery}), "this week")
         ),
         "CURRENT",
         IF(
           OR(
             CONTAINS(LOWER({!var_UserQuery}), "program"),
             CONTAINS(LOWER({!var_UserQuery}), "course"),
             CONTAINS(LOWER({!var_UserQuery}), "admission"),
             CONTAINS(LOWER({!var_UserQuery}), "degree")
           ),
           "PROGRAM",
           "GENERAL"
         )
       )
     )
  
  2. var_RequiresBothSources = 
     IF(
       OR(
         var_QueryIntent = "PROGRAM",
         var_QueryIntent = "GENERAL",
         AND(
           CONTAINS(LOWER({!var_UserQuery}), "compare"),
           CONTAINS(LOWER({!var_UserQuery}), "difference")
         )
       ),
       TRUE,  # Needs both sources
       FALSE  # Single source sufficient
     )

Next: Decision_Route_By_Intent
```

#### 2. Routing Decision (Smart Router)
```yaml
Element: Decision_Route_By_Intent
Type: Decision

Outcomes:
  1. Policy_Single_Source
     Conditions: 
       - var_QueryIntent = "POLICY"
       - var_RequiresBothSources = FALSE
     Next: Action_Query_Knowledge_Validate
  
  2. Current_Single_Source
     Conditions:
       - var_QueryIntent = "CURRENT"
       - var_RequiresBothSources = FALSE
     Next: Action_Query_Web_Validate
  
  3. Requires_Both_Sources
     Conditions:
       - var_RequiresBothSources = TRUE
     Next: Subflow_Parallel_Query_Both
  
  4. Fallback_Both (Default)
     Next: Subflow_Parallel_Query_Both
```

#### 3. Knowledge Query with Validation
```yaml
Element: Action_Query_Knowledge_Validate
Type: Action (Prompt)

Configuration:
  Prompt: SIM_Knowledge_Retriever_With_Validation
  
  Inputs:
    UserQuery: {!var_UserQuery}
    UserType: {!var_UserType}
    RequireValidation: TRUE
    MinConfidence: 0.7
  
  Outputs:
    ResponseContent → var_KnowledgeResults
    Found → var_KnowledgeFound
    Confidence → var_KnowledgeConfidence
    SourceInfo → var_SourceAttribution

Next: Decision_Check_Knowledge_Found
```

#### 4. Validation Decision Tree
```yaml
Element: Decision_Check_Knowledge_Found
Type: Decision

Outcomes:
  1. Found_Valid_Answer
     Conditions:
       - var_KnowledgeFound = TRUE
       - var_KnowledgeConfidence >= 0.7
     Next: Action_Generate_KB_Response
  
  2. Low_Confidence_Answer
     Conditions:
       - var_KnowledgeFound = TRUE
       - var_KnowledgeConfidence < 0.7
     Next: Decision_Try_Web_Fallback
  
  3. No_Answer_Found
     Conditions:
       - var_KnowledgeFound = FALSE
     Next: Action_Generate_Apology
```

#### 5. Parallel Query Subflow (Both Sources)
```yaml
Element: Subflow_Parallel_Query_Both
Type: Subflow

Configuration:
  Flow: SIM_Parallel_Retriever_Validation
  
  Inputs:
    UserQuery: {!var_UserQuery}
    UserType: {!var_UserType}
  
  Outputs:
    KB_Content → var_KnowledgeResults
    KB_Found → var_KnowledgeFound
    KB_Confidence → var_KnowledgeConfidence
    
    Web_Content → var_WebResults
    Web_Found → var_WebFound
    Web_Confidence → var_WebConfidence

Next: Decision_Validate_Both_Results
```

#### 6. Both Sources Validation Matrix
```yaml
Element: Decision_Validate_Both_Results
Type: Decision

Outcomes:
  1. Both_Found_Success
     Conditions:
       - var_KnowledgeFound = TRUE
       - var_WebFound = TRUE
     Next: Action_Synthesize_Prioritize_KB
  
  2. Only_KB_Found
     Conditions:
       - var_KnowledgeFound = TRUE
       - var_WebFound = FALSE
     Next: Action_Generate_KB_Response
  
  3. Only_Web_Found
     Conditions:
       - var_KnowledgeFound = FALSE
       - var_WebFound = TRUE
     Next: Action_Generate_Web_Response
  
  4. Neither_Found (Default)
     Next: Action_Generate_Apology
```

#### 7. Response Synthesis with Priority
```yaml
Element: Action_Synthesize_Prioritize_KB
Type: Action (Prompt)

Configuration:
  Prompt: SIM_Response_Synthesis_With_Priority
  
  Inputs:
    Query: {!var_UserQuery}
    KBContent: {!var_KnowledgeResults}
    KBConfidence: {!var_KnowledgeConfidence}
    WebContent: {!var_WebResults}
    WebConfidence: {!var_WebConfidence}
    PrioritySource: "KNOWLEDGE"
    
  Outputs:
    FinalResponse → var_FinalResponse
    Attribution → var_SourceAttribution

Next: End_Success
```

#### 8. Apology Handler
```yaml
Element: Action_Generate_Apology
Type: Assignment

Assignments:
  var_FinalResponse = 
    "I apologize, but I couldn't find specific information about your 
     query in our knowledge base or website. This might be because:
     
     • The information you're looking for may not be available yet
     • Your question might need clarification
     • This topic might be handled by a specific department
     
     Please contact our support team at support@sim.edu or call 
     +65-6248-9746 for personalized assistance.
     
     Source: System Message"
     
  var_ResponseSuccess = FALSE
  var_SourceAttribution = "No matching content found"

Next: End_With_Apology
```

---

## SUBFLOW: SIM_Parallel_Retriever_Validation

### Subflow Variables
```yaml
Input:
  - sub_UserQuery (Text)
  - sub_UserType (Text)

Output:
  - sub_KnowledgeResults (Text)
  - sub_KnowledgeFound (Boolean)
  - sub_KnowledgeConfidence (Number)
  - sub_WebResults (Text)
  - sub_WebFound (Boolean)
  - sub_WebConfidence (Number)
```

### Subflow Elements
```yaml
1. START
   ↓
2. Parallel_Branch
   ├─ Branch 1: Action_Get_Knowledge
   │  └─ Prompt: SIM_Knowledge_Retriever_With_Validation
   │     Output → sub_KnowledgeResults, sub_KnowledgeFound, sub_KnowledgeConfidence
   │
   └─ Branch 2: Action_Get_Web
      └─ Prompt: SIM_Web_Crawler_Retriever_With_Validation
         Output → sub_WebResults, sub_WebFound, sub_WebConfidence
   ↓
3. END (Return to Main Flow)
```

---

## PART 4: PROMPT TEMPLATE TYPES & FLOW COMPATIBILITY

### ⚠️ CRITICAL: Template Type Requirements

**For Salesforce Flow Integration, you MUST use Flex Templates**

#### Template Type Comparison:

| Template Type | Flow Compatible | Use Case | Can Call from Flow |
|---------------|----------------|----------|--------------------|
| **Flex Template** | ✅ YES | Custom logic with inputs/outputs | ✅ YES |
| Standard Template | ❌ NO | Simple text generation | ❌ NO |
| Advanced Template | ❌ NO | Complex AI workflows | ❌ NO |

#### Why Flex Templates are Required:
- **Flow Action Integration**: Only Flex Templates appear in the Flow Action picker
- **Input/Output Mapping**: Flex Templates support variable mapping to/from Flows
- **Dynamic Content**: Can process Flow variables and return structured responses
- **Validation Support**: Can return structured JSON for validation logic

#### Flex Template Configuration:
```yaml
Template Setup:
  Type: Flex Template
  Model: GPT-4 (or your org's configured LLM)
  Input Variables: 
    - Define all inputs that Flow will pass
    - Set default values where appropriate
  Output Variables:
    - Define structured outputs for Flow to capture
    - Include validation flags (found, confidence)
  
Flow Integration:
  - Template appears in Flow Builder Action picker
  - Can be dragged into Flow as Action element
  - Input/Output mapping available in Flow
```

#### Template Creation Checklist:
```yaml
□ Select "Flex Template" (NOT Standard or Advanced)
□ Configure Input Variables with appropriate data types
□ Define Output Variables matching Flow requirements  
□ Test template individually before Flow integration
□ Verify template appears in Flow Action picker
□ Confirm input/output mapping works in Flow Builder
```

---

## PART 5: ENHANCED PROMPT TEMPLATES WITH VALIDATION

### Template 1: Knowledge Article Retriever Prompt

```yaml
Prompt Name: SIM_Knowledge_Retriever_With_Validation
Prompt Type: Flex Template (REQUIRED for Flow Integration)
Template Category: Search & Summarize
Model Configuration: GPT-4 / Claude-3
Flow Compatibility: YES - Only Flex Templates can be called from Salesforce Flows
```

**⚠️ Important**: Only Flex Templates can be used with Salesforce Flows. Standard and Advanced templates cannot be invoked from Flow actions.

#### Prompt Template Content:
```liquid
# Knowledge Article Search Prompt

## System Context
You are searching the SIM Knowledge Article database containing official policies, 
requirements, and authoritative information for students and prospects.

## User Query
{{UserQuery}}

## User Context
- User Type: {{UserType}}
- Session ID: {{SessionId}}
- Minimum Confidence: {{MinConfidence | default: 0.7}}

## Instructions
Search the knowledge article database and:

1. Find the most relevant articles that answer the user's question
2. Focus on official policies, requirements, and guidelines
3. Prioritize the most recent and comprehensive articles
4. Extract key information that directly addresses the query

## Search Strategy
{% if UserQuery contains "admission" %}
  - Priority: Admission requirements, deadlines, criteria
  - Include: Application process, documentation needed
{% elsif UserQuery contains "program" or UserQuery contains "course" %}
  - Priority: Program details, curriculum, duration
  - Include: Prerequisites, outcomes, accreditation
{% elsif UserQuery contains "fee" or UserQuery contains "cost" %}
  - Priority: Tuition fees, payment schedules
  - Include: Financial aid, scholarships
{% else %}
  - General search across all article categories
{% endif %}

## Grounding Configuration
- Data Source: {{!Data_Cloud.Knowledge_Article_Retriever}}
- Search Fields: [Title, Summary, Body, Keywords]
- Filters: 
  - Status = Published
  - Language = English
  - RecordType = Knowledge Article
- Max Results: 10
- Relevance Threshold: 0.7

## Response Validation Logic
Determine if answer was found:
- If relevance_score >= 0.7 AND content addresses query: found = TRUE
- If relevance_score < 0.7 OR content partially relevant: found = TRUE, lower confidence
- If no relevant content found: found = FALSE

## REQUIRED Response Structure
```json
{
  "found": boolean (TRUE/FALSE),
  "confidence": number (0.0-1.0),
  "response_content": {
    "answer": "Direct answer to query if found",
    "key_points": ["point1", "point2"],
    "additional_context": "Supporting information"
  },
  "source_articles": [
    {
      "id": "KB001234",
      "title": "Article Title",
      "relevance": 0.95,
      "excerpt": "Relevant excerpt",
      "last_updated": "2024-01-15"
    }
  ],
  "source_attribution": "Official SIM Knowledge Base - [Article Title(s)]",
  "metadata": {
    "search_timestamp": "{{NOW}}",
    "total_articles_searched": number,
    "articles_matched": number
  }
}
```

## Content Extraction Rules
{% if found == TRUE %}
### When Content Found:
Extract and format:
1. Direct answer addressing the query
2. Supporting details from the article
3. Any important conditions or exceptions
4. Related information that might be helpful

Always cite specific article IDs and titles.

{% else %}
### When No Content Found:
Return:
{
  "found": false,
  "confidence": 0.0,
  "response_content": {
    "answer": "No matching content found in knowledge base"
  },
  "source_attribution": "Search completed - No results",
  "metadata": {
    "search_timestamp": "{{NOW}}",
    "suggestion": "Try rephrasing your query or contact support"
  }
}
{% endif %}

## Quality Checks
Before returning response, verify:
- [ ] Found indicator is set (TRUE/FALSE)
- [ ] Confidence score is between 0.0 and 1.0
- [ ] Source attribution is included
- [ ] Response directly addresses the query (if found)
- [ ] Article citations are included (if found)
```

### Template 2: Web Crawler Retriever Prompt

```yaml
Prompt Name: SIM_Web_Crawler_Retriever_With_Validation
Prompt Type: Flex Template (REQUIRED for Flow Integration)
Template Category: Search & Summarize
Model Configuration: GPT-4 / Claude-3
Flow Compatibility: YES - Only Flex Templates can be called from Salesforce Flows
```

**⚠️ Important**: This must be a Flex Template to enable Flow action invocation.

#### Prompt Template Content:
```liquid
# Website Content Retriever with Result Validation

## System Role
You are searching SIM's website for current information.
You MUST indicate whether relevant content was found.

## Query Input
User Query: {{UserQuery}}
User Type: {{UserType}}
Session ID: {{SessionId}}
Excluded Paths: {{ExcludePaths | default: "/professional-development/,/enterprise/"}}

## Search Instructions
1. Search website content thoroughly
2. Exclude specified paths
3. Determine if relevant content exists
4. Return validation flags with response

## Grounding Configuration
- Data Source: {{!Data_Cloud.Web_Crawler_Retriever}}
- Search Fields: [content, title, meta_description, url, headers]
- Exclusions: 
  {% for path in ExcludePaths %}
  - Exclude: {{path}}
  {% endfor %}
- Max Results: 10
- Freshness Weight: 0.4
- Relevance Threshold: 0.6

## Content Validation Rules
Set found = TRUE when:
- Content directly answers the query
- Content provides relevant current information
- Content is from non-excluded sections

Set found = FALSE when:
- No relevant pages found
- Only outdated content available
- All relevant content is in excluded sections

## REQUIRED Response Structure
```json
{
  "found": boolean (TRUE/FALSE),
  "confidence": number (0.0-1.0),
  "response_content": {
    "answer": "Current information from website",
    "highlights": ["key point 1", "key point 2"],
    "updates": "Recent changes or announcements"
  },
  "source_pages": [
    {
      "url": "https://www.sim.edu.sg/page",
      "title": "Page Title",
      "last_crawled": "2024-01-20",
      "relevance": 0.85,
      "excerpt": "Relevant content excerpt"
    }
  ],
  "source_attribution": "SIM Website - [Page Title(s)]",
  "metadata": {
    "search_timestamp": "{{NOW}}",
    "pages_searched": number,
    "pages_matched": number,
    "excluded_results": number
  }
}
```

## Response Generation
{% if found == TRUE %}
### Content Found - Format Response:
1. Provide current information from website
2. Include dates for time-sensitive content
3. Highlight any upcoming events or deadlines
4. Link to source pages

Source line MUST include:
"Source: SIM Website - {{page_title}} (Updated: {{last_crawled}})"

{% else %}
### No Content Found - Return:
{
  "found": false,
  "confidence": 0.0,
  "response_content": {
    "answer": "No current information found on website"
  },
  "source_attribution": "Website search completed - No results",
  "metadata": {
    "suggestion": "Information may not be published yet"
  }
}
{% endif %}

## Special Handling for Time-Sensitive Content
If content contains dates/deadlines:
- Clearly indicate the date context
- Note if information might be outdated
- Suggest verifying if critical
```

### Template 3: Response Synthesis with Source Priority

```yaml
Prompt Name: SIM_Response_Synthesis_With_Priority
Prompt Type: Flex Template (REQUIRED for Flow Integration)
Template Category: Generate
Model Configuration: GPT-4 / Claude-3
Flow Compatibility: YES - Only Flex Templates can be called from Salesforce Flows
```

**⚠️ Important**: Must be Flex Template for Flow integration. Standard templates cannot be used in this architecture.

#### Prompt Template Content:
```liquid
# Response Synthesis with Intelligent Prioritization

## System Role
Synthesize responses from multiple sources with clear attribution.
Apply intelligent prioritization based on content availability.

## Input Data
Query: {{UserQuery}}
User Type: {{UserType}}

### Knowledge Base Results
Found: {{KBFound}}
Confidence: {{KBConfidence}}
Content: {{KBContent}}

### Website Results  
Found: {{WebFound}}
Confidence: {{WebConfidence}}
Content: {{WebContent}}

## Prioritization Matrix

{% if KBFound == TRUE and WebFound == TRUE %}
### SCENARIO: Both Sources Have Content
Priority: Knowledge Base (Official Information)
Strategy: 
  - Lead with KB answer
  - Supplement with current web info
  - Note any discrepancies
  
Attribution: "Source: Official Knowledge Base with current website updates"

{% elsif KBFound == TRUE and WebFound == FALSE %}
### SCENARIO: Only Knowledge Base Has Content
Priority: Knowledge Base Only
Strategy:
  - Use KB content exclusively
  - Note this is from official documentation
  
Attribution: "Source: Official SIM Knowledge Base"

{% elsif KBFound == FALSE and WebFound == TRUE %}
### SCENARIO: Only Website Has Content
Priority: Website Only
Strategy:
  - Use web content exclusively
  - Note this is current but may not be official policy
  
Attribution: "Source: SIM Website (Current Information)"

{% else %}
### SCENARIO: No Content Found
This should not reach synthesis - should go to apology handler
Attribution: "No relevant information found"
{% endif %}

## Response Generation Template

{% if KBFound == TRUE or WebFound == TRUE %}

### Generate Structured Response:

**Opening Statement:**
{{primary_answer}}

{% if KBFound == TRUE and WebFound == TRUE %}
**From Official Documentation:**
{{kb_key_points}}

**Current Website Information:**
{{web_updates}}

{% if kb_content != web_content %}
📝 Note: We're showing information from our official knowledge base. 
For the most current details, you may also want to check our website 
or contact admissions.
{% endif %}
{% endif %}

**Source Attribution Line (REQUIRED):**
─────────────────────────────
{% if KBFound == TRUE and WebFound == TRUE %}
📚 Sources: Official Knowledge Base + SIM Website
{% elsif KBFound == TRUE %}
📚 Source: Official SIM Knowledge Base - {{kb_article_title}}
{% elsif WebFound == TRUE %}
🌐 Source: SIM Website - {{web_page_title}} (Updated: {{web_date}})
{% endif %}

{% if confidence < 0.8 %}
ℹ️ Confidence Note: This answer may be partial. For complete information, 
please contact support@sim.edu
{% endif %}

{% else %}
### No Information Available
Should not reach this point - handled by apology flow
{% endif %}

## Final Output Structure
```json
{
  "final_response": "{{synthesized_answer_with_formatting}}",
  "source_attribution": "{{attribution_text}}",
  "confidence_level": {{overall_confidence}},
  "sources_used": ["{{list_of_sources}}"],
  "response_metadata": {
    "kb_used": {{KBFound}},
    "web_used": {{WebFound}},
    "synthesis_method": "{{method_used}}",
    "timestamp": "{{NOW}}"
  }
}
```

## Conflict Resolution Rules

When KB and Web content conflict:
1. Always prioritize Knowledge Base for:
   - Policies and regulations
   - Admission requirements
   - Academic rules
   - Fee structures

2. Prioritize Website for:
   - Events and dates
   - Current promotions
   - News and announcements
   - Contact information

3. When unclear, include both with notation:
   "According to our official documentation... 
    However, our website currently shows..."

## Source Attribution Requirements

EVERY response MUST include one of these attribution formats:

1. Single Source:
   - "Source: Official SIM Knowledge Base - [Article Name]"
   - "Source: SIM Website - [Page Title]"

2. Multiple Sources:
   - "Sources: Knowledge Base + Website"
   - "Primary Source: Knowledge Base | Also Referenced: Website"

3. With Confidence Indicator:
   - "Source: Knowledge Base (High Confidence)"
   - "Source: Website (Moderate Confidence - Verify if Critical)"

## Error Prevention
Before returning response, verify:
- [ ] Source attribution is included
- [ ] Attribution specifies KB, Web, or Both
- [ ] Confidence level is indicated if < 0.8
- [ ] Any conflicts are explicitly noted
- [ ] Response addresses original query
```

---

## PART 6: VALIDATION FLOW LOGIC

### Validation Decision Matrix

| KB Found | Web Found | Content Match | Query Intent | KB Conf | Web Conf | Action | Source Attribution |
|----------|-----------|---------------|--------------|---------|----------|--------|----------------------|
| TRUE | TRUE | SAME | Any | High | High | Use KB Priority | "Official KB (Verified)" |
| TRUE | TRUE | DIFFERENT | News/Updates | Any | High | Use Web | "SIM Website (Current)" |
| TRUE | TRUE | DIFFERENT | Academic/Policy | High | Any | Use KB | "Official KB (Authoritative)" |
| TRUE | TRUE | DIFFERENT | Unclear | High | Low | Use KB Only | "Official KB (Verified)" |
| TRUE | TRUE | DIFFERENT | Unclear | Low | High | Merge Both | "Website + KB Reference" |
| TRUE | FALSE | N/A | Any | Any | N/A | Use KB | "Official Knowledge Base" |
| FALSE | TRUE | N/A | Any | N/A | Any | Use Web | "SIM Website" |
| FALSE | FALSE | N/A | N/A | N/A | N/A | Apologize | "Information Not Available" |

### Confidence Scoring Rules

```yaml
Confidence Calculation:
  High: >= 0.8
  Medium: 0.6 - 0.79
  Low: < 0.6
  
Minimum Threshold for Valid Answer: 0.6

Actions by Confidence:
  High: Return answer directly
  Medium: Return answer with verification note
  Low: Try alternative source or suggest contact support
```

---

## PART 7: ERROR HANDLING & EDGE CASES

### Comprehensive Error Scenarios

```yaml
Error Handlers:

1. Timeout Errors:
   If Prompt Timeout:
     - Try cached response
     - If no cache: Return partial answer
     - Add note: "Full search incomplete"

2. Data Cloud Connection Failure:
   If Connection Error:
     - Log error
     - Return: "System temporarily unavailable"
     - Suggest: "Please try again in a few moments"

3. Invalid Query Detection:
   If Query Contains Blocked Terms:
     - Return: "This query cannot be processed"
     - Log for review

4. Ambiguous Query:
   If Confidence < 0.4 for all sources:
     - Return: "Could you please clarify your question?"
     - Provide suggestions based on partial matches
```

---

## Summary

This implementation guide provides:

1. **Clear Visual Flow**: Shows all decision paths and validation logic
2. **Step-by-Step Sequence**: Exact order of creation with dependencies
3. **Detailed Technical Specs**: Complete flow and prompt configurations
4. **Validation Framework**: Smart prioritization and source attribution
5. **Error Handling**: Comprehensive fault tolerance
6. **Testing Strategy**: Validation for all scenarios

The system ensures users always get the best possible answer with clear source attribution, and gracefully handles cases where information isn't available.