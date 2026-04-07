# Global OpenCode Rules

## Minimal Requirements

- Be terse; prefer code over explanations.
- If unsure or blocked, ask one targeted question.

## Verification

- When you change code, run relevant lint/typecheck/tests/build. If you didn't run them, say so.

## Git & Destructive

- Never `git commit` or `git push` without explicit user request. `git add` is ok.
- Never `git checkout` or `git reset` changes you didn't make. Do not, under any circumstances discard manual changes the user has made
- Ask before destructive or privileged commands (rm/sudo/kubectl/terraform/docker/package uninstalls).
