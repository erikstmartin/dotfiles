# FZF configuration (env vars only — fzf integration loaded from config.fish after mise)
# Requires: fd, bat, eza

# ── Catppuccin Mocha colour theme ──────────────────────────────────────────
set -gx FZF_DEFAULT_OPTS "\
  --color=bg+:#313244,bg:#11111b,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --color=selected-bg:#45475a \
  --color=border:#6c7086,label:#cdd6f4 \
  --border=rounded --border-label='' --preview-window=border-rounded:right:60%:wrap \
  --height=80% \
  --prompt='> ' --marker='-' --pointer='◆' \
  --separator='-' --scrollbar='|' --layout=reverse"

# ── fd-backed default commands ─────────────────────────────────────────────
if type -q fd
    set -gx FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
    set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --strip-cwd-prefix --exclude .git"
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
end

# ── Preview helpers (bat for files, eza for dirs) ──────────────────────────
if type -q eza; and type -q bat
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always --icons=always {} | head -200'"
    set -gx FZF_CTRL_T_OPTS "\
      --preview 'if test -d {}; then eza --tree --color=always --icons=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi' \
      --height 60% \
      --border sharp \
      --layout reverse \
      --prompt '∷ ' \
      --pointer ▶ \
      --marker ⇒"
end
