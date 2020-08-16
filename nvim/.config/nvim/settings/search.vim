""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set gdefault " Assume the /g flag on :s substitutions to replace all matches in a line
set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow 
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
set grepformat=%f:%l:%c:%m

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ctrl-c: Copy (works with system clipboard due to clipboard setting)
vnoremap <c-c> y`]

" Ctrl-r: Easier search and replace
vnoremap <c-r> "hy:%s/<c-r>h//gc<left><left><left>

" Ctrl-s: Easier substitue
vnoremap <c-s> :s/\%V//g<left><left><left>

" Ctrl-f: Find with MultipleCursors
vnoremap <c-f> :MultipleCursorsFind 

" Backspace: Toggle search highlight
nnoremap <bs> :set hlsearch! hlsearch?<cr>
