# Claude Code Commands

Shared Claude Code commands and configurations for use across projects.

## Commands

### plan-manager

Manage hierarchical plans with linked sub-plans. Maintains a single source of truth (master plan) while allowing sub-plans to branch off for handling issues discovered during execution.

**Key Features:**
- Initialize and track master plans
- Branch into sub-plans when issues arise
- Capture tangential plans created during work
- Automatically link related plans together
- Rename randomly-named plans to meaningful names
- Archive completed plans
- Visualize plan hierarchies

**Installation:**

Copy `commands/plan-manager.md` to your global commands directory:

```bash
cp commands/plan-manager.md ~/.claude/commands/
```

**Usage:**

- `/plan-manager init <path>` — Initialize a master plan
- `/plan-manager overview` — See all plans and their relationships
- `/plan-manager organize` — Auto-link related plans and clean up
- `/plan-manager capture` — Link a plan you just created
- `/plan-manager rename <file> [new-name]` — Rename a plan and update references
- `/plan-manager status` — Show plan hierarchy
- `/plan-manager audit` — Find orphaned or broken plans

Or use natural language:
- "organize my plans"
- "capture that plan"
- "rename that plan"
- "what plans do we have?"

See [commands/plan-manager.md](commands/plan-manager.md) for full documentation.

## Contributing

Contributions welcome! This is a collection of useful Claude Code commands and configurations.

## License

MIT
