# Command: capture

## Usage

```
capture [file] [--phase N] [--step N] [--parent <path>] [--master <path>]
```

Retroactively link an existing plan that was created during tangential discussion.

When `--parent <path>` points to a sub-plan, use `--step N` to specify which step it relates to (instead of `--phase N`). This captures the plan as a nested sub-plan.

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

**Context-aware mode** (no file specified):
1. Look at recent conversation context to identify the plan file that was just created
2. If multiple candidates or none found, ask the user which file to capture
3. Proceed to linking

**Explicit mode** (file specified):
1. Validate the file exists

**For both modes:**
1. **Detect plans directory root**:
   - Try reading `.claude/settings.local.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/settings.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/plan-manager-state.json`, look for `plansDirectory` field
   - If not found, auto-detect by checking these directories (use first that exists with .md files):
     - `plans/` (relative to project root)
     - `docs/plans/` (relative to project root)
     - `.plans/` (relative to project root)
   - **CRITICAL**: All plan paths are relative to the project root, NOT to `~/.claude/`
   - **CRITICAL**: Never use `~/.claude/plans/` - that's a fallback location only for plans mode, not for plan-manager
   - Store the detected directory (e.g., "plans", "docs/plans") for use in subsequent steps
2. **Determine parent plan and target**:
   - If `--parent <path>` points to a sub-plan:
     - Parent is that sub-plan; if `--step N` not provided, ask which step it relates to
     - Determine master plan by looking up `masterPlan` in state for the parent sub-plan
   - Otherwise (default):
     - Parent is the active master plan (or specified via `--master`)
     - If `--phase N` not provided, ask which phase this relates to
3. Read the state file to get master plan path (use active master, or specified via --master)
4. **Ask plan type** using **AskUserQuestion**:
   ```
   Question: "What type of plan is this?"
   Header: "Plan type"
   Options:
     - Label: "Sub-plan"
       Description: "Implements a phase that needs substantial planning"
     - Label: "Branch"
       Description: "Handles an unexpected issue or problem discovered during execution"
   ```
5. **Detect if plan has a random/meaningless name**:
   - Check if filename matches random name patterns:
     - `{adjective}-{adjective}-{noun}.md` (e.g., magical-moseying-swing.md, lexical-puzzling-emerson.md)
     - `{word}-{word}-{word}.md` with no semantic connection to content
     - Generic names like `plan-1.md`, `new-plan.md`, `untitled.md`
   - If random name detected, proceed to step 6
   - If meaningful name, skip to step 7

6. **Suggest meaningful rename** (only if random name detected):
   - Read the plan content to understand what it's about
   - Analyze the phase description and title from the master plan
   - Generate 2-3 meaningful filename suggestions based on:
     - The plan's title/heading
     - Key topics and keywords
     - Parent phase context (e.g., `phase2-{topic}.md` or `{phase-title-slug}.md`)
   - Use **AskUserQuestion** to confirm:
     ```
     Question: "This plan has a random name. Suggest a better name?"
     Header: "Rename"
     Options:
       - Label: "{suggested-name-1}.md"
         Description: "Based on plan content: {brief description}"
       - Label: "{suggested-name-2}.md"
         Description: "Based on phase {N}: {phase title}"
       - Label: "Keep current name"
         Description: "Don't rename, keep {current-name}.md"
     ```
   - If user chooses to rename, store the new name for use in subsequent steps
   - The rename will happen during the move in step 7

7. **Move to subdirectory if needed**:
   - **Always use the root master plan's subdirectory**, regardless of nesting depth
   - Use the plans directory detected in step 1
   - Check the root master plan's `subdirectory` field in the state file
   - If master plan is already in a subdirectory and captured plan is not in it:
     - Move and optionally rename the plan to: `{plansDirectory}/{subdirectory}/{new-or-current-name}.md`
     - Example: Move from `plans/magical-moseying-swing.md` to `plans/smufl-rewrite/smufl-phase2.md`
   - If master plan is flat (`subdirectory: null`) — this is the first sub-plan, so promote:
     - Extract base name from master filename (e.g., `legacy-plan.md` → `legacy-plan`)
     - Create subdirectory: `{plansDirectory}/legacy-plan/`
     - Move master plan into it: `{plansDirectory}/legacy-plan.md` → `{plansDirectory}/legacy-plan/legacy-plan.md`
     - Move (and optionally rename) the captured plan to: `{plansDirectory}/legacy-plan/{new-or-current-name}.md`
     - Update the state file: set master `path` to new location and `subdirectory` to `"legacy-plan"`
   - **CRITICAL**: Never move plans to or from `~/.claude/plans/` - all operations should be within the project plans directory
   - Update all references to the old path (in state file, master plan links, etc.)

8. **Normalize the plan and add parent reference**:
   - Follow the **normalize command** steps with `--type {sub-plan|branch}`, `--phase N` or `--step N`, `--master {master-path}`
   - If `--parent` was used, also pass `--parent {parent-path}` to normalize
   - Skip normalize's type-detection step (type is already known from step 4) and its tracking-offer step (capture handles linking)
   - This ensures the file has standard `## ⏳ Step N:` or `## ⏳ Phase N:` headings and the correct header block:

**For sub-plans (parent is master):**
```markdown
**Type:** Sub-plan  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Captured:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

{original content}
```

**For sub-plans (parent is sub-plan, nested):**
```markdown
**Type:** Sub-plan  <br>
**Parent:** {parent-sub-plan-path} → Step {N}  <br>
**Master:** {master-plan-path}  <br>
**Captured:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

{original content}
```

**For branches (parent is master):**
```markdown
**Type:** Branch  <br>
**Parent:** {master-plan-path} → Phase {N}  <br>
**Captured:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

{original content}
```

**For branches (parent is sub-plan, nested):**
```markdown
**Type:** Branch  <br>
**Parent:** {parent-sub-plan-path} → Step {N}  <br>
**Master:** {master-plan-path}  <br>
**Captured:** {date}  <br>
**Status:** In Progress  <br>
**BlockedBy:** —

---

{original content}
```

9. **Update the parent plan**:
   - **If parent is a master plan**:
     - Update the phase header icon to match the plan type (📋 for sub-plan, 🔀 for branch)
     - Update Status Dashboard: change Status to `📋 Sub-plan` or `🔀 Branch` and add plan reference to the Sub-plan column (use the new filename if renamed)
     - Update the Description column link anchor to match the updated phase header
     - Update the phase section with link to the plan (use the new filename if renamed)
   - **If parent is a sub-plan**:
     - Find the target step in the parent sub-plan
     - Update the step's icon to 📋 (sub-plan) or 🔀 (branch)
     - Add a blockquote reference below the step: `> Sub-plan: [name.md](./name.md)` or `> Branch: [name.md](./name.md)`
10. **Update state file**:
   - Set `type: "sub-plan"` or `"branch"`, use new path if renamed
   - Set `parentPlan` to the parent plan path (master or sub-plan)
   - If parent is a master: set `parentPhase`, `parentStep` to null
   - If parent is a sub-plan: set `parentStep`, `parentPhase` to null
   - Set `masterPlan` to the root master plan path
11. Confirm based on type:
   - Sub-plan (renamed): `✓ Captured and renamed {old-file} → {new-file}, linked as sub-plan to Phase {N}`
   - Sub-plan (not renamed): `✓ Captured {file} → linked as sub-plan to Phase {N}`
   - Branch (renamed): `✓ Captured and renamed {old-file} → {new-file}, linked as branch to Phase {N}`
   - Branch (not renamed): `✓ Captured {file} → linked as branch to Phase {N}`
