# Plan Manager Workflow Examples

This document provides comprehensive examples of common workflows using the plan-manager skill.

## Starting Fresh (with Config Setup)

```
User: "Let's implement the new layout engine"
Claude: *Creates plans/layout-engine.md with 5 phases*

User: "/plan-manager init plans/layout-engine.md"
Claude: ✓ Initialized master plan: plans/layout-engine.md (flat)
        ✓ Added Status Dashboard with 5 phases

        Configure category organization for standalone plans?
        ┌─────────────────────────────────────────────────────────┐
        │ Setup                                                   │
        │                                                         │
        │ ○ Configure now (Recommended)                           │
        │   Set up category directories (migrations/, docs/, etc.)│
        │                                                         │
        │ ○ Use defaults                                          │
        │   Use built-in defaults (migrations, docs, designs,     │
        │   etc.)                                                 │
        │                                                         │
        │ ○ Skip for now                                          │
        │   Don't set up categories yet, I'll configure later     │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Use defaults"*
Claude: ✓ Will use default category directories

        Initialization complete! You can customize category directories
        later by running `/plan-manager config --edit`

User: *Working on Phase 2...*
User: "Wait, we need to rethink the grid system"
Claude: *Creates plans/grid-rethink.md*

User: "/plan-manager capture"
Claude: I see you just created plans/grid-rethink.md. Which phase does this relate to?
User: "Phase 2"
Claude: ✓ Promoted master plan to subdirectory: plans/layout-engine/
        ✓ Moved plans/layout-engine.md → plans/layout-engine/layout-engine.md
        ✓ Moved plans/grid-rethink.md → plans/layout-engine/grid-rethink.md
        ✓ Captured plans/layout-engine/grid-rethink.md → linked to Phase 2
        ✓ Updated master plan Status Dashboard

User: "/plan-manager status"
Claude: Master Plan: plans/layout-engine/layout-engine.md (subdirectory: layout-engine/)

        Phase 1: ✅ Complete
        Phase 2: 🔄 In Progress
          └─ plans/layout-engine/grid-rethink.md (In Progress)
        Phase 3: ⏳ Pending
        ...
```

## Joining Existing Project / New Session

```
User: "What plans do we have?"
Claude: *Runs /plan-manager overview*

        Plans Overview: plans/
        ═══════════════════════════════════════════════════════════

        ACTIVE HIERARCHIES
        ──────────────────

        📋 layout-engine.md (Master Plan)
        │   Status: 2/5 phases complete
        │
        ├── Phase 1: ✅ Complete
        ├── Phase 2: 🔄 In Progress
        │   └── 📄 grid-rethink.md (In Progress)
        ...

        ORPHANED / UNLINKED
        ───────────────────

        ⚠️  performance-notes.md
            No parent reference, created 3 days ago

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 1 orphaned plan. How would you like to handle it? │
        │                                                         │
        │ ○ Review it                                             │
        │   Show content summary and decide what to do            │
        │                                                         │
        │ ○ Link to a phase                                       │
        │   Connect this plan to a phase in the master plan       │
        │                                                         │
        │ ○ Archive it                                            │
        │   Move to plans/completed/ to get it out of the way      │
        │                                                         │
        │ ○ Leave as-is                                           │
        │   Don't take any action right now                       │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Link to a phase"*
Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Which phase should performance-notes.md link to?        │
        │                                                         │
        │ ○ Phase 2: Layout Engine                                │
        │ ○ Phase 3: Rendering Pipeline                           │
        │ ○ Phase 4: Performance Optimization                     │
        │ ○ Phase 5: Testing                                      │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Phase 4: Performance Optimization"*
Claude: ✓ Captured performance-notes.md → linked to Phase 4
```

## Using Nested Structure (Opt-in)

```
User: "I want this plan organized in its own folder from the start"
Claude: "Use the --nested flag to immediately create a subdirectory"

User: "/plan-manager init plans/simple-feature.md --nested"
Claude: ✓ Created subdirectory: plans/simple-feature/
        ✓ Moved plans/simple-feature.md → plans/simple-feature/simple-feature.md
        ✓ Initialized master plan: plans/simple-feature/simple-feature.md (nested)
        ✓ Added Status Dashboard with 3 phases

User: "/plan-manager branch 2"
Claude: *Creates plans/simple-feature/feature-branch.md (in subdirectory)*
        ✓ Created branch: plans/simple-feature/feature-branch.md (branched from Phase 2)
```

## Cleaning Up After Long Work Session

