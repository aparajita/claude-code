# Command: overview

## Usage

```
overview [directory]
```

Discover and visualize all plans in the project, regardless of whether they're tracked in state.

**This command works even without initialization** — useful for understanding an existing project's plans.

## Steps

1. **Determine plans directory**:
   - If `directory` argument provided: use that path
   - Otherwise: use **Plans Directory Detection** (see above)
   - This establishes which directory to scan

2. **Scan all markdown files** in the directory and subdirectories:
   - Recursively scan the plans directory for `.md` files
   - Include files in subdirectories (e.g., `plans/layout-engine/*.md`)
   - Read each `.md` file
   - Classify each file by analyzing its content:

   | Classification | Detection Criteria |
   |----------------|-------------------|
   | **Master Plan** | Has phases/steps (## Phase N or ## Step N), may have Status Dashboard |
   | **Sub-plan (linked)** | Has `**Parent:**` header pointing to a master |
   | **Sub-plan (orphaned)** | Looks like a sub-plan but no Parent reference or parent doesn't exist |
   | **Standalone Plan** | Has plan structure but no phase/step hierarchy |
   | **Completed** | Has `**Status:** Completed` or all phases/steps marked ✅ |
   | **Abandoned** | Old modification date, marked as abandoned, or superseded |
   | **Reference Doc** | Not a plan — just documentation |

   **Additionally, classify standalone plans by category** for organization:

   | Category | Detection Criteria |
   |----------|-------------------|
   | **Documentation** | Titles/content include "docs", "documentation", "guide", "manual", "how-to", "reference" |
   | **Migration** | Titles/content include "migration", "migrate", "upgrade", "transition", "port" |
   | **Design** | Titles/content include "design", "architecture", "proposal", "RFC", "spec" |
   | **Feature** | Titles/content include "feature", "enhancement", "new", "add" |
   | **Bugfix** | Titles/content include "bug", "fix", "issue", "problem", "error" |
   | **Reference** | Pure reference material, glossaries, decision logs |
   | **Standalone** | Doesn't match other categories |

3. **Build relationship graph**:
   - Map parent → children relationships
   - Identify which sub-plans link to which master plans
   - Detect circular references or broken links
   - Extract blocker information from phase sections and state file
   - For blocked phases, determine what's blocking them (phases, steps, or sub-plans)

4. **Display ASCII hierarchy chart**:
   - Show phase status with emojis (✅ Complete, 🔄 In Progress, ⏸️ Blocked, ⏳ Pending)
   - For blocked phases, include blocker details: `⏸️ Blocked by Phase 3` or `⏸️ Blocked by Phase 3, api-redesign.md`
   - Blocker format:
     - Phase blockers: `Phase N`
     - Step blockers: `Step N.M`
     - Sub-plan blockers: filename only (e.g., `api-redesign.md`)
     - Multiple blockers: comma-separated

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
│  ├── Phase 3: ⏸️ Blocked by Phase 2
│  │   └── 📄 api-redesign.md (Completed)
│  ├── Phase 4: ⏸️ Blocked by Phase 3, api-redesign.md
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

5. **Interactive cleanup for orphaned/completed**:

If orphaned, unlinked completed, or uncategorized standalone plans are found, use the **AskUserQuestion tool** with descriptive options:

```
Question: "Found 2 orphaned plans, 1 completed plan, and 5 uncategorized standalone plans. How would you like to handle them?"
Header: "Cleanup"
Options:
  - Label: "Organize all"
    Description: "Categorize standalone plans, analyze content, suggest links for related plans, then handle completed/orphaned"
  - Label: "Review individually"
    Description: "I'll show a summary of each plan and ask what to do with it one by one"
  - Label: "Move completed"
    Description: "Move completed unlinked plans to plans/completed/ directory"
  - Label: "Leave as-is"
    Description: "Just show the report, don't take any action"
```

Based on selection:
- **Organize all**: Switch to the `organize` workflow — organize by category, analyze relationships, suggest links, then cleanup
- **Review individually**: For each plan, show content summary and use AskUserQuestion again: Organize by category? Link to phase? Move to completed? Delete? Skip?
- **Move completed**: Move completed unlinked plans to `plans/completed/` (sibling to plans directory)
- **Leave as-is**: Just report, no action

6. **Output state suggestion**:

If no state file exists but master plans were detected:

```
💡 Tip: Run `/plan-manager init plans/layout-engine.md` to start tracking this plan hierarchy.
```
