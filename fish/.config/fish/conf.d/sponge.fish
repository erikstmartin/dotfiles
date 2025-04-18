# Sponge — history filtering
# Requires: meaningful-ooo/sponge (installed via fisher)
#
# Filter noisy / sensitive patterns from history
set -g sponge_regex_patterns \
    "git commit .*" \
    "^ " \
    "^git (push|pull) --force" \
    "^(curl|wget) .*(password|token|secret|key).*"

# Purge failed commands from history (non-zero exit)
set -g sponge_purge_only_on_exit false
set -g sponge_delay 5
