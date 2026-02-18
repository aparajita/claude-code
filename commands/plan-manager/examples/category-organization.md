# Plan Manager Category Organization Examples

This document demonstrates how to organize standalone plans by category using the plan-manager skill.

## Category Classification

Standalone plans are automatically classified into categories for organization:

| Category | Detection Criteria |
|----------|-------------------|
| **Documentation** | Titles/content include "docs", "documentation", "guide", "manual", "how-to", "reference" |
| **Migration** | Titles/content include "migration", "migrate", "upgrade", "transition", "port" |
| **Design** | Titles/content include "design", "architecture", "proposal", "RFC", "spec" |
| **Feature** | Titles/content include "feature", "enhancement", "new", "add" |
| **Bugfix** | Titles/content include "bug", "fix", "issue", "problem", "error" |
| **Reference** | Pure reference material, glossaries, decision logs |
| **Standalone** | Doesn't match other categories |

## Organizing Standalone Plans by Category

```
User: "I have a lot of migration and design docs mixed in with my plans. Can we organize them?"
Claude: "Absolutely! Let me run the organize command."

User: "/plan-manager organize"
Claude: *Scans plans directory*

        BY CATEGORY (with suggested organization)
        ──────────────────────────────────────────

        📂 migrations/ (suggested category dir)
           📄 database-schema-v2.md — Migration plan
           📄 api-v3-migration.md — Migration plan
           📄 auth-upgrade.md — Migration plan

        📂 docs/ (suggested category dir)
           📄 onboarding-guide.md — Documentation
           📄 api-reference.md — Documentation

        📂 designs/ (suggested category dir)
           📄 new-cache-design.md — Design proposal

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 6 standalone plans that can be organized by       │
        │ category. Organize them?                                │
        │                                                         │
        │ ○ Organize all (Recommended)                            │
        │   Move plans to category subdirs (migrations/, docs/,   │
        │   designs/)                                             │
        │                                                         │
        │ ○ Review by category                                    │
        │   I'll show each category and you approve or skip       │
        │                                                         │
        │ ○ Skip categories                                       │
        │   Don't organize by category, move on to linking        │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Organize all"*
Claude: ✓ Created plans/migrations/
        ✓ Moved 3 migration plans → plans/migrations/
        ✓ Created plans/docs/
        ✓ Moved 2 documentation plans → plans/docs/
        ✓ Created plans/designs/
        ✓ Moved 1 design plan → plans/designs/

        Organization Complete
        ─────────────────────

        ✓ Organized by category:
          • 3 migration plans → migrations/
          • 2 documentation plans → docs/
          • 1 design plan → designs/

        Current state:
        ├── Master plans: 1 active (using subdirectory)
        ├── Linked sub-plans: 4
        ├── Category-organized: 6
        └── Unlinked: 0
```

## Customizing Category Directories (Interactive Editor)

