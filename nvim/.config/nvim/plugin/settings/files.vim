""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ffs=unix,mac,dos

set directory=~/.vim/.cache/swap
set noswapfile
set showfulltag
set tags=./git/tags,./tags,tags;/
set modeline
set modelines=5

set noswapfile

" backups
"set backup
"set backupdir=~/.vim/.cache/backup
set nobackup

" undo file
if exists('+undofile')
  set undofile
  set undodir=~/.vim/.cache/undo
endif

try
  lang en_us
catch
endtry

autocmd BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc execute ':AirlineRefresh'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Fast saving
nmap <leader>w :w!<cr>

" Fast quiting
nmap <leader>q :q!<cr>
