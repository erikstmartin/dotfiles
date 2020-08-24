## Erik's dotfiles

A collection of tools, scripts, configuration to make my shell and vim more awesome

### Install

This repo is meant to store configuration files which are then symlinked by using GNU Stow. You'll want to install it via your standard package manager.

##### Download / Install dotfiles
<pre>
cd ~/
git clone git@github.com:erikstmartin/dotfiles.git
git submodule update --init --recursive
cd dotfiles
</pre>

##### Link dotfiles

You can choose which configuration files you'd like to use individually
<pre>
cd ~/dotfiles
stow -vv vim
</pre>

##### Install Vim plugins
I use Plug to manage my plugins.

The first time you open nvim you will need to install plugins by typing
<pre>
:PlugInstall
</pre>

You can periodically update it from within vim using the following command
<pre>
:PlugUpdate
</pre>

I use NeoVim's LSP. You will need to install language servers for any languages you use. In the case of my nvim setup.

Go - gopls
Rust - rust_analyzer
Python - pyls
Typescript - tsserver

##  Fonts
Both the vim setup, and zsh setup make use of a font provided with power-line fonts in the vendor/deps directory, you'll need to install them and set them up

##### Install Powerline Fonts
<pre>
cd
_vendor/powerline-fonts
./install.sh
</pre>
