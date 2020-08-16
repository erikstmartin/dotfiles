nnoremap <leader>tag :Dispatch ctags -R<cr>


nnoremap <silent> <space>d :call CallDispatchWithCommand() <CR>

function! CallDispatchWithCommand()
  let dispatch_command = input('> ')
  execute ':Dispatch ' . dispatch_command
endfunction
