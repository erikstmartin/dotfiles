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

"autocmd BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif

" For .rb files we also want to search tags in our gems as well (TODO: not sure if the exec for rvm works, also might want to use rbenv)
"autocmd BufWritePost,FileWritePost *.rb :Start! ctags -R . "`rvm gemdir`/gems/*

" For .go files we also want to be able to search tags within the GOPATH for packages we are using, as well as the std library
"autocmd BufWritePre *.go :Fmt " Automatically run 'go fmt' on write
"autocmd BufWritePost,FileWritePost *.go :Start! ctags -R . `go env GOPATH`/src/**/*.go `go env GOROOT`/src/pkg/**/*.go

" For .php files
"autocmd BufWritePost,FileWritePost *.php :Start! ctags -R .

autocmd BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc execute ':AirlineRefresh'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Fast saving
nmap <leader>w :w!<cr>

" Fast quiting
nmap <leader>q :q!<cr>
