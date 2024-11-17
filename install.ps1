Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

New-Item -Path $HOME\AppData\Local\nvim -ItemType SymbolicLink -Value .\nvim\.config\nvim

scoop install innounp neovim git gcc zig nodejs python go jq make ripgrep direnv ag rustup fzf main/nmap
