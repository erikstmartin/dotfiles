local helpers = require("custom.codecompanion.helpers")

return {
  {
    role = "system",
    content = helpers.COPILOT_INSTRUCTIONS,
    opts = {
      visible = false,
    },
  },
  {
    role = "user",
    content = function(context)
      return string.format(
        [[
Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.
I want you to return raw code only (no codeblocks and no explanations). If you can't respond with code, respond with nothing.

```%s
%s
```
]],
        context.filetype,
        helpers.get_code(context)
      )
    end,
    opts = {
      contains_code = true,
    },
  },
}
