# 1Password SSH agent
# On macOS: configured via ~/.ssh/config (IdentityAgent for github.com).
# On WSL: use ssh.exe aliases so SSH requests are forwarded to the 1Password
# SSH agent running on the Windows host — no bridge/relay needed.
# See: https://developer.1password.com/docs/ssh/integrations/wsl
if test -f /proc/version; and grep -qi microsoft /proc/version 2>/dev/null
    alias ssh='ssh.exe'
    alias ssh-add='ssh-add.exe'
end
