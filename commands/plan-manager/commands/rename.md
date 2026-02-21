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

1. Validate the source file exists
2. Rename the file to the new name
3. Find and update all references:
   - Master plan Status Dashboard Sub-plan column links
   - Master plan phase section links
   - Other sub-plans that reference this file
   - State file entries
4. Update the plan's own header if it has a title
5. Confirm: `✓ Renamed lexical-puzzling-emerson.md → layout-grid-fixes.md (updated 3 references)`

## Without new name (suggest mode)

```
/plan-manager rename plans/lexical-puzzling-emerson.md
```

1. Read the plan content
2. Analyze the content to understand what it's about
3. Generate a meaningful, descriptive filename based on:
   - The plan's title/heading
   - Key topics and keywords
   - Parent phase context (if linked)
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

5. If confirmed, proceed with rename and reference updates

## Detecting random/meaningless names

Names are considered "random" if they match patterns like:
- `{adjective}-{adjective}-{noun}.md` (e.g., lexical-puzzling-emerson.md)
- `{word}-{word}-{word}.md` with no semantic connection to content
- UUID-style names
- Generic names like `plan-1.md`, `new-plan.md`, `untitled.md`
