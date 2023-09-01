let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "goimports"

" Disable 'K' for godoc, we're using it for lsp hover
let g:go_doc_keywordprg_enabled=0

" Use nvim lsp to handle jumping around
let g:go_def_mapping_enabled=0
let g:go_gopls_enabled=0
"let g:go_textobj_enabled=0

function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <leader>t <Plug>(go-test)
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
