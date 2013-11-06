let g:submode_timeout = 0 " Don't leave submode automatically

" scrolling
call submode#enter_with('scroll', 'n', '', '<space>j', ':call smooth_scroll#down(&scroll/2, 5, 1)<CR>')
call submode#enter_with('scroll', 'n', '', '<space>k', ':call smooth_scroll#up(&scroll/2, 5, 1)<CR>')
call submode#map('scroll', 'n', '', 'j', ':call smooth_scroll#down(&scroll/2, 5, 1)<CR>')
call submode#map('scroll', 'n', '', 'k', ':call smooth_scroll#up(&scroll/2, 5, 1)<CR>')

" Space-=: Resize windows
nnoremap <space>= <c-w>=
