autocmd BufRead,BufNewFile *.prawn set filetype=ruby
autocmd BufRead,BufNewFile *.thor set filetype=ruby
autocmd BufRead,BufNewFile *.jbuilder set filetype=ruby
autocmd BufRead,BufNewFile *.csvbuilder set filetype=ruby
autocmd BufRead,BufNewFile *.ejs set filetype=html
autocmd BufRead,BufNewFile Guardfile set filetype=ruby

" set ruby compiler
autocmd FileType ruby compiler ruby
