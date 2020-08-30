filetype plugin indent on

call plug#begin()
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'vim-syntastic/syntastic'
Plug 'prettier/vim-prettier'
Plug 'nvim-treesitter/nvim-treesitter'

Plug 'tpope/vim-surround'

Plug 'neomake/neomake'
Plug 'tpope/vim-dispatch'

Plug 'majutsushi/tagbar'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
"Plug 'norcalli/snippets.nvim' " Still needs a bigger snippet library or support for ultisnip snippets

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'

Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline' 			    " statusline
Plug 'vim-airline/vim-airline-themes'

Plug 'rking/ag.vim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git', {'autoload':{'filetypes':['gitcommit','gitconfig', 'gitrebase', 'gitsendmail']}}
Plug 'kdheepak/lazygit.nvim'

Plug 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}}

if has('nvim')
  Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/denite.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

Plug 'kyazdani42/nvim-web-devicons'
Plug 'neovim/nvim-lsp'
Plug 'tjdevries/lsp_extensions.nvim'
Plug 'nvim-lua/diagnostic-nvim'
Plug 'nvim-lua/completion-nvim'
Plug 'steelsojka/completion-buffers'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/telescope.nvim'
Plug 'openresty/lua-cjson'

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

set statusline=
