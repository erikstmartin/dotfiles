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

NeoBundle 'marijnh/tern_for_vim'
NeoBundle 'chriskempson/base16-vim'
NeoBundle 'rking/ag.vim' 			          " search
NeoBundle 'vim-airline/vim-airline' 			    " statusline
NeoBundle 'vim-airline/vim-airline-themes'
"NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'Shougo/unite.vim' 			      " completion window
NeoBundle 'Shougo/unite-outline' 
NeoBundleLazy 'tsukkee/unite-tag', {'autoload':{'unite_sources':['tag','tag/file']}}
"NeoBundle 'scrooloose/syntastic' 		    " syntax check on buffer save
NeoBundle 'tomtom/tlib_vim'             " VimL utility functions 
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'tpope/vim-fugitive'			    " git
"NeoBundleLazy 'tpope/vim-markdown', {'autoload':{'filetypes':['markdown', 'md']}}
NeoBundle 'tpope/vim-repeat'
NeoBundle 'airblade/vim-rooter'         " sets current working directory based on project files (vcs, rakefile, etc)
NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}}
NeoBundle 'majutsushi/tagbar'
NeoBundle 'ervandew/supertab'
NeoBundle 'SirVer/ultisnips'
"NeoBundle 'Chiel92/vim-autoformat'                 " Autoformat code
NeoBundle 'Valloric/YouCompleteMe', {'build': {'unix': './install.sh --clang-completer', 'mac': './install.sh --clang-completer'}}

" Git
NeoBundle 'tpope/vim-git', {'autoload':{'filetypes':['gitcommit','gitconfig', 'gitrebase', 'gitsendmail']}}

" HTML / CSS
"NeoBundleLazy 'cakebaker/scss-syntax.vim', {'autoload':{'filetypes':['scss','sass']}}
"NeoBundleLazy 'hail2u/vim-css3-syntax', {'autoload':{'filetypes':['css','scss','sass']}}
"NeoBundleLazy 'ap/vim-css-color', {'autoload':{'filetypes':['css','scss','sass','less']}}

"NeoBundleLazy 'mattn/emmet-vim', {'autoload':{'filetypes':['html','css','sass','scss','less']}} " HTML completion

" Ruby
"NeoBundleLazy 'janx/vim-rubytest', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
"NeoBundleLazy 'tpope/vim-rails', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
"NeoBundleLazy 'vim-ruby/vim-ruby', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
"NeoBundleLazy 'kana/vim-textobj-user', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
"NeoBundleLazy 'nelstrom/vim-textobj-rubyblock', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
"NeoBundleLazy 'tpope/vim-rbenv', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
"NeoBundleLazy 'KurtPreston/vim-autoformat-rails', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}         
"NeoBundle 'tpope/vim-bundler', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}
"NeoBundle 'tpope/gem-ctags', {'autoload':{'filetypes':['eruby', 'ruby', 'erb']}}

" Vim
"NeoBundleLazy 'tpope/vim-scriptease', {'autoload':{'filetypes':['vim']}}

" Go
NeoBundleLazy 'fatih/vim-go', {'autoload':{'filetypes':['go']}}

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
"set ttymouse=xterm2

let loaded_matchparen = 1 " this should fix issue with long lines 

let mapleader = ","
let g:mapleader = ","

ca W w
ca h tab help

" Set augroup
augroup MyAutoCmd
  autocmd!
augroup END
