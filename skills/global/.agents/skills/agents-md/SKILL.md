---
name: agents-md
description: Use when asked to write or review AGENTS.md/CLAUDE.md/LLMs.md context files.
---

# AGENTS.md Guidance (Minimal)

## Overview

Keep AGENTS.md short and only include non-discoverable constraints. Extra requirements reduce agent performance.

## When to Use

- Create, review, or trim AGENTS.md / CLAUDE.md / LLMs.md
- Decide whether a requirement belongs in a context file

## What to Include (Only)

- Non-obvious test/lint/build commands
- Required tooling or environment constraints the agent cannot infer
- Hard safety rules (e.g., no commit/push, ask before destructive commands)

## What to Exclude

- Repo structure overviews
- Style guides or “nice to know” conventions
- Generic best practices or “always run X” rules
- Anything already in README/docs
- Auto-generated context files (/init outputs)

## Value Test

Include a line only if:
1) It changes agent behavior on this repo, and
2) It cannot be discovered by reading the code/docs.

If unsure, ask.

## Minimal Template

```markdown
# AGENTS.md

## Minimal Requirements
- [Non-obvious test/lint/build command]
- [Non-obvious tooling/env constraint]

## Git & Destructive
- Never commit/push without explicit request.
- Ask before destructive/privileged commands.
```
