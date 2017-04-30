" Always start at the top line when writing a commit message.
exe "normal gg"

" If any fugitive buffers are loaded in the current tab don't show diff for
" the commit. (Chances are I'm committing via fugitive :)
let s:buflist = map(filter(range(0, bufnr('$')), 'bufwinnr(v:val)>=0'), 'bufname(v:val)')

if match(s:buflist, 'fugitive:*') == -1
    DiffGitCached | set nowrap | wincmd p

    " Close the preview window when the commit message buffer is unloaded
    " (Useful when committing from a long-running session via fugitive.)
    au BufUnload <buffer> pclose
endif
