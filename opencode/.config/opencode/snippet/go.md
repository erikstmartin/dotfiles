---
aliases: golang
description: "Go idioms and conventions"
---
Follow Go idioms. Return errors, don't panic. Wrap errors with `fmt.Errorf("context: %w", err)`. Use early returns to reduce nesting. Prefer table-driven tests. No `interface{}` — use `any`. Use `context.Context` as first parameter where appropriate. Respect `golangci-lint` conventions.
