set guioptions -=T 	" Remove toolbar
set guioptions -=t 	" Remove tear-off menus
set guioptions +=c 	" Use :ex command-mode prompts instead of modal dialogs
set guioptions -=e 	" Use terminal style tabs instead of real ones
set guioptions -=gim
set guioptions +=LlRrb  " Add scrollbars in one shot so we can remove them below
set guioptions -=LlRrb  " Remove scrollbars
set vb t_vb=
set guifont=Source\ Code\ Pro\ for\ Powerline\ Semi-Light\ 12
set background=dark

if has("gui_macvim")
  set fuopt+=maxvert,maxhorz
  set guifont=Source\ Code\ Pro\ for\ Powerline:h14
  set transparency=2
elseif has("Win32")
  set guifont=Consolas:h11
  set transparency=2
end

" Setting these in GVim/MacVim because terminals cannot distinguish between
" <Space> and <S-Space> because curses sees them the same
nnoremap <Space> <PageDown>
nnoremap <S-Space> <PageUp>

if has("autocmd")
  " Automatically resize viewport splits when resizing MacVim window
  autocmd VimResized * wincmd =
endif

" Turn off bell (for real)
autocmd! GUIEnter * set vb t_vb=
