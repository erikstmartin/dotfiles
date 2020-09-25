" Grep as you type (requires rg currently)
nnoremap <Leader>/ :lua require('telescope.builtin').live_grep()<CR>

" Convert currently quickfixlist to telescope
nnoremap <Leader>qf :lua require('telescope.builtin').quickfix()<CR>

" Fuzzy find over git files in your directory
nnoremap <c-p> :lua require'telescope.builtin'.git_files()<CR>
nnoremap <Leader>p :lua require'telescope.builtin'.find_files{}<CR>

" Use builtin LSP to request references under cursor. Fuzzy find over results.
nnoremap <Leader>gr :lua require'telescope.builtin'.lsp_references()<CR>
nnoremap <Leader>ts :lua require'telescope.builtin'.treesitter()<CR>

nnoremap <Leader>tp :lua require'telescope.builtin'.planets()<CR>
