# Usage Guide

Keybindings, aliases and workflows.

## Hammerspoon (macOS)

Global hotkeys that launch or focus an app.
First run: grant Accessibility permission (System Settings → Privacy & Security → Accessibility → Hammerspoon).

- `Cmd+Opt+1` - Obsidian
- `Cmd+Opt+2` - WezTerm
- `Cmd+Opt+3` - Microsoft Edge
- `Cmd+Opt+4` - Slack
- `Cmd+Opt+5` - Godot
- `Cmd+Opt+r` - Reload Hammerspoon config (also auto-reloads when `~/.hammerspoon/*.lua` changes)

## Wezterm

**Leader**: `Alt-b` (1000ms timeout)

### Pane Management
- `Leader + -` - Split pane below
- `Leader + \` - Split pane right
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
- `Leader + Ctrl-Space` - Domain picker (local / WSL / SSH)

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
- `Leader + o` - Open Obsidian vault in Neovim
- `Leader + a` - Open AI assistant
- `Leader + A` - Workmux dashboard (agent overview)
- `Leader + P` - Open PowerShell 7 in a new tab
- `Leader + Shift+C` - Open Command Prompt in a new tab
- `Leader + Shift+W` - Open WSL (Ubuntu) in a new tab
- `Leader + Ctrl-w` - Split the pane into WSL (Ubuntu)

### Config
- `Leader + Alt-r` - Reload Wezterm config

## Tmux

**Prefix**: `Ctrl-b`

### Session Management
- `Prefix + Shift-Tab` - Switch to last session
- `Prefix + Ctrl-c` - Create new session (prompts for name)
- `Prefix + Ctrl-r` - Rename current session
- `Prefix + Ctrl-q` - Kill current session (with confirmation)
- `Prefix + s` - Session picker

### Window Management
- `Prefix + r` - Rename current window
- `Prefix + n/p` - Next/previous window
- `Prefix + Tab` - Switch to last active window
- `Prefix + Ctrl-h/l` - Move current window left/right

### Pane Management
- `Prefix + -` - Split horizontally
- `Prefix + \` - Split vertically
- `Prefix + h/j/k/l` - Navigate panes (vim-style)
- `Prefix + H/J/K/L` - Resize panes (vim-style)
- `Prefix + >` - Swap with next pane
- `Prefix + <` - Swap with previous pane
- `Prefix + z` or `Prefix + Enter` - Toggle pane zoom
- `Prefix + x/X` - Kill pane/window

### Menus and Popups
- `Prefix + Space` - Launcher menu (Lazygit, Lazydocker, k9s, gh-dash, Obsidian, AI assistant, terminal, config)
- `Prefix + S` - Session management menu
- `Prefix + W` - Window management menu
- `Prefix + P` - Pane management menu

### Other
- `Prefix + Alt-r` - Reload tmux config
- `Prefix + M` - Toggle CPU and memory stats in the status bar
- `Prefix + v` - Paste from system clipboard (pbpaste / wl-paste / xclip / xsel / PowerShell)
- `Prefix + #` / `Prefix + Ctrl-p` / `Prefix + Ctrl-Shift-p` - List / paste / choose paste buffers
- `Prefix + d` - Detach (tmux default)

### Workmux
- `Prefix + A` - Agent dashboard (popup)
- `Prefix + Ctrl-t` - Toggle agent sidebar
- `Prefix + a` - Jump to the most recently finished/waiting agent (repeat to cycle)
- `Prefix + Backspace` - Toggle between current and last-visited agent
- `Alt-j/k`, `Alt-1..9` - Cycle / jump to agents (no prefix)

## Shell Keybindings

The same in zsh and fish unless noted.

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

### Completion
- `Shift-Tab` - Fuzzy-filter completions at the cursor

## FZF (Fuzzy Finder)

### Built-in Key Bindings (both shells)
- `Ctrl-T` - Search files and directories (insert path at cursor)
- `Ctrl-R` - Search command history
- `Alt-C` - cd into a selected directory

File and directory lists come from `fd`, which skips caches and tool data (`~/Library`, `~/.cache`, `node_modules`, ...; see `fd/.config/fd/ignore`). `fd -u` searches everything.

### Git Integration (both shells, via fzf-git.sh)
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

