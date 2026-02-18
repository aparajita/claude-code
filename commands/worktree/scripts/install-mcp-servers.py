#!/usr/bin/env python3
"""Install project MCP servers into a git worktree.

Usage: install-mcp-servers.py <project-dir> <worktree-path> <server1> [<server2> ...]
"""

import json
import sys
from pathlib import Path


def main():
    if len(sys.argv) < 4:
        print("Usage: install-mcp-servers.py <project-dir> <worktree-path> <server1> [<server2> ...]")
        sys.exit(1)

    project_dir = sys.argv[1]
    worktree_path = sys.argv[2]
    selected_servers = sys.argv[3:]

    claude_json_path = Path.home() / ".claude.json"

    if not claude_json_path.exists():
        print("Error: ~/.claude.json not found", file=sys.stderr)
        sys.exit(1)

    with open(claude_json_path) as f:
        claude_data = json.load(f)

    projects = claude_data.get("projects", {})
    source_servers = projects.get(project_dir, {}).get("mcpServers", {})

    if not source_servers:
        print(f"No MCP servers found for project: {project_dir}", file=sys.stderr)
        sys.exit(1)

    servers_to_install = {
        name: config
        for name, config in source_servers.items()
        if name in selected_servers
    }

    if not servers_to_install:
        print("No matching servers found", file=sys.stderr)
        sys.exit(1)

    # Update ~/.claude.json for the worktree project entry
    if worktree_path not in projects:
        projects[worktree_path] = {
            "allowedTools": [],
            "mcpContextUris": [],
            "mcpServers": {},
            "enabledMcpjsonServers": [],
            "disabledMcpjsonServers": [],
            "hasTrustDialogAccepted": False,
            "projectOnboardingSeenCount": 0,
            "hasClaudeMdExternalIncludesApproved": False,
            "hasClaudeMdExternalIncludesWarningShown": False,
        }

    projects[worktree_path].setdefault("mcpServers", {}).update(servers_to_install)
    claude_data["projects"] = projects

    with open(claude_json_path, "w") as f:
        json.dump(claude_data, f, indent=2)

    print(f"Installed MCP servers: {', '.join(servers_to_install)}")


if __name__ == "__main__":
    main()
