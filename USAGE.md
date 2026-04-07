# Usage Guide

Quick reference for keybindings, aliases, and common workflows.

## Wezterm

**Leader**: `Alt-b` (1000ms timeout)

### Pane Management
- `Leader + -` - Split pane below
- `Leader + _` - Split pane right
- `Leader + h/j/k/l` - Navigate panes (vim-style)
- `Leader + H/J/K/L` - Resize panes
- `Leader + z` or `Leader + Enter` - Toggle pane zoom
- `Leader + >` - Rotate panes clockwise
- `Leader + <` - Rotate panes counter-clockwise
- `Leader + x` - Kill pane

### Tab Management
- `Leader + c` - New tab
- `Leader + n` - Next tab
- `Leader + p` - Previous tab
- `Leader + Tab` - Last active tab
- `Leader + 1-9` - Jump to tab by number
- `Leader + Ctrl-h` - Move tab left
- `Leader + Ctrl-l` - Move tab right
- `Leader + r` - Rename tab
- `Leader + w` - Tab navigator (fuzzy)
- `Leader + X` - Kill tab

### Workspace Management
- `Leader + s` - Switch workspace (fuzzy picker)
- `Leader + Ctrl-c` - New workspace
- `Leader + Ctrl-r` - Rename workspace

### Copy Mode
- `Leader + [` - Enter copy mode (vi keys below)
  - `v` - Character select
  - `V` - Line select
  - `Ctrl-v` - Block select
  - `y` - Yank to clipboard and exit
  - `q` or `Esc` - Exit copy mode
  - `h/j/k/l` - Move cursor
  - `w/b/e` - Word motions
  - `0/$` - Start/end of line
  - `^` - First non-blank character
  - `g/G` - Top/bottom of scrollback
  - `Ctrl-u/d` - Page up/down

### Clipboard
- `Leader + Ctrl-p` - Paste from clipboard
- `Super + v` - Paste from clipboard
- `Right-click` - Paste from clipboard

### Window
- `Leader + m` - Toggle maximize (keeps dock)
- `Leader + f` - Toggle fullscreen (hides dock)
- `Leader + Q` - Quit application

### Quick Launch
- `Leader + Space` - Fuzzy app launcher (lazygit, lazydocker, k9s, etc.)
- `Leader + t` - Sesh session picker
- `Leader + o` - Open Obsidian vault in Neovim
- `Leader + a` - Open AI assistant

### Config
- `Leader + Alt-r` - Reload Wezterm config

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

## Shell Keybindings

These bindings are consistent across both zsh and fish.

### History
- `Ctrl-p` - Previous command
- `Ctrl-n` - Next command
- `Ctrl-r` - FZF fuzzy search history
- `Up/Down` - Substring search in history

### Line Editing (zsh)
- `Ctrl-a` - Beginning of line
- `Ctrl-e` - End of line
- `Ctrl-u` - Delete to beginning of line
- `Ctrl-k` - Delete to end of line
- `Ctrl-w` - Delete word before cursor
- `Alt-d` - Delete word after cursor
- `Ctrl-x Ctrl-e` - Edit command in $EDITOR

### Directory Navigation
- `Ctrl-T` - FZF file/directory search (insert path at cursor) — zsh & fish

## FZF (Fuzzy Finder)

### Built-in Key Bindings (both shells)
- `Ctrl-T` - Search files and directories (insert path at cursor)
- `Ctrl-R` - Search command history
- `Alt-C` - cd into a selected directory

### Git Integration (both shells — via fzf-git.sh)
Inserts the selected git object reference at the cursor.
- `Ctrl-G f` - Files
- `Ctrl-G b` - Branches
- `Ctrl-G t` - Tags
- `Ctrl-G r` - Remotes
- `Ctrl-G h` - Commit hashes
- `Ctrl-G s` - Stashes
- `Ctrl-G l` - Reflogs
- `Ctrl-G w` - Worktrees
- `Ctrl-G ?` - Show all fzf-git bindings

### FZF UI Navigation
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

## Neovim

**Leader**: `Space`

