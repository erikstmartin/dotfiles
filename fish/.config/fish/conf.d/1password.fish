# 1Password SSH agent
# On macOS: configured via ~/.ssh/config (IdentityAgent for github.com).
# On WSL machines with the Windows 1Password SSH agent, set
# WSL_1PASSWORD_SSH=1 in ~/.env.local to use Windows OpenSSH.
# See: https://developer.1password.com/docs/ssh/integrations/wsl
# GIT_SSH_COMMAND does the same for git (and lazygit, Neovim, ...).
if test "$WSL_1PASSWORD_SSH" = 1; and test -x /mnt/c/Windows/System32/OpenSSH/ssh.exe
    alias ssh='/mnt/c/Windows/System32/OpenSSH/ssh.exe'
    alias ssh-add='/mnt/c/Windows/System32/OpenSSH/ssh-add.exe'
    set -gx GIT_SSH_COMMAND /mnt/c/Windows/System32/OpenSSH/ssh.exe
end
