" Heavily truncate a file path
"
" /path/to/file.js -> /p/t/file.js
" /home/path/to/file.js -> ~/p/t/file.js
fu! fp#ShortPath(path)
    let l:sep = '/'

    let l:file = fnamemodify(a:path, ':t')
    let l:path = fnamemodify(a:path, ':p:~:h')
    let l:head = l:path[0] is '/' ? l:path[0] : ''

    let l:segs = split(l:path, l:sep)
    let l:mods = map(l:segs, 'v:val[0]')
    let l:ret = join(l:mods, l:sep)

    return l:head . l:ret . l:sep . l:file
endfu

" Log a message with a prefix
" fp#Log('The type is', {x -> type(x)})
fu! fp#Log(prefix, fn)
    let l:prefix = a:prefix
    let l:Fn = type(a:fn) is v:t_string ? function(a:fn, a:000) : a:fn
    fu! LogWrapped(x) closure
        echom printf('%s: %s', l:prefix, l:Fn(a:x))
        return a:x
    endfu

    return funcref('LogWrapped')
endfu

" Optionally call a function if the input isn't empty.
" fp#Maybe({x -> x})('')
fu! fp#Maybe(fn, ...)
    let l:Fn = type(a:fn) is v:t_string ? function(a:fn, a:000) : a:fn
    return {arg -> arg == '' || arg is 0 ? 0 : l:Fn(arg)}
endfu

" Reduce, curried.
" fp#Reduce({acc, cur -> acc + cur}, 0)([1, 2, 3])
fu! fp#Reduce(fn, seed)
    let l:Fn = type(a:fn) is v:t_string ? function(a:fn) : a:fn
    let l:Acc = a:seed

    fu! ReduceWrapped(xs) closure
        for l:X in a:xs
            let l:Acc = l:Fn(l:Acc, l:X)
        endfor
        return l:Acc
    endfu

    return funcref('ReduceWrapped')
endfu

" Make a pipeline of functions that returns a function.
" fp#Pipe([{x -> x}, {x -> x}])('foo')
fu! fp#Pipe(fns)
    let l:fns = reverse(copy(a:fns))
    return fp#Reduce({f, g -> {val -> f(g(val))}}, {x -> x})(l:fns)
endfu

" Map, curried with index & value arguments swapped.
" fp#Map({x, i -> x + 1})([1,2,3])
fu! fp#Map(fn)
    let l:Fn = type(a:fn) is v:t_string ? function(a:fn) : a:fn
    return {xs -> map(xs, {i, x -> l:Fn(x, i)})}
endfu

" Filter, curried with index & value arguments swapped.
" fp#Filter({x, i -> x == 2})([1,2,3])
fu! fp#Filter(fn)
    let l:Fn = type(a:fn) is v:t_string ? function(a:fn) : a:fn
    return {xs -> filter(xs, {i, x -> l:Fn(x, i)})}
endfu

" Join, curried with arguments reversed.
" fp#Join(', ')(['foo', 'bar'])
fu! fp#Join(str)
    return {xs -> join(xs, a:str)}
endfu

" type() comparison, curried.
" fp#Is(v:t_string)('foo')
fu! fp#Is(type)
    return {x -> type(x) is a:type}
endfu

" Check if a value is false
fu! fp#IsNil(val, ...)
    return a:val is 0
endfu

" Complement
" Takes a function that returns a boolean and returns a function that returns
" the opposite.
fu! fp#Complement(fn)
    let l:Fn = type(a:fn) is v:t_string ? function(a:fn) : a:fn
    return {x -> !l:Fn(x)}
endfu
