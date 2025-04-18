# Skill Catalog
Tech-specific skills for OpenCode / oh-my-opencode-slim, stored in the dotfiles repo for version control and portability.

These skills are **not loaded globally** — they're meant to be copied or symlinked into individual projects as needed.

## Structure

```
skills/catalog/
├── rust/                    # Rust development
│   ├── rust-best-practices/
│   └── rust-async-patterns/
├── cpp/                     # C++ development
│   ├── cpp-coding-standards/
│   ├── cpp-pro/
│   └── cpp-testing/
├── frontend/                # Web frontend
│   ├── vite/
│   ├── vitest/
│   ├── tailwind-design-system/
│   └── shadcn-ui/
├── infra/                   # Infrastructure & DevOps
│   ├── terraform-style-guide/
│   ├── terraform-module-library/
│   ├── docker-expert/
│   └── kubernetes-specialist/
├── godot/                   # Godot Engine
│   ├── godot-development/
│   ├── gdscript/
│   ├── godot-master/
│   └── godot-audio/
├── multimedia/              # Audio, video, media
│   ├── ffmpeg/
│   ├── audio-engineering-principles/
│   ├── dsp-algorithms/
│   ├── audio-systems/
│   ├── juce-framework/
│   └── audio-analysis/
├── sql/                     # SQL databases (cross-engine)
│   ├── sqlite/
│   ├── sql-schema-design/
│   ├── sql-performance/
│   └── postgres/
├── ruby/                    # Ruby on Rails
│   └── ruby-rails/
└── csharp/                  # C# / .NET
    └── csharp/
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
cp -R ~/dotfiles/skills/catalog/postgres .agents/skills/postgres
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

### OpenCode project-level skills

If the project uses OpenCode directly (not Claude), skills go in `.config/opencode/skills/`:

```bash
mkdir -p .config/opencode/skills
cp -R ~/dotfiles/skills/catalog/rust/* .config/opencode/skills/
```

## Suggested Skill Sets by Project Type
| Project Type | Copy |
|---|---|
| Rust service | `rust/*` + `infra/docker-expert` |
| Go service | `infra/docker-expert` + `infra/kubernetes-specialist` |
| Terraform infra | `infra/terraform-*` |
| React/Vite frontend | `frontend/*` |
| Godot game | `godot/*` |
| SQLite-backed app | `sql/sqlite` + `sql/sql-schema-design` |
| SQL-heavy app | `sql/sql-performance` + `sql/sql-schema-design` |
| Ruby/Rails app | `ruby/ruby-rails` + `sql/postgres` |
| C++ project | `cpp/*` |
| C# project | `csharp/csharp` |
| Video/media tool | `multimedia/*` + `godot/godot-audio` |
## Skill Sources
| Skill | Source |
|---|---|
| `rust-best-practices` | apollographql/skills |
| `rust-async-patterns` | wshobson/agents |
| `cpp-coding-standards` | affaan-m/everything-claude-code |
| `cpp-pro` | jeffallan/claude-skills |
| `cpp-testing` | affaan-m/everything-claude-code |
| `vite` | antfu/skills |
| `vitest` | antfu/skills |
| `tailwind-design-system` | wshobson/agents |
| `shadcn-ui` | giuseppe-trisciuoglio/developer-kit |
| `terraform-style-guide` | hashicorp/agent-skills |
| `terraform-module-library` | wshobson/agents |
| `docker-expert` | sickn33/antigravity-awesome-skills |
| `kubernetes-specialist` | jeffallan/claude-skills |
| `godot-master` | thedivergentai/gd-agentic-skills |
| `godot-development` | zate/cc-godot |
| `gdscript` | Custom (based on wshobson/agents godot-gdscript-patterns) |
| `godot-audio` | erichowens/some_claude_skills |
| `ffmpeg` | digitalsamba/claude-code-video-toolkit |
| `audio-engineering-principles` | Custom (converted from standalone .md) |
| `dsp-algorithms` | Custom (converted from standalone .md) |
| `audio-systems` | Custom (converted from standalone .md) |
| `juce-framework` | Custom (converted from standalone .md) |
| `audio-analysis` | Custom (converted from standalone .md) |
| `postgres` | planetscale/database-skills |
| `sqlite` | Custom |
| `sql-schema-design` | Custom |
| `sql-performance` | Custom |
| `ruby-rails` | mindrally/skills |
| `csharp` | jeffallan/claude-skills |
## Global Workflow Skills (always loaded)

These 19 skills live in `~/dotfiles/skills/global/.agents/skills/` and are stowed to `~/.agents/skills/`:

obra/superpowers (14): brainstorming, dispatching-parallel-agents, executing-plans, finishing-a-development-branch, receiving-code-review, requesting-code-review, subagent-driven-development, systematic-debugging, test-driven-development, using-git-worktrees, using-superpowers, verification-before-completion, writing-plans, writing-skills

Others (5): agent-browser, cartography, code-review-excellence, deslop, simplify
