# Command: version

## Usage

```
version
```

Display the worktree skill version number.

## Implementation

Derive the path to `version.txt` from the path of this command file: replace `commands/version.md` with `version.txt`.
- Example: if this file is `/home/user/.claude/commands/worktree/commands/version.md`, the version file is `/home/user/.claude/commands/worktree/version.txt`

Read the version and output:

```
Worktree v{version}
```

## Example

```
Worktree v1.3.9
```
