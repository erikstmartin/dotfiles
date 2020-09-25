map <F5> :TagbarToggle<CR>
let g:tagbar_position = 'vertical topleft'
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1
let g:tagbar_show_visibility = 1
let g:tagbar_sort = 1
let g:tagbar_compact = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_foldlevel = 0

let g:tagbar_type_go = {
    \ 'ctagstype': 'go',
    \ 'kinds' : [
        \'p:packages',
        \'f:functions',
        \'v:variables',
        \'t:types',
        \'i:imports',
        \'w:fields',
        \'m:methods',
        \'c:constants'
    \]
\}

let g:tagbar_visibility_symbols = {
\ 'public'    : '+',
\ 'protected' : '#',
\ 'private'   : '-'
\ }

let g:tagbar_scopestrs = {
\    'class': "\uf0e8",
\    'const': "\uf8ff",
\    'constant': "\uf8ff",
\    'enum': "\uf702",
\    'field': "\uf30b",
\    'func': "\uf794",
\    'function': "\uf794",
\    'getter': "\ufab6",
\    'implementation': "\uf776",
\    'interface': "\uf7fe",
\    'map': "\ufb44",
\    'member': "\uf02b",
\    'method': "\uf6a6",
\    'setter': "\uf7a9",
\    'variable': "\uf71b",
\ }

