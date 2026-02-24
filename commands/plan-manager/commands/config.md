# Command: config

## Usage

```
config [--user|--project] [--edit] [--no-categories] [--categories]
```

Display and configure category organization settings interactively.

## With --no-categories flag

Set `enableCategoryOrganization: false` in user settings (`~/.claude/plan-manager-settings.json`) without running the interactive wizard.

- If no user settings file exists, create it with `{"enableCategoryOrganization": false}`
- If a user settings file exists, merge `enableCategoryOrganization: false` into it (preserve other keys)
- Confirm with: `✓ Category organization disabled in user settings (~/.claude/plan-manager-settings.json)`

## With --categories flag

Set `enableCategoryOrganization: true` in user settings (`~/.claude/plan-manager-settings.json`) without running the interactive wizard.

- If no user settings file exists, create it with `{"enableCategoryOrganization": true}`
- If a user settings file exists, merge `enableCategoryOrganization: true` into it (preserve other keys)
- Confirm with: `✓ Category organization enabled in user settings (~/.claude/plan-manager-settings.json)`

## Without flags (show current configuration)

1. Load and display current configuration from all sources.

2. When `enableCategoryOrganization` is **true** (or default), display:

```
Plan Manager Configuration
══════════════════════════

Source Priority (highest to lowest):
  1. Project settings: .claude/plan-manager-settings.json [NOT FOUND]
  2. User settings: ~/.claude/plan-manager-settings.json [ACTIVE]
  3. Built-in defaults [FALLBACK]

Active Configuration (from user settings):
──────────────────────────────────────────

Category Organization: ENABLED

Category Directories:
  documentation  → docs/
  migration      → db-migrations/
  design         → designs/
  reference      → reference/
  feature        → features/
  bugfix         → bug-fixes/
  standalone     → misc/

File Location: ~/.claude/plan-manager-settings.json
```

3. When `enableCategoryOrganization` is **false**, suppress the `Category Directories:` block entirely — showing disabled directories is misleading. Show instead:

```
Plan Manager Configuration
══════════════════════════

Source Priority (highest to lowest):
  1. Project settings: .claude/plan-manager-settings.json [NOT FOUND]
  2. User settings: ~/.claude/plan-manager-settings.json [ACTIVE]
  3. Built-in defaults [FALLBACK]

Active Configuration (from user settings):
──────────────────────────────────────────

Category Organization: DISABLED
  (category directories are not used)

File Location: ~/.claude/plan-manager-settings.json
```

4. Use **AskUserQuestion** to offer actions:

```
Question: "What would you like to do?"
Header: "Config actions"
Options:
  - Label: "Edit categories"
    Description: "Modify category directory names interactively"
  - Label: "Toggle organization"
    Description: "Enable/disable category organization"
  - Label: "Create project config"
    Description: "Create project-specific settings to override user settings"
  - Label: "Done"
    Description: "Exit configuration (use Other to edit the file directly)"
```

## With --edit flag (interactive editor)

1. Load current settings (or defaults if none exist)
2. If no settings file exists, ask which scope to create (user or project)
3. Enter interactive editing mode using **AskUserQuestion** for each setting:

**Step 1: Enable/disable category organization**
```
Question: "Enable category organization for standalone plans?"
Header: "Organization"
Options:
  - Label: "Enabled (Recommended)"
    Description: "Organize standalone plans by category (migrations/, docs/, etc.)"
  - Label: "Disabled"
    Description: "Don't organize standalone plans by category"
```

**Step 2: Edit each category** (if enabled):
For each category, use **AskUserQuestion**:

```
Question: "Directory name for migration plans? (current: migrations)"
Header: "Migration plans"
Options:
  - Label: "migrations (current)"
    Description: "Use 'migrations' directory"
  - Label: "db-migrations"
    Description: "Use 'db-migrations' directory"
  - Label: "migration"
    Description: "Use 'migration' directory (singular)"
  - Label: "Custom..."
    Description: "Enter a custom directory name"
```

Repeat for: documentation, design, reference, feature, bugfix, standalone

**Step 3: Add custom categories** (optional)
```
Question: "Add custom category types?"
Header: "Custom categories"
Options:
  - Label: "Add one"
    Description: "Define a new category (e.g., 'infrastructure', 'api')"
  - Label: "Done"
    Description: "No more categories, save configuration"
```

If "Add one", ask for:
- Category type (e.g., "infrastructure")
- Directory name (e.g., "infra")
- Keywords for detection (e.g., "infrastructure, infra, k8s, docker")

**Step 4: Save**
4. Show preview of configuration
5. Use **AskUserQuestion** to confirm:

```
Question: "Save this configuration?"
Header: "Confirm"
Options:
  - Label: "Save to project"
    Description: "Save to .claude/plan-manager-settings.json"
  - Label: "Save to user settings"
    Description: "Save to ~/.claude/plan-manager-settings.json"
  - Label: "Discard changes"
    Description: "Don't save, exit without changes"
```

6. Write settings to selected file
7. Confirm: `✓ Saved configuration to <path>`

## With --user flag

- Show/edit `~/.claude/plan-manager-settings.json` (user-wide) only

## With --project flag

- Show/edit `.claude/plan-manager-settings.json` (project-specific) only

## Examples

```bash
/plan-manager config                    # Show current config
/plan-manager config --edit             # Interactive editor
/plan-manager config --user             # Show user-wide config
/plan-manager config --project --edit   # Edit project config
/plan-manager config --no-categories    # Disable category organization (user settings)
/plan-manager config --categories       # Enable category organization (user settings)
```
