# Command: help

## Usage

```
help
```

Display command reference with descriptions and examples.

## Output

Output the following verbatim, with no preamble or added commentary:

```
Plan Manager Commands
═══════════════════════════════════════════════════════════

GETTING STARTED
───────────────
  init <path>
    Initialize or add a master plan
    Options: --nested, --description "text"
    Example: /plan-manager init plans/feature.md

  config
    View/edit category organization settings
    Options: --edit, --user, --project
    Example: /plan-manager config --edit

WORKING WITH PLANS
──────────────────
  branch <phase-or-step>
    Create a branch plan for handling issues
    Options: --master <path>, --parent <path>
    Example: /plan-manager branch 3
    Example: /plan-manager branch 2 --parent plans/layout-engine/grid-rethink.md

  sub-plan <phase-or-step> (also: subplan)
    Create a sub-plan for implementing a phase or step
    Options: --master <path>, --parent <path>
    Example: /plan-manager sub-plan 3
    Example: /plan-manager sub-plan 3 --parent plans/layout-engine/grid-rethink.md

  capture [file]
    Link an existing plan to a phase or step
    Options: --phase N, --step N, --parent <path>, --master <path>
    Example: /plan-manager capture plans/fix.md --phase 2
    Example: /plan-manager capture plans/fix.md --step 3 --parent plans/grid-rethink.md

  add [file]
    Context-aware: add as master plan or link to phase
    Options: --phase N, --master <path>
    Example: /plan-manager add plans/feature.md

  complete <file-or-phase-or-range> [step]
    Mark a sub-plan, phase, range, or step within a sub-plan as complete
    Example: /plan-manager complete 3
    Example: /plan-manager complete 1-5
    Example: /plan-manager complete plans/sub-plan.md 2

  merge [file-or-phase]
    Merge a sub-plan or branch's content into the master plan
    Example: /plan-manager merge grid-fixes.md

  archive [file-or-phase]
    Archive or delete a completed plan
    Example: /plan-manager archive completed-plan.md

  block <phase-or-step> by <blocker>
    Mark a phase or step as blocked by another phase/step/sub-plan
    Example: /plan-manager block 4 by 3

  unblock <phase-or-step>
    Remove blockers from a phase or step
    Options: from <blocker> (remove specific blocker)
    Example: /plan-manager unblock 4

VIEWING STATUS
──────────────
  status
    Show master plan hierarchy and status
    Options: --all (show all masters), --master <path> (specific master)
    Example: /plan-manager status

  overview [directory]
    Discover and visualize all plans
    Example: /plan-manager overview

  list-masters
    Show all tracked master plans
    Example: /plan-manager list-masters

ORGANIZATION
────────────
  normalize <file>
    Normalize any plan format (milestones, tasks, checkboxes, etc.) to standard
    Options: --type master|sub-plan|branch, --phase N, --step N, --master <path>
    Example: /plan-manager normalize plans/rough-plan.md

  organize [directory]
    Auto-organize, link, and clean up plans
    Options: --nested (skip solo nested master flattening)
    Example: /plan-manager organize

  rename <file> [name]
    Rename a plan and update references
    Example: /plan-manager rename plans/old.md new-name.md

  audit
    Find orphaned plans and broken links
    Example: /plan-manager audit

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
  • Sub-plans can be nested: create sub-plans for steps within sub-plans
```
