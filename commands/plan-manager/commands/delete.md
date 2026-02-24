# Command: delete

**Aliases**: `remove`, `rm`

## Usage

```
delete <file>
remove <file>
rm <file>
```

Permanently delete a plan file and remove it from the state file. Works on any plan regardless of completion status. Prompts for confirmation before deleting.

**Accepts:** a file path (relative or just the filename)

## Steps

1. **Resolve the file path**
   - If the argument is just a filename (no path separator), search for it under `plans/`
   - If multiple matches are found, use **AskUserQuestion** to pick one
   - If no match is found, report an error

2. **Read the plan** to determine its type (master plan or sub-plan/branch) and gather context:
   - For master plans: list any linked sub-plans/branches
   - For sub-plans/branches: identify the parent plan and the phase/step it is linked to

3. **Warn about linked sub-plans** (master plans only):
   - If the master plan has linked sub-plans or branches still in the state file, use **AskUserQuestion**:
     ```
     Question: "{master-name} has {N} linked sub-plan(s)/branch(es):\n  {list of linked plans}\nThese will be orphaned. Delete anyway?"
     Header: "Linked plans"
     Options:
       - Label: "Delete anyway"
         Description: "Remove the master plan; linked plans remain on disk but become orphaned"
       - Label: "Cancel"
         Description: "Do not delete"
     ```
   - If user selects "Cancel", stop.

4. **Confirm deletion** using **AskUserQuestion**:

   For master plans:
   ```
   Question: "Permanently delete '{filename}'? This cannot be undone."
   Header: "Confirm delete"
   Options:
     - Label: "Delete"
       Description: "Remove the file and clean up state references"
     - Label: "Cancel"
       Description: "Do not delete"
   ```

   For sub-plans/branches:
   ```
   Question: "Permanently delete '{filename}'? This cannot be undone."
   Header: "Confirm delete"
   Options:
     - Label: "Delete"
       Description: "Remove the file and clean up state references and master plan links"
     - Label: "Cancel"
       Description: "Do not delete"
   ```

5. **Perform deletion**:
   - Delete the file
   - If the file is a **master plan**:
     - Remove the master plan entry from the state file
     - If it was the active master plan, clear the `activeMaster` field (or switch to another if one exists)
     - If it had a subdirectory containing no other files, delete the subdirectory
   - If the file is a **sub-plan or branch**:
     - Remove the entry from the state file
     - Remove the link from the parent plan's Status Dashboard (the line referencing this file)
     - Update the parent plan phase/step status icon if the sub-plan's icon was 📋 or 🔀

6. **Confirm**:
   ```
   ✓ Deleted {filename}
   ```
   If parent plan was updated, also report:
   ```
     Updated {parent-plan} (removed link from Phase/Step N)
   ```

## Example

```
User: "/plan-manager delete someplan.md"
Claude: Permanently delete 'someplan.md'? This cannot be undone.
        ┌──────────────────────────────────────────┐
        │ Confirm delete                           │
        │                                          │
        │ ○ Delete                                 │
        │   Remove the file and clean up state     │
        │   references and master plan links       │
        │                                          │
        │ ○ Cancel                                 │
        │   Do not delete                          │
        └──────────────────────────────────────────┘

User: *Selects "Delete"*
Claude: ✓ Deleted someplan.md
          Updated feature-engine.md (removed link from Phase 3)
```

## Notes

- Unlike `archive`, this command works on plans of any completion status.
- Deletion is permanent — ensure content is merged or backed up first.
- Linked sub-plans of a deleted master plan are not automatically deleted; they remain on disk but become orphaned (no longer tracked).
- To delete a batch of completed plans interactively, use `prune` instead.
