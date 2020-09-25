set nocompatible

let base16colorspace=256  " Access colors present in 256 colorspace, used with base16-shell
set termguicolors
"colorscheme ir_black
colorscheme base16-default-dark
set background=dark

set cmdheight=1 		" Height of command bar
set shortmess=a                 " Show shorter messages
set hidden			" Handle multiple buffers better
set ruler 			" Show the cursor position all the time
set scrolloff=5			" set 5 lines to the cursur (move when moving verticaly)
set sidescrolloff=5		" set 5 columns to the cursur (move when moving verticaly)
set wildmenu 			" Enhanced commandline completion
set ignorecase 			" Case-insensitive searching
set smartcase 			" But case-sensitive if expression contains a capital letter
set incsearch 			" Highlight matches as you type
set hlsearch 			" Highlight matches
set showmatch 			" Briefly jump to matching brace
set matchtime=2 		" Speed things up
set lazyredraw 			" Don't redraw while executing macros (good performance)
"set notimeout
"set ttimeout
"set ttimeoutlen=1
set timeoutlen=750              " Don't wait so long for next keypress
set magic			" Regular expressions
set showcmd 			" Display incomplete commands
set noshowmode 			" Don't display the mode we're in (done in airline)
set nowrap 			" Turn off line wrapping
set mouse=a 			" Allow mouse scrolling
set title 			" Set the terminal's title
set noerrorbells 		" No beeping
set novisualbell 		" No annoying bells
set vb
set t_vb=
set winminheight=0
"set relativenumber
set laststatus=2                " Show status line all the time
set ambiwidth=single
set helpheight=30 		" Set window height when opening vim help windows
"set showbreak=↪\ \ 		" string to put before wrapped screen lines
set display+=lastline 		" show last line even if it doesnt fit in the window
set number 			" show line numbers
set viewoptions=folds,options,cursor,unix,slash     "unix/windows compatibility
set updatetime=2000
"set cursorline
set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
set fcs=vert:│
set virtualedit=onemore         " Give one virtual space at end of line
set splitbelow                  " open horizontal splits below by default
set splitright                  " open vertical splits to right by default
set colorcolumn=+1              " Column width indicator
set nosmartindent               " do not auto ident
set cindent
set pastetoggle=
"set switchbuf=usetab,newtab "switch to the existing tab if the buffer is open, or creating a new one if not
set nocompatible

set wildmode=list:longest,full
set wildignore=*.o,*.obj,*~ 
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=vendor/bundle/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/Library/**,*/.rbenv/**
set wildignore+=*/.nx/**,*.app

nnoremap <Leader>cc :cclose<CR>
