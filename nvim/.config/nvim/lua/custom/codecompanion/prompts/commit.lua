local helpers = require("custom.codecompanion.helpers")

return {
  {
    role = "system",
    content = helpers.COPILOT_INSTRUCTIONS,
  },
  {
    role = "user",
    content = function()
      return string.format(
        [[Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.:
```diff
%s
```
]],
        vim.fn.system "git diff --no-ext-diff --staged"
      )
    end,
  },
}
