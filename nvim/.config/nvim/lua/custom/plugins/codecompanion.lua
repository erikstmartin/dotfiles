-- Slash commands that open a picker (CodeCompanion would otherwise pick
-- mini.pick, which is installed via mini.nvim but not used)
local slash_commands = {}
for _, name in ipairs { "buffer", "fetch", "file", "help", "image", "skills", "skills-group", "symbols" } do
  slash_commands[name] = { opts = { provider = "snacks" } }
end

local function prompt(alias)
  return function()
    require("codecompanion").prompt(alias)
  end
end

local function cli(text, opts)
  return function()
    require("codecompanion").cli(text, opts)
  end
end

--- Stop the agent CLI in the current window, or else the one on screen.
local function close_cli()
  if vim.bo.filetype == "codecompanion_cli" then
    return vim.cmd "bdelete!"
  end
  local visible = require("codecompanion.interactions.cli").get_visible()
  if visible then
    visible:close()
  else
    vim.notify("No agent CLI open here", vim.log.levels.INFO)
  end
end

local function toggle_cli()
  require("codecompanion").toggle_cli()
end

--- Start a new agent CLI, choosing which agent
local function new_cli()
  local agents = vim.tbl_keys(require("codecompanion.config").interactions.cli.agents)
  table.sort(agents)
  vim.ui.select(agents, { prompt = "Agent" }, function(agent)
    if agent then
      local instance = require("codecompanion.interactions.cli").create { agent = agent }
      if instance then
        instance.ui:open()
      end
    end
  end)
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" },
      opts = { latex = { enabled = false } },
    },
  },
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCLI",
    "CodeCompanionCmd",
    "CodeCompanionCodeReview",
  },
  -- Keys say where the request goes:
  --   <leader>a<key>   Agent: Claude Code (etc.) in a terminal; works on the repo
  --   <leader>ac<key>  Chat: CodeCompanion side panel (Copilot); answers, no edits
  --   <leader>ai<key>  Inline: Copilot edits this buffer; accept g2 / reject g3
  keys = {
    -- Agent
    { "<leader>aa", toggle_cli, desc = "[A]I: [A]gent (show/hide)" },
    { "<leader>an", new_cli, desc = "[A]I: [N]ew agent" },
    { "<leader>ak", cli(nil, { prompt = true }), mode = { "n", "v" }, desc = "[A]I: As[k] agent" },
    { "<leader>as", cli("#{this}", { focus = false }), mode = { "n", "v" }, desc = "[A]I: [S]end buffer/selection to agent" },
    {
      "<leader>ad",
      cli("#{diagnostics} Can you fix these?", { focus = false, submit = true }),
      desc = "[A]I: Send [D]iagnostics to agent",
    },
    {
      "<leader>at",
      cli("#{terminal} Sharing the output from the terminal. Can you fix it?", { focus = false, submit = true }),
      desc = "[A]I: Send [T]erminal output to agent",
    },
    { "<leader>ar", "<cmd>CodeCompanionCodeReview<CR>", desc = "[A]I: [R]eview agent changes" },
    { "<leader>ax", close_cli, desc = "[A]I: E[x]it agent" },

    -- Chat
    { "<leader>acc", "<cmd>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, desc = "[A]I [C]hat: Toggle [C]hat" },
    { "<leader>ace", prompt "explain", mode = "v", desc = "[A]I [C]hat: [E]xplain" },
    { "<leader>acf", prompt "fix", mode = "v", desc = "[A]I [C]hat: [F]ix" },
    { "<leader>acl", prompt "lsp", mode = "v", desc = "[A]I [C]hat: Explain [L]SP diagnostics" },
    { "<leader>acr", prompt "review", mode = "v", desc = "[A]I [C]hat: [R]eview" },
    { "<leader>aco", prompt "optimize", mode = "v", desc = "[A]I [C]hat: [O]ptimize" },
    { "<leader>acm", prompt "commit", desc = "[A]I [C]hat: Commit [M]essage (staged)" },

    -- Inline
    { "<leader>aii", ":CodeCompanion<CR>", mode = { "n", "v" }, desc = "[A]I [I]nline: [I]nline prompt" },
    { "<leader>aid", prompt "docs", mode = "v", desc = "[A]I [I]nline: [D]ocument" },
    { "<leader>ait", prompt "tests", mode = "v", desc = "[A]I [I]nline: Unit [T]ests (new buffer)" },

    -- Everything else (all prompts, open chats, ...)
    { "<leader>ap", "<cmd>CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "[A]I: Action [P]alette" },
  },
  opts = {
    interactions = {
      chat = {
        slash_commands = slash_commands,
        tools = {
          -- Read-only, limited to the working directory: no approval prompt
          -- (review/optimize load them). Files in cwd are sent to the model.
          ["read_file"] = { opts = { require_approval_before = false } },
          ["grep_search"] = { opts = { require_approval_before = false } },
          ["run_command"] = {
            opts = {
              -- Run without asking in Auto mode (gty). Prefix match; commands
              -- with ; & | < > ` or $( always ask. Tests run project code.
              safe_commands = {
                "git status", "ls", "pwd", -- defaults
                "git diff", "git log", "git show",
                "go build", "go vet", "go test",
                "cargo check", "cargo clippy", "cargo test",
                "dotnet build", "dotnet test",
                "pytest", "uv run pytest",
                "make test",
              },
            },
          },
          -- DuckDuckGo needs no API key (default Tavily does)
          ["web_search"] = { opts = { adapter = "duckduckgo" } },
        },
      },
      cli = {
        agent = "claude_code",
        agents = {
          claude_code = { cmd = "claude", args = {}, description = "Claude Code" },
          codex = { cmd = "codex", args = {}, description = "OpenAI Codex" },
          opencode = { cmd = "opencode", args = {}, description = "opencode" },
          copilot = { cmd = "copilot", args = {}, description = "GitHub Copilot CLI" },
          omp = { cmd = "omp", args = {}, description = "Oh My Pi" },
        },
      },
    },
    display = {
      action_palette = { provider = "snacks" },
    },
    prompt_library = {
      markdown = { dirs = { vim.fn.stdpath "config" .. "/prompts" } },
    },
  },
}
