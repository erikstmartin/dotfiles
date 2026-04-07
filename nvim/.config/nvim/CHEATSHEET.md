# Neovim Cheatsheet

## Fast jumps inside a file (Flash)

| Key | Action | When to use |
| --- | --- | --- |
| `<leader>fs` | Flash jump | You know roughly where you want to land in visible text |
| `<leader>fS` | Flash Treesitter | You want to jump/select by syntax node |
| `r` (operator-pending) | Flash remote | You want an operator (`d`, `c`, `y`) at a remote target |
| `R` (operator/visual) | Treesitter search | You want structural target search for edits/selections |

## Working set navigation (Harpoon)

| Key | Action | When to use |
| --- | --- | --- |
| `<leader>mm` | Toggle tag | Mark/unmark current file in your active task set |
| `<leader>mt` | Toggle tags window | View, reorder, and pick from your tagged task files |
| `<leader>mn` | Next tag | Rotate forward through tagged files while implementing |
| `<leader>mp` | Previous tag | Rotate backward through tagged files |

## Jump history navigation (built-in)

| Key | Action | When to use |
| --- | --- | --- |
| `<C-o>` / `<C-i>` | Jumplist back / forward | Return to where you were before a jump |
| `g;` / `g,` | Changelist back / forward | Revisit recent edit locations |

## Related

| Key | Action |
| --- | --- |
| `<leader>ff` / `<leader><leader>` | Find files (Snacks picker) |
| `<leader>/` | Project grep (Snacks picker) |
| `<leader>fq` | Quickfix list picker |
| `<leader>df` | Diagnostics picker (all) |
| `<leader>gdb` | Toggle Diffview |

## Daily loop

1. Find or open files with `<leader>ff`.
2. Tag active files with `<leader>mm`.
3. Move between tagged files with `<leader>mn` / `<leader>mp`.
4. Use `<leader>fs` / `<leader>fS` for fast local movement while editing.
5. Use `<C-o>` / `g;` when you need to recover context from recent jumps or edits.
