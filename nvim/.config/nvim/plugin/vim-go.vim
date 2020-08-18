let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "goimports"

" Disable 'K' for godoc, we're using it for lsp hover
let g:go_doc_keywordprg_enabled=0

" Use nvim lsp to handle jumping around
let g:go_def_mapping_enabled=0
let g:go_gopls_enabled=0
"let g:go_textobj_enabled=0
