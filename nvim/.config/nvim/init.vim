filetype plugin indent on

call plug#begin()
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'vim-syntastic/syntastic'

Plug 'tpope/vim-surround'

Plug 'neomake/neomake'
Plug 'tpope/vim-dispatch'

Plug 'majutsushi/tagbar'
Plug 'airblade/vim-rooter'         " sets current working directory based on project files (vcs, rakefile, etc)

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'

Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline' 			    " statusline
Plug 'vim-airline/vim-airline-themes'

Plug 'rking/ag.vim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git', {'autoload':{'filetypes':['gitcommit','gitconfig', 'gitrebase', 'gitsendmail']}}

Plug 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}}

if has('nvim')
  Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/denite.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

Plug 'neovim/nvim-lsp'
Plug 'nvim-lua/diagnostic-nvim'
Plug 'nvim-lua/completion-nvim'
Plug 'steelsojka/completion-buffers'


Plug 'junegunn/fzf', {'dir': '~/.fzf','do': '/home/erik/.config/nvim/plugged/fzf/install --all'}
Plug 'junegunn/fzf.vim' " needed for previews

Plug 'mattn/emmet-vim', {'autoload':{'filetypes':['html','css','sass','scss','less']}} " HTML completion
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Settings
" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on " Enable syntax highlighting
filetype plugin indent on" Enable filetype-specific indenting and plugins

set autoread" Automatically read file when changed outside Vim
set history=100 	" Keep 100 lines of command line history
set viminfo^=%    " Remember info about open buffers on close
set ttyfast  " this is the 21st century, people
set nrformats-=octal      "always assume decimal numbers
set nocompatible
set mouse=a

let loaded_matchparen = 1 " this should fix issue with long lines 

let mapleader = ","
let g:mapleader = ","

ca W w
ca h tab help

" Set augroup
augroup MyAutoCmd
   autocmd!
augroup END

" fzf file fuzzy search that respects .gitignore
" If in git directory, show only files that are committed, staged, or unstaged
" else use regular :Files
nnoremap <expr> <C-p> (len(system('git rev-parse')) ? ':Files' : ':GFiles --exclude-standard --others --cached')."\<cr>"

" Load individual config files
let g:nvim_config_root = stdpath('config')
let g:config_file_list = ['settings/completion.vim',
			\ 'settings/files.vim',
			\ 'settings/filetypes.vim',
			\ 'settings/movement.vim',
			\ 'settings/search.vim',
			\ 'settings/tagbar.vim',
			\ 'settings/text.vim',
			\ 'settings/ui.vim',
			\ 'plugin/airline.vim',
			\ 'plugin/denite.vim',
			\ 'plugin/dispatch.vim',
			\ 'plugin/emmet.vim',
			\ 'plugin/fugitive.vim',
			\ 'plugin/indentline.vim',
			\ 'plugin/nerdtree.vim',
			\ 'plugin/syntastic.vim',
			\ 'plugin/tagbar.vim',
			\ 'plugin/ultisnips.vim',
			\ ]

for f in g:config_file_list
    execute 'source ' . g:nvim_config_root . '/' . f
endfor

