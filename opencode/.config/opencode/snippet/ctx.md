---
aliases: context
description: "Inject current project context"
---
Project: !`basename $(pwd)`
Branch: !`git branch --show-current`
Recent changes: !`git diff --stat HEAD~3 2>/dev/null | tail -5`
