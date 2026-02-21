# Command: merge

## Usage

```
merge [file-or-phase]
```

Merge a sub-plan or branch's content into the master plan.

**Purpose**: Sub-plans and branches often contain updates, refinements, or extensions to the master plan's phase content. This command integrates that work back into the master plan instead of keeping it as a separate document. (Note: Branches are more commonly merged; sub-plans typically remain separate as detailed implementation guides.)

**Accepts:** phase numbers (3), subphases (4.1), step numbers (2), substeps (2.3), file paths, or no argument (interactive selection)

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

**Without argument (interactive mode):**
1. Read state file to get active master plan
2. List all sub-plans and branches linked to the active master
3. Use **AskUserQuestion** to select which plan to merge:
   ```
   Question: "Which sub-plan or branch do you want to merge into the master?"
   Header: "Select plan"
   Options:
     - Label: "{plan-1-name}.md"
       Description: "Phase {N}: {brief-description} (Type: {type}, Status: {status})"
     - Label: "{plan-2-name}.md"
       Description: "Phase {M}: {brief-description} (Type: {type}, Status: {status})"
     [... up to 4 most recent plans, use "Other" for text input if more]
   ```

**With argument:**
1. If argument is a number/subphase, find plan for that phase/step; otherwise use as file path
2. Validate the plan exists and is linked to the active master

**Merge workflow:**

1. **Read the plan content**
2. **Identify the target phase or step** in the parent plan (from the plan's Parent header):
   - If `**Parent:**` references `→ Phase {N}`: target is a phase in the master plan
   - If `**Parent:**` references `→ Step {N}`: target is a step in a parent sub-plan
3. **Use AskUserQuestion to confirm merge approach**:
   ```
   Question: "How should this plan's content be merged?"
   Header: "Merge strategy"
   Options:
     - Label: "Append to {phase/step}"
       Description: "Add plan content to the end of {Phase/Step} {N} section"
     - Label: "Inline content (Recommended)"
       Description: "Replace {Phase/Step} {N} body with plan content, then delete the sub-plan file"
     - Label: "Reference to sub-plan"
       Description: "Replace {Phase/Step} {N} body with summary + link to sub-plan"
     - Label: "Manual review"
       Description: "Show me both and I'll decide what to keep"
   ```
   Where {Phase/Step} adapts based on whether the target is a master plan phase or a sub-plan step.

4. **Perform the merge**:
   - If "Append to phase/step":
     - Extract the main content from the plan (excluding the Parent header and metadata)
     - If target is a master plan phase: add a subsection `### Merged from {plan-name}.md` to the phase
     - If target is a sub-plan step: add merged content below the step section
     - Append the plan content under that subsection
     - Proceed to step 5
   - If "Inline content":
     - Replace the entire phase/step section body with the plan content
     - Preserve the phase/step heading (`## Phase {N}: {title}` or `## Step {N}: {title}`)
     - Delete the sub-plan file immediately
     - Skip step 7 (cleanup already handled)
     - Proceed to step 5
   - If "Reference to sub-plan":
     - Generate a summary of the sub-plan (extract first paragraph or create brief overview)
     - Replace the phase/step body with: `{summary}\n\nSee [[{plan-name}.md]] for detailed implementation plan.`
     - Proceed to step 5
   - If "Manual review":
     - Display both the current phase content and plan content
     - Ask user to indicate what should be kept/combined
     - Proceed to step 5

5. **Update parent plan metadata**:
   - **If parent is a master plan**:
     - Update Status Dashboard:
       - If "Inline content" or "Append to phase": remove the plan reference from the Sub-plan column
       - If "Reference to sub-plan": keep the Sub-plan reference (content is still separate)
     - Update the Description column link anchor to match the updated phase header
     - Add a note in the phase section:
       - If "Inline content" or "Append to phase": `✓ Merged from [{plan-name}.md](path) on {date}`
       - If "Reference to sub-plan": `✓ References [{plan-name}.md](path)`
   - **If parent is a sub-plan**:
     - Update the step section in the parent sub-plan
     - If "Inline content" or "Append to step": remove the blockquote sub-plan reference
     - Add a note below the step: `✓ Merged from [{plan-name}.md](path) on {date}`

6. **Update state file**:
   - If "Inline content" or "Append to phase": Mark the plan as merged (add `"merged": true, "mergedAt": "{date}"`)
   - If "Reference to sub-plan": Keep the plan active in state (no merge flag)

7. **Ask about plan cleanup** (skip if "Inline content" was selected) using **AskUserQuestion**:
   ```
   Question: "Plan merged successfully. What should happen to the plan file?"
   Header: "Plan cleanup"
   Options:
     - Label: "Delete it (Recommended)"
       Description: "Remove the file (content is now in master plan)"
     - Label: "Archive it"
       Description: "Move to plans/completed/ directory for reference"
     - Label: "Leave in place"
       Description: "Keep in current location"
   ```
   - If "Delete it": Delete the plan file and remove from state
   - If "Archive it": Move to plans/completed/ mirroring subdirectory structure
   - If "Leave in place": Do nothing

8. **Ask about phase/step status** using **AskUserQuestion**:
   ```
   Question: "Plan merged. What's the status of {Phase/Step} {N}?"
   Header: "{Phase/Step} status"
   Options:
     - Label: "{Phase/Step} complete"
       Description: "All work for {Phase/Step} {N} is done, mark it ✅ Complete"
     - Label: "Still in progress"
       Description: "More work remains on {Phase/Step} {N}, keep it 🔄 In Progress"
   ```
   - If parent is a master: update the phase header icon and Status Dashboard accordingly
   - If parent is a sub-plan: update the step icon in the parent sub-plan

9. **Confirm**: `✓ Merged {plan-name}.md into {Phase/Step} {N} of {parent-plan}`

## Example

### Example 1: Inline content (recommended for completed work)

```
User: "/plan-manager merge grid-edge-cases.md"
Claude: *Reads plan content*

        How should this plan's content be merged?
        ┌─────────────────────────────────────────────────────────┐
        │ Merge strategy                                          │
        │                                                         │
        │ ○ Append to phase                                       │
        │   Add plan content to the end of Phase 2 section        │
        │                                                         │
        │ ○ Inline content (Recommended)                          │
        │   Replace Phase 2 body with plan content, then delete   │
        │   the sub-plan file                                     │
        │                                                         │
        │ ○ Reference to sub-plan                                 │
        │   Replace Phase 2 body with summary + link to sub-plan  │
        │                                                         │
        │ ○ Manual review                                         │
        │   Show me both and I'll decide what to keep             │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Inline content"*
Claude: ✓ Replaced Phase 2 with grid-edge-cases.md content
        ✓ Deleted grid-edge-cases.md
        ✓ Merged grid-edge-cases.md into Phase 2 of master plan
```

### Example 2: Reference to sub-plan (keep as modular documentation)

```
User: "/plan-manager merge data-pipeline.md"
Claude: *Reads plan content*

        [Same merge strategy question...]

User: *Selects "Reference to sub-plan"*
Claude: ✓ Replaced Phase 3 with summary and reference to data-pipeline.md
        ✓ Sub-plan remains available at data-pipeline.md
        ✓ Phase 3 now references data-pipeline.md for detailed implementation
```
