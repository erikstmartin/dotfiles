local ruby = require "custom.ruby"

--- ruby-lsp's test code lenses pass [path, name, command, location], where
--- command is a shell command (bundle exec ruby -Itest … / rspec …), run
--- with 'shell' so it works on Windows too
local function shell_cmd(command)
  return vim.list_extend({ vim.o.shell, unpack(vim.split(vim.o.shellcmdflag, " ", { trimempty = true })) }, { command })
end

local function run_test(command, ctx)
  local root = ruby.root(ctx.bufnr)
  Snacks.terminal(shell_cmd(command.arguments[3]), { cwd = root, interactive = false })
end

return {
  cmd = { "ruby-lsp" },
  filetypes = { "ruby", "eruby" },
  root_markers = { "Gemfile", ".git" },
  init_options = {
    enabledFeatures = {
      codeLens = true,
    },
  },
  -- Client-side commands behind the ▶ Run / Run In Terminal / Debug lenses
  commands = {
    ["rubyLsp.runTest"] = run_test,
    ["rubyLsp.runTestInTerminal"] = run_test,
    ["rubyLsp.debugTest"] = function(command, ctx)
      local args = command.arguments
      local cmd = shell_cmd(args[3])
      require("dap").run {
        type = "ruby",
        request = "launch",
        name = "Debug " .. args[2],
        command = cmd[1],
        args = vim.list_slice(cmd, 2),
        cwd = ruby.root(ctx.bufnr),
      }
    end,
  },
}
