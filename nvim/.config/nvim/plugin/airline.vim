" unicode symbols
let g:airline_powerline_fonts = 1
let g:airline_theme = 'tomorrow'
let g:airline_exclude_filetypes = ['unite']
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#enabled = 1

"call airline#parts#define_function('goinfo', 'go#complete#GetInfo')
"call airline#parts#define_condition('goinfo', '&ft =~ "go"')
function! AirlineInit()
    " Ended up not having virtualenv here since for some reason it insisted on having that as a bare string
"    let g:airline_section_x = airline#section#create_right(['goinfo', 'tagbar', 'filetype'])
endfunction
autocmd VimEnter * call AirlineInit()


set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\ %{fugitive#statusline()}

let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
