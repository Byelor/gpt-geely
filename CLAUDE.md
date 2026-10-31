
<!-- BACKLOG.MD MCP GUIDELINES START -->
<!-- backlog.md-instructions-version: 1.54.0 -->

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_backlog_instructions()` to load the tool-oriented overview. Use the `instruction` selector when you need `task-creation`, `task-execution`, or `task-finalization`.

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->

## GRAPHIFY ↔ BACKLOG INTEGRATION

`graphify-out/graph.json` is this project's knowledge graph. Backlog tasks and the graph must stay in sync:

- **Before executing a task:** run `graphify query "<task title or topic>"` to find the affected files, nodes and communities instead of grepping blindly. Record the relevant node/community names in the task's plan or notes.
- **After completing a task** that changed code or docs: run `graphify update` (code only, no LLM) or `/graphify --update` (docs/images) so the graph reflects the finished work.
- **Before creating a task:** check `list_tasks` first and the graph's communities second — search-first applies to both, so a new task is only created when neither the board nor the graph already covers the work.
- When a task's scope maps to a graph community (see `graphify-out/GRAPH_REPORT.md`), reference that community by name so the task and the graph describe the same area.
