return {
  -- LSP progress notifications
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
    -- Server configs live in lsp/<name>.lua (picked up by vim.lsp.config).
    -- blink.cmp is a dependency so its capabilities (vim.lsp.config("*")) are
    -- registered before any server starts.
    name = "lsp-setup",
    dir = vim.fn.stdpath "config",
    event = "VeryLazy",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          -- Ruff's hover is minimal; leave hover to pyright
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end

          -- Neovim also maps K (hover), grn/gra/grr/gri/grt/grx, gO and <C-s> (insert).
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or "n", keys, func, { buffer = buf, desc = "[L]SP: " .. desc })
          end
          local pick = require("custom.util").pick
          map("gd", pick "lsp_definitions", "[G]oto [D]efinition")
          map("gD", pick "lsp_declarations", "[G]oto [D]eclaration")
          map("gI", pick "lsp_implementations", "[G]oto [I]mplementation")
          map("gy", pick "lsp_type_definitions", "[G]oto T[y]pe Definition")

          map("<leader>lR", vim.lsp.buf.rename, "[R]ename")
          map("<leader>lA", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
          map("<leader>lk", vim.lsp.buf.signature_help, "Signature help ([K])")
          map("<leader>lr", pick "lsp_references", "[R]eferences")
          map("<leader>ls", pick "lsp_workspace_symbols", "[S]ymbols (workspace)")
          map("<leader>lS", pick "lsp_symbols", "[S]ymbols (buffer)")
          map("<leader>li", pick "lsp_incoming_calls", "[I]ncoming calls")
          map("<leader>lo", pick "lsp_outgoing_calls", "[O]utgoing calls")
          map("<leader>lF", function()
            Snacks.rename.rename_file()
          end, "Rename [F]ile (updates imports)")
          map("<leader>ll", pick "lsp_config", "[L]ist servers")
          map("<leader>lX", "<cmd>lsp restart<CR>", "Restart (e[X]it and start)")

          -- Jump between uses of the symbol under the cursor (highlighted by snacks.words).
          -- Intentionally replaces the built-in ]]/[[ (next/prev section).
          map("]]", function()
            Snacks.words.jump(vim.v.count1)
          end, "Next reference")
          map("[[", function()
            Snacks.words.jump(-vim.v.count1)
          end, "Previous reference")

          if client:supports_method("textDocument/inlayHint", buf) then
            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, "Toggle Inlay [H]ints")
          end

          -- Neovim 0.12+ refreshes codelens automatically once enabled
          if client:supports_method("textDocument/codeLens", buf) then
            map("<leader>lc", vim.lsp.codelens.run, "Run [C]ode lens")
            vim.lsp.codelens.enable(true, { bufnr = buf })
          end

          -- C/C++: jump between a source file and its header
          if client.name == "clangd" then
            map("<leader>lH", function()
              local params = vim.lsp.util.make_text_document_params(buf)
              client:request("textDocument/switchSourceHeader", params, function(err, uri)
                if err or not uri then
                  return vim.notify("No matching header/source file", vim.log.levels.INFO)
                end
                vim.cmd.edit(vim.uri_to_fname(uri))
              end, buf)
            end, "Switch [H]eader/source")
          end

          -- Copilot ghost-text suggestions via native LSP inline completion
          if client.name == "copilot" then
            vim.lsp.inline_completion.enable(true, { bufnr = buf })
            local imap = function(keys, func, desc)
              vim.keymap.set("i", keys, func, { buffer = buf, desc = "Copilot: " .. desc })
            end
            imap("<M-y>", function()
              vim.lsp.inline_completion.get()
            end, "Accept suggestion")
            imap("<M-]>", function()
              vim.lsp.inline_completion.select { count = 1 }
            end, "Next suggestion")
            imap("<M-[>", function()
              vim.lsp.inline_completion.select { count = -1 }
            end, "Prev suggestion")
          end
        end,
      })

      -- rust-analyzer is managed by rustaceanvim (custom/plugins/rust.lua)
      vim.lsp.enable {
        "bashls", "bicep", "buf", "clangd", "copilot", "cssls", "docker_compose_language_service", "dockerls",
        "gdscript", "golangci_lint_ls", "gopls", "helm_ls", "html", "jsonls", "lemminx", "lua_ls",
        "marksman", "neocmake", "pyright", "rubocop", "ruby_lsp", "ruff", "sqls", "tailwindcss", "taplo", "terraformls",
        "vtsls", "yamlls",
      }
    end,
  },

  { -- Autoformat
    "stevearc/conform.nvim",
    event = "BufWritePre", -- must be loaded for format_on_save
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format { async = true, lsp_format = "fallback" }
        end,
        mode = { "n", "x" },
        desc = "[L]SP: [F]ormat buffer/selection",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- No LSP fallback for languages without a standard style
        local no_lsp_fallback = { c = true, cpp = true }
        return {
          timeout_ms = 1000,
          lsp_format = no_lsp_fallback[vim.bo[bufnr].filetype] and "never" or "fallback",
        }
      end,
      formatters = {
        -- The project's own RuboCop (version and plugins) when it's in the bundle
        -- (a function override is resolved once per lookup, not per field)
        rubocop = function(bufnr)
          local ruby = require "custom.ruby"
          if ruby.bundles(ruby.root(bufnr), "rubocop") then
            return { command = "bundle", prepend_args = { "exec", "rubocop" } }
          end
          return {}
        end,
      },
      formatters_by_ft = {
        cmake = { "gersemi" },
        cs = { "csharpier" },
        css = { "prettier" },
        gdscript = { "gdformat" },
        go = { "goimports", "gofumpt" }, -- gofumpt matches gopls `gofumpt = true`
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        python = { "ruff_format" },
        -- Projects that use RuboCop format with it (their style); others with rubyfmt
        ruby = function(bufnr)
          return require("custom.ruby").uses_rubocop(bufnr) and { "rubocop" } or { "rubyfmt" }
        end,
        rust = { "rustfmt" },
        scss = { "prettier" },
        sql = { "sql_formatter" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
      },
    },
  },
}
