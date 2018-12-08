" Always start at the top line when writing a commit message.
exe "normal gg"

" Don't fold anything in the inline diff.
setl nofoldenable

" See :help ft-gitcommit-plugin
DiffGitCached | set nowrap | wincmd p

" Close the preview window when the commit message buffer is unloaded.
au BufUnload <buffer> pclose
