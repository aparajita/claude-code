# Command: div

## Usage

```
div [file|all] [--remove] [--master <path>]
```

Add or remove `<div class="markdown-body">` wrapper around a plan file or all plans.

**Special argument**:
- `all` — Apply operation to all plan files in the plans directory

## Purpose

This command wraps plan content with HTML div tags to apply GitHub markdown styling when viewing plans in contexts that support the `markdown-body` class. This is useful when:
- Rendering plans in web interfaces that use GitHub's markdown CSS
- Viewing plans in tools that recognize the `markdown-body` class
- Ensuring consistent styling across different viewing contexts

## Steps

**CRITICAL EXECUTION CHECKPOINT**: You MUST check the `addDiv` setting and prompt the user about future plan preferences. The prompt differs based on whether the user is targeting a single plan or all plans. Do not skip the setting check.

### Single Plan Mode

1. **Determine target plan and mode**:
   - If `[file]` is `"all"` OR user said something like "add div to all plans", "wrap all plans":
     - Set mode to **All Plans Mode**
     - Skip to step 2 (All Plans Mode)
   - If `[file]` is provided, use that plan file
   - If not provided, analyze recent conversation context:
     - Which plan was most recently discussed?
     - Which plan file was most recently created or modified?
   - If unclear, use **AskUserQuestion**:
     ```
     Question: "Which plan should have divs added?"
     Header: "Target plan"
     Options:
       - For each recent plan in conversation:
         Label: "{plan filename}"
         Description: "{brief description or first heading}"
       - Label: "All plans"
         Description: "Apply to all plan files in the directory"
       - Label: "Specify file"
         Description: "I'll enter a specific plan file path"
     ```
   - If user selects "All plans", set mode to **All Plans Mode** and skip to step 2 (All Plans Mode)

2. **CRITICAL: Check addDiv setting and prompt for single-plan changes**:
   - **Always check settings first**: Look for `plan-manager-settings.json` at project level (`.claude/plan-manager-settings.json`) or user level (`~/.claude/plan-manager-settings.json`)

   - **When ADDING divs**: If no settings file exists OR `addDiv` is not `true`, you MUST prompt:
     ```
     Question: "The addDiv setting is currently disabled. Would you like to enable it?"
     Header: "Enable addDiv"
     Options:
       - Label: "Yes, but leave other plans as is"
         Description: "Enable addDiv setting but only add div to this plan"
       - Label: "Yes, and add div to all plans"
         Description: "Enable addDiv setting and add div wrapper to all existing plans"
       - Label: "No, leave the setting disabled"
         Description: "Keep addDiv disabled, only add div to this specific plan"
     ```
     - If "Yes, but leave other plans as is":
       - Ask which scope if both project and user settings exist, otherwise use project level
       - Create/update settings file with `"addDiv": true`
       - Continue to step 3
     - If "Yes, and add div to all plans":
       - Ask which scope if both project and user settings exist, otherwise use project level
       - Create/update settings file with `"addDiv": true`
       - Switch to **All Plans Mode** and proceed to step 2 (All Plans Mode)
     - If "No, leave the setting disabled":
       - Do not modify settings
       - Continue to step 3

   - **When REMOVING divs**: If `addDiv` is `true`, you MUST prompt:
     ```
     Question: "The addDiv setting is currently enabled. Would you like to disable it?"
     Header: "Disable addDiv"
     Options:
       - Label: "Yes, but leave other plans as is"
         Description: "Disable addDiv setting but only remove div from this plan"
       - Label: "Yes, and remove divs from all plans"
         Description: "Disable addDiv setting and remove div wrapper from all existing plans"
       - Label: "No, leave the setting enabled"
         Description: "Keep addDiv enabled, only remove div from this specific plan"
     ```
     - If "Yes, but leave other plans as is":
       - Update settings file with `"addDiv": false`
       - Continue to step 3
     - If "Yes, and remove divs from all plans":
       - Update settings file with `"addDiv": false`
       - Switch to **All Plans Mode** and proceed to step 2 (All Plans Mode) with removal behavior
     - If "No, leave the setting enabled":
       - Do not modify settings
       - Continue to step 3

3. **Read the plan file**:
   - Use **Read** tool to load the current plan content
   - Verify the file exists

