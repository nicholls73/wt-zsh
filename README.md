# wt - Git Worktree Manager for Zsh

A lightweight CLI tool for managing git worktrees, designed for parallel development workflows with multiple editors (Claude Code, Cursor, VS Code, etc.).

## Why?

Git worktrees let you have multiple branches checked out simultaneously in separate directories. This is perfect for:

- Running multiple AI coding agents on different features of the same repo
- Reviewing PRs while keeping your current work untouched
- Testing changes in isolation without stashing
- Parallel development across features

`wt` makes worktree management simple with automatic dependency installation, editor launching, and easy navigation.

## Installation

```zsh
# 1. Download the script
mkdir -p ~/.local/bin
curl -sL https://raw.githubusercontent.com/nicholls73/wt-zsh/main/wt > ~/.local/bin/wt
chmod +x ~/.local/bin/wt

# 2. Add to your ~/.zshrc (required for cd and tab completion)
echo 'eval "$(~/.local/bin/wt --init)"' >> ~/.zshrc

# 3. Reload your shell
source ~/.zshrc
```

## Usage

```zsh
# Create a new worktree and branch
wt new feature-auth

# Create from a specific ref
wt new hotfix --from v1.0.0

# Create and launch Claude Code
wt new feature-api --claude

# Create and launch Cursor
wt new feature-ui --cursor

# Create and launch both
wt new feature-all --all

# Switch between worktrees
wt switch feature-auth
wt switch main              # back to main repo

# List all worktrees
wt list

# Show current status
wt status

# Remove a worktree
wt remove feature-auth

# Clean up all worktrees
wt clean
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `wt new <branch>` | | Create new worktree and branch |
| `wt switch <branch>` | `wt s` | Switch to worktree |
| `wt list` | `wt ls` | List all worktrees |
| `wt status` | `wt st` | Show current worktree status |
| `wt remove <branch>` | `wt rm` | Remove a worktree |
| `wt clean` | | Remove all worktrees |
| `wt help` | `wt h` | Show help |

### Options for `wt new`

| Option | Description |
|--------|-------------|
| `--from <ref>` | Base worktree on specific ref (tag, branch, commit) |
| `--claude` | Launch Claude Code after creation |
| `--cursor` | Launch Cursor after creation |
| `--all` | Launch both Claude Code and Cursor |
| `--none` | Don't launch any editor |

## Configuration

Set these environment variables in your `~/.zshrc`:

```zsh
# Change worktree base directory (default: ~/.wt)
export WT_BASE_DIR="$HOME/.worktrees"

# Add flags for Claude Code (e.g., skip permission prompts)
export WT_CLAUDE_FLAGS="--dangerously-skip-permissions"
```

## How it works

Worktrees are created in `~/.wt/<repo-name>/<branch-name>/`:

```
~/.wt/
└── my-project/
    ├── feature-auth/      # Full checkout with own node_modules
    ├── feature-api/       # Another full checkout
    └── bugfix-123/        # And another
```

Each worktree:
- Has its own working directory
- Has its own `node_modules` (auto-installed)
- Shares git history with the main repo
- Can run independently

## Features

- **Auto-detects package manager** - Supports bun, npm, yarn, and pnpm
- **Tab completion** - Branch names autocomplete for switch/remove
- **Smart defaults** - Detects main/master branch automatically
- **Remote tracking** - Sets up push tracking automatically
- **Editor integration** - Launch Claude Code or Cursor with one flag

## Requirements

- Zsh shell
- Git 2.5+ (for worktree support)
- Optional: bun/npm/yarn/pnpm for dependency installation
- Optional: `claude` CLI for Claude Code integration
- Optional: `cursor` CLI for Cursor integration

## Credits

Inspired by [roderik/wt](https://github.com/roderik/wt) (Fish shell version).

## License

MIT