```
User: "/plan-manager overview"
Claude: *Shows full hierarchy with 2 completed sub-plans not linked to active work*

        COMPLETED (not linked to active work)
        ─────────────────────────────────────

        ✅ hotfix-login.md — Completed, standalone
        ✅ cache-optimization.md — Completed, parent phase also done

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 2 completed plans not linked to active work.      │
        │ How would you like to handle them?                      │
        │                                                         │
        │ ○ Move completed                                        │
        │   Move to plans/completed/                              │
        │                                                         │
        │ ○ Review individually                                   │
        │   Show each plan and decide one by one                  │
        │                                                         │
        │ ○ Leave as-is                                           │
        │   Keep them where they are                              │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Move completed"*
Claude: ✓ Moved hotfix-login.md → plans/completed/hotfix-login.md
        ✓ Moved cache-optimization.md → plans/completed/cache-optimization.md
```

## Organizing Messy Plans

```
User: "Organize my plans"
Claude: *Runs /plan-manager organize*

        Plans Overview: plans/
        ═══════════════════════════════════════════════════════════

        [... displays hierarchy ...]

        Found 1 master plan nested with no sub-plans: layout-engine/

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 1 master plan nested in a subdirectory with no   │
        │ sub-plans. Flatten it?                                  │
        │                                                         │
        │ ○ Flatten all (Recommended)                             │
        │   Move each lone master plan to the plans root          │
        │                                                         │
        │ ○ Review individually                                   │
        │   Ask about each master plan separately                 │
        │                                                         │
        │ ○ Keep nested                                           │
        │   Leave them in their subdirectories                    │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Flatten all"*
Claude: ✓ Moved layout-engine/layout-engine.md → layout-engine.md
        ✓ Removed empty subdirectory: plans/layout-engine/
        ✓ Updated all references

        BY CATEGORY (with suggested organization)
        ──────────────────────────────────────────

        📂 migrations/ (suggested)
           📄 database-schema-v2.md — Migration plan
           📄 api-v3-migration.md — Migration plan

        📂 docs/ (suggested)
           📄 onboarding-guide.md — Documentation

        STANDALONE PLANS
        ────────────────

        📄 performance-notes.md — mentions "caching", "render optimization"
        📄 edge-cases.md — mentions "grid", "layout edge cases"
        📄 random-ideas.md — miscellaneous notes

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Found 3 standalone plans that can be organized by       │
        │ category. Organize them?                                │
        │                                                         │
        │ ○ Organize all (Recommended)                            │
        │   Move plans to category subdirs (migrations/, docs/)   │
        │                                                         │
        │ ○ Review by category                                    │
        │   I'll show each category and you approve or skip       │
        │                                                         │
        │ ○ Skip categories                                       │
        │   Don't organize by category, move on to linking        │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Organize all"*
Claude: ✓ Created category subdirectories
        ✓ Moved 2 migration plans → plans/migrations/
        ✓ Moved 1 documentation plan → plans/docs/

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ I found 3 unlinked plans that may relate to your       │
        │ master plan. Review my linking suggestions?            │
        │                                                         │
        │ ○ Review suggestions                                    │
        │   I'll show each suggestion and you approve or reject   │
        │                                                         │
        │ ○ Link all                                              │
        │   Accept all my linking suggestions without review      │
        │                                                         │
        │ ○ Skip linking                                          │
        │   Don't link anything, move on to cleanup               │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Review suggestions"*

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ performance-notes.md mentions "caching" and "render     │
        │ optimization". Link to Phase 4 (Performance)?           │
        │                                                         │
        │ ○ Yes, link it                                          │
        │   Add parent reference and update master plan           │
        │                                                         │
        │ ○ Different phase                                       │
        │   Link to a different phase instead                     │
        │                                                         │
        │ ○ Skip this one                                         │
        │   Don't link this plan                                  │
        │                                                         │
        │ ○ It's not a sub-plan                                   │
        │   This is standalone documentation, not a sub-plan      │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Yes, link it"*
Claude: ✓ Linked performance-notes.md → Phase 4

        [... continues for remaining plans ...]

Claude: Organization Complete
        ─────────────────────

        ✓ Linked 2 plans to master:
          • performance-notes.md → Phase 4
          • edge-cases.md → Phase 2

        ⚠️ 1 plan left unlinked (marked as standalone):
          • random-ideas.md

        Current state:
        ├── Master plans: 1 active
        ├── Linked sub-plans: 5
        └── Standalone: 1
```
