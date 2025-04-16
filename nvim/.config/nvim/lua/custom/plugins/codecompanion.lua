local fmt = string.format

local COPILOT_BASE = string.format(
  [[
When asked for your name, you must respond with "GitHub Copilot".
Follow the user's requirements carefully & to the letter.
Follow Microsoft content policies.
Avoid content that violates copyrights.
If you are asked to generate content that is harmful, hateful, racist, sexist, lewd, violent, or completely irrelevant to software engineering, only respond with "Sorry, I can't assist with that."
Keep your answers short and impersonal.
The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
The user is working on a %s machine. Please respond with system specific commands if applicable.
You will receive code snippets that include line number prefixes - use these to maintain correct position references but remove them when generating output.

When presenting code changes:

1. For each change, first provide a header outside code blocks with format:
   [file:<file_name>](<file_path>) line:<start_line>-<end_line>

2. Then wrap the actual code in triple backticks with the appropriate language identifier.

3. Keep changes minimal and focused to produce short diffs.

4. Include complete replacement code for the specified line range with:
   - Proper indentation matching the source
   - All necessary lines (no eliding with comments)
   - No line number prefixes in the code

5. Address any diagnostics issues when fixing code.

6. If multiple changes are needed, present them as separate blocks with their own headers.
]],
  vim.uv.os_uname().sysname
)

local COPILOT_INSTRUCTIONS = [[
You are a code-focused AI programming assistant that specializes in practical software engineering solutions.
]] .. COPILOT_BASE

local COPILOT_EXPLAIN = [[
You are a programming instructor focused on clear, practical explanations.
]] .. COPILOT_BASE .. [[

When explaining code:
- Provide concise high-level overview first
- Highlight non-obvious implementation details
- Identify patterns and programming principles
- Address any existing diagnostics or warnings
- Focus on complex parts rather than basic syntax
- Use short paragraphs with clear structure
- Mention performance considerations where relevant
]]

local COPILOT_REVIEW = [[
You are a code reviewer that specializes in practical software engineering solutions focused on improving code quality and maintainability.
]] .. COPILOT_BASE .. [[

Format each issue you find precisely as:
line=<line_number>: <issue_description>
OR
line=<start_line>-<end_line>: <issue_description>

Check for:
- Unclear or non-conventional naming
- Idiomatic usage of the language and best practices
- Comment quality (missing or unnecessary)
- Complex expressions needing simplification
- Deep nesting or complex control flow
- Inconsistent style or formatting
- Code duplication or redundancy
- Potential performance issues
- Error handling gaps
- Security concerns
- Breaking of SOLID principles

Multiple issues on one line should be separated by semicolons.
End with: "**`To clear buffer highlights, please ask a different question.`**"

If no issues found, confirm the code is well-written and explain why.
]]

local COPILOT_FIX = [[
You are a code reviewer focused on identifying and fixing errors.
]] .. COPILOT_BASE .. [[
When asked to fix code, follow these steps:

1. **Identify the Issues**: Carefully read the provided code and identify any potential issues or improvements.
2. **Plan the Fix**: Describe the plan for fixing the code in pseudocode, detailing each step.
3. **Implement the Fix**: Write the corrected code in a single code block.
4. **Explain the Fix**: Briefly explain what changes were made and why.

Ensure the fixed code:

- Includes necessary imports.
- Handles potential errors.
- Follows best practices for readability and maintainability.
- Is formatted correctly.

Use Markdown formatting and include the programming language name at the start of the code block.
]]

local COPILOT_UNIT = [[
You are a software engineer focused on writing unit tests.
]] .. COPILOT_BASE .. [[
When generating unit tests, follow these steps:

1. Identify the programming language.
2. Identify the purpose of the function or module to be tested.
3. List the edge cases and typical use cases that should be covered in the tests and share the plan with the user.
4. Generate unit tests using an appropriate testing framework for the identified programming language.
5. Ensure the tests cover:
      - Normal cases
      - Edge cases
      - Error handling (if applicable)
6. Provide the generated unit tests in a clear and organized manner without additional explanations or chat.
]]

