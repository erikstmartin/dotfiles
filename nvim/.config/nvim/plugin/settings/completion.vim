" better key bindings for UltiSnipsExpandTrigger
"let g:UltiSnipsExpandTrigger="<cr>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
":lua vim.lsp.buf.code_action()

" configure lsp
"let g:diagnostic_enable_virtual_text = 1
lua << EOF
  local on_attach_vim = function(client)
    require'completion'.on_attach(client)
  end

  require'lspconfig'.gopls.setup{on_attach=on_attach_vim}
  require'lspconfig'.rust_analyzer.setup{on_attach=on_attach_vim}
  require'lspconfig'.tsserver.setup{on_attach=on_attach_vim}
  require'lspconfig'.pyls.setup{on_attach=on_attach_vim}
  require'lspconfig'.cssls.setup{on_attach=on_attach_vim}
  require'lspconfig'.bashls.setup{on_attach=on_attach_vim}
  require'lspconfig'.sumneko_lua.setup{on_attach=on_attach_vim}

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- Enable underline, use default values
      underline = true,
      -- Enable virtual text, override spacing to 4
      virtual_text = {
        spacing = 4,
        prefix = '~',
      },
      -- Use a function to dynamically turn signs off
      -- and on, using buffer local variables
      signs = function(bufnr, client_id)
        local ok, result = pcall(vim.api.nvim_buf_get_var, bufnr, 'show_signs')
        -- No buffer local variable set, so just enable by default
        if not ok then
          return true
        end

        return result
      end,
      -- Disable a feature
      update_in_insert = false,
    }
  )

  require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
      enable = true,              -- false will disable the whole extension
      disable = { "java" },  -- list of language that will be disabled
    },
  }
EOF

" Use completion-nvim in every buffer
"autocmd BufEnter * lua require'completion'.on_attach()
autocmd Filetype go,python,ts,typescript,rust,javascript,python,lua,bash,css setlocal omnifunc=v:lua.vim.lsp.omnifunc

autocmd InsertLeave,BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{highlight = "NonText", prefix = ' » ', aligned = false, only_current_line = false}

let g:completion_enable_auto_popup = 1
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ completion#trigger_completion()

" possible value: 'UltiSnips', 'Neosnippet', 'vim-vsnip'
let g:completion_enable_snippet = 'UltiSnips'

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

nmap <tab> <Plug>(completion_smart_tab)
nmap <s-tab> <Plug>(completion_smart_s_tab)

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

let g:completion_enable_auto_hover = 0
let g:completion_enable_auto_signature = 0
" possible value: "length", "alphabet", "none"
"let g:completion_sorting = "length"
"let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy', 'all']
"g:completion_matching_ignore_case = 1
let g:completion_trigger_character = ['.', '::']

" Setup default LSP keybinds
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> <Leader>re <cmd>lua vim.lsp.buf.rename()<CR>
