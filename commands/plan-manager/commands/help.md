# Command: help

## Usage

```
help
```

Display command reference with descriptions and examples.

## Output

Show a formatted list of all available commands:

```
Plan Manager Commands
═══════════════════════════════════════════════════════════

GETTING STARTED
───────────────
  init <path>
    Initialize or add a master plan
    Options: --flat, --description "text"
    Example: /plan-manager init plans/feature.md

  config
    View/edit category organization settings
    Options: --edit, --user, --project
    Example: /plan-manager config --edit

WORKING WITH PLANS
──────────────────
  branch <phase>
    Create a branch plan for handling issues
    Options: --master <path>
    Example: /plan-manager branch 3

  sub-plan <phase>
    Create a sub-plan for implementing a phase
    Options: --master <path>, --pre-planned
    Example: /plan-manager sub-plan 3

  capture [file]
    Link an existing plan to a phase
    Options: --phase N, --master <path>
    Example: /plan-manager capture plans/fix.md --phase 2

  add [file]
    Context-aware: add as master plan or link to phase
    Options: --phase N, --master <path>
    Example: /plan-manager add plans/feature.md

  complete <plan>
    Mark a sub-plan or phase as complete
    Example: /plan-manager complete 3

  merge [file]
    Merge a branch plan's content into the master plan
    Example: /plan-manager merge grid-fixes.md

  archive [file]
    Archive or delete a completed plan
    Example: /plan-manager archive completed-plan.md

  block <phase> by <blocker>
    Mark a phase as blocked by another phase/step/sub-plan
    Example: /plan-manager block 4 by 3

  unblock <phase>
    Remove blockers from a phase
    Options: from <blocker> (remove specific blocker)
    Example: /plan-manager unblock 4

VIEWING STATUS
──────────────
  status
    Show master plan hierarchy and status
    Options: --all (show all masters)
    Example: /plan-manager status

  overview [directory]
    Discover and visualize all plans
    Example: /plan-manager overview

  list-masters
    Show all tracked master plans
    Example: /plan-manager list-masters

ORGANIZATION
────────────
  organize [directory]
    Auto-organize, link, and clean up plans
    Example: /plan-manager organize

  rename <file> [name]
    Rename a plan and update references
    Example: /plan-manager rename plans/old.md new-name.md

  audit
    Find orphaned plans and broken links
    Example: /plan-manager audit

FORMATTING
──────────
  div [file]
    Add or remove div wrapper for markdown-body styling
    Options: --remove (remove wrapper instead of adding)
    Example: /plan-manager div plans/layout-engine.md

MULTI-MASTER
────────────
  switch [master]
    Change which master plan is active
    Example: /plan-manager switch

HELP & INFO
───────────
  help
    Show this command reference
    Example: /plan-manager help

  version
    Show plan-manager version
    Example: /plan-manager version

TIPS
────
  • Run '/plan-manager' with no command for interactive menu
  • Use natural language: "capture that plan", "organize my plans"
  • Phase completion is auto-detected when you say "Phase X is complete"
  • Merge branch plans back into master to consolidate updates
  • Category organization keeps different plan types separated
  • Subdirectories keep master plans and sub-plans together

For detailed documentation, see the full plan-manager guide.
```
