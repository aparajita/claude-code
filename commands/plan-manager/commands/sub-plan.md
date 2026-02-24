# Command: sub-plan

## Usage

```
sub-plan|subplan <phase-or-step> [--master <path>] [--parent <path>]
```

Create a sub-plan for implementing a phase or step that needs substantial planning. Both "sub-plan" and "subplan" are accepted.

When `--parent <path>` is provided, the argument is a **step number** in the parent sub-plan (instead of a phase number in the master plan). This creates a nested sub-plan.

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
5. Ask the user for a brief description of the sub-plan topic
5a. **Determine a meaningful filename** for the new sub-plan:
   - Derive a descriptive kebab-case filename from the description and phase/step context
   - Examples: `auth-token-refresh.md`, `phase3-layout-refactor.md`, `grid-edge-cases.md`
   - **Never use random-sounding or auto-generated names** (see `rename.md` § Detecting random/meaningless names)
   - If unsure, prefer `{topic-slug}.md` over `phase{N}-{something}.md` for readability
6. **Determine sub-plan location**:
   - **Always use the root master plan's subdirectory** for the sub-plan file location, regardless of nesting depth
   - Use the plans directory detected in step 1 (e.g., "plans" or "docs/plans")
   - Look up the root master plan's subdirectory from its state entry (`subdirectory` field)
   - If master is already in a subdirectory (e.g., `plans/smufl-rewrite/smufl-rewrite.md`):
     - Extract the subdirectory path (e.g., `smufl-rewrite`)
     - Create sub-plan in same subdirectory: `{plansDirectory}/{subdirectory}/{sub-plan-name}.md`
   - If master is flat (e.g., `plans/legacy-plan.md`, `subdirectory: null` in state):
     - **Promote master plan to subdirectory** (this is the first sub-plan, so nesting is now needed):
       - Extract base name from master filename (e.g., `legacy-plan.md` → `legacy-plan`)
       - Create subdirectory: `{plansDirectory}/legacy-plan/`
       - Move master plan into it: `{plansDirectory}/legacy-plan.md` → `{plansDirectory}/legacy-plan/legacy-plan.md`
       - Update the state file: set `path` to new location and `subdirectory` to `"legacy-plan"`
       - Update any existing links in the master plan itself to use relative paths
     - Create sub-plan in the new subdirectory: `{plansDirectory}/legacy-plan/{sub-plan-name}.md`
   - **CRITICAL**: Path must be relative to project root, never use `~/.claude/plans/`
7. **Update the parent plan**:
   - **If parent is a master plan** (no `--parent` flag):
     - Update the phase header icon to 📋 (e.g., `## 📋 Phase 3: Layout Engine`)
     - Update the Status Dashboard: change phase Status to `📋 Sub-plan` and add the sub-plan link to the Sub-plan column (e.g., `[sub-plan.md](./sub-plan.md)`)
     - Update the Description column link anchor to match the updated phase header (e.g., `[Layout Engine](#-phase-3-layout-engine)`)
     - Add sub-plan reference to the phase section
     - Use relative path for link if in same subdirectory (e.g., `[sub-plan.md](./sub-plan.md)`)
   - **If parent is a sub-plan** (`--parent` flag used):
     - Find the target step in the parent sub-plan
     - Update the step's icon to 📋 (e.g., `3. 📋 Research edge cases` or `## 📋 Step 3: Research edge cases`)
     - Add a blockquote sub-plan reference below the step: `> Sub-plan: [name.md](./name.md)`
8. **Create the sub-plan file** with the appropriate template:

   **When parent is a master plan:**
   ```markdown
   # Sub-plan: {description}

   **Type:** Sub-plan  <br>
   **Parent:** {master-plan-path} → Phase {N}  <br>
   **Created:** {date}  <br>
   **Status:** In Progress  <br>
   **BlockedBy:** —

   ---

   ## Purpose

   {Brief description of what this phase aims to accomplish}

   ## Implementation Approach

   {To be filled in - how will this phase be implemented}

   ## Dependencies

   {Any dependencies or prerequisites}

   ## Plan

   {Detailed implementation steps}
   ```

   **When parent is a sub-plan (nested):**
   ```markdown
   # Sub-plan: {description}

   **Type:** Sub-plan  <br>
   **Parent:** {parent-sub-plan-path} → Step {N}  <br>
   **Master:** {master-plan-path}  <br>
   **Created:** {date}  <br>
   **Status:** In Progress  <br>
   **BlockedBy:** —

   ---

   ## Purpose

   {Brief description of what this step aims to accomplish}

   ## Implementation Approach

   {To be filled in - how will this step be implemented}

   ## Dependencies

   {Any dependencies or prerequisites}

   ## Plan

   {Detailed implementation steps}
   ```

8a. **Post-creation rename check**: If the filename of the newly-created sub-plan matches random/meaningless name patterns (see `rename.md` § Detecting random/meaningless names), immediately offer to rename it using the rename suggest mode before updating the state file and parent plan references. Apply the rename before proceeding so that all subsequent references (state file, parent plan links) use the correct name.
9. **Update state file** with new sub-plan entry:
   - Set `type: "sub-plan"`
   - Set `parentPlan` to the parent plan path (master or sub-plan)
   - If parent is a master: set `parentPhase` to the phase number, `parentStep` to null
   - If parent is a sub-plan: set `parentStep` to the step number, `parentPhase` to null
   - Set `masterPlan` to the root master plan path
10. Confirm:
    - If master was promoted from flat: `✓ Promoted master plan to subdirectory: {plansDirectory}/{baseName}/`
    - If nested: `✓ Created sub-plan: {path} (for Step {N} of {parent-name})`
    - Otherwise: `✓ Created sub-plan: {path} (for Phase {N} implementation)`
