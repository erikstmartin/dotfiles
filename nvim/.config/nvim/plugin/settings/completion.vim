" better key bindings for UltiSnipsExpandTrigger
"let g:UltiSnipsExpandTrigger="<cr>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
" let g:completion_auto_change_source = 1
" let g:completion_chain_complete_list = [
"      \{'complete_items': ['lsp', 'snippet', 'tags', 'buffers', 'tmux']},
"     \{'mode': '<c-p>'},
"     \{'mode': '<c-n>'}
" \]

" configure lsp
let g:diagnostic_enable_virtual_text = 1
lua << EOF
  vim.lsp.buf.code_action()
  require('crates').setup()

  local util = require "lspconfig".util

  require("mason").setup({
      PATH = "prepend", -- "skip" seems to cause the spawning error
      pip = {
        upgrade_pip = true,
      }
  })

  require("mason-lspconfig").setup {
    ensure_installed = { "bashls", "clangd", "cmake", "cssls", "docker_compose_language_service", "dockerls",
    "dotls", "eslint", "gopls", "helm_ls", "html", "jsonls", "lua_ls","marksman", "pyright",
    "rust_analyzer", "sorbet", "spectral", "sqlls", "svelte", "tailwindcss", "taplo", "terraformls",
    "tsserver", "vuels", "vimls", "yamlls"}
  }

  local cmp = require'cmp'
  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'omni' },
      { name = 'tags' },
      { name = 'treesitter' },
      { name = 'ultisnips' }, -- For ultisnips users.
    }, {
      { name = 'buffer' },
      { name = 'html' },
      { name = 'tmux' },
      { name = 'html-css' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })


  local on_attach_vim = function(client)
    -- return require'completion'.on_attach(client)
  end

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities.textDocument.completion.completionItem.snippetSupport = true

  require'lspconfig'.bashls.setup{on_attach=on_attach_vim}
  require'lspconfig'.clangd.setup{on_attach=on_attach_vim}
  require("clangd_extensions").setup{on_attach=on_attach_vim}
  require'lspconfig'.cmake.setup{on_attach=on_attach_vim}

  require'lspconfig'.cssls.setup {
    capabilities = capabilities,
    on_attach=on_attach_vim,
  }

  require'lspconfig'.docker_compose_language_service.setup{
    root_dir=util.root_pattern('docker-compose.yml', 'docker-compose.yaml'),
    on_attach=on_attach_vim
  }
  require'lspconfig'.dockerls.setup{on_attach=on_attach_vim}
  require'lspconfig'.dotls.setup{on_attach=on_attach_vim}

  require'lspconfig'.eslint.setup({
    on_attach = function(client, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        command = "EslintFixAll",
      })
    end,
  })

  require'lspconfig'.gopls.setup{
    capabilities = capabilities,
    on_attach=on_attach_vim
  }

  require'lspconfig'.helm_ls.setup{on_attach=on_attach_vim}

  require'lspconfig'.html.setup {
    capabilities = capabilities,
    on_attach=on_attach_vim,
  }

  require'lspconfig'.jsonls.setup {
    capabilities = capabilities,
    on_attach=on_attach_vim
  }

  require'lspconfig'.lua_ls.setup {
    on_attach=on_attach_vim,
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
        client.config.settings = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            library = { vim.env.VIMRUNTIME }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        })

        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
      return true
    end
  }
  require'lspconfig'.marksman.setup{on_attach=on_attach_vim}
  require'lspconfig'.pyright.setup{on_attach=on_attach_vim}

  require'lspconfig'.rust_analyzer.setup{on_attach=on_attach_vim}
  require'lspconfig'.sorbet.setup{on_attach=on_attach_vim}
  require'lspconfig'.spectral.setup{on_attach=on_attach_vim}
  require'lspconfig'.sqlls.setup{on_attach=on_attach_vim}
  require'lspconfig'.svelte.setup{on_attach=on_attach_vim}
  require'lspconfig'.tailwindcss.setup{on_attach=on_attach_vim}
  require'lspconfig'.taplo.setup{on_attach=on_attach_vim}
  require'lspconfig'.terraformls.setup{on_attach=on_attach_vim}
  require'lspconfig'.textlsp.setup{on_attach=on_attach_vim}

  require'lspconfig'.tsserver.setup{
    filetypes = { "javascript", "typescript", "typescriptreact", "typescript.tsx" },
    on_attach=on_attach_vim,
    root_dir = function() return vim.loop.cwd() end
  }
  require("typescript-tools").setup {on_attach = on_attach_vim}

  require'lspconfig'.vimls.setup{on_attach=on_attach_vim}
  require'lspconfig'.vuels.setup{on_attach=on_attach_vim}
  require'lspconfig'.yamlls.setup{on_attach=on_attach_vim}

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

EOF

imap <silent><script><expr> <leader>j copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" Use completion-nvim in every buffer
"autocmd BufEnter * lua require'completion'.on_attach()
autocmd Filetype go,python,ts,typescript,rust,javascript,python,lua,bash,css setlocal omnifunc=v:lua.vim.lsp.omnifunc

autocmd InsertLeave,BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{highlight = "NonText", prefix = ' » ', aligned = false, only_current_line = false}

"let g:completion_enable_auto_popup = 1
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" inoremap <silent><expr> <TAB>
"   \ pumvisible() ? "\<C-n>" :
"   \ <SID>check_back_space() ? "\<TAB>" :
"   \ completion#trigger_completion()

" Use <Tab> and <S-Tab> to navigate through popup menu
" inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"nmap <tab> <Plug>(completion_smart_tab)
"nmap <s-tab> <Plug>(completion_smart_s_tab)

" possible value: 'UltiSnips', 'Neosnippet', 'vim-vsnip'
"let g:completion_enable_snippet = 'UltiSnips'

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

" let g:completion_enable_auto_hover = 0
" let g:completion_enable_auto_signature = 0
" possible value: "length", "alphabet", "none"
"let g:completion_sorting = "length"
"let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy', 'all']
"g:completion_matching_ignore_case = 1
" let g:completion_trigger_character = ['.', '::']

" Setup default LSP keybinds
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> td    <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> ca    <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> <Leader>re <cmd>lua vim.lsp.buf.rename()<CR>
