# Get Messaging Session Transcript

## Purpose
Retrieve the actual conversation transcript from a Salesforce MessagingSession record using the `getConvTscpForRecord` REST API action.

## Prerequisites
- Connected to the target Salesforce org via SF CLI (`sf org login`)
- Org alias configured (e.g., `sim-staging`)

## Quick Command

### Get Transcript by MessagingSession ID
```bash
sf api request rest "/services/data/v60.0/actions/standard/getConvTscpForRecord" \
  --method POST \
  --body '{"inputs":[{"recordId":"<MESSAGING_SESSION_ID>"}]}' \
  --target-org <ORG_ALIAS>
```

### Example
```bash
sf api request rest "/services/data/v60.0/actions/standard/getConvTscpForRecord" \
  --method POST \
  --body '{"inputs":[{"recordId":"0Mw85000005VRpCCAW"}]}' \
  --target-org sim-staging
```

## Response Format
```json
[
  {
    "actionName": "getConvTscpForRecord",
    "isSuccess": true,
    "outputValues": {
      "conversationTranscript": "( 0s ) Chatbot: Hello! ... <br>( 45s ) EndUser: ... <br>"
    }
  }
]
```

The `conversationTranscript` field contains the full conversation with:
- Timestamps in parentheses: `( 0s )`, `( 1m 8s )`
- Actor prefix: `Chatbot:` or `EndUser:`
- Messages separated by `<br>` tags

## Workflow: Find and Retrieve Transcripts

### Step 1: List Recent MessagingSessions
```bash
sf data query --query "SELECT Id, Name, CreatedDate, Status, LeadId, ConversationSummary__c FROM MessagingSession WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 10" --target-org <ORG_ALIAS> --result-format json
```

### Step 2: Get Transcript for Specific Session
```bash
sf api request rest "/services/data/v60.0/actions/standard/getConvTscpForRecord" \
  --method POST \
  --body '{"inputs":[{"recordId":"<ID_FROM_STEP_1>"}]}' \
  --target-org <ORG_ALIAS>
```

### Step 3: Parse Transcript for Readability (Optional)
```bash
# Pipe through jq and sed to format nicely
sf api request rest "/services/data/v60.0/actions/standard/getConvTscpForRecord" \
  --method POST \
  --body '{"inputs":[{"recordId":"0Mw85000005VRpCCAW"}]}' \
  --target-org sim-staging 2>&1 | \
  grep -o '"conversationTranscript": "[^"]*"' | \
  sed 's/<br>/\n/g' | \
  sed 's/"conversationTranscript": "//g' | \
  sed 's/"$//g'
```

## Batch Retrieval: Multiple Sessions

To get transcripts for multiple sessions, use a loop:
```bash
for ID in 0Mw85000005VRpCCAW 0Mw85000005W4IXCA0; do
  echo "=== Transcript for $ID ==="
  sf api request rest "/services/data/v60.0/actions/standard/getConvTscpForRecord" \
    --method POST \
    --body "{\"inputs\":[{\"recordId\":\"$ID\"}]}" \
    --target-org sim-staging 2>&1 | \
    grep -o '"conversationTranscript": "[^"]*"'
  echo ""
done
```

## Filter Sessions by Criteria

### Find Sessions with Specific Lead
```bash
sf data query --query "SELECT Id, Name FROM MessagingSession WHERE LeadId = '00Q8500000FNq26EAD'" --target-org sim-staging --result-format json
```

### Find Sessions from Yesterday
```bash
sf data query --query "SELECT Id, Name, ConversationSummary__c FROM MessagingSession WHERE CreatedDate = YESTERDAY ORDER BY CreatedDate DESC" --target-org sim-staging --result-format json
```

### Find Sessions with Parent Leads
```bash
sf data query --query "SELECT m.Id, m.Name, m.LeadId, l.Prospect_Sub_Type__c FROM MessagingSession m, Lead l WHERE m.LeadId = l.Id AND l.Prospect_Sub_Type__c = 'Parent' ORDER BY m.CreatedDate DESC LIMIT 10" --target-org sim-staging --result-format json
```

## Technical Notes

### Why Not SOQL on ConversationEntry?
For Messaging for In-App and Web (MIAW), conversation messages are stored **off-platform** in a separate database. The `ConversationEntry` object will return empty results via SOQL. The `getConvTscpForRecord` action is the only reliable way to retrieve transcripts.

### Supported Record Types
The `getConvTscpForRecord` action supports:
- `MessagingSession` (MIAW, SMS, WhatsApp, Facebook)
- `VoiceCall`
- `LiveChatTranscript`

### API Version
Minimum API version: v60.0 (tested and working)

## Troubleshooting

### Empty Transcript
- Session may still be active (transcript available after session ends)
- Check if `Status = 'Ended'` on the MessagingSession

### NOT_FOUND Error
- Verify the MessagingSession ID is correct
- Ensure you're connected to the correct org

### Permission Issues
- User needs "Access Conversation Entries" permission
- Available in API version 50.0+
