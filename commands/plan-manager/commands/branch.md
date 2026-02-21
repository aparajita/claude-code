# Command: branch

## Usage

```
branch <phase-or-step> [--master <path>] [--parent <path>]
```

Create a branch plan for handling an unexpected issue or problem discovered during execution.

When `--parent <path>` is provided, the argument is a **step number** in the parent sub-plan (instead of a phase number in the master plan). This creates a nested branch.

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

1. **Detect plans directory root**:
   - Try reading `.claude/settings.local.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/settings.json` in the project root, look for `plansDirectory` field
   - If not found, try reading `.claude/plan-manager-state.json`, look for `plansDirectory` field
   - If not found, auto-detect by checking these directories (use first that exists with .md files):
     - `plans/` (relative to project root)
     - `docs/plans/` (relative to project root)
     - `.plans/` (relative to project root)
   - **CRITICAL**: All plan paths in state file and commands are relative to the project root, NOT to `~/.claude/`
   - **CRITICAL**: Never create plans in `~/.claude/plans/` - that's a fallback location only for plans mode, not for plan-manager
   - Store the detected directory (e.g., "plans", "docs/plans") for use in subsequent steps
2. **Determine parent plan**:
   - If `--parent <path>` is provided: the parent is that sub-plan, and the argument is a step number
   - Otherwise: the parent is the active master plan (or specified via `--master`), and the argument is a phase number (current behavior)
3. **Determine master plan**:
   - If parent is a master plan: master = parent (unchanged)
   - If parent is a sub-plan: look up `masterPlan` in the state file for that sub-plan, or walk the `parentPlan` chain until reaching a master plan
4. Read the parent plan to verify the phase/step exists
5. Ask the user for a brief description of the branch topic
6. **Determine branch location**:
   - **Always use the root master plan's subdirectory** for the branch file location, regardless of nesting depth
   - Use the plans directory detected in step 1 (e.g., "plans" or "docs/plans")
   - Look up the root master plan's subdirectory from its state entry
   - If master is in subdirectory (e.g., `plans/migrations/smufl-rewrite/smufl-rewrite.md`):
     - Extract the subdirectory path (e.g., `migrations/smufl-rewrite`)
     - Create branch in same subdirectory: `{plansDirectory}/{subdirectory}/{branch-name}.md`
   - If master is flat (e.g., `plans/legacy-plan.md`, `subdirectory: null` in state):
     - **Promote master plan to subdirectory** (this is the first child plan, so nesting is now needed):
       - Extract base name from master filename (e.g., `legacy-plan.md` → `legacy-plan`)
       - Create subdirectory: `{plansDirectory}/legacy-plan/`
       - Move master plan into it: `{plansDirectory}/legacy-plan.md` → `{plansDirectory}/legacy-plan/legacy-plan.md`
       - Update the state file: set `path` to new location and `subdirectory` to `"legacy-plan"`
       - Update any existing links in the master plan itself to use relative paths
     - Create branch in the new subdirectory: `{plansDirectory}/legacy-plan/{branch-name}.md`
   - **CRITICAL**: Path must be relative to project root, never use `~/.claude/plans/`
7. **Update the parent plan**:
   - **If parent is a master plan** (no `--parent` flag):
     - Update the phase header icon to 🔀 (e.g., `## 🔀 Phase 2: API Layer`)
     - Update the Status Dashboard: change phase Status to `🔀 Branch` and add the branch link to the Sub-plan column (e.g., `[branch.md](./branch.md)`)
     - Update the Description column link anchor to match the updated phase header (e.g., `[API Layer](#-phase-2-api-layer)`)
     - Add sub-plan reference to the phase section
     - Use relative path for link if in same subdirectory (e.g., `[branch.md](./branch.md)`)
   - **If parent is a sub-plan** (`--parent` flag used):
     - Find the target step in the parent sub-plan
     - Update the step's icon to 🔀 (e.g., `3. 🔀 Investigate caching` or `## 🔀 Step 3: Investigate caching`)
     - Add a blockquote branch reference below the step: `> Branch: [name.md](./name.md)`
8. **Create the branch file** with the appropriate template:

   **When parent is a master plan:**
   ```markdown
   # Branch: {description}

   **Type:** Branch  <br>
   **Parent:** {master-plan-path} → Phase {N}  <br>
   **Created:** {date}  <br>
   **Status:** In Progress  <br>
   **BlockedBy:** —

   ---

   ## Context

   {Brief description of the issue/topic that led to this branch}

   ## Plan

   {To be filled in}
   ```

   **When parent is a sub-plan (nested):**
   ```markdown
   # Branch: {description}

   **Type:** Branch  <br>
   **Parent:** {parent-sub-plan-path} → Step {N}  <br>
   **Master:** {master-plan-path}  <br>
   **Created:** {date}  <br>
   **Status:** In Progress  <br>
   **BlockedBy:** —

   ---

   ## Context

   {Brief description of the issue/topic that led to this branch}

   ## Plan

   {To be filled in}
   ```

9. **Update state file** with new sub-plan entry:
   - Set `type: "branch"`
   - Set `parentPlan` to the parent plan path (master or sub-plan)
   - If parent is a master: set `parentPhase` to the phase number, `parentStep` to null
   - If parent is a sub-plan: set `parentStep` to the step number, `parentPhase` to null
   - Set `masterPlan` to the root master plan path
10. Confirm:
    - If master was promoted from flat: `✓ Promoted master plan to subdirectory: {plansDirectory}/{baseName}/`
    - If nested: `✓ Created branch: {path} (branched from Step {N} of {parent-name})`
    - Otherwise: `✓ Created branch: {path} (branched from Phase {N})`
