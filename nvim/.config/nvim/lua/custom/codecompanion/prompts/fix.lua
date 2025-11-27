local helpers = require("custom.codecompanion.helpers")

return {
  {
    role = "system",
    content = helpers.COPILOT_FIX,
    opts = {
      visible = false,
    },
  },
  {
    role = "user",
    content = function(context)
      return string.format(
        [[
There is a problem in this code. Identify the issues and rewrite the code with fixes.
I want you to return raw code only (no codeblocks and no explanations). If you can't respond with code, respond with nothing.

```%s
%s
```

%s
]],
        context.filetype,
        helpers.get_code(context),
        helpers.get_diagnostics(context)
      )
    end,
    opts = {
      contains_code = true,
    },
  },
}
