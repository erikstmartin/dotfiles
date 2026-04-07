# Skill Catalog
Tech-specific skills for OpenCode, stored in the dotfiles repo for version control and portability.

These skills are **not loaded globally** — they're meant to be copied or symlinked into individual projects as needed.

## Structure

```
skills/catalog/
├── audio/                   # Audio, video, media
│   ├── audio-dsp/
│   ├── audio-engineering-principles/
│   ├── ffmpeg/
│   └── juce-framework/
├── cpp/                     # C++ development
│   ├── cpp-development/
│   └── cpp-testing/
├── csharp/                  # C# / .NET
│   └── csharp/
├── frontend/                # Web frontend
│   ├── shadcn-ui/
│   ├── tailwind-design-system/
│   ├── vite/
│   └── vitest/
├── godot/                   # Godot Engine
│   ├── godot-architecture/
│   ├── godot-audio/
│   └── godot-core/
├── infra/                   # Infrastructure & DevOps
│   ├── cybersecurity/
│   ├── docker-expert/
│   ├── kubernetes-specialist/
│   └── terraform/
├── ruby/                    # Ruby on Rails
│   └── ruby-rails/
├── rust/                    # Rust development
│   ├── rust-async-patterns/
│   └── rust-best-practices/
└── sql/                     # SQL databases
    ├── postgres/
    └── sqlite/
```

## Usage

### Copy a whole category into a project

```bash
# All frontend skills
mkdir -p .agents/skills
cp -R ~/dotfiles/skills/catalog/frontend/* .agents/skills/
# All godot skills
cp -R ~/dotfiles/skills/catalog/godot/* .agents/skills/
# Mix categories + standalone skills
cp -R ~/dotfiles/skills/catalog/infra/* .agents/skills/
cp -R ~/dotfiles/skills/catalog/sql/postgres .agents/skills/postgres
```

### Copy individual skills

```bash
mkdir -p .agents/skills
cp -R ~/dotfiles/skills/catalog/rust/rust-best-practices .agents/skills/rust-best-practices
cp -R ~/dotfiles/skills/catalog/rust/rust-async-patterns .agents/skills/rust-async-patterns
```

### Symlink (no duplication)

```bash
mkdir -p .agents/skills
ln -s ~/dotfiles/skills/catalog/frontend/vite .agents/skills/vite
ln -s ~/dotfiles/skills/catalog/frontend/vitest .agents/skills/vitest
```

### Project-level skills

If the project uses local project skills, install them into `.agents/skills/`:

```bash
project-skills rust
```

## Suggested Skill Sets by Project Type
| Project Type | Copy |
|---|---|
| Rust service | `rust/*` + `infra/docker-expert` |
| Go service | `infra/docker-expert` + `infra/kubernetes-specialist` |
| Terraform infra | `infra/terraform-*` |
| React/Vite frontend | `frontend/*` |
| Godot game | `godot/*` |
| SQLite-backed app | `sql/sqlite` |
| SQL-heavy app | `sql/postgres` |
| Ruby/Rails app | `ruby/ruby-rails` + `sql/postgres` |
| C++ project | `cpp/*` |
| C# project | `csharp/csharp` |
| Video/media tool | `audio/*` + `godot/godot-audio` |
## Skill Sources
| Skill | Source |
|---|---|
| `rust-best-practices` | apollographql/skills |
| `rust-async-patterns` | wshobson/agents |
| `cpp-development` | affaan-m/ECC + Jeffallan/claude-skills |
| `cpp-testing` | affaan-m/everything-claude-code |
| `vite` | antfu/skills |
| `vitest` | antfu/skills |
| `tailwind-design-system` | wshobson/agents |
| `shadcn-ui` | giuseppe-trisciuoglio/developer-kit |
| `terraform` | hashicorp/agent-skills + wshobson/agents |
| `docker-expert` | sickn33/agentic-awesome-skills |
| `kubernetes-specialist` | jeffallan/claude-skills |
| `godot-architecture` | thedivergentai/gd-agentic-skills |
| `godot-core` | zate/cc-godot |
| `godot-audio` | curiositech/some_claude_skills |
| `ffmpeg` | digitalsamba/claude-code-video-toolkit |
| `audio-engineering-principles` | Custom (converted from standalone .md) |
| `audio-dsp` | Custom (converted from standalone .md) |
| `juce-framework` | Custom (converted from standalone .md) |
| `postgres` | planetscale/database-skills |
| `sqlite` | Custom |
| `cybersecurity` | Custom |
| `ruby-rails` | mindrally/skills |
| `csharp` | jeffallan/claude-skills |
## Marketplace-managed workflow skills

Superpowers is no longer vendored under `skills/global`.
Install it per harness via each harness's marketplace/plugin manager.

- Claude Code: `superpowers@claude-plugins-official`
- Codex: `superpowers@openai-curated`
- GitHub Copilot CLI: `superpowers@superpowers-marketplace`
- OpenCode: `superpowers@git+https://github.com/obra/superpowers.git`

Custom cross-agent skills are tracked locally under `agents/.agents/skills/`
as the single source of truth.
