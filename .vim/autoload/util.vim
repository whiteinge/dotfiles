" Heavily truncate a file path
"
" /path/to/file.js -> /p/t/file.js
" /home/path/to/file.js -> ~/p/t/file.js
fu! util#ShortPath(path)
    let l:sep = '/'

    let l:file = fnamemodify(a:path, ':t')
    let l:path = fnamemodify(a:path, ':p:~:h')
    let l:head = l:path[0] is '/' ? l:path[0] : ''

    let l:segs = split(l:path, l:sep)
    let l:mods = map(l:segs, 'v:val[0]')
    let l:ret = join(l:mods, l:sep)

    return l:head . l:ret . l:sep . l:file
endfu

" Vim only has quickfix/loclist autocommands that trigger when specific
" commands are run and not when the actual contents change. This makes it hard
" to react to changes that happen behind the scenes (e.g., setqflist()).
fu! util#OnChanged(Fn, Cb)
    let l:lastret = v:null
    let l:Fn = a:Fn
    let l:Cb = a:Cb

    fu! Wrapper(...) closure
        let l:newret = l:Fn(a:000)
        if l:lastret is v:null " First run.
            call l:Cb(l:lastret, a:000)
        else
            if l:lastret != l:newret
                call l:Cb(l:lastret, a:000)
            endif
        endif
        let l:lastret = l:newret
    endfu

    return funcref('Wrapper')
endfu

let s:Qfchanged = util#OnChanged({-> getqflist({'changedtick': 1, 'id': 0})},
    \ {-> execute('silent doautocmd <nomodeline> User Qfchanged')})
let s:Llchanged = util#OnChanged({-> getloclist(0, {'changedtick': 1, 'id': 0})},
    \ {-> execute('silent doautocmd <nomodeline> User Llchanged')})

fu! util#StartQfWatchers()
    call timer_start(1000, s:Qfchanged, {'repeat': -1})
    call timer_start(1000, s:Llchanged, {'repeat': -1})
endfu

" Call system() and then call :redraw!
" Pass args as data-first to allow use as a method.
" Check v:shell_error if you need to know the exit code.
fu! util#SysR(arr, cmd)
    let l:ret = system(a:cmd, a:arr)
    redraw!
    return l:ret
endfu

" Return the first item in a list that satisfies a predicate function.
" Data-first so works as a method.
fu! util#Find(list, fn)
    for i in a:list
        let l:ret = a:fn(i)
        if l:ret == v:true
            return i
        endif
    endfor
    return v:false
endfu
