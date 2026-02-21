# Command: add

## Usage

```
add [file] [--phase N] [--master <path>]
```

Context-aware command that routes to either `init` or `capture` based on the user's intent.

## Routing Logic

**As master plan** (no phase context):
- "add this plan"
- "add as master plan"
- "make this a master plan"
→ Routes to `init` command

**As sub-plan/branch** (with phase context):
- "add this to phase X"
- "add this to the master plan"
- "link this to the master"
→ Routes to `capture` command

## Steps

> **Terminology:** Throughout this document, "Phase" also includes "Milestone" or "Step" when used as section headers. Detect which term the plan uses and preserve it. See SKILL.md § Terminology.

1. **Determine intent from context:**
   - If explicit phase/milestone number mentioned (e.g., "phase 2", "milestone 2") → route to capture with that phase
   - If "master plan" mentioned without phase → need to infer phase
   - If no phase context at all → route to init

2. **For master plan routing (init):**
   - Execute the `init` command with the plan file
   - See [init.md](init.md) for full steps

3. **For sub-plan/branch routing (capture):**

   **If phase not explicitly specified:**
   - Read the state file to get active master plan
   - Read the master plan to see available phases
   - Analyze recent conversation context to infer which phase is most relevant:
     - Which phase was most recently discussed?
     - Which phase is currently in progress?
     - Does the plan content match any phase description?

   **If phase can be confidently inferred:**
   - Confirm with user: "I'll add this to Phase X based on [reason]. Is that correct?"
   - If yes, proceed with capture
   - If no, ask which phase

   **If phase cannot be confidently inferred:**
   - Use **AskUserQuestion** to ask which phase:
     ```
     Question: "Which phase should this plan be linked to?"
     Header: "Target phase"
     Options:
       - For each in-progress or pending phase:
         Label: "Phase X: {phase title}"
         Description: "{phase description or context}"
       - Label: "Other phase"
         Description: "I'll specify a different phase number"
     ```

   **Once phase determined:**
   - Execute the `capture` command with the determined phase
   - See [capture.md](capture.md) for full steps

## Examples

```bash
# As master plan
User: "add this plan"
→ Routes to init, creates new master plan

# As sub-plan with explicit phase
User: "add this to phase 2"
→ Routes to capture with phase 2

# As sub-plan with inference needed
User: "add this to the master plan"
→ Analyzes context, infers phase or asks user
→ Routes to capture with determined phase
```

## Notes

- The "add" command is a convenience wrapper that provides intelligent routing
- It doesn't introduce new functionality, just makes the workflow more intuitive
- All actual work is delegated to `init` or `capture` commands
