
call plug#begin()
Plug 'flazz/vim-colorschemes'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'simrat39/rust-tools.nvim'
Plug 'saecki/crates.nvim'
Plug 'p00f/clangd_extensions.nvim'
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

Plug 'tpope/vim-surround'

Plug 'neomake/neomake'
Plug 'tpope/vim-dispatch'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'norcalli/snippets.nvim' " Still needs a bigger snippet library or support for ultisnip snippets

Plug 'ElPiloto/sidekick.nvim'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-commentary'

Plug 'chriskempson/base16-vim'

Plug 'rking/ag.vim'
Plug 'BurntSushi/ripgrep'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git', {'autoload':{'filetypes':['gitcommit','gitconfig', 'gitrebase', 'gitsendmail']}}
Plug 'kdheepak/lazygit.nvim'

Plug 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}}

Plug 'kyazdani42/nvim-web-devicons'

Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'neovim/nvim-lsp'
Plug 'tjdevries/lsp_extensions.nvim'
Plug 'github/copilot.vim'
" Plug 'nvim-lua/completion-nvim'
" Plug 'nvim-treesitter/completion-treesitter'
" Plug 'kristijanhusak/completion-tags'
" Plug 'steelsojka/completion-buffers'
" Plug 'albertoCaroM/completion-tmux'
" Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'hrsh7th/cmp-omni'
Plug 'andersevenrud/cmp-tmux'
Plug 'Jezda1337/nvim-html-css'
Plug 'delphinus/cmp-ctags'
Plug 'ray-x/cmp-treesitter'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'openresty/lua-cjson'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'sindrets/diffview.nvim'

Plug 'rmagatti/auto-session'
Plug 'rmagatti/session-lens'

Plug 'mattn/emmet-vim', {'autoload':{'filetypes':['html','css','sass','scss','less']}} " HTML completion
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'pmizio/typescript-tools.nvim'

Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

Plug 'mbbill/undotree'
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
