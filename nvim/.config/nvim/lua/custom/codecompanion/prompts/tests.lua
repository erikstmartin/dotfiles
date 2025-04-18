local helpers = require("custom.codecompanion.helpers")

return {
  {
    role = "system",
    content = helpers.COPILOT_UNIT,
  },
  {
    role = "user",
    content = function(context)
      return string.format(
        [[
Generate unit tests for the selected code. Ensure that the tests cover all edge cases and provide clear assertions for expected behavior.

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
