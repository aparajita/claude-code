# Command: rename

## Usage

```
rename <file> [new-name]
```

Rename a plan file and update all references to it.

## With new name provided

```
/plan-manager rename plans/lexical-puzzling-emerson.md layout-grid-fixes.md
```

1. Validate the source file exists.
2. Rename the file: `mv "$OLD_PATH" "$NEW_PATH"` (preserving directory, only changing filename).
3. Update the plan's own header title if it has one (Edit the file directly).
4. Find and update all references:
   - Scan all plan files for references to the old path:
     ```bash
     # For each plan file in the plans directory:
     commands/plan-manager/bin/pm-md update-links --file "$PLAN" --old "$OLD_NAME" --new "$NEW_NAME"
     ```
   - Update state file:
     ```bash
     commands/plan-manager/bin/pm-state update-subplan --path "$OLD_PATH" --new-path "$NEW_PATH"
     ```
5. Confirm: `✓ Renamed lexical-puzzling-emerson.md → layout-grid-fixes.md (updated N references)`

## Without new name (suggest mode)

```
/plan-manager rename plans/lexical-puzzling-emerson.md
```

1. Check if this is a random/meaningless name:
   ```bash
   commands/plan-manager/bin/pm-md detect-random-name --filename "$(basename $FILE)"
   ```
2. Read the plan content and classify it:
   ```bash
   commands/plan-manager/bin/pm-md classify --file "$FILE"
   ```
3. Analyze the content and parent phase context (if linked) to generate 2-3 meaningful filename suggestions.
4. Use **AskUserQuestion tool** to confirm:
   ```
   Question: "Suggest a new name for lexical-puzzling-emerson.md?"
   Header: "Rename"
   Options:
     - Label: "layout-grid-edge-cases.md"
       Description: "Based on content about grid layout edge case handling"
     - Label: "phase2-grid-fixes.md"
       Description: "Includes parent phase reference (Phase 2)"
     - Label: "Enter custom name"
       Description: "Type your own filename"
     - Label: "Keep current name"
       Description: "Don't rename this file"
   ```
5. If confirmed, proceed with rename and reference updates (same as "with new name" workflow above).

## Detecting random/meaningless names

Names are considered "random" if they match patterns like:
- `{adjective}-{adjective}-{noun}.md` (e.g., lexical-puzzling-emerson.md)
- `{word}-{word}-{word}.md` with no semantic connection to content
- UUID-style names
- Generic names like `plan-1.md`, `new-plan.md`, `untitled.md`

Use `pm-md detect-random-name` for automated detection.