```
User: "I want my migration plans to go in 'db-migrations' instead of 'migrations'"
Claude: "No problem! Let me open the interactive configuration editor."

User: "/plan-manager config --edit"
Claude: *Runs config command in edit mode*

        Enable category organization for standalone plans?
        ┌─────────────────────────────────────────────────────────┐
        │ Organization                                            │
        │                                                         │
        │ ○ Enabled (Recommended)                                 │
        │   Organize standalone plans by category (migrations/,   │
        │   docs/, etc.)                                          │
        │                                                         │
        │ ○ Disabled                                              │
        │   Don't organize standalone plans by category           │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Enabled"*
Claude: *Asks about each category directory*

        Directory name for migration plans? (current: migrations)
        ┌─────────────────────────────────────────────────────────┐
        │ Migration plans                                         │
        │                                                         │
        │ ○ migrations (current)                                  │
        │   Use 'migrations' directory                            │
        │                                                         │
        │ ○ db-migrations                                         │
        │   Use 'db-migrations' directory                         │
        │                                                         │
        │ ○ migration                                             │
        │   Use 'migration' directory (singular)                  │
        │                                                         │
        │ ○ Custom...                                             │
        │   Enter a custom directory name                         │
        └─────────────────────────────────────────────────────────┘

User: *Selects "db-migrations"*
Claude: *Continues for other categories...*

        [After configuring all categories]

        Configuration Preview:
        ═════════════════════

        Category Organization: ENABLED

        Category Directories:
          documentation  → docs/
          migration      → db-migrations/
          design         → designs/
          reference      → reference/
          feature        → features/
          bugfix         → bug-fixes/
          standalone     → misc/

        Save this configuration?
        ┌─────────────────────────────────────────────────────────┐
        │ Confirm                                                 │
        │                                                         │
        │ ○ Save to project                                       │
        │   Save to .claude/plan-manager-settings.json            │
        │                                                         │
        │ ○ Save to user settings                                 │
        │   Save to ~/.claude/plan-manager-settings.json          │
        │                                                         │
        │ ○ Discard changes                                       │
        │   Don't save, exit without changes                      │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Save to project"*
Claude: ✓ Saved configuration to .claude/plan-manager-settings.json

        Now when you run `/plan-manager organize`, migration plans will be
        moved to plans/db-migrations/ instead of plans/migrations/.
```

## Viewing Current Configuration

```
User: "/plan-manager config"
Claude: *Shows current configuration*

        Plan Manager Configuration
        ══════════════════════════

        Source Priority (highest to lowest):
          1. Project settings: .claude/plan-manager-settings.json [ACTIVE]
          2. User settings: ~/.claude/plan-manager-settings.json [NOT FOUND]
          3. Built-in defaults [FALLBACK]

        Active Configuration (from project settings):
        ─────────────────────────────────────────────

        Category Organization: ENABLED

        Category Directories:
          documentation  → docs/
          migration      → db-migrations/
          design         → designs/
          reference      → reference/
          feature        → features/
          bugfix         → bug-fixes/
          standalone     → misc/

        File Location: .claude/plan-manager-settings.json

        What would you like to do?
        ┌─────────────────────────────────────────────────────────┐
        │ Config actions                                          │
        │                                                         │
        │ ○ Edit categories                                       │
        │   Modify category directory names interactively         │
        │                                                         │
        │ ○ Toggle organization                                   │
        │   Enable/disable category organization                  │
        │                                                         │
        │ ○ Create project config                                 │
        │   Create project-specific settings to override user     │
        │   settings                                              │
        │                                                         │
        │ ○ Done                                                  │
        │   Exit configuration (use Other to edit file directly)  │
        └─────────────────────────────────────────────────────────┘
```

## Adding Custom Categories

```
User: "I have a lot of infrastructure plans. Can I create a custom category for them?"
Claude: "Absolutely! Use the interactive editor to add custom categories."

User: "/plan-manager config --edit"
Claude: *After configuring standard categories...*

        Add custom category types?
        ┌─────────────────────────────────────────────────────────┐
        │ Custom categories                                       │
        │                                                         │
        │ ○ Add one                                               │
        │   Define a new category (e.g., 'infrastructure', 'api') │
        │                                                         │
        │ ○ Done                                                  │
        │   No more categories, save configuration                │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Add one"*
Claude: What type of plans is this category for? (e.g., "infrastructure", "api", "testing")

User: "infrastructure"
Claude: What directory name should be used? (e.g., "infra", "infrastructure")

User: "infra"
Claude: ✓ Added custom category: infrastructure → infra/

        This category will match plans with keywords like "infrastructure",
        "infra", "k8s", "kubernetes", "docker", "deployment"

        Add custom category types?
        [Same options as before...]

User: *Selects "Done"*
Claude: *Shows preview with custom category included*

        Configuration Preview:
        ═════════════════════

        Category Organization: ENABLED

        Category Directories:
          documentation    → docs/
          migration        → migrations/
          design           → designs/
          infrastructure   → infra/        [CUSTOM]
          reference        → reference/
          feature          → features/
          bugfix           → bug-fixes/
          standalone       → misc/

        [Saves configuration...]
```