4. **Check for existing div wrapper**:
   - Check if the plan already starts with `<div class="markdown-body">` (with or without blank line)
   - Check if the plan already ends with `</div>` (with or without blank line before it)
   - If both wrappers are already present:
     - If `--remove` flag is set, proceed to step 6 (removal)
     - Otherwise, inform user: `ℹ️  Plan already has div wrapper, skipping`
     - Exit without making changes

5. **Add div wrapper** (if not using --remove):
   - Prepend `<div class="markdown-body">\n\n` to the beginning of the file (blank line after opening tag)
   - Append `\n\n</div>` to the end of the file (blank line before closing tag)
   - Use **Write** or **Edit** tool to save the updated content
   - Confirm: `✓ Added div wrapper to {filename}`

6. **Remove div wrapper** (if using --remove):
   - Remove `<div class="markdown-body">\n\n` from the beginning (if present)
   - Remove `\n\n</div>` from the end (if present)
   - Also handle variations: `<div class="markdown-body">\n` or `<div class="markdown-body">` without newlines, `\n</div>` or `</div>` at end
   - Use **Write** or **Edit** tool to save the updated content
   - Confirm: `✓ Removed div wrapper from {filename}`

### All Plans Mode

When user explicitly requested to apply to all plans (via `[file]` = `"all"`, natural language, or by choosing "Yes, and add/remove div to/from all plans" in step 2):

1. **CRITICAL: Check addDiv setting and prompt for future plan preferences**:
   - **Always check settings first**: Look for `plan-manager-settings.json` at project level (`.claude/plan-manager-settings.json`) or user level (`~/.claude/plan-manager-settings.json`)

   - **When ADDING divs to all plans**: If no settings file exists OR `addDiv` is not `true`, you MUST prompt:
     ```
     Question: "Would you like to enable addDiv for future plans?"
     Header: "Future plans"
     Options:
       - Label: "Yes"
         Description: "Add the div wrapper to future plans"
       - Label: "No"
         Description: "I will decide later whether to add the div wrapper to future plans"
     ```
     - If "Yes":
       - Ask which scope if both project and user settings exist, otherwise use project level
       - Create/update settings file with `"addDiv": true`
     - If "No":
       - Do not modify settings

   - **When REMOVING divs from all plans**: If `addDiv` is `true`, you MUST prompt:
     ```
     Question: "Would you like to disable addDiv for future plans?"
     Header: "Future plans"
     Options:
       - Label: "Yes"
         Description: "Remove the div wrapper from future plans"
       - Label: "No"
         Description: "I will decide later whether to remove the div wrapper from future plans"
     ```
     - If "Yes":
       - Update settings file with `"addDiv": false`
     - If "No":
       - Do not modify settings

2. **Discover all plan files**:
   - Use **Glob** to find all `.md` files in the plans directory
   - Include all subdirectories (master plan subdirectories, category directories, and completed plans)
   - Example pattern: `plans/**/*.md`

3. **Process each plan**:
   - For each plan file found:
     - Read the file content
     - Check if div wrapper exists
     - If adding and wrapper already exists, skip with info message
     - If removing and wrapper doesn't exist, skip with info message
     - Otherwise, add or remove wrapper as specified
     - Track successes and skips

4. **Report results**:
   ```
   ✓ Processed 15 plans:
     - Added div wrapper to 12 plans
     - Skipped 3 plans (already had wrapper)
   ```
   Or for removal:
   ```
   ✓ Processed 15 plans:
     - Removed div wrapper from 10 plans
     - Skipped 5 plans (no wrapper present)
   ```

## Settings Integration

The `addDiv` setting in `plan-manager-settings.json` controls whether new plans are automatically wrapped with divs:

```json
{
  "addDiv": true  // Auto-wrap all new plans with divs
}
```

When `addDiv` is `true`:
- New plans created by `init`, `branch`, `sub-plan` commands are automatically wrapped
- Existing plans retain their current state (this command can be used to add wrappers)

When `addDiv` is `false` or not set:
- Plans are created without div wrappers (default behavior)
- This command can be used to manually add wrappers to specific plans

### Interactive Setting Changes

**When adding/removing a div for a single plan:**
- Always check if the setting matches the action (adding requires `addDiv: true`, removing suggests `addDiv: false`)
- If there's a mismatch, prompt with three options:
  - Change the setting and apply to all plans
  - Change the setting but only affect this plan
  - Don't change the setting, only affect this plan
- This prevents inconsistent state and gives the user full control