### Window / Split Navigation
- `Ctrl-h/j/k/l` - Move focus between Neovim splits (tmux panes: `Prefix + h/j/k/l`)
- `Alt-h/j/k/l` - Resize Neovim splits (tmux panes: `Prefix + H/J/K/L`)

### Terminal
- `Esc Esc` - Exit terminal mode
- `Space r r` - Toggle terminal
- `Space r l` - Run the current line in a terminal
- `Space r s` - Run the visual selection in a terminal

### Diagnostics
- `[d` / `]d` - Previous / next diagnostic
- `Space d e` - Show diagnostic float
- `Space d L` - Toggle virtual lines (inline diagnostic text)
- `Space d T` - Toggle virtual text
- `Space d f` / `Space d F` - Find diagnostics (all / buffer) via picker
- `Space x x` / `Space x X` - Diagnostics (all / buffer) in a Trouble panel

### Quickfix & Location List
- `[q` / `]q` - Previous / next quickfix entry
- `[l` / `]l` - Previous / next location list entry
- `>` - Expand quickfix context (inside qf buffer)
- `<` - Collapse quickfix context (inside qf buffer)

### LSP
Go to (picker when there are several results):
- `K` - Hover documentation
- `gd` / `gD` - Definition / declaration
- `gI` / `gy` - Implementation / type definition
- `]]` / `[[` - Next / previous use of the symbol under the cursor

Actions and searches — `Space l`:
- `Space l R` - Rename symbol
- `Space l A` - Code action (normal or visual)
- `Space l k` - Signature help
- `Space l r` - References
- `Space l s` / `Space l S` - Symbols (workspace / buffer)
- `Space l i` / `Space l o` - Incoming / outgoing calls
- `Space l F` - Rename file (LSP updates imports)
- `Space l >` / `Space l <` - Swap argument with next / previous (Treesitter; works without a server)
- `Space l f` - Format buffer / selection (Conform; also runs on save)
- `Space l h` - Toggle inlay hints
- `Space l c` - Run code lens
- `Space l H` - Switch between C/C++ header and source
- `Space l l` - List LSP servers
- `Space l X` - Restart LSP servers for this buffer

Neovim's defaults also work: `grn` rename, `gra` code action, `grr` references, `gri` implementation, `grt` type definition, `grx` code lens, `gO` buffer symbols.

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
- `Space f c` - Command history
- `Space f C` - Commands
- `Space f H` - Search history
- `Space f s` - Flash jump (type a few characters, then the label)
- `Space f S` - Flash Treesitter select (pick a syntax node)
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
- `Space g g` - Neogit status (stage `s`, unstage `u`, discard `x`, commit `c`, push `P`, `?` help)
- `Space g c` - Commit (Neogit)
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

#### Hunks — reviewing changes (e.g. from an agent)
Open buffers reload automatically when files change on disk, so hunks appear
live. Stage = accept, reset = reject; anything still unstaged is unreviewed.
Works in normal files and in diffview's working-tree pane.
- `]h` / `[h` - Next / previous hunk
- `Space g a` - Accept hunk (stage; again on a staged hunk = unstage). Visual: selected lines
- `Space g r` - Reject hunk (reset, and save the file). Visual: selected lines
- `Space g A` / `Space g R` - Accept / reject the whole file
- `Space g p` - Preview hunk inline (shows its deleted lines)
- `Space g b` - Blame line
- `Space g w` - Toggle word diff + line highlights
- `ih` - Hunk text object (e.g. `vih`, `dih`)

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
- `;` / `,` - Repeat the last `f`/`F`/`t`/`T` jump forward / backward (flash.nvim; not textobject moves)

### Marks (Harpoon) — `Space m`
Tagged files, per git repo:
- `Space m m` - Tag / untag the current file
- `Space m t` - Toggle the tags window (view, reorder, pick)
- `Space m n` / `Space m p` - Next / previous tagged file

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
- `Ctrl-x Ctrl-t` - Complete words from the other tmux panes

### Copilot (inline suggestions)
- `Alt-y` - Accept suggestion
- `Alt-]` / `Alt-[` - Next / previous suggestion
- Keep typing or leave insert mode to dismiss

### AI — `Space a`
The keys say where a request goes: `Space a <key>` = agent terminal, `Space a c <key>` = chat panel, `Space a i <key>` = inline edit of this buffer.

