
call plug#begin()
Plug 'flazz/vim-colorschemes'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

Plug 'tpope/vim-surround'

Plug 'neomake/neomake'
Plug 'tpope/vim-dispatch'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
"Plug 'norcalli/snippets.nvim' " Still needs a bigger snippet library or support for ultisnip snippets

Plug 'ElPiloto/sidekick.nvim'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-commentary'

Plug 'chriskempson/base16-vim'

Plug 'rking/ag.vim'

"Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git', {'autoload':{'filetypes':['gitcommit','gitconfig', 'gitrebase', 'gitsendmail']}}
Plug 'kdheepak/lazygit.nvim'

Plug 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}}

Plug 'kyazdani42/nvim-web-devicons'
Plug 'neovim/nvim-lsp'
Plug 'tjdevries/lsp_extensions.nvim'
Plug 'nvim-lua/completion-nvim'
Plug 'steelsojka/completion-buffers'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/telescope.nvim'
Plug 'openresty/lua-cjson'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'sindrets/diffview.nvim'

Plug 'codota/tabnine-vim'

Plug 'rmagatti/auto-session'
Plug 'rmagatti/session-lens'

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
