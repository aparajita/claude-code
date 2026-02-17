# Command: No command (interactive menu)

When invoked without any command (`/plan-manager`), display an interactive menu of available commands using regular text output.

**Display this menu:**

```
Plan Manager — Available Commands
══════════════════════════════════════════════════════════════

VIEWING & STATUS
────────────────
  1. status        Show master plan hierarchy and sub-plan status
  2. overview      Discover all plans in the project and their relationships
  3. list-masters  Show all tracked master plans

GETTING STARTED
───────────────
  4. init          Initialize or add a master plan
  5. config        View/edit category organization settings

WORKING WITH PLANS
──────────────────
  6. branch        Create a branch plan for handling issues
  7. sub-plan      Create a sub-plan for implementing a phase (also: subplan)
  8. capture       Link an existing plan to a master plan phase
  9. add           Context-aware: add as master or link to phase
  10. complete     Mark a sub-plan or phase as complete
  11. merge        Merge a branch plan's content into the master plan
  12. archive      Archive or delete a completed plan
  13. block        Mark a phase as blocked by another phase/step/sub-plan
  14. unblock      Remove blockers from a phase

ORGANIZATION
────────────
  15. organize     Auto-organize, link, and clean up plans
  16. rename       Rename a plan and update all references
  17. audit        Find orphaned plans and broken links

MULTI-MASTER
────────────
  18. switch       Change which master plan is active

HELP & INFO
───────────
  19. help         Show detailed command reference and examples
  20. version      Show plan-manager version

══════════════════════════════════════════════════════════════

Please respond with the number or name of the command you'd like to use.
```

After the user responds with their choice, parse it (accepting either number or command name), then prompt for any required arguments for that command and execute it.

**Examples:**

```
User: "/plan-manager"
Claude: *Shows text menu*

        Plan Manager — Available Commands
        ══════════════════════════════════════════════════════════════

        VIEWING & STATUS
        ────────────────
          1. status        Show master plan hierarchy and sub-plan status
          2. overview      Discover all plans in the project and their relationships
          ...

        Please respond with the number or name of the command you'd like to use.

User: "1" (or "status")
Claude: *Uses AskUserQuestion to ask about scope*
        Do you want to see all master plans or just the active one?
        ┌─────────────────────────────────────────────────────────┐
        │ Status scope                                            │
        │                                                         │
        │ ○ Active master only                                    │
        │   Show status for the currently active master plan      │
        │                                                         │
        │ ○ All master plans                                      │
        │   Show status for all tracked master plans              │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Active master only"*
Claude: *Runs `/plan-manager status` and shows output*
```

```
User: "/plan-manager"
Claude: *Shows text menu*

User: "init" (or "4")
Claude: Which plan file should I initialize as a master plan?
User: "plans/new-feature.md"
Claude: *Runs `/plan-manager init plans/new-feature.md`*
```

```
User: "/plan-manager"
Claude: *Shows text menu*

User: "help" (or "19")
Claude: *Runs `/plan-manager help` and shows command reference*

        Plan Manager Commands
        ═══════════════════════════════════════════════════════════

        GETTING STARTED
        ───────────────

          init <path>              Initialize or add a master plan
          config                   View/edit category organization settings

        WORKING WITH PLANS
        ──────────────────

          branch <phase>           Create a sub-plan for a phase
          capture [file]           Link an existing plan to a phase
          complete <plan>          Mark a sub-plan or phase as complete

        [... full command reference ...]
```

This makes the skill discoverable for new users and provides quick access to common operations without memorizing command names.