### General
- `Esc` - Clear search highlight (normal mode)
- `Ctrl-s` - Save file
- `Space q` - Quit
- `Space Q` - Quit all
- `\` - Toggle file explorer (Snacks)

### Window / Split Navigation (smart-splits)
- `Ctrl-h/j/k/l` - Move focus between splits (works across Neovim + tmux)
- `Alt-h/j/k/l` - Resize splits (works across Neovim + tmux)
- `Ctrl-m h/j/k/l` - Swap buffer with adjacent split

### Terminal
- `Esc Esc` - Exit terminal mode
- `Space t t` - Toggle terminal
- `Space t l` - Execute current line in terminal
- `Space t s` - Execute visual selection in terminal

### Diagnostics
- `[d` / `]d` - Previous / next diagnostic
- `Space d e` - Show diagnostic float
- `Space d q` - Send diagnostics to quickfix
- `Space d l` - Send diagnostics to loclist
- `Space d L` - Toggle virtual lines (inline diagnostic text)
- `Space d T` - Toggle virtual text
- `Space d f` / `Space d F` - Find diagnostics (all / buffer) via picker

### Quickfix & Location List
- `[q` / `]q` - Previous / next quickfix entry
- `[l` / `]l` - Previous / next location list entry
- `>` - Expand quickfix context (inside qf buffer)
- `<` - Collapse quickfix context (inside qf buffer)

### LSP
- `K` - Hover documentation
- `gD` - Go to declaration
- `Space l R` - Rename symbol
- `Space l A` - Code action
- `Space l h` - Toggle inlay hints
- `Space l r` - Find references (picker)
- `Space l s` - Workspace symbols (picker)
- `Space l S` - Buffer symbols (picker)
- `Space f` - Format buffer (Conform)

### Find (Snacks Pickers) — `Space f`
- `Space f f` or `Space Space` - Find files
- `Space f F` - Find files (git)
- `Space f b` - Buffers
- `Space f r` - Recent files
- `Space f h` - Help tags
- `Space f k` - Keymaps
- `Space f m` - Marks
- `Space f M` - Man pages
- `Space f j` - Jump list
- `Space f l` - Location list
- `Space f L` - Lines (current buffer)
- `Space f q` - Quickfix list
- `Space f d` - Diagnostics (all)
- `Space f D` - Diagnostics (buffer)
- `Space f c` - Command history
- `Space f C` - Commands
- `Space f s` - Search history
- `Space f t` - Treesitter symbols
- `Space f T` - Colorschemes
- `Space f u` - Undo history
- `Space f z` - Zoxide directories
- `Space f n` - Notifications
- `Space f p` - Projects
- `Space f P` - All pickers
- `Space f R` - Registers
- `Space /` - Grep (live)

### Git
- `Space g s` - Git status (picker)
- `Space g l` - Git log — branch (picker)
- `Space g L` - Git log — file (picker)
- `Space g Ctrl-l` - Git log — line (picker)
- `Space g S` - Git stash (picker)
- `Space g /` - Git grep (picker)
- `Space g o` - Open in browser (gitbrowse)
- `Space g d b` - Diff branch (toggle DiffviewOpen/Close)
- `Space g D` - Close diffview
- `Space g d f` - Diff file history
- `Space g d p` - Diff prompt (branch)
- `Space g d P` - Diff prompt (file history)

#### Merge (available in diff buffers)
- `Space g m l` - Get LOCAL hunk
- `Space g m r` - Get REMOTE hunk
- `Space g m b` - Get BASE hunk
- `Space g m L` - Put LOCAL hunk
- `Space g m R` - Put REMOTE hunk
- `Space g m B` - Put BASE hunk

### Trouble — `Space x`
- `Space x x` - Diagnostics (all)
- `Space x X` - Diagnostics (buffer)
- `Space x l` - LSP definitions/references (side panel)
- `Space x q` - Quickfix list
- `Space x L` - Location list
- `Space x t` - Todo comments
- `Space x s` - Symbols

### Bufferline (Tabs) — `Space b`
- `[b` / `]b` - Previous / next tab
- `Space b p` - Pin / unpin tab
- `Space b P` - Purge unpinned tabs
- `Space b o` - Close all other tabs
- `Space b r` - Close tabs to the right
- `Space b l` - Close tabs to the left

### Treesitter Text Objects

#### Select (operator-pending: `d`, `y`, `c`, `v`, etc.)
- `af` / `if` - Around / inside function
- `ac` / `ic` - Around / inside class
- `aa` / `ia` - Around / inside argument
- `ai` / `ii` - Around / inside conditional
- `al` / `il` - Around / inside loop
- `ab` / `ib` - Around / inside block

#### Move
- `]f` / `[f` - Next / previous function start
- `]F` / `[F` - Next / previous function end
- `]c` / `[c` - Next / previous class start
- `]C` / `[C` - Next / previous class end
- `]a` / `[a` - Next / previous argument start
- `]A` / `[A` - Next / previous argument end
- `;` - Repeat last textobject move forward
- `,` - Repeat last textobject move backward

#### Swap
- `Space s a` - Swap argument with next
- `Space s A` - Swap argument with previous

### Treesitter Context
- `[x` - Jump to context (function/class header at top of window)

### Treesj (Split/Join)
- `g S` - Split block to multiple lines
- `g J` - Join block to single line
- `g M` - Toggle split/join

### Completion (blink.cmp)
- `Ctrl-y` - Accept completion
- `Ctrl-Space` - Open completion menu (or docs if open)
- `Ctrl-n` / `Ctrl-p` - Next / previous item
- `Ctrl-e` - Hide completion menu
- `Ctrl-k` - Toggle signature help

### Copilot (inline suggestions)
- `Alt-y` - Accept suggestion
- `Alt-]` / `Alt-[` - Next / previous suggestion
- `Ctrl-]` - Dismiss suggestion

### AI (CodeCompanion) — `Space a`
- `Space a c` - Open AI chat
- `Space a p` - AI prompt (inline)
- `Space a a` - AI actions menu
- `Space a e` - Explain code (normal/visual)
- `Space a r` - Review code (normal/visual)
- `Space a f` - Fix & explain (normal/visual)
- `Space a F` - Fix inline (normal/visual)
- `Space a o` - Optimize & explain (normal/visual)
- `Space a O` - Optimize inline (normal/visual)
- `Space a d` - Generate docs (normal/visual)
- `Space a t` - Generate tests (normal/visual)
- `Space a C` - Generate commit message
- `Ctrl-y` - Accept inline change
- `Ctrl-n` - Reject inline change

### Debug (DAP)
- `F5` - Start / continue
- `F1` - Step into
- `F2` - Step over
- `F3` - Step out
- `F7` - Toggle DAP UI
- `F9` - Toggle breakpoint
- `Shift-F9` - Conditional breakpoint

### REPL (iron.nvim) — `Space r`
- `Space r t` - Focus REPL
- `Space r h` - Open REPL here (current split)
- `Space r l` - Send line
- `Space r v` - Send visual selection
- `Space r f` - Send file
- `Space r u` - Send until cursor
- `Space r p` - Send paragraph
- `Space r b` - Send code block
- `Space r c` - Clear REPL
- `Space r r` - Restart REPL
- `Space r q` - Quit REPL

### Notes (Obsidian) — `Space n`
- `Space n n` - New note
- `Space n o` - Open in Obsidian app
- `Space n b` - Backlinks
- `Space n t` - Tags
- `Space n l` - Links
- `Space n p` - Paste image
- `Space n r` - Rename note
- `Space n e` - Explorer (vault)
- `Space n f` - Find files (vault)
- `Space n /` - Grep (vault)

### HTTP (Kulala) — `Space h` (in `.http` / `.rest` files)
- `Space h h` - Run request under cursor
- `Space h l` - Replay last request
- `Space h a` - Run all requests
- `Space h s` - Open scratchpad
- `Space h A` - Code actions (LSP)

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

Configured in `.zshrc` and `conf.d/aliases.fish`:

### Navigation & Files
- `l` → `eza` (with color, git status, icons)
- `ll` → `eza --long --header --time-style=relative`
- `la` → `eza --long --all --header --time-style=relative`
- `tree` → `eza --tree --icons=always`
- `lt` → `eza --tree --level=2 --icons=always`

### Editors
- `vim`, `vi` → `nvim` (also `v` in fish)

### Shortcuts
- `g` → `git`
- `k` → `kubectl`
- `y` → `yazi`

### Smart Wrappers
- `j [args]` — Runs `just` with local `justfile` if present, otherwise uses `--global-justfile`

## Fish Shell Extras

### puffer-fish Path Expansion
- `..` → `../`
- `...` → `../../`
- `....` → `../../../`
- (and so on — each additional `.` adds another level)

## Tools

### Lazygit
Interactive git UI - `Prefix + g` in tmux or `lazygit` in terminal

### Lazydocker
Interactive docker UI - `Prefix + m` in tmux or `lazydocker` in terminal

### k9s
Interactive Kubernetes UI - `Prefix + k` in tmux or `k9s` in terminal

### Yazi
Terminal file manager - run `yazi` (or `y`) in terminal

---

**Tip**: Most of these tools have their own extensive keybindings. Press `?` within most tools to see their help/keybinding menu.