Agent — Claude Code (or codex/opencode/copilot/omp) in a terminal; reads, runs and edits across the repo:
- `Space a a` - Show / hide the agent (starts one if none)
- `Space a n` - New agent (pick which)
- `Space a k` - Ask the agent (visual: include the selection)
- `Space a s` - Send the buffer/selection to the agent
- `Space a d` - Send diagnostics to the agent to fix
- `Space a t` - Send terminal output (e.g. failing tests) to the agent to fix
- `Space a r` - Review the agent's changes (`ga` accept / `gr` revert hunk, `gc` comment)
- `Space a x` - Close the agent (or exit it, e.g. `/exit`); `{` / `}` cycle agents in normal mode

Chat — CodeCompanion side panel (Copilot); answers questions, doesn't edit files:
- `Space a c c` - Toggle chat (visual: with the selection)
- `Space a c e` - Explain the selection
- `Space a c f` - Fix the selection
- `Space a c l` - Explain LSP diagnostics in the selection
- `Space a c r` - Review the selection
- `Space a c o` - Optimize the selection
- `Space a c m` - Commit message for staged changes

Inline — Copilot edits this buffer directly (`g2` accept, `g3` reject):
- `Space a i i` - Inline prompt
- `Space a i d` - Document the selection (in place)
- `Space a i t` - Unit tests for the selection (new buffer)

- `Space a p` - Action palette (every prompt, open chats, saved sessions)

In chat: `ga` change adapter/model, `/save` / `/resume` sessions, `#{buffer}`, `#{diagnostics}`, `#{selection}` for context.
Diffs and tool approvals: `g2` accept, `g3` reject, `g1` always accept, `g4` cancel, `gv` view diff.

