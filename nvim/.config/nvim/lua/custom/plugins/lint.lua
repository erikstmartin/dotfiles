return {

  { -- Linting
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"
      -- Covered by language servers instead: sh (bashls runs shellcheck), json
      -- (jsonls), ruby (ruby-lsp, or rubocop --lsp; see lsp/rubocop.lua), proto (buf lsp), python (ruff server)
      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
        markdown = { "markdownlint-cli2" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        terraform = { "tflint" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        yaml = { "yamllint" },
        gdscript = { "gdlint" },
        sql = { "sqlfluff" },
      }

      -- sqlfluff exits with "No dialect was specified" unless a config sets
      -- one, so default to ANSI when the project has no .sqlfluff
      local sqlfluff = lint.linters.sqlfluff
      lint.linters.sqlfluff = function()
        if vim.fs.root(0, ".sqlfluff") then
          return sqlfluff
        end
        return vim.tbl_extend("force", sqlfluff, { args = { "lint", "--format=json", "--dialect=ansi", "-" } })
      end

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Linux kernel trees: run the tree's own scripts/checkpatch.pl on C files,
      -- from the tree root (nvim-lint's default only looks in the cwd)
      local function kernel_root(bufnr)
        for dir in vim.fs.parents(vim.api.nvim_buf_get_name(bufnr)) do
          if vim.uv.fs_stat(dir .. "/scripts/checkpatch.pl") and vim.uv.fs_stat(dir .. "/Kconfig") then
            return dir
          end
        end
      end
      local checkpatch = lint.linters.checkpatch
      lint.linters.checkpatch = function()
        local root = kernel_root(0)
        return vim.tbl_extend("force", checkpatch, { cmd = root .. "/scripts/checkpatch.pl", cwd = root })
      end

      -- Only run linters that are installed: a machine may not have every mise
      -- module enabled, and nvim-lint reports an error on every run otherwise.
      -- Cached by resolved command, not linter name: e.g. eslint_d's cmd is
      -- the project's node_modules/.bin/eslint_d when there is one.
      local installed = {}
      local function is_installed(name)
        local linter = lint.linters[name]
        if type(linter) == "function" then
          linter = linter()
        end
        local cmd = linter and linter.cmd
        if type(cmd) == "function" then
          cmd = cmd()
        end
        if type(cmd) ~= "string" then
          return false
        end
        if installed[cmd] == nil then
          installed[cmd] = vim.fn.executable(cmd) == 1
        end
        return installed[cmd]
      end

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function(args)
          local names = vim.tbl_filter(is_installed, lint._resolve_linter_by_ft(vim.bo[args.buf].filetype))
          if #names > 0 then
            lint.try_lint(names)
          end
          if vim.bo[args.buf].filetype == "c" and kernel_root(args.buf) then
            lint.try_lint "checkpatch"
          end
        end,
      })
    end,
  },
}
