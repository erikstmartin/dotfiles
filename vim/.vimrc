set nocompatible

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin Manager
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('vim_starting')
  set runtimepath +=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc', {'build' : {'mac' : 'make -f make_mac.mak', 'unix' : 'make -f make_unix.mak'}}

NeoBundle 'fatih/vim-go' " Go
NeoBundle 'chriskempson/base16-vim'
NeoBundle 'rking/ag.vim' 			          " search
NeoBundle 'bling/vim-airline' 			    " statusline
"NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'Shougo/unite.vim' 			      " completion window
NeoBundle 'Shougo/unite-outline' 
NeoBundleLazy 'tsukkee/unite-tag', {'autoload':{'unite_sources':['tag','tag/file']}}
NeoBundle 'scrooloose/syntastic' 		    " syntax check on buffer save
NeoBundle 'vim-scripts/vim-startify'    " start screen
NeoBundle 'tomtom/tlib_vim'             " VimL utility functions 
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'tpope/vim-fugitive'			    " git
NeoBundleLazy 'tpope/vim-markdown', {'autoload':{'filetypes':['markdown', 'md']}}
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-surround'
NeoBundle 'airblade/vim-rooter'         " sets current working directory based on project files (vcs, rakefile, etc)
NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}}
NeoBundle 'majutsushi/tagbar'
NeoBundle 'tpope/vim-dispatch' " build tasks FTW
NeoBundle 'Valloric/YouCompleteMe', {'build': {'unix': './install.sh --clang-completer', 'mac': './install.sh --clang-completer'}}
NeoBundle 'SirVer/ultisnips'
NeoBundle 'Chiel92/vim-autoformat'                 " Autoformat code

" Git
NeoBundle 'tpope/vim-git', {'autoload':{'filetypes':['gitcommit','gitconfig', 'gitrebase', 'gitsendmail']}}

" OSX Only
NeoBundleLazy 'troydm/pb.vim', {'autoload':{'functions':["has('mac')"]}} " OSX pastebuffer interaction
"NeoBundleLazy 'Dinduks/vim-holylight', {'autoload':{'functions':["has('mac')"]}}                " set dark/light background based on OSX light sensor

" Themes
NeoBundle 'mtortonesi/vim-irblack'

" HTML / CSS
NeoBundleLazy 'cakebaker/scss-syntax.vim', {'autoload':{'filetypes':['scss','sass']}}
NeoBundleLazy 'hail2u/vim-css3-syntax', {'autoload':{'filetypes':['css','scss','sass']}}
NeoBundleLazy 'ap/vim-css-color', {'autoload':{'filetypes':['css','scss','sass','less']}}

NeoBundleLazy 'mattn/emmet-vim', {'autoload':{'filetypes':['html','css','sass','scss','less']}} " HTML completion

" Javascript
NeoBundleLazy 'pangloss/vim-javascript', {'autoload':{'filetypes':['javascript', 'js']}}
NeoBundleLazy 'maksimr/vim-jsbeautify', {'autoload':{'filetypes':['javascript', 'js']}}
NeoBundleLazy 'leshill/vim-json', {'autoload':{'filetypes':['json']}}

" Ruby
NeoBundleLazy 'janx/vim-rubytest', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
NeoBundleLazy 'brentmc79/vim-rspec', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
NeoBundleLazy 'tpope/vim-rails', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
NeoBundleLazy 'vim-ruby/vim-ruby', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
NeoBundleLazy 'kana/vim-textobj-user', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
NeoBundleLazy 'nelstrom/vim-textobj-rubyblock', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
NeoBundleLazy 'tpope/vim-rbenv', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
NeoBundleLazy 'KurtPreston/vim-autoformat-rails', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}         
NeoBundle 'tpope/vim-bundler'
NeoBundle 'tpope/gem-ctags'

" Vim
NeoBundleLazy 'tpope/vim-scriptease', {'autoload':{'filetypes':['vim']}}

call neobundle#end()

NeoBundleCheck

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on			" Enable syntax highlighting
filetype plugin indent on	" Enable filetype-specific indenting and plugins

set autoread			" Automatically read file when changed outside Vim
set history=100 	" Keep 100 lines of command line history
set viminfo^=%    " Remember info about open buffers on close
set ttyfast			  " this is the 21st century, people
set noesckeys 		" disable recognition of keys sending an escape sequence when in insert mode
set nrformats-=octal      "always assume decimal numbers
set nocompatible
set mouse=a
set ttymouse=xterm2

let loaded_matchparen = 1 " this should fix issue with long lines 

let mapleader = ","
let g:mapleader = ","

" Set augroup
augroup MyAutoCmd
  autocmd!
augroup END
