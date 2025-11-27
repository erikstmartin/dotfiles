# Usage Guide

Quick reference for keybindings, aliases, and common workflows.

## Tmux

**Prefix**: `Ctrl-b`

### Session Management
- `Prefix + Shift-Tab` - Switch to last session
- `Prefix + Ctrl-a` - FZF session switcher (popup)
- `Prefix + Ctrl-c` - Create new session (prompts for name)
- `Prefix + Ctrl-r` - Rename current session
- `Prefix + Ctrl-q` - Kill current session (with confirmation)

### Window Management
- `Prefix + r` - Rename current window
- `Prefix + Tab` - Switch to last active window
- `Prefix + Ctrl-h` - Previous window
- `Prefix + Ctrl-l` - Next window

### Pane Management
- `Prefix + -` - Split horizontally
- `Prefix + _` - Split vertically
- `Prefix + h/j/k/l` - Navigate panes (vim-style)
- `Prefix + H/J/K/L` - Resize panes (vim-style)
- `Prefix + >` - Swap with next pane
- `Prefix + <` - Swap with previous pane
- `Ctrl-h/j/k/l` - Smart navigation (works with Neovim splits)
- `Alt-h/j/k/l` - Smart resize (works with Neovim windows)

### Popup Windows
- `Prefix + g` - Lazygit (80% screen)
- `Prefix + m` - Lazydocker (80% screen)
- `Prefix + k` - k9s (80% screen)
- `Prefix + t` - Terminal (75% screen)
- `Prefix + Ctrl-s` - Scratch window toggle

### Other
- `Prefix + Alt-r` - Reload tmux config
- `Ctrl-l` - Clear screen and history
- `Ctrl-\` - Toggle last pane

## Zsh

### History
- `Ctrl-p` - Previous command
- `Ctrl-n` - Next command
- `Ctrl-r` - FZF fuzzy search history
- `Up/Down` - Substring search in history

### Line Editing
- `Ctrl-a` - Beginning of line
- `Ctrl-e` - End of line
- `Ctrl-u` - Delete to beginning of line
- `Ctrl-k` - Delete to end of line
- `Ctrl-w` - Delete word before cursor
- `Alt-d` - Delete word after cursor
- `Ctrl-x Ctrl-e` - Edit command in $EDITOR

### Directory Navigation
- `Ctrl-t` - FZF file search (insert path at cursor)
- `Alt-c` - FZF directory search (cd into selected)

## FZF (Fuzzy Finder)

### Built-in Commands
- `Ctrl-r` - Search command history
- `Ctrl-t` - Search files
- `Alt-c` - Search directories

### Git Integration
- `Ctrl-g Ctrl-f` - Files
- `Ctrl-g Ctrl-b` - Branches
- `Ctrl-g Ctrl-t` - Tags
- `Ctrl-g Ctrl-r` - Remotes
- `Ctrl-g Ctrl-h` - Commit hashes
- `Ctrl-g Ctrl-s` - Stashes

### Navigation
- `Ctrl-j/k` or `Down/Up` - Navigate results
- `Enter` - Select
- `Tab` - Mark multiple
- `Shift-Tab` - Unmark

### Using FZF in Your Own Commands

FZF is incredibly powerful for building your own interactive commands:

```bash
# Kill process interactively
kill -9 $(ps aux | fzf | awk '{print $2}')

# Checkout git branch
git checkout $(git branch -a | fzf | sed 's/^[* ]*//' | sed 's|remotes/origin/||')

# Preview and open files with your editor
nvim $(fzf --preview 'bat --color=always {}')

# Search and cd into any subdirectory
cd $(find . -type d | fzf)

# Interactive docker container selection
docker exec -it $(docker ps | fzf | awk '{print $1}') /bin/bash

# Pipe any list to FZF for selection
ls | fzf
```

**Common FZF options:**
- `--preview 'command {}'` - Show preview window
- `--multi` - Allow multiple selections
- `--height 40%` - Limit height
- `--reverse` - List from top to bottom
- `--bind 'key:action'` - Custom keybindings

## Git Aliases

Configured in `.gitconfig`:

### Basic Operations
- `git s` - Status (short format)
- `git a` - Add files
- `git au` - Add all tracked files
- `git c "message"` - Commit with message
- `git co` - Checkout
- `git b` - Branch

### Push/Pull/Fetch
- `git p` - Pull
- `git pu` - Push
- `git f` - Fetch

### Merge
- `git m` - Merge (no fast-forward)
- `git mff` - Merge (fast-forward only)

### Stash
- `git st` - Stash
- `git stp` - Stash pop

### Diff
- `git d` - Diff (unstaged changes)
- `git staged` - Diff staged changes
- `git unstaged` - Diff unstaged changes

### Log & History
- `git l` - Pretty log with graph
- `git rl` - Reflog

### Undo
- `git unstage` - Unstage files (reset HEAD)

## Shell Aliases

Configured in `.zshenv`:
- `g` → `git`
- `k` → `kubectl`

## Tools

### Lazygit
Interactive git UI - `Prefix + g` in tmux or `lazygit` in terminal

### Lazydocker
Interactive docker UI - `Prefix + m` in tmux or `lazydocker` in terminal

### k9s
Interactive Kubernetes UI - `Prefix + k` in tmux or `k9s` in terminal

### Yazi
Terminal file manager - run `yazi` in terminal

---

**Tip**: Most of these tools have their own extensive keybindings. Press `?` within most tools to see their help/keybinding menu.
