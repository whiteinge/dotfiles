let g:tagbar_type_vlang = {
  \ 'kinds': [
    \ 'm:imodule',
    \ 'M:module',
    \ 'C:cfunction',
    \ 'f:function',
    \ 'h:method',
    \ 'c:const',
    \ 'v:variable',
    \ 's:struct',
    \ 'e:enum',
    \ 'i:interface',
    \ 'S:sfield',
    \ 'E:efield',
  \ ],
\ }

let b:ale_linter_aliases = { 'vlang': 'v' }
let b:ale_fixers = ['vfmt']
