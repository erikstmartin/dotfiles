return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- install() is a no-op for present parsers. Building needs the tree-sitter
      -- CLI; without it, skip rather than error on every launch.
      if vim.fn.executable "tree-sitter" == 1 then
        local parsers = {
          "asm", "bash", "bicep", "c", "c_sharp", "cmake", "comment", "cpp", "css", "cuda", "devicetree",
          "diff", "dockerfile", "doxygen", "embedded_template", "fish", "gdscript", "git_config", "git_rebase",
          "gitattributes", "gitignore", "go", "gomod", "gosum", "gotmpl", "gowork",
          "hcl", "helm", "html", "http", "javascript", "jsdoc", "json", "just", "kconfig",
          "linkerscript", "lua", "luadoc", "make", "markdown", "markdown_inline", "ninja", "printf",
          "proto", "python", "query", "regex", "ruby", "rust", "scss", "sql", "ssh_config",
          "terraform", "toml", "tsv", "tsx", "typescript", "typespec", "vim", "vimdoc", "xml",
          "yaml",
        }
        if vim.fn.has "win32" == 0 then
          table.insert(parsers, "gitcommit")
        end
        require("nvim-treesitter").install(parsers)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function(args)
          -- Falls back to the filetype's regex syntax/indent when no parser exists
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      require("nvim-treesitter-textobjects").setup({
        move = { set_jumps = true },
      })

      local move = require("nvim-treesitter-textobjects.move")
      local select = require("nvim-treesitter-textobjects.select")
      local swap = require("nvim-treesitter-textobjects.swap")

      vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end, { desc = "around function" })
      vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end, { desc = "inside function" })
      vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end, { desc = "around class" })
      vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end, { desc = "inside class" })
      vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer", "textobjects") end, { desc = "around argument" })
      vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner", "textobjects") end, { desc = "inside argument" })
      vim.keymap.set({ "x", "o" }, "ai", function() select.select_textobject("@conditional.outer", "textobjects") end, { desc = "around conditional" })
      vim.keymap.set({ "x", "o" }, "ii", function() select.select_textobject("@conditional.inner", "textobjects") end, { desc = "inside conditional" })
      vim.keymap.set({ "x", "o" }, "al", function() select.select_textobject("@loop.outer", "textobjects") end, { desc = "around loop" })
      vim.keymap.set({ "x", "o" }, "il", function() select.select_textobject("@loop.inner", "textobjects") end, { desc = "inside loop" })
      -- ab/ib: treesitter blocks, intentionally replacing the built-in "( )" block
      vim.keymap.set({ "x", "o" }, "ab", function() select.select_textobject("@block.outer", "textobjects") end, { desc = "around block" })
      vim.keymap.set({ "x", "o" }, "ib", function() select.select_textobject("@block.inner", "textobjects") end, { desc = "inside block" })

      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function start" })
      -- ]c/[c fall back to Vim's next/prev change in diff mode (diffview, merges)
      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        if vim.wo.diff then return vim.cmd.normal { vim.v.count1 .. "]c", bang = true } end
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start / next change (diff)" })
      -- ]a/[a/]A/[A intentionally replace the built-in arglist maps (:next/:prev/:last/:first)
      vim.keymap.set({ "n", "x", "o" }, "]a", function() move.goto_next_start("@parameter.outer", "textobjects") end, { desc = "Next argument start" })
      vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end, { desc = "Next function end" })
      vim.keymap.set({ "n", "x", "o" }, "]C", function() move.goto_next_end("@class.outer", "textobjects") end, { desc = "Next class end" })
      vim.keymap.set({ "n", "x", "o" }, "]A", function() move.goto_next_end("@parameter.outer", "textobjects") end, { desc = "Next argument end" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Previous function start" })
      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        if vim.wo.diff then return vim.cmd.normal { vim.v.count1 .. "[c", bang = true } end
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Previous class start / previous change (diff)" })
      vim.keymap.set({ "n", "x", "o" }, "[a", function() move.goto_previous_start("@parameter.outer", "textobjects") end, { desc = "Previous argument start" })
      vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end, { desc = "Previous function end" })
      vim.keymap.set({ "n", "x", "o" }, "[C", function() move.goto_previous_end("@class.outer", "textobjects") end, { desc = "Previous class end" })
      vim.keymap.set({ "n", "x", "o" }, "[A", function() move.goto_previous_end("@parameter.outer", "textobjects") end, { desc = "Previous argument end" })

      -- Under <leader>l with the LSP keys (Treesitter-based, so no server needed)
      vim.keymap.set("n", "<leader>l>", function() swap.swap_next("@parameter.inner") end, { desc = "[L]SP: Swap argument with next ([>])" })
      vim.keymap.set("n", "<leader>l<", function() swap.swap_previous("@parameter.inner") end, { desc = "[L]SP: Swap argument with previous ([<])" })

      -- ; and , are left to flash.nvim, which repeats f/F/t/T
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      enable = true,
      max_lines = 3,
      multiline_threshold = 1,
      -- Diffview sets ts_context_disable on its diff buffers so context
      -- lines don't throw off scrollbind alignment between the two panes.
      on_attach = function(buf)
        local excluded = { snacks_dashboard = true, lazy = true, help = true }
        return not vim.b[buf].ts_context_disable and not excluded[vim.bo[buf].filetype]
      end,
    },
    keys = {
      {
        "[x",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Jump to context (upward)",
      },
    },
  },
}
