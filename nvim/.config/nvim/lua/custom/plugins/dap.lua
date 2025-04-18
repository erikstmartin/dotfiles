return {
  {
    "mfussenegger/nvim-dap",
    ft = { "go", "c", "cpp", "rust" },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F1>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F2>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F3>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      {
        "<S-F9>",
        function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc = "Debug: Conditional Breakpoint",
      },
      { "<F7>", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Virtual text (inline variable values)
      require("nvim-dap-virtual-text").setup()

      -- codelldb adapter (C/C++/Rust) — installed via mise
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- C/C++ debug configurations
      local codelldb_config = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      dap.configurations.c = codelldb_config
      dap.configurations.cpp = codelldb_config

      -- Rust debug configurations (cargo build output)
      dap.configurations.rust = {
        {
          name = "Launch (cargo build)",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Try to find the binary from cargo metadata
            local handle = io.popen("cargo metadata --format-version 1 --no-deps 2>/dev/null")
            if handle then
              local result = handle:read("*a")
              handle:close()
              local ok, metadata = pcall(vim.json.decode, result)
              if ok and metadata.target_directory then
                local name = metadata.packages and metadata.packages[1] and metadata.packages[1].name
                if name then
                  local bin = metadata.target_directory .. "/debug/" .. name
                  if vim.fn.filereadable(bin) == 1 then
                    return bin
                  end
                end
              end
            end
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      -- Go (via nvim-dap-go — auto-configures delve)
      require("dap-go").setup({
        delve = {
          -- On Windows delve must be run attached or it crashes.
          detached = vim.fn.has("win32") == 0,
        },
      })

      -- DAP UI setup
      dapui.setup({
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
      })

      -- Auto-open/close DAP UI on debug session start/end
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close
    end,
  },
}
