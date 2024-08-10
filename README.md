## Erik's dotfiles

A collection of tools, scripts, configuration to make my shell and vim more awesome

### Install

This repo is meant to store configuration files which are then symlinked by using GNU Stow. You'll want to install it via your standard package manager.

##### Download / Install dotfiles
<pre>
cd ~/
git clone git@github.com:erikstmartin/dotfiles.git
cd dotfiles
git submodule update --init --recursive
</pre>

##### Install Dependencies (script currently assumes Ubuntu/Debian)
<pre>
    ./install.sh
</pre>

##### Link dotfiles
You can choose which configuration files you'd like to use individually
<pre>
cd ~/dotfiles
stow -vv nvim zsh starship tmux
</pre>

##### 1Password for ssh keys
You must turn on the SSH Agent in 1Password. You can find it under Settings->Developer
