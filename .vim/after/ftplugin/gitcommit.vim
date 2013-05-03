if match(keys(getbufvar(bufname('%'), '')), 'fugitive*') == -1
    DiffGitCached | set nowrap | wincmd p
endif
