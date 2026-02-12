# ClickUp Navigation Best Practices

## Key Insights from SIMU Project

### Major Discovery: API Filter Limitations
The ClickUp API often **returns all tasks regardless of status filters**. This was discovered during the SIMU action items task where filtering by "ready for dev" or "in development" still returned the entire task list.

### Solution: Manual Filtering Required
Always manually review the returned task list and filter by:
1. Task name patterns (especially `[Client Task]` prefix)
2. Status field in the response
3. Due dates and assignees
4. Custom fields and task descriptions

## Systematic Task Discovery Workflow

### Step 1: Use the New "Client Task" Type Filter
- User created a "Client Task" type specifically for easier filtering
- This should be the primary method going forward
- Use this in `mcp__clickup__get_workspace_tasks` with appropriate type filters

### Step 2: Multi-Status Search Strategy
Don't rely on single status searches. Always check:
- `["in development", "ready for dev"]` together
- Include common variations: `["IN DEVELOPMENT", "READY FOR DEV"]` (uppercase)
- Check `["complete"]` for recently finished items that might need follow-up

### Step 3: Pattern-Based Name Searches  
Use `mcp__clickup__get_task` with `taskName` parameter to find tasks by patterns:
- Search for `"[Client Task]"` to find all client-related items
- Search for key stakeholder names: `"Yazeed"`, `"Sean"`, `"Ash"`
- Search for common terms: `"provide"`, `"create"`, `"complete"`

### Step 4: Manual ID Verification
When users provide specific task IDs (like they did with `86d0dvtr0` and `86d0e1xcu`), always check them individually as they might not appear in list searches.

## MCP Tools Usage Patterns

### Primary Search Tool
```
mcp__clickup__get_workspace_tasks
- Use list_ids: ["901610369300"] for SIMU SOW 1
- Try multiple status combinations
- Use detail_level: "summary" to avoid token limits
- Remember: API may ignore status filters
```

### Individual Task Lookup
```
mcp__clickup__get_task
- Use taskId when available (most reliable)
- Use taskName + listName for pattern searches
- Always include subtasks: true for complete context
```

### Task Type Filtering (New Feature)
With the new "Client Task" type, use:
- Custom field filtering in get_workspace_tasks
- Type-based searches (implementation TBD)

## Common Gotchas and Solutions

### Problem: "I searched for status but got everything"
**Solution:** The API often ignores status filters. Manually filter the returned results by checking the `status` field in each task summary.

### Problem: "Task exists but doesn't show up in searches"  
**Solution:** Task might be:
- In a different list than expected
- Have a slightly different status name
- Be archived or in a different state
- Use direct task ID lookup if known

### Problem: "Found some [Client Task] items but missed others"
**Solution:** 
- Use multiple search strategies (status, name patterns, individual lookups)
- Ask user if they know of specific task IDs
- Check recently created/updated tasks
- Verify with user: "Are there other tasks I should check?"

## Lessons from SIMU Project

### What We Missed Initially
1. **Task 86d0dvtr0**: "[Client Task] Ash & Yazeed to provide icon for agent" - Only found when user provided ID
2. **Task 86d0dr1k5**: "[Client Task] Create Teams chat for project coordination" - Found through name search
3. **Task 86d0e1xcu**: "📅 [Client Task] Provide list of public holidays and SIM shutdown days" - User had to point it out

### What Worked
1. **Direct task ID lookup**: Most reliable method
2. **Name pattern searches**: Found tasks when status filtering failed  
3. **Multiple status searches**: Caught tasks in different states
4. **User collaboration**: Ask user if they know of specific tasks

## Recommended Search Checklist

For comprehensive task discovery:

- [ ] Try `get_workspace_tasks` with status filters
- [ ] Manually review ALL returned tasks (ignore status parameter results)
- [ ] Search by name patterns: `[Client Task]`, stakeholder names
- [ ] Check individual task IDs if provided by user
- [ ] Use the new "Client Task" type filter when available
- [ ] Ask user: "Are there other specific tasks I should check?"
- [ ] Verify found tasks match user expectations
- [ ] Document any missed tasks for future reference

## Task Organization Tips

### Group by Urgency
- Overdue items first
- Current/immediate items
- Future items by date

### Include Context
- Due dates (converted to readable format)
- Stakeholder requirements (Sean's approval, Yazeed coordination)
- Format requirements (Excel/CSV, Yes/No, etc.)

### Verify Completeness
Always ask the user: "Does this list look complete, or are there other tasks you know about that I missed?"

## Future Improvements

1. **Leverage Client Task Type**: Once implemented, use this for more reliable filtering
2. **Create Task Discovery Agent**: Consider using the general-purpose agent for complex searches
3. **Maintain Task Database**: Track discovered task IDs for future reference
4. **User Verification Loop**: Always confirm completeness with user

## Emergency Fallback

If searches are not working:
1. Ask user for specific task IDs they know about
2. Use `get_task` for each individual ID
3. Use general-purpose Task agent for complex searches
4. Manually browse ClickUp interface if necessary

Remember: **It's better to ask the user for help than to miss critical tasks.**