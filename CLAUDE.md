# CLAUDE.md

This file provides context for Claude Code when working on this project.

## Project Overview

`wt` is a Git Worktree Manager for Zsh. It simplifies creating, switching, and managing git worktrees for parallel development workflows.

## Architecture

This is a single-file shell script (`wt`) with no dependencies beyond git and zsh.

### Key Components

- **Wrapper function** (`wt --init`): Outputs a shell function that users eval in their `.zshrc`. This wrapper intercepts `__WT_CD__:` markers from the script output to perform directory changes in the parent shell.

- **Main script** (`wt`): Handles all subcommands (new, switch, list, remove, clean, status, help).

### How `cd` works

Shell scripts run in subshells, so `cd` doesn't persist. We solve this by:
1. Script outputs `__WT_CD__:/path/to/dir` when a directory change is needed
2. Wrapper function captures this, strips it from output, and performs `cd` in the parent shell

## Configuration

Users can set these environment variables:
- `WT_BASE_DIR` - Where worktrees are created (default: `~/.wt`)
- `WT_CLAUDE_FLAGS` - Extra flags passed to `claude` CLI (e.g., `--dangerously-skip-permissions`)

## Testing

Run tests with:
```zsh
./tests/run_tests.zsh
```

## Common Tasks

### Adding a new subcommand

1. Create function `_wt_<subcommand>()` in the script
2. Add case to `main()` dispatcher
3. Update `_wt_help()` with usage info
4. Add completion in `_wt_init()` if needed
5. Add tests in `tests/`

### Modifying editor launch behavior

Editor launching is in `_wt_launch_claude()` and the `--cursor`/`--all` cases in `main()`.

## Code Style

- Use `local` for all function variables
- Prefix internal functions with `_wt_`
- Use `echo` for user output, `_wt_request_cd` for directory change requests
- Keep emojis for user-facing status messages
