# Plan Manager Natural Language Triggers and Command Reference

This document contains all natural language triggers that invoke the plan-manager skill, along with a complete command reference.

## Natural Language Triggers

The plan-manager skill responds to the following natural language phrases:

### Command Invocation
- "/plan-manager" (no command - shows interactive menu)
- "/plan-manager {command}"
- "use /plan-manager to capture..."

### Menu & Help
- "show me the plan-manager menu" / "what can plan-manager do"
- "plan-manager help" / "show plan-manager commands" / "how do I use plan-manager"

### Adding & Capturing Plans
- "add this plan" / "add as master plan" (creates new master plan)
- "add this to phase X" / "add this to the master plan" (links to phase as sub-plan/branch)
- "capture that plan" / "capture the plan you just created"
- "link this to the master plan" / "link this back to phase 3"

### Creating Plans
- "branch from phase 3" / "we need to branch here"
- "create a sub-plan for phase 3" / "create a subplan for phase 3"

### Merging
- "merge this branch" / "merge the branch plan" / "merge into master" / "integrate this back"

### Status & Overview
- "show plan status" / "what's the plan status"
- "overview of plans" / "what plans do we have" / "show me all plans"
- "scan the plans directory" / "discover plans"

### Auditing
- "audit the plans" / "check for orphaned plans"

### Organization
- "organize my plans" / "organize the plans" / "link related plans" / "clean up plans"
- "migrate plans to subdirectories" / "organize into folders"
- "organize plans by category" / "categorize my plans" / "group plans by type"
- "rename that plan" / "rename plan X" / "give that plan a better name"
- "archive that plan" / "archive the completed plan" / "move plan to completed"

### Configuration
- "customize category directories" / "configure plan categories" / "setup plan-manager config"
- "create plan-manager settings" / "configure plan-manager" / "edit plan-manager config"
- "show plan-manager config" / "view configuration" / "what are my category settings"

### Multiple Masters
- "switch master plan" / "switch to different master" / "list master plans"

### Completion Detection
- "Phase X is complete" / "Step Y is done" / "Phase 4.1 finished" / "completed Step 2.3"
- "mark step 2 of plans/sub-plan.md as complete" / "step 3 of that sub-plan is complete"
- "complete step 1 in plans/layout-engine/api-redesign.md"

### Blocking
- "block phase 4 by phase 3" / "mark phase 4 as blocked by phase 3"
- "phase X is blocked by phase Y" / "phase 4 can't start until phase 3 is done"
- "unblock phase 4" / "remove the block on phase 4" / "phase 3 is done, unblock 4"

## Command Reference Quick List

```bash
# Getting Started
/plan-manager init <path>              # Initialize or add a master plan
/plan-manager config                   # View/edit category organization settings
/plan-manager config --edit            # Interactive editor

# Working with Plans
/plan-manager branch <phase>           # Create a sub-plan for a phase
/plan-manager sub-plan <phase>         # Create a sub-plan for implementing a phase
/plan-manager capture [file]           # Link an existing plan to a phase
/plan-manager add [file]               # Context-aware: add as master or link to phase
/plan-manager complete <plan> [step]   # Mark a sub-plan, phase, or step as complete
/plan-manager merge [file]             # Merge a branch plan's content into master
/plan-manager archive [file]           # Archive or delete a completed plan
/plan-manager block <phase> [--reason] # Mark a phase as blocked
/plan-manager unblock <phase>          # Remove blockers from a phase

# Viewing Status
/plan-manager status                   # Show master plan hierarchy and status
/plan-manager status --all             # Show all master plans
/plan-manager overview [directory]     # Discover and visualize all plans
/plan-manager list-masters             # Show all tracked master plans

# Organization
/plan-manager organize [directory]     # Auto-organize, link, and clean up plans
/plan-manager rename <file> [name]     # Rename a plan and update references
/plan-manager audit                    # Find orphaned plans and broken links

# Multi-Master
/plan-manager switch [master]          # Change which master plan is active

# Help
/plan-manager help                     # Show detailed command reference
/plan-manager version                  # Show plan-manager version
/plan-manager                          # Show interactive menu
```

## Interactive Menu Example

```
User: "/plan-manager"
Claude: *Shows text-based menu*

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

User: "2" (or "overview")
Claude: *Runs overview command and shows plan hierarchy*
```

## Command Output Examples

### Status Command Output (Default)

```
Master Plan: plans/layout-engine/layout-engine.md (ACTIVE)
Subdirectory: layout-engine/
UI layout system redesign

Phase 1: ✅ Complete
Phase 2: 🔄 In Progress
  └─ layout-fix.md (Branch - In Progress)
Phase 3: 📋 Sub-plan
  └─ api-redesign.md (Sub-plan - In Progress)
Phase 4: ⏳ Pending

Sub-plans: 2 total (1 sub-plan, 1 branch; 1 in progress, 1 completed)
```

### Overview Command Output