**When adding/removing divs for all plans:**
- Always prompt about future plan preferences with two options:
  - Change the setting to match (enable `addDiv` when adding, disable when removing)
  - Leave the setting unchanged for now
- This ensures the user consciously decides about future plan behavior

## Natural Language Triggers

This command responds to phrases like:
- "add divs to \<plan\>" / "add div to \<plan\>"
- "wrap \<plan\> with markdown-body div"
- "add div wrapper to the plan"
- "remove divs from \<plan\>" / "remove div from \<plan\>"
- "unwrap \<plan\>"
- "add div to all plans" / "add divs to all plans"
- "remove div from all plans" / "remove divs from all plans"
- "wrap all plans with divs"
- "unwrap all plans"

## Examples

### Add divs to a specific plan
```bash
/plan-manager div plans/layout-engine.md
```

### Add divs to the most recent plan
```bash
User: "add divs to that plan"
Claude: *Analyzes context, finds most recent plan*
        ✓ Added div wrapper to plans/sub-plan-1.md
```

### Remove divs from a plan
```bash
/plan-manager div plans/layout-engine.md --remove
```

### With master plan context
```bash
User: "add divs to the master plan"
Claude: *Uses active master plan*
        ✓ Added div wrapper to plans/layout-engine/layout-engine.md
```

### Add divs to all plans
```bash
/plan-manager div all
```

Or with natural language:
```bash
User: "add div to all plans"
Claude: *Discovers all plan files*
        ✓ Processed 15 plans:
          - Added div wrapper to 12 plans
          - Skipped 3 plans (already had wrapper)
```

### Remove divs from all plans
```bash
/plan-manager div all --remove
```

Or with natural language:
```bash
User: "remove divs from all plans"
Claude: *Processes all plan files*
        ✓ Processed 15 plans:
          - Removed div wrapper from 10 plans
          - Skipped 5 plans (no wrapper present)
```

### Interactive setting workflow (single plan)
```bash
User: "add div to plans/feature.md"
Claude: The addDiv setting is currently disabled. Would you like to enable it?

        ┌──────────────────────────────────────────────────────────────┐
        │ Enable addDiv                                                │
        │                                                              │
        │ ○ Yes, but leave other plans as is                          │
        │   Enable addDiv setting but only add div to this plan       │
        │                                                              │
        │ ○ Yes, and add div to all plans                             │
        │   Enable addDiv setting and add div wrapper to all          │
        │   existing plans                                             │
        │                                                              │
        │ ○ No, leave the setting disabled                            │
        │   Keep addDiv disabled, only add div to this specific plan  │
        └──────────────────────────────────────────────────────────────┘

User: *Selects "Yes, and add div to all plans"*
Claude: ✓ Enabled addDiv setting in .claude/plan-manager-settings.json
        ✓ Processed 15 plans:
          - Added div wrapper to 14 plans (including plans/feature.md)
          - Skipped 1 plan (already had wrapper)
```

### Interactive setting workflow (all plans)
```bash
User: "add div to all plans"
Claude: Would you like to enable addDiv for future plans?

        ┌──────────────────────────────────────────────────────────────┐
        │ Future plans                                                 │
        │                                                              │
        │ ○ Yes                                                        │
        │   Add the div wrapper to future plans                       │
        │                                                              │
        │ ○ No                                                         │
        │   I will decide later whether to add the div wrapper to     │
        │   future plans                                               │
        └──────────────────────────────────────────────────────────────┘

User: *Selects "Yes"*
Claude: ✓ Enabled addDiv setting in .claude/plan-manager-settings.json
        ✓ Processed 15 plans:
          - Added div wrapper to 14 plans
          - Skipped 1 plan (already had wrapper)
```

## Error Handling

**File not found**:
```
✗ Plan file not found: plans/nonexistent.md
```

**Already wrapped (when adding)**:
```
ℹ️  Plan already has div wrapper, skipping
```

**No wrapper present (when removing)**:
```
ℹ️  Plan doesn't have div wrapper, skipping
```

## Notes

- The div wrapper doesn't affect markdown parsing in most contexts
- GitHub, GitLab, and many markdown renderers ignore the HTML wrapper
- The `markdown-body` class is specifically for GitHub's CSS framework
- Divs are added outside all markdown content, not inside any frontmatter
- The command is idempotent - running it multiple times won't add duplicate wrappers
