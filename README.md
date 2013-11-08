## Erik's dotfiles

A collection of tools, scripts, configuration to make my shell and vim more awesome

Assumptions (to be fixed later):
- This repo will be located at ~/Dropbox/dotfiles
- Go will be located at ~/go/go (only matters if you're developing Go)

### Install

The Thor script used to do the install assumes you have Ruby 2.0 and Bundler installed

##### TODO: Install Ruby

##### Install Bundler
<pre>
gem install bundler
</pre>

##### Download / Install dotfiles
<pre>
cd ~/Dropbox
git clone git@github.com:erikstmartin/dotfiles.git
git submodule init && git submodule update
cd dotfiles
bundle install
./dotfiles install
</pre>

This may take a while as it will install a bunch of packages via homebrew (will eventaully support apt-get when run on linux)

##### Install Vim plugins
The first time you open vim it will prompt you to install any plugins mentioned in the vimrc file that have not been installed already (in this case all of them). This may take some time.

<pre>
vim
</pre>

##### Install Fonts
Both the vim setup, and zsh setup make use of a font provided with power-line fonts in the vendor/deps directory, you'll need to install them and set them up

Doubleclick / install all fonts in the following directory
<pre>
vendor/deps/powerline-fonts/SourceCodePro
</pre>

##### Setup iTerm2 to use Fonts / Colors

###### Font
Open iTerm2 and go to Preferences &gt; Text

Change font for both "Regular Font" and "Non-ASCII Font" to _Source Code Pro for Powerline_. If you wish for the font size in your terminal to match the font size in the vim configuration, set your font size to _14pt_.

###### Colors

Open iTerm2 and go to Preferences &gt; Colors
Click "Load Presets..."
Click "Import"
Navigate to and select "~/Dropbox/dotfiles/vendor/deps/base16-iterm2.git/base16-bright.dark.itermcolors"

Now you can click "Load Presets..." again and select "base16-bright.dark"
