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
Claude: *Runs /plan-manager organize — scans everything first, then presents consolidated plan*

        Organization Plan
        ─────────────────

        FLATTEN (1 solo nested master)
          plans/layout-engine/layout-engine.md → plans/layout-engine.md

        RENAME (1 randomly-named file)
          abstract-floating-jenkins.md → performance-notes.md (based on content: render performance analysis)

        CATEGORIZE (3 standalone plans → category subdirs)
          database-schema-v2.md  → migrations/
          api-v3-migration.md    → migrations/
          onboarding-guide.md    → docs/

        LINK (2 plans → parent plans)
          performance-notes.md → Master: layout-engine.md → Phase 4: Performance Optimization
          edge-cases.md        → Master: layout-engine.md → Phase 2: Grid Engine

        NO ACTION (1 plan — no clear category or phase match)
          random-ideas.md

Claude: *Uses AskUserQuestion tool*
        ┌─────────────────────────────────────────────────────────┐
        │ Proceed with this organization plan?                    │
        │                                                         │
        │ ○ Apply all (Recommended)                               │
        │   Execute every change listed above                     │
        │                                                         │
        │ ○ Review each section                                   │
        │   I'll walk through each category of changes and you    │
        │   approve or skip                                       │
        │                                                         │
        │ ○ Cancel                                                │
        │   Don't make any changes                                │
        └─────────────────────────────────────────────────────────┘

User: *Selects "Apply all"*
Claude: Organization Complete
        ─────────────────────

        ✓ Flattened 1 solo nested master:
          • plans/layout-engine/layout-engine.md → plans/layout-engine.md

        ✓ Renamed 1 plan:
          • abstract-floating-jenkins.md → performance-notes.md

        ✓ Organized by category:
          • 2 migration plans → migrations/
          • 1 documentation plan → docs/

        ✓ Linked 2 plans to parent plans:
          • performance-notes.md → Master: layout-engine.md → Phase 4
          • edge-cases.md → Master: layout-engine.md → Phase 2

        ⚠️ 1 plan left unchanged (no clear category or phase match):
          • random-ideas.md

        Current state:
        ├── Master plans: 1 active (flat)
        ├── Linked sub-plans: 5
        ├── Category-organized: 3
        └── Unlinked: 1
```

## Creating Nested Sub-plans

```
User: "/plan-manager sub-plan 3"
Claude: *Creates plans/layout-engine/grid-rethink.md for Phase 3*
        ✓ Created sub-plan: plans/layout-engine/grid-rethink.md (for Phase 3 implementation)

User: *Works on grid-rethink.md, which has 4 steps*
User: "Step 2 of the grid rethink needs its own detailed plan"

User: "/plan-manager sub-plan 2 --parent plans/layout-engine/grid-rethink.md"
Claude: What's this sub-plan about?
User: "Edge case handling for nested grids"
Claude: ✓ Created sub-plan: plans/layout-engine/nested-grid-edges.md (for Step 2 of grid-rethink.md)

        *File created with:*
        **Parent:** plans/layout-engine/grid-rethink.md → Step 2
        **Master:** plans/layout-engine/layout-engine.md

        *grid-rethink.md updated:*
        2. 📋 Handle nested grid edge cases
           > Sub-plan: [nested-grid-edges.md](./nested-grid-edges.md)

User: "/plan-manager status"
Claude: Master Plan: plans/layout-engine/layout-engine.md (ACTIVE)
        Subdirectory: layout-engine/

        Phase 1: ✅ Complete
        Phase 2: 🔄 In Progress
        Phase 3: 📋 Sub-plan
          └─ grid-rethink.md (Sub-plan - In Progress)
             Step 2: 📋 Sub-plan
               └─ nested-grid-edges.md (Sub-plan - In Progress)
        Phase 4: ⏳ Pending
        Phase 5: ⏳ Pending

        Sub-plans: 2 total (2 sub-plans; 2 in progress, depth: 2)

User: *Completes all work in nested-grid-edges.md*
User: "/plan-manager complete plans/layout-engine/nested-grid-edges.md"
Claude: *Updates nested-grid-edges.md status to Completed*

        This sub-plan is complete. How should it be integrated?
        [User selects "Just mark complete"]

        ✓ Updated grid-rethink.md Step 2 icon to ✅

        All steps in the parent sub-plan (grid-rethink.md) are now complete.
        Mark it as complete too?
        [User selects "Yes, complete parent"]

        ✓ Completed sub-plan: plans/layout-engine/grid-rethink.md
        ✓ Updated master plan Phase 3 to ✅ Complete
```
