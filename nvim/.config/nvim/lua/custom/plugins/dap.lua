--- Files under `root` matching `pred`, skipping VCS/dependency directories
local function find_files(root, pred, depth)
  local skip = { [".git"] = true, node_modules = true, [".venv"] = true, obj = true, CMakeFiles = true }
  local found = {}
  for name, type in vim.fs.dir(root, {
    depth = depth or 8,
    skip = function(dir)
      return not skip[vim.fs.basename(dir)]
    end,
  }) do
    local path = vim.fs.joinpath(root, name)
    if type == "file" and pred(path) then
      table.insert(found, path)
    end
  end
  table.sort(found)
  return found
end

--- Run a command without blocking the UI, from inside a DAP config function
--- (those run in a coroutine). Returns the vim.system result.
local function run_async(cmd, cwd)
  local co = coroutine.running()
  vim.system(cmd, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      coroutine.resume(co, result)
    end)
  end)
  return coroutine.yield()
end

--- C/C++: pick an executable, from build/ dirs when there are any, else from the project
local function pick_program()
  local dap = require "dap"
  local cwd = vim.fn.getcwd()
  -- Top-level build dirs only: searching downward through e.g. a kernel tree is slow
  local roots = {}
  for name, type in vim.fs.dir(cwd) do
    if type == "directory" and (name == "build" or name == "out" or name:match "^cmake%-build") then
      table.insert(roots, vim.fs.joinpath(cwd, name))
    end
  end
  local depth = #roots > 0 and 8 or 3
  roots = #roots > 0 and roots or { cwd }
  local is_win = vim.fn.has "win32" == 1
  local programs = {}
  for _, root in ipairs(roots) do
    vim.list_extend(
      programs,
      find_files(root, function(path)
        if is_win then
          return path:match "%.exe$" ~= nil
        end
        -- Executable bit, and no extension (or a.out): skips scripts and .so files
        local stat = vim.uv.fs_stat(path)
        return stat ~= nil
          and bit.band(stat.mode, tonumber("100", 8)) ~= 0
          and (not vim.fs.basename(path):match "%." or path:match "%.out$" ~= nil)
      end, depth)
    )
  end
  if #programs == 0 then
    local path = vim.fn.input("Path to executable: ", cwd .. "/", "file")
    return path ~= "" and path or dap.ABORT
  end
  return require("dap.ui").pick_if_many(programs, "Program", function(path)
    return vim.fs.relpath(cwd, path) or path
  end) or dap.ABORT
end

local function ask_args()
  return require("dap.utils").splitstr(vim.fn.input "Arguments: ")
end