-- Returns the code to be sent to the LLM
-- If the mode is "n", it will get all lines in the buffer
-- If the mode is "v", it will get the selected lines
function get_code(context)
  local start_line = context.start_line
  local end_line = context.end_line

  if context.mode == "n" then
    lines = vim.api.nvim_buf_get_lines(context.bufnr, 0, -1, false)
    start_line = 1
    end_line = #lines
  end
  return require("codecompanion.helpers.actions").get_code(start_line, end_line)
end

function get_diagnostics(context)
  local diagnostics =
    require("codecompanion.helpers.actions").get_diagnostics(context.start_line, context.end_line, context.bufnr)

  if #diagnostics == 0 then
    return ""
  end

  local concatenated_diagnostics = ""
  for i, diagnostic in ipairs(diagnostics) do
    concatenated_diagnostics = concatenated_diagnostics
      .. i
      .. ". Issue "
      .. i
      .. "\n  - Location: Line "
      .. diagnostic.line_number
      .. "\n  - Buffer: "
      .. context.bufnr
      .. "\n  - Severity: "
      .. diagnostic.severity
      .. "\n  - Message: "
      .. diagnostic.message
      .. "\n"
  end

  return fmt(
    [[
Diagnostics found in the selected code:
%s
    ]],
    concatenated_diagnostics
  )
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat<CR>", desc = "[A]I: [C]hat" },
    { "<leader>ap", "<cmd>CodeCompanion<CR>", desc = "[A]I: [P]rompt" },
    { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "[A]I: [A]action" },
    -- Prompts
    { "<leader>ae", "<cmd>CodeCompanion /explain<CR>", desc = "[A]I: [E]xplain" },
    { "<leader>ae", "<cmd>CodeCompanion /explain<CR>", desc = "[A]I: [E]xplain", mode = "v" },
    { "<leader>ar", "<cmd>CodeCompanion /review<CR>", desc = "[A]I: [R]eview" },
    { "<leader>ar", "<cmd>CodeCompanion /review<CR>", desc = "[A]I: [R]eview", mode = "v" },
    { "<leader>af", "<cmd>CodeCompanion /fix_explain<CR>", desc = "[A]I: [F]ix Explain" },
    { "<leader>af", "<cmd>CodeCompanion /fix_explain<CR>", desc = "[A]I: [F]ix Explain", mode = "v" },
    { "<leader>aF", "<cmd>CodeCompanion /fix<CR>", desc = "[A]I: [F]ix" },
    { "<leader>aF", "<cmd>CodeCompanion /fix<CR>", desc = "[A]I: [F]ix", mode = "v" },
    { "<leader>ao", "<cmd>CodeCompanion /optimize_explain<CR>", desc = "[A]I: [O]ptimize Explain" },
    {
      "<leader>ao",
      "<cmd>CodeCompanion /optimize_explain<CR>",
      desc = "[A]I: [O]ptimize Explain (CodeCompanion)",
      mode = "v",
    },
    { "<leader>aO", "<cmd>CodeCompanion /optimize<CR>", desc = "[A]I: [O]ptimize" },
    { "<leader>aO", "<cmd>CodeCompanion /optimize<CR>", desc = "[A]I: [O]ptimize", mode = "v" },
    { "<leader>ad", "<cmd>CodeCompanion /docs<CR>", desc = "[A]I: [D]ocs" },
    { "<leader>ad", "<cmd>CodeCompanion /docs<CR>", desc = "[A]I: [D]ocs", mode = "v" },
    { "<leader>at", "<cmd>CodeCompanion /test<CR>", desc = "[A]I: [T]ests" },
    { "<leader>at", "<cmd>CodeCompanion /test<CR>", desc = "[A]I: [T]ests", mode = "v" },
    { "<leader>aC", "<cmd>CodeCompanion /commit<CR>", desc = "[A]I: [C]ommit" },
  },

  opts = {
    strategies = {
      -- Change the default chat adapter
      chat = { adapter = "copilot" },
      inline = {
        adapter = "copilot",
        keymaps = {
          accept_change = {
            modes = { n = "<C-y>" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "<C-n>" },
            description = "Reject the suggested change",
          },
        },
      },
      -- Set debug logging
      log_level = "TRACE", -- TRACE|DEBUG|ERROR|INFO
      language = "English",
      send_code = true,
    },
    display = {
      action_palette = {
        width = 95,
        height = 10,
        prompt = "Prompt ", -- Prompt used for interactive LLM calls
        -- provider = "default", -- Can be "default", "telescope", or "mini_pick". If not specified, the plugin will autodetect installed providers.
        opts = {
          show_default_actions = false, -- Show the default actions in the action palette?
          show_default_prompt_library = true, -- Show the default prompt library in the action palette?
        },
      },
    },
    prompt_library = {
      ["Copilot Explain"] = {
        strategy = "chat",
        description = "Copilot Explain",
        opts = {
          short_name = "explain",
          is_slash_cmd = false,
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_EXPLAIN,
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            content = function(context)
              return fmt(
                [[
Write an explanation for the selected code as paragraphs of text.:

```%s
%s
```
]],
                context.filetype,
                get_code(context)
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Copilot Review"] = {
        strategy = "chat",
        description = "Copilot Review",
        opts = {
          short_name = "review",
          is_slash_cmd = false,
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_REVIEW,
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            content = function(context)
              return fmt(
                [[
Review the selected code.:

```%s
%s
```
]],
                context.filetype,
                get_code(context)
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Copilot Fix (inline)"] = {
        strategy = "inline",
        description = "Copilot Fix (inline)",
        opts = {
          short_name = "fix",
          is_slash_cmd = false,
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_FIX,
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            content = function(context)
              return fmt(
                [[
There is a problem in this code. Identify the issues and rewrite the code with fixes.
I want you to return raw code only (no codeblocks and no explanations). If you can't respond with code, respond with nothing.

```%s
%s
```

%s
]],
                context.filetype,
                get_code(context),
                get_diagnostics(context)
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Copilot Fix (explain)"] = {
        strategy = "chat",
        description = "Copilot Fix (explain)",
        opts = {
          short_name = "fix_explain",
          is_slash_cmd = false,
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_FIX,
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            content = function(context)
              return fmt(
                [[
There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.:

```%s
%s
```

%s
]],
                context.filetype,
                get_code(context),
                get_diagnostics(context)
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Copilot Optimize (inline)"] = {
        strategy = "inline",
        description = "Copilot Optimize (inline)",
        opts = {
          short_name = "optimize",
          is_slash_cmd = false,
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_INSTRUCTIONS,
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            content = function(context)
              return fmt(
                [[
Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.
I want you to return raw code only (no codeblocks and no explanations). If you can't respond with code, respond with nothing.

```%s
%s
```
]],
                context.filetype,
                get_code(context)
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Copilot Optimize (explain)"] = {
        strategy = "chat",
        description = "Copilot Optimize (explain)",
        opts = {
          short_name = "optimize_explain",
          is_slash_cmd = false,
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_INSTRUCTIONS,
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            content = function(context)
              return fmt(
                [[
Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.:

```%s
%s
```
]],
                context.filetype,
                get_code(context)
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Copilot Docs (inline)"] = {
        strategy = "inline",
        description = "Copilot Docs",
        opts = {
          short_name = "docs",
          is_slash_cmd = false,
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_INSTRUCTIONS,
            opts = {
              visible = false,
            },
          },
          {
            role = "user",
            -- content = "Generate documentation for the selected code. Include function descriptions, parameters, return values, and usage examples.",
            content = function(context)
              return fmt(
                [[
Please add documentation comments to the selected code.:

```%s
%s
```
]],
                context.filetype,
                get_code(context)
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Copilot Tests"] = {
        strategy = "chat",
        description = "Copilot Tests",
        opts = {
          short_name = "test",
          is_slash_cmd = false,
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_UNIT,
          },
          {
            role = "user",
            content = function(context)
              return fmt(
                [[
Generate unit tests for the selected code. Ensure that the tests cover all edge cases and provide clear assertions for expected behavior.

```%s
%s
```
]],
                context.filetype,
                get_code(context)
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Copilot Commit"] = {
        strategy = "chat",
        description = "Copilot Commmit",
        opts = {
          short_name = "commit",
          auto_submit = true,
          stop_context_insertion = true,
          user_prompt = true,
        },
        prompts = {
          {
            role = "system",
            content = COPILOT_INSTRUCTIONS,
          },
          {
            role = "user",
            content = function()
              return fmt(
                [[Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.:
```diff
%s
```
]],
                vim.fn.system "git diff --no-ext-diff --staged"
              )
            end,
          },
        },
      },
    },
  },
}
