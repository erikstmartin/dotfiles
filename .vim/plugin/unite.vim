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

call unite#filters#matcher_default#use(['matcher_fuzzy'])
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
nnoremap <silent> <space><space> :Unite -buffer-name=files buffer_tab bookmark file_rec/async<CR>

" Quick registers
nnoremap <silent> <space>r :Unite -buffer-name=register register<CR>

" Quick buffer and mru
nnoremap <silent> <space>u :Unite -buffer-name=buffers buffer file_mru<CR>

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
nnoremap <silent> <space>g :<C-u>Unite -buffer-name=grep grep:.<CR>

" Quick help
nnoremap <silent> <space>h :<C-u>Unite -buffer-name=help help<CR>

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
" Custom Unite settings
autocmd MyAutoCmd FileType unite call s:unite_settings()
function! s:unite_settings()

  nmap <buffer> <ESC> <Plug>(unite_exit)
  imap <buffer> <ESC> <Plug>(unite_exit)
  " imap <buffer> <c-j> <Plug>(unite_select_next_line)
  imap <buffer> <c-j> <Plug>(unite_insert_leave)
  nmap <buffer> <c-j> <Plug>(unite_loop_cursor_down)
  nmap <buffer> <c-k> <Plug>(unite_loop_cursor_up)
  imap <buffer> <c-a> <Plug>(unite_choose_action)
  imap <buffer> <Tab> <Plug>(unite_exit_insert)
  imap <buffer> jj <Plug>(unite_insert_leave)
  imap <buffer> <C-w> <Plug>(unite_delete_backward_word)
  imap <buffer> <C-u> <Plug>(unite_delete_backward_path)
  imap <buffer> '     <Plug>(unite_quick_match_default_action)
  nmap <buffer> '     <Plug>(unite_quick_match_default_action)
  nmap <buffer> <C-r> <Plug>(unite_redraw)
  imap <buffer> <C-r> <Plug>(unite_redraw)
  inoremap <silent><buffer><expr> <C-s> unite#do_action('split')
  nnoremap <silent><buffer><expr> <C-s> unite#do_action('split')
  inoremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  nnoremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')

  let unite = unite#get_current_unite()
  if unite.buffer_name =~# '^search'
    nnoremap <silent><buffer><expr> r     unite#do_action('replace')
  else
    nnoremap <silent><buffer><expr> r     unite#do_action('rename')
  endif

  nnoremap <silent><buffer><expr> cd     unite#do_action('lcd')

  " Using Ctrl-\ to trigger outline, so close it using the same keystroke
  if unite.buffer_name =~# '^outline'
    imap <buffer> <C-\> <Plug>(unite_exit)
  endif

  " Using Ctrl-/ to trigger line, close it using same keystroke
  if unite.buffer_name =~# '^search_file'
    imap <buffer> <C-_> <Plug>(unite_exit)
  endif
endfunction