```
Plans Overview: plans/
═══════════════════════════════════════════════════════════

ACTIVE HIERARCHIES
──────────────────

📋 layout-engine/ (Subdirectory)
│  └── layout-engine.md (Master Plan)
│      Status: 3/5 phases complete
│
│  ├── Phase 1: ✅ Complete
│  ├── Phase 2: 🔄 In Progress
│  │   └── 📄 grid-rethink.md (In Progress)
│  │       └── 📄 grid-edge-cases.md (In Progress)
│  ├── Phase 3: ⏸️ Blocked
│  │   └── 📄 api-redesign.md (Completed)
│  ├── Phase 4: ⏳ Pending
│  └── Phase 5: ⏳ Pending

📋 auth-migration.md (Master Plan, flat structure)
│   Status: 1/3 phases complete
│
├── Phase 1: ✅ Complete
├── Phase 2: 🔄 In Progress
└── Phase 3: ⏳ Pending


BY CATEGORY (with suggested organization)
──────────────────────────────────────────

📂 migrations/ (suggested category dir)
   📄 database-schema-v2.md — Migration plan
   📄 api-v3-migration.md — Migration plan

📂 docs/ (suggested category dir)
   📄 quick-fix-notes.md — Documentation
   📄 onboarding-guide.md — Documentation

📂 designs/ (suggested category dir)
   📄 performance-ideas.md — Design proposal
   📄 new-api-design.md — Architecture design


UNCATEGORIZED STANDALONE
─────────────────────────

📄 random-ideas.md — Standalone, no clear category


ORPHANED / UNLINKED
───────────────────

⚠️  old-layout-approach.md
    Claims parent: layout-engine.md → Phase 2
    But not referenced in parent's Status Dashboard

⚠️  experimental-cache.md
    No parent reference, looks like abandoned sub-plan
    Last modified: 45 days ago


COMPLETED (not linked to active work)
─────────────────────────────────────

✅ v1-migration.md — Completed master plan (all phases done)
✅ hotfix-auth.md — Completed, parent plan also complete


SUMMARY
───────

Total plans: 16
├── Master plans: 3 (2 active, 1 completed)
├── Linked sub-plans: 4
├── Category-organized: 5 (migrations: 2, docs: 2, designs: 1)
├── Uncategorized standalone: 1
└── Orphaned/Unlinked: 2
```

### Audit Command Output

```
Audit Results:

⚠️  Orphaned sub-plan: plans/old-idea.md (not linked to master)
⚠️  Broken link: plans/deleted.md (in state but file missing)
⚠️  Missing back-reference: plans/tangent.md (no Parent header)
✓  No stale phases detected

Recommendations:
- Run `/plan-manager capture plans/old-idea.md` to link orphan
- Manually remove the broken entry from `.claude/plan-manager-state.json` to clean up broken links
```

### Merge Command Example

```
User: "/plan-manager merge grid-edge-cases.md"
Claude: *Reads plan content*

        How should this plan's content be merged?
        ┌─────────────────────────────────────────────────────────┐
        │ Merge strategy                                          │
        │                                                         │
        │ ○ Append to phase                                       │
        │   Add plan content to the end of Phase 2 section        │
        │                                                         │
        │ ○ Inline content (Recommended)                          │
        │   Replace Phase 2 body with plan content, then delete   │
        │   the sub-plan file                                     │
        │                                                         │
        │ ○ Reference to sub-plan                                 │
        │   Replace Phase 2 body with summary + link to sub-plan  │
        │                                                         │
        │ ○ Manual review                                         │
        │   Show me both and I'll decide what to keep             │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Append to phase"*
Claude: ✓ Appended grid-edge-cases.md content to Phase 2

        Plan merged successfully. What should happen to the plan file?
        [cleanup options...]

User: *Selects "Delete it"*
Claude: ✓ Deleted grid-edge-cases.md
        ✓ Merged grid-edge-cases.md into Phase 2 of master plan
```

### Configuration Display

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

## Rename Pattern Detection

Names are considered "random" or meaningless if they match patterns like:
- `{adjective}-{adjective}-{noun}.md` (e.g., lexical-puzzling-emerson.md)
- `{word}-{word}-{word}.md` with no semantic connection to content
- UUID-style names
- Generic names like `plan-1.md`, `new-plan.md`, `untitled.md`

When detected, the skill will suggest meaningful names based on:
- The plan's title/heading
- Key topics and keywords
- Parent phase context (if linked)

## Context-Aware "add" Command

The `add` command intelligently routes based on context:

### As Master Plan (no phase context)
When you say "add this plan" without mentioning a phase, it creates a new master plan:
```
User: "add this plan"
Claude: *Routes to init command*
        ✓ Initialized master plan: plans/new-plan.md
```

### As Sub-plan/Branch (with phase context)
When you mention a phase, it captures the plan and links it to that phase:
```
User: "add this to phase 2"
Claude: *Routes to capture command with phase 2*
        ✓ Captured plan.md → linked to Phase 2
```

### Intelligent Phase Detection
When you say "add this to the master plan" without specifying which phase:
1. Analyzes recent conversation for phase context
2. Checks plan content for clues about which phase it relates to
3. Looks at current in-progress or pending phases
4. If confident, suggests a phase with confirmation
5. If unclear, asks with intelligent options

```
User: "add this to the master plan"
Claude: *Analyzes context, sees Phase 3 was recently discussed*
        I'll add this to Phase 3: API Layer based on recent discussion. Is that correct?

User: "yes"
Claude: ✓ Captured plan.md → linked to Phase 3
```

Or if unclear:
```
User: "add this to the master plan"
Claude: Which phase should this plan be linked to?

        ┌─────────────────────────────────────────┐
        │ Phase 2: Layout Engine (In Progress)    │
        │ Phase 3: API Layer (Pending)            │
        │ Phase 4: Testing (Pending)              │
        │ Other phase                              │
        └─────────────────────────────────────────┘
```

## Tips

- Run '/plan-manager' with no command for interactive menu
- Use natural language: "capture that plan", "organize my plans"
- Phase completion is auto-detected when you say "Phase X is complete"
- Merge branch plans back into master to consolidate updates
- Category organization keeps different plan types separated
- Subdirectories keep master plans and sub-plans together
- Settings are optional - defaults work great for most projects
- Project settings override user settings for team consistency
