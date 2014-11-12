if neobundle#is_sourced('vim-dispatch')
  nnoremap <leader>tag :Dispatch ctags -R<cr>
endif


nnoremap <silent> <space>d :call CallDispatchWithCommand() <CR>

function! CallDispatchWithCommand()
  let dispatch_command = input('> ')
  execute ':Dispatch ' . dispatch_command
endfunction
