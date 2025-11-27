local helpers = require("custom.codecompanion.helpers")

return {
  {
    role = "system",
    content = helpers.COPILOT_EXPLAIN,
    opts = {
      visible = false,
    },
  },
  {
    role = "user",
    content = function(context)
      return string.format(
        [[
Write an explanation for the selected code as paragraphs of text.:

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