--- C#: `dotnet build`, then pick a project's own Debug output (not its
--- dependency DLLs). Projects can live anywhere in the solution.
local function build_and_pick_dll()
  local dap = require "dap"
  local cwd = vim.fn.getcwd()
  vim.notify("dotnet build…", vim.log.levels.INFO)
  local result = run_async({ "dotnet", "build", "-c", "Debug" }, cwd)
  if result.code ~= 0 then
    local out = vim.split(result.stdout or "", "\n", { trimempty = true })
    vim.notify("dotnet build failed:\n" .. table.concat(vim.list_slice(out, math.max(1, #out - 15)), "\n"), vim.log.levels.ERROR)
    return dap.ABORT
  end
  local dlls = {}
  for _, csproj in ipairs(find_files(cwd, function(path)
    return path:match "%.csproj$" ~= nil
  end)) do
    local dir, name = vim.fs.dirname(csproj), vim.fn.fnamemodify(csproj, ":t:r")
    vim.list_extend(dlls, vim.fn.glob(dir .. "/bin/Debug/*/" .. name .. ".dll", false, true))
  end
  if #dlls == 0 then
    vim.notify("No bin/Debug/*/<Project>.dll found after building", vim.log.levels.ERROR)
    return dap.ABORT
  end
  return require("dap.ui").pick_if_many(dlls, "Project", function(path)
    return vim.fs.relpath(cwd, path) or path
  end) or dap.ABORT
end

local function dap_fn(name, ...)
  local args = { ... }
  return function()
    require("dap")[name](unpack(args))
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      -- F-keys (F1-F3 need Fn on a Mac keyboard)
      { "<F5>", dap_fn "continue", desc = "Debug: Start/Continue" },
      { "<S-F5>", dap_fn "terminate", desc = "Debug: Stop" },
      { "<C-F5>", dap_fn "restart", desc = "Debug: Restart" },
      { "<F1>", dap_fn "step_into", desc = "Debug: Step Into" },
      { "<F2>", dap_fn "step_over", desc = "Debug: Step Over" },
      { "<F3>", dap_fn "step_out", desc = "Debug: Step Out" },
      { "<F9>", dap_fn "toggle_breakpoint", desc = "Debug: Toggle Breakpoint" },
      {
        "<S-F9>",
        function()
          require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
        end,
        desc = "Debug: Conditional Breakpoint",
      },
      {
        "<F7>",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: Toggle UI",
      },

      -- <leader>D: everything, discoverable in which-key
      { "<leader>Dc", dap_fn "continue", desc = "[D]ebug: [C]ontinue / start" },
      { "<leader>DC", dap_fn "run_to_cursor", desc = "[D]ebug: Run to [C]ursor" },
      { "<leader>Db", dap_fn "toggle_breakpoint", desc = "[D]ebug: Toggle [B]reakpoint" },
      {
        "<leader>DB",
        function()
          require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
        end,
        desc = "[D]ebug: Conditional [B]reakpoint",
      },
      {
        "<leader>Dp",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input "Log message ({expr} interpolates): ")
        end,
        desc = "[D]ebug: Log [P]oint",
      },
      { "<leader>Dx", dap_fn "clear_breakpoints", desc = "[D]ebug: Clear breakpoints ([x])" },
      { "<leader>DE", dap_fn "set_exception_breakpoints", desc = "[D]ebug: Break on [E]xceptions" },
      {
        "<leader>Dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "[D]ebug: [R]EPL",
      },
      {
        "<leader>De",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "x" },
        desc = "[D]ebug: [E]valuate expression",
      },
      { "<leader>Dk", dap_fn "up", desc = "[D]ebug: Up the stac[k]" },
      { "<leader>Dj", dap_fn "down", desc = "[D]ebug: Down the stack ([j])" },
      { "<leader>Dl", dap_fn "run_last", desc = "[D]ebug: Run [L]ast" },
      { "<leader>Dt", dap_fn "terminate", desc = "[D]ebug: [T]erminate" },
      {
        "<leader>Du",
        function()
          require("dapui").toggle()
        end,
        desc = "[D]ebug: Toggle [U]I",
      },
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      -- Breakpoint signs (colours come from catppuccin's Dap* highlight groups)
      vim.api.nvim_set_hl(0, "DapStoppedLine", { link = "Visual", default = true })
      for name, sign in pairs {
        DapBreakpoint = { text = "" },
        DapBreakpointCondition = { text = "" },
        DapLogPoint = { text = "" },
        DapBreakpointRejected = { text = "" },
        DapStopped = { text = "", linehl = "DapStoppedLine" },
      } do
        vim.fn.sign_define(name, { text = sign.text, texthl = name, linehl = sign.linehl, numhl = "" })
      end

      require("nvim-dap-virtual-text").setup()

      -- codelldb adapter (C/C++) — installed via mise; rustaceanvim finds the same binary on PATH for Rust
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- C/C++ debug configurations. "integrated" runs the program in a
      -- terminal so it can read from stdin.
      local c_configs = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = pick_program,
          cwd = "${workspaceFolder}",
          terminal = "integrated",
        },
        {
          name = "Launch with arguments",
          type = "codelldb",
          request = "launch",
          program = pick_program,
          args = ask_args,
          cwd = "${workspaceFolder}",
          terminal = "integrated",
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      -- Linux: gdb's built-in DAP mode (gdb 14+), alongside codelldb
      if vim.fn.has "linux" == 1 and vim.fn.executable "gdb" == 1 then
        dap.adapters.gdb = {
          type = "executable",
          command = "gdb",
          args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
        }
        vim.list_extend(c_configs, {
          {
            name = "Launch (gdb)",
            type = "gdb",
            request = "launch",
            program = pick_program,
            args = ask_args,
            cwd = "${workspaceFolder}",
            stopAtBeginningOfMainSubprogram = false,
          },
          {
            name = "Attach to process (gdb)",
            type = "gdb",
            request = "attach",
            pid = require("dap.utils").pick_process,
          },
        })
      end

      dap.configurations.c = c_configs
      dap.configurations.cpp = c_configs

      -- C#/.NET: netcoredbg (installed via mise). "netcoredbg" is the adapter
      -- name neotest-vstest uses when debugging tests.
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }
      dap.adapters.netcoredbg = dap.adapters.coreclr
      dap.configurations.cs = {
        {
          name = "Build and launch",
          type = "coreclr",
          request = "launch",
          program = build_and_pick_dll,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach to process",
          type = "coreclr",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      -- Ruby: `command` + `args` (the neotest-rspec/minitest shape) are wrapped
      -- in rdbg unless already rdbg; without a command, attach to `port`. The
      -- test adapters send "attach" + `-e cont`, which lets a fast test finish
      -- before breakpoints are set, so both become a paused "launch".
      local ruby = require "custom.ruby"
      dap.adapters.ruby = function(callback, config)
        local server = { type = "server", host = "127.0.0.1", options = { source_filetype = "ruby" } }
        if not config.command then
          return callback(vim.tbl_extend("force", server, { port = config.port }))
        end
        local cmd = { config.command }
        local args = vim.deepcopy(config.args or {})
        for i = 1, #args do
          if not (args[i] == "-e" and args[i + 1] == "cont") and not (args[i] == "cont" and args[i - 1] == "-e") then
            table.insert(cmd, args[i])
          end
        end
        local port = config.port
        if config.command ~= "rdbg" then
          local rdbg = ruby.bundles(config.cwd, "debug") and { "bundle", "exec", "rdbg" } or { "rdbg" }
          cmd = vim.list_extend(vim.list_extend(rdbg, { "--open", "--port", "${port}", "--command", "--" }), cmd)
          port = "${port}"
        end
        callback(vim.tbl_extend("force", server, {
          port = port,
          executable = { command = cmd[1], args = vim.list_slice(cmd, 2), cwd = config.cwd },
          enrich_config = function(cfg, on_config)
            on_config(vim.tbl_extend("force", cfg, { request = "launch" }))
          end,
        }))
      end

      --- Launch config running `build(file)` on the current file, under
      --- `bundle exec` in a bundled project
      local function ruby_launch(name, build)
        local cmd = function()
          return ruby.exec(ruby.root(0), build(vim.api.nvim_buf_get_name(0)))
        end
        return {
          name = name,
          type = "ruby",
          request = "launch",
          command = function()
            return cmd()[1]
          end,
          args = function()
            return vim.list_slice(cmd(), 2)
          end,
          cwd = function()
            return ruby.root(0)
          end,
        }
      end
      dap.configurations.ruby = {
        ruby_launch("Debug current file", function(file)
          return { "ruby", file }
        end),
        ruby_launch("Debug current test file (RSpec / Minitest)", function(file)
          return file:match "_spec%.rb$" and { "rspec", file } or { "ruby", "-Itest", file }
        end),
        {
          name = "Attach to rdbg (rdbg --open --port N)",
          type = "ruby",
          request = "attach",
          port = function()
            return tonumber(vim.fn.input "rdbg port: ")
          end,
        },
      }

      -- Rust debugging is handled by rustaceanvim (:RustLsp debuggables / <leader>cd)

      -- Go (via nvim-dap-go — auto-configures delve)
      require("dap-go").setup {
        delve = {
          -- On Windows delve must be run attached or it crashes.
          detached = vim.fn.has "win32" == 0,
        },
      }

      -- Python: debugpy run through uv in the project's environment, so
      -- nothing needs installing globally
      require("dap-python").setup "uv"

      dapui.setup {
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      }

      -- Open the UI as a session starts (so startup errors are visible),
      -- close it when the program ends
      dap.listeners.before.attach.dapui_config = dapui.open
      dap.listeners.before.launch.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close
    end,
  },
}
