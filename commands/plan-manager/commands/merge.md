# Command: merge

## Usage

```
merge [file-or-phase]
```

Merge a sub-plan or branch's content into the master plan.

**Purpose**: Sub-plans and branches often contain updates, refinements, or extensions to the master plan's phase content. This command integrates that work back into the master plan instead of keeping it as a separate document. (Note: Branches are more commonly merged; sub-plans typically remain separate as detailed implementation guides.)

**Accepts:** phase numbers (3), subphases (4.1), step numbers (2), substeps (2.3), file paths, or no argument (interactive selection)

## Steps

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
2. **Identify the target phase** in the master plan (from the plan's Parent header)
3. **Use AskUserQuestion to confirm merge approach**:
   ```
   Question: "How should this plan's content be merged?"
   Header: "Merge strategy"
   Options:
     - Label: "Append to phase (Recommended)"
       Description: "Add plan content to the end of Phase {N} section"
     - Label: "Replace phase content"
       Description: "Replace Phase {N} content entirely with plan content"
     - Label: "Manual review"
       Description: "Show me both and I'll decide what to keep"
   ```

4. **Perform the merge**:
   - If "Append to phase":
     - Extract the main content from the plan (excluding the Parent header and metadata)
     - Add a subsection to the master plan's phase: `### Merged from {plan-name}.md`
     - Append the plan content under that subsection
   - If "Replace phase content":
     - Replace the entire phase section with the plan content
     - Preserve the phase heading (`## Phase {N}: {title}`)
   - If "Manual review":
     - Display both the current phase content and plan content
     - Ask user to indicate what should be kept/combined

5. **Update master plan metadata**:
   - Update Status Dashboard: remove the plan reference from the Sub-plan column
   - Update the Description column link anchor to match the updated phase header
   - Add a note in the phase section: `✓ Merged from [{plan-name}.md](path) on {date}`

6. **Update state file**: Mark the plan as merged (add `"merged": true, "mergedAt": "{date}"`)

7. **Ask about plan cleanup** using **AskUserQuestion**:
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

8. **Ask about phase status** using **AskUserQuestion**:
   ```
   Question: "Plan merged. What's the status of Phase {N}?"
   Header: "Phase status"
   Options:
     - Label: "Phase complete"
       Description: "All work for Phase {N} is done, mark it ✅ Complete"
     - Label: "Still in progress"
       Description: "More work remains on Phase {N}, keep it 🔄 In Progress"
   ```
   - Update the phase header icon based on selection (✅ for complete, 🔄 for in progress)
   - Update Status Dashboard accordingly

9. **Confirm**: `✓ Merged {plan-name}.md into Phase {N} of master plan`

## Example

```
User: "/plan-manager merge grid-edge-cases.md"
Claude: *Reads plan content*

        How should this plan's content be merged?
        ┌─────────────────────────────────────────────────────────┐
        │ Merge strategy                                          │
        │                                                         │
        │ ○ Append to phase (Recommended)                         │
        │   Add plan content to the end of Phase 2 section        │
        │                                                         │
        │ ○ Replace phase content                                 │
        │   Replace Phase 2 content entirely with plan content    │
        │                                                         │
        │ ○ Manual review                                         │
        │   Show me both and I'll decide what to keep             │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Append to phase"*
Claude: ✓ Appended grid-edge-cases.md content to Phase 2

        Plan merged successfully. What should happen to the plan file?
        [cleanup options...]

User: *Selects "Delete it"*
Claude: ✓ Deleted grid-edge-cases.md
        ✓ Merged grid-edge-cases.md into Phase 2 of master plan
```
