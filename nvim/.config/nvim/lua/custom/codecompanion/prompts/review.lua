local helpers = require("custom.codecompanion.helpers")

return {
  {
    role = "system",
    content = helpers.COPILOT_REVIEW,
    opts = {
      visible = false,
    },
  },
  {
    role = "user",
    content = function(context)
      return string.format(
        [[
Review the selected code.:

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
