" Grep as you type (requires rg currently)
nnoremap <Leader>/ :lua require('telescope.builtin').live_grep()<CR>

" Convert currently quickfixlist to telescope
nnoremap <Leader>qf :lua require('telescope.builtin').quickfix()<CR>

" Fuzzy find over git files in your directory
nnoremap <c-p> :lua require'telescope.builtin'.git_files()<CR>
nnoremap <Leader>p :lua require'telescope.builtin'.find_files{}<CR>

" Use builtin LSP to request references under cursor. Fuzzy find over results.
nnoremap <Leader>fr :lua require'telescope.builtin'.lsp_references()<CR>
nnoremap <Leader>ts :lua require'telescope.builtin'.treesitter()<CR>

nnoremap <Leader>fp :lua require'telescope.builtin'.planets()<CR>
nnoremap <Leader>fs :lua require('session-lens').search_session()<CR>

nnoremap <Leader>fkm :lua require'telescope.builtin'.keymaps{}<CR>
nnoremap <Leader>fm :lua require'telescope.builtin'.marks{}<CR>
nnoremap <Leader>ft :lua require'telescope.builtin'.tags{}<CR>
nnoremap <Leader>fb :lua require'telescope.builtin'.buffers{}<CR>
