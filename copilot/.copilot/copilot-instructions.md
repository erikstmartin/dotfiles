# Global Copilot Rules

## Git Commit and Push

Never run `git commit` or `git push` without explicit permission from the user.

- If the user's prompt does not explicitly ask you to commit or push, do not do so.
- If you believe a commit or push would be helpful, ask the user first before running it.
- Staging files with `git add` is allowed without asking.
- All other git read operations (`git status`, `git log`, `git diff`, etc.) are allowed without asking.

## Destructive Commands

Always ask before running commands that delete, overwrite, or mutate infrastructure/dependencies:

- `rm` / `rm -rf` — ask before any deletion
- `sudo` — ask before any privileged command
- `kubectl delete`, `kubectl apply`, `kubectl patch`, `kubectl exec` — ask before any cluster mutation
- `terraform apply`, `terraform destroy` — ask before any infrastructure change
- `docker rm`, `docker rmi`, `docker stop` — ask before removing containers or images
- `brew uninstall`, `npm uninstall`, `pip uninstall`, `cargo uninstall`, `gem uninstall` — ask before removing packages
