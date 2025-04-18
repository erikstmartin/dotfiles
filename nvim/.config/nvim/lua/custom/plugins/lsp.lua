return {
  -- Useful status updates for LSP.
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },

  -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
  -- used for completion, annotations and signatures of Neovim apis
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },

  -- Schema information
  { "b0o/SchemaStore.nvim", lazy = true },

  {
    event = "VeryLazy",
    name = "lsp-setup",
    dir = vim.fn.stdpath("config"),
    config = function()
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "[L]SP: " .. desc })
          end
          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map("<leader>lR", vim.lsp.buf.rename, "[R]ename")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>lA", vim.lsp.buf.code_action, "Code [A]ction")

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          -- Show signature help for the function under your cursor.
          map("<leader>lk", vim.lsp.buf.signature_help, "Signature [H]elp")

          -- Jump to the definition of the word under your cursor.
          map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

          -- Jump to the implementation of the word under your cursor.
          map("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")

          -- Jump to the type definition of the word under your cursor.
          map("gy", vim.lsp.buf.type_definition, "[G]oto T[y]pe Definition")

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "lsp-highlight", buffer = event2.buf }
              end,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, "Toggle Inlay [H]ints")
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Enable the following language servers.
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        bashls = {
          cmd = { "bash-language-server", "start" },
          filetypes = { "sh", "bash", "zsh" },
        },
        buf = {
          cmd = { "buf", "lsp", "serve" },
          filetypes = { "proto" },
          root_markers = { "buf.yaml", "buf.work.yaml", ".git" },
        },
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        },
        cssls = {
          cmd = { "vscode-css-language-server", "--stdio" },
          filetypes = { "css", "scss", "less" },
        },
        docker_compose_language_service = {
          cmd = { "docker-compose-langserver", "--stdio" },
          filetypes = { "yaml.docker-compose" },
        },
        dockerls = {
          cmd = { "docker-langserver", "--stdio" },
          filetypes = { "dockerfile" },
        },
        gopls = {
          cmd = { "gopls" },
          filetypes = { "go", "gomod", "gowork", "gotmpl", "gosum" },
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
        helm_ls = {
          cmd = { "helm_ls", "serve" },
          filetypes = { "helm" },
        },
        html = {
          cmd = { "vscode-html-language-server", "--stdio" },
          filetypes = { "html", "templ" },
        },
        jsonls = {
          cmd = { "vscode-json-language-server", "--stdio" },
          filetypes = { "json", "jsonc" },
        },
        marksman = {
          cmd = { "marksman", "server" },
          filetypes = { "markdown", "markdown.mdx" },
        },
        pyright = {
          cmd = { "pyright-langserver", "--stdio" },
          filetypes = { "python" },
        },
        ruby_lsp = {
          cmd = { "ruby-lsp" },
          filetypes = { "ruby", "eruby" },
        },
        rubocop = {
          cmd = { "rubocop" },
          filetypes = { "ruby" },
        },
        rust_analyzer = {
          cmd = { "rust-analyzer" },
          filetypes = { "rust" },
        },
        -- sorbet = {},
        -- spectral = {},
        svelte = {
          cmd = { "svelteserver", "--stdio" },
          filetypes = { "svelte" },
        },
        tailwindcss = {
          cmd = { "tailwindcss-language-server", "--stdio" },
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
        },
        taplo = {
          cmd = { "taplo", "lsp", "stdio" },
          filetypes = { "toml" },
        },
        terraformls = {
          cmd = { "terraform-ls", "serve" },
          filetypes = { "terraform", "terraform-vars", "hcl" },
        },
        yamlls = {
          cmd = { "yaml-language-server", "--stdio" },
          filetypes = { "yaml", "yaml.docker-compose" },
          settings = {
            yaml = {
              schemas = require("schemastore").yaml.schemas(),
              validate = true,
            },
          },
        },
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        --
        lua_ls = {
          cmd = { "lua-language-server" },
          filetypes = { "lua" },
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        -- GDScript LSP (Godot's built-in language server over TCP, not a subprocess)
        gdscript = {
          cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
          filetypes = { "gd", "gdscript", "gdscript3" },
          root_markers = { "project.godot", ".git" },
        },
        -- Dart LSP (ships with Dart SDK, started via `dart language-server`)
        dartls = {
          cmd = { "dart", "language-server", "--protocol=lsp" },
          filetypes = { "dart" },
        },
        -- SQL LSP
        sqls = {
          cmd = { "sqls" },
          filetypes = { "sql", "mysql", "plsql" },
        },
        -- XML LSP (lemminx)
        lemminx = {
          cmd = { "lemminx" },
          filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
        },
      }

      -- Configure and enable all servers via the native vim.lsp.config API (nvim 0.11+).
      for name, config in pairs(servers) do
        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },

  { -- Autoformat
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format { async = true, lsp_fallback = true }
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 1000,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform can also run multiple formatters sequentially
        python = { "ruff_format" },
        go = { "goimports", "gofmt" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        ruby = { "rubyfmt" },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        javascript = { "prettier" },
        typescript = { "prettier" },
        gdscript = { "gdformat" },
        rust = { "rustfmt" },
        cs = { "csharpier" },
        dart = { "dart_format" },
        scss = { "prettier" },
        sql = { "sql_formatter" },
        svelte = { "prettier" },
      },
      formatters = {
        prettier = {
          prepend_args = function(self, ctx)
            if vim.bo[ctx.buf].filetype == "svelte" then
              local plugin_path = vim.fn.trim(vim.fn.system("mise where npm:prettier-plugin-svelte"))
                .. "/lib/node_modules/prettier-plugin-svelte/plugin.js"
              return { "--plugin", plugin_path }
            end
            return {}
          end,
        },
      },
    },
  },
}
