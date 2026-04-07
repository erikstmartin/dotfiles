return {
  "seblyng/roslyn.nvim",
  ft = { "cs" },
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    -- Let roslyn watch files itself instead of Neovim's watcher (roslyn.nvim's
    -- recommendation; Neovim's watcher is slow on large solutions)
    filewatching = "roslyn",
  },
  init = function()
    -- Client-side commands behind Roslyn's code lenses; roslyn.nvim doesn't
    -- implement them, so wire them to Neovim references and neotest
    local function goto_pos(uri, pos)
      -- Switch buffers only if needed: re-running :edit on the current file
      -- reloads it and cancels the LSP request that follows
      local bufnr = vim.uri_to_bufnr(uri)
      if bufnr ~= vim.api.nvim_get_current_buf() then
        vim.fn.bufload(bufnr)
        vim.bo[bufnr].buflisted = true
        vim.api.nvim_win_set_buf(0, bufnr)
      end
      vim.api.nvim_win_set_cursor(0, { pos.line + 1, pos.character })
    end
    vim.lsp.commands["roslyn.client.peekReferences"] = function(command)
      local uri, pos = unpack(command.arguments)
      goto_pos(uri, pos)
      vim.lsp.buf.references()
    end
    vim.lsp.commands["dotnet.test.run"] = function(command)
      local args = command.arguments[1]
      goto_pos(args.textDocument.uri, args.range.start)
      -- Nearest test: the method, or every test in the class on a class lens
      require("neotest").run.run { strategy = args.attachDebugger and "dap" or nil }
    end

    vim.lsp.config("roslyn", {
      settings = {
        -- Shown when inlay hints are toggled on (<leader>lh)
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
          dotnet_enable_inlay_hints_for_parameters = true,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
          dotnet_enable_tests_code_lens = true,
        },
      },
    })
  end,
}
