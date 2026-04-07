---
name: simplify
description: Use after code changes when the implementation works but should be easier to read, flatter, or more direct without changing behavior.
---

# simplify

Scope to the recent diff unless told otherwise. Prefer the smallest change that makes the code more obvious.

Prefer:
- deleting unnecessary abstraction
- flattening defensive nesting with guard clauses
- clearer names
- smaller focused branches/functions
- removing dead or duplicate code
- replacing clever flow with direct flow

Use this order:
1. delete dead code
2. inline pointless indirection
3. flatten control flow
4. rename for clarity
5. extract only if a block has a clear single purpose

Rules:
- do not change behavior
- do not optimize for fewer lines
- do not widen scope into a general refactor
- do not introduce new abstractions unless they clearly reduce complexity
- prefer obvious code over clever code
- preserve project conventions
- if a simplification would make tests or types less clear, skip it

Red flags:
- "while I'm here"
- renaming things across unrelated files
- converting one style preference into a repo-wide rewrite
- extracting helpers used only once without a strong naming win

End with a brief summary of what became simpler.
