" Heavily truncate a file path
"
" /path/to/file.js -> /p/t/file.js
" /home/path/to/file.js -> ~/p/t/file.js
function! shortpath#ShortPath(path)
    let l:sep = '/'

    let l:file = fnamemodify(a:path, ':t')
    let l:path = fnamemodify(a:path, ':p:~:h')
    let l:head = l:path[0] == '/' ? l:path[0] : ''

    let l:segs = split(l:path, l:sep)
    let l:mods = map(l:segs, 'v:val[0]')
    let l:ret = join(l:mods, l:sep)

    return l:head . l:ret . l:sep . l:file
endfunction
