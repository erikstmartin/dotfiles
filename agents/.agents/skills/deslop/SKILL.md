---
name: deslop
description: Use after AI-assisted code changes to remove low-value comments, defensive clutter, unnecessary casts, and other non-idiomatic artifacts without changing behavior.
---

# deslop

Scope to the recent diff unless told otherwise. Prefer deleting slop over reshaping working code.

Remove:
- comments that restate the code
- redundant null/undefined guards on already-validated or trusted paths
- broad try/catch wrappers that only log and rethrow
- `any`/type escapes added just to silence errors
- one-off helpers or indirection that add no real meaning
- duplicated "defensive" branches that only preserve impossible states

Rules:
- do not change behavior
- do not remove intentional validation at boundaries
- do not remove error handling that adds context, recovery, or cleanup
- do not refactor unrelated code
- if unsure whether a guard is real business logic, keep it
- match the surrounding style
- prefer smaller diffs over "cleaner" rewrites

Red flags:
- "clean up the whole file"
- replacing a real abstraction with a different abstraction
- deleting code you do not understand
- touching tests unless they contain obvious AI slop too

End with a brief summary of what you cleaned up.
