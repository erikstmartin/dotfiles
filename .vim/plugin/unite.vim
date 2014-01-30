let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable = 1
let g:unite_data_directory='~/.vim/.cache/unite'
let g:unite_prompt='» '
let g:unite_winheight = 10
let g:unite_split_rule = 'botright'
let g:unite_update_time = 200
let g:unite_cursor_line_highlight = 'TabLineSel'
let g:unite_source_file_mru_filename_format = ':~:.'
let g:unite_source_file_mru_limit = 1000
let g:unite_source_file_mru_time_format = ''
let g:unite_source_rec_max_cache_files = 2000

let g:unite_source_grep_command = 'ag'
let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
let g:unite_source_grep_recursive_opt = ''

call unite#filters#sorter_default#use(['sorter_rank'])
call unite#set_profile('files', 'smartcase', 1)
call unite#custom#source('line,outline','matchers','matcher_fuzzy')
call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
      \ 'ignore_pattern', join([
      \ '\.git/',
      \ 'tmp/',
      \ '.sass-cache',
      \ ], '\|'))

" General fuzzy search
nnoremap <silent> <space><space> :<C-u>Unite -buffer-name=files buffer_tab bookmark file_rec/async<CR>

" Quick registers
nnoremap <silent> <space>r :<C-u>Unite -buffer-name=register register<CR>

" Quick buffer and mru
nnoremap <silent> <space>u :<C-u>Unite -buffer-name=buffers buffer file_mru<CR>

" Quick yank history
nnoremap <silent> <space>y :<C-u>Unite -buffer-name=yanks history/yank<CR>

" Quick outline
nnoremap <silent> <space>o :<C-u>Unite -buffer-name=outline -vertical outline<CR>

" Quick sources
nnoremap <silent> <space>a :<C-u>Unite -buffer-name=sources source<CR>

" Quick snippet
nnoremap <silent> <space>s :<C-u>Unite -buffer-name=snippets ultisnips<CR>

" Quick file search
nnoremap <silent> <space>f :<C-u>Unite -buffer-name=files file_rec/async file/new<CR>

" Quick grep from cwd
nnoremap <silent> <space>g :<C-u>Unite -buffer-name=grep git_grep<CR>

" Quick line using the word under cursor
nnoremap <silent> <space>l :<C-u>UniteWithCursorWord -buffer-name=search_file line<CR>

" Quick MRU search
nnoremap <silent> <space>m :<C-u>Unite -buffer-name=mru file_mru<CR>

" Quick find
nnoremap <silent> <space>n :<C-u>Unite -buffer-name=find find:.<CR>

" Quick commands
nnoremap <silent> <space>c :<C-u>Unite -buffer-name=commands command<CR>

" Quick tags
nnoremap <silent> <space>t :<C-u>Unite -buffer-name=tags tag<CR>

" Quick bookmarks
nnoremap <silent> <space>b :<C-u>Unite -buffer-name=bookmarks bookmark<CR>

" Overwrite settings.
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
  " ctrl+s to open in split
  imap <silent><buffer><expr> <C-s><t_ü>  unite#do_action('split')

  " hit o to open
  nnoremap <silent><buffer><expr> o   unite#do_action('open')
  
  " hit p to show preview window
  noremap <silent><buffer><expr> p
    \ empty(filter(range(1, winnr('$')),
    \ 'getwinvar(v:val, "&previewwindow") != 0')) ?
    \ unite#do_action('preview') : ":\<C-u>pclose!\<CR>"
endfunction