### Debug (DAP) — `Space D`
- `F5` / `Space D c` - Start / continue
- `Shift-F5` / `Space D t` - Stop
- `Ctrl-F5` - Restart
- `Space D l` - Run the last debug configuration again
- `F1` / `F2` / `F3` - Step into / over / out (Fn + key on a Mac)
- `Space D C` - Run to cursor
- `F9` / `Space D b` - Toggle breakpoint
- `Shift-F9` / `Space D B` - Conditional breakpoint
- `Space D p` - Log point (prints a message, doesn't stop; `{expr}` is interpolated)
- `Space D x` - Clear all breakpoints
- `Space D E` - Break on exceptions (choose which)
- `Space D e` - Evaluate the expression under the cursor (visual: the selection)
- `Space D r` - Debug console (REPL)
- `Space D k` / `Space D j` - Up / down the call stack
- `F7` / `Space D u` - Toggle the debug UI

Launching: Go (nvim-dap-go), Python (debugpy via `uv`), Ruby (rdbg: current file, current test file, or attach), Rust (`Space c d`, rustaceanvim), C/C++ (codelldb; picks an executable from `build/`, `out/` or `cmake-build-*`), C# (runs `dotnet build`, then picks a project's `bin/Debug` DLL). `.vscode/launch.json` is read too. Debug the nearest test with `Space t d` (neotest).

### Tests (neotest: Go, Rust, C#, Python, Ruby RSpec/Minitest) — `Space t`
- `Space t n` - Run nearest test
- `Space t f` - Run tests in file
- `Space t a` - Run all tests
- `Space t l` - Re-run last test
- `Space t d` - Debug nearest test
- `Space t x` - Stop running tests
- `Space t w` - Watch file (re-run on save)
- `Space t s` - Toggle test summary
- `Space t o` / `Space t O` - Test output / output panel
- `]t` / `[t` - Next / previous failed test

### Ruby
- ruby-lsp for completion, navigation and diagnostics. When the project bundles RuboCop, ruby-lsp runs it; a project with only a `.rubocop.yml` gets the global RuboCop linter instead
- Formatting on save: RuboCop (`bundle exec` when bundled) in projects that use it, otherwise rubyfmt
- Code lenses above tests (`Space l c`): ▶ Run (in a terminal) / Debug. RSpec lenses need the project to bundle `ruby-lsp-rspec`
- Commands run under `bundle exec` when the project has a Gemfile

### Rust (rustaceanvim, Rust buffers only) — `Space c`
- `Space c r` - Runnables
- `Space c d` - Debuggables
- `Space c t` - Testables
- `Space c m` - Expand macro
- `Space c e` - Explain error
- `Space c D` - Render diagnostic
- `Space c c` - Open Cargo.toml
- `Space c p` - Parent module
- `Space c j` - Join lines
- Code lenses (`Space l c`): Run / Debug / references above items

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

## Global Just Cleanup

Run these through `jg` (or `just --global-justfile`):

- `jg clean` — remove rebuildable package-manager and language caches: mise cache downloads and stale configuration links (`mise prune`), Homebrew/Scoop cache, npm's unreachable cache entries, pip, uv, and Go build/test caches. It does not uninstall active mise toolchains.
- `jg clean-old-logs` — delete only user-level `*.log` files older than 30 days. It does not delete application support, databases, crash reports, or system logs.
- `jg docker-clean` — remove stopped containers, unused networks, and unused images. Volumes are kept.
- `jg docker-clean-anonymous-volumes` — also remove unused anonymous Docker volumes. Named volumes are preserved.

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
- `y` → `yazi`, then changes the shell to Yazi's directory on exit

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
Interactive git UI - `Prefix + Space` then `g` in tmux (launcher menu), `Leader + Space` in Wezterm, or `lazygit` in terminal
- `x` or `?` - Keybindings menu
- `z` / `Ctrl-z` - Undo / redo
- `c` / `v` / `Ctrl-r` - Copy (cherry-pick) / paste / reset copied commits (commits panel)
- `C` - Set fixup message (commits panel)
- Diffs are plain `git diff` output (no delta)

### Lazydocker
Interactive docker UI - `Prefix + Space` then `d` in tmux (launcher menu) or `lazydocker` in terminal

### dive
Explore a Docker image layer by layer (what each layer adds, wasted space) - `dive <image>`

### k9s
Interactive Kubernetes UI - `Prefix + Space` then `k` in tmux (launcher menu) or `k9s` in terminal
- `Ctrl-L` - Follow logs from every pod of the selected pod/deployment/statefulset/daemonset/job (stern)
- `Shift-D` - Explore the selected container's image (dive, in the containers view)

### Azure
`az`, the Bicep CLI, the Bicep language server and kubelogin come from the `azure` mise module (Bicep's language server also needs the `dotnet` module; on Windows `az` is installed with WinGet). `az bicep` uses that Bicep CLI rather than downloading its own.
- `kubelogin convert-kubeconfig -l azurecli` - Make an AKS kubeconfig (from `az aks get-credentials`) sign in with your `az login` session
- `~/.azure/config` is tracked in the repo (`azure` package): telemetry and survey prompts are off. Manage it with `az config set` (it writes through the link); login tokens stay in `~/.azure` and are never tracked
- In Neovim, `.bicep` files get completion, hover docs, type checking and diagnostics; ARM template JSON files (with the usual `"$schema": "https://schema.management.azure.com/..."` line) are validated against the ARM schema
- `bicep build main.bicep` compiles to an ARM template; `bicep decompile template.json` converts an ARM template to Bicep

### Kubernetes CLI
- `kubectx` / `kubens` - Switch context / namespace (fzf picker with no arguments; `-` switches back)
- `stern <name>` - Follow logs from every pod whose name matches (`-n <ns>`, `--tail 50`, `-c <container>`)
- `helm diff upgrade <release> <chart> -f values.yaml` - Show what an upgrade would change in the cluster before running it (helm-diff; installed and updated with signature checks by `jg helm-plugins` / `jg update`)

In Neovim, manifests under `k8s/`, `kubernetes/`, `manifests/`, `deploy/` (or named `*.k8s.yaml`) get Kubernetes completion and validation, including common custom resources (cert-manager, Argo, …). Other files opt in with a first-line `# yaml-language-server: $schema=…` comment (see `nvim/lsp/yamlls.lua`). Helm templates are validated by helm_ls.

### Yazi
Terminal file manager - run `yazi` (or `y`) in terminal
- `t` - New tab in the current directory (yazi default: `t t`)
- `T` - Rename the current tab (yazi default: `t r`)
- `g C` - Go to `~/Code`
- `O` / `Shift+Enter` - Choose an opener (`jqp` is available for JSON/NDJSON)
- `~` or `F1` - Help (type to filter)
