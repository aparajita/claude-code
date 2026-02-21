# Command: init

## Usage

```
init <path> [--description "text"] [--nested]
```

Initialize or add a master plan to tracking.

## Steps

1. **Detect plans directory**:
   ```bash
   commands/plan-manager/bin/pm-state get-plans-dir
   ```
   If this fails (no plans directory found) and this is a new initialization, ask the user via AskUserQuestion which directory to use (options: `plans/`, `docs/plans/`, `Custom path`).

2. **Determine subdirectory organization**:
   - By default, new master plans are placed flat in the root of the plans directory (no subdirectory).
   - Use `--nested` flag to immediately create a subdirectory and place the plan inside it.
   - If the plan file already exists, preserve its current location.

3. **Set up subdirectory structure** (only if `--nested` flag was provided):
   ```bash
   commands/plan-manager/bin/pm-files promote-master --master <path> --plans-dir <plans-dir>
   ```
   This creates `{plans-dir}/{baseName}/` and moves the master plan into it.

4. **If multiple masters exist**, ask via **AskUserQuestion**:
   ```
   Question: "You have multiple master plans. Make this the active one?"
   Header: "Active master"
   Options:
     - Label: "Yes, switch to this"
       Description: "Make this the active master plan for commands"
     - Label: "No, keep current"
       Description: "Add to tracking but keep current master active"
   ```

5. **Extract or ask for a brief description** to identify this master plan.

6. **If the master plan doesn't have a Status Dashboard section**, offer to add one:
   - Update phase headings to include ⏳ icon and insert the Status Dashboard:
     ```bash
     commands/plan-manager/bin/pm-md add-dashboard --file <path>
     ```
   - **CRITICAL:** Use ⏳ (hourglass) for pending status, NEVER ⬜ or other icons.

7. **Add to state**:
   ```bash
   commands/plan-manager/bin/pm-state add-master \
     --path <final-path> \
     --description "<description>" \
     [--subdirectory <name>]   # only if nested
   ```
   - **CRITICAL**: Always ensure `plansDirectory` is set in the state file. After adding master, verify with `pm-state read | jq .plansDirectory`. If null/missing, update it manually.

8. **Offer configuration setup** (only if this is the first master plan and no settings exist):
   - Check if `~/.claude/plan-manager-settings.json` or `.claude/plan-manager-settings.json` exists.
   - If neither exists, use **AskUserQuestion**:
     ```
     Question: "Configure category organization for standalone plans?"
     Header: "Setup"
     Options:
       - Label: "Configure now (Recommended)"
         Description: "Set up category directories (migrations/, docs/, etc.)"
       - Label: "Use defaults"
         Description: "Use built-in defaults (migrations, docs, designs, etc.)"
       - Label: "Skip for now"
         Description: "Don't set up categories yet, I'll configure later"
     ```
   - If "Configure now", run the `config` command interactively.

9. **Confirm initialization**:
   - `✓ Added master plan: {path} (active)` or `✓ Added master plan: {path}`
   - If subdirectory created: `✓ Created subdirectory: {plans-dir}/{baseName}/`
