return {
  {
    -- Manages rust-analyzer itself (don't also enable it via vim.lsp.enable).
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false, -- the plugin is already lazy-loaded by filetype
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            local map = function(keys, func, desc)
              vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "[C]argo: " .. desc })
            end
            -- Buffer-local group: the keys only exist in Rust buffers
            require("which-key").add { { "<leader>c", group = "[C]argo (Rust)", buffer = bufnr } }
            map("<leader>cr", function()
              vim.cmd.RustLsp "runnables"
            end, "[R]unnables")
            map("<leader>cd", function()
              vim.cmd.RustLsp "debuggables"
            end, "[D]ebuggables")
            map("<leader>ct", function()
              vim.cmd.RustLsp "testables"
            end, "[T]estables")
            map("<leader>cm", function()
              vim.cmd.RustLsp "expandMacro"
            end, "Expand [M]acro")
            map("<leader>ce", function()
              vim.cmd.RustLsp "explainError"
            end, "[E]xplain error")
            map("<leader>cD", function()
              vim.cmd.RustLsp "renderDiagnostic"
            end, "Render [D]iagnostic")
            map("<leader>cc", function()
              vim.cmd.RustLsp "openCargo"
            end, "Open [C]argo.toml")
            map("<leader>cp", function()
              vim.cmd.RustLsp "parentModule"
            end, "[P]arent module")
            map("<leader>cj", function()
              vim.cmd.RustLsp "joinLines"
            end, "[J]oin lines")
          end,
          default_settings = {
            ["rust-analyzer"] = {
              -- Run clippy on save instead of `cargo check`
              check = { command = "clippy" },
              lens = {
                enable = true,
                run = { enable = true },
                debug = { enable = true },
                implementations = { enable = true },
                references = {
                  adt = { enable = true },
                  enumVariant = { enable = true },
                  method = { enable = true },
                  trait = { enable = true },
                },
              },
            },
          },
        },
      }
    end,
  },
}
