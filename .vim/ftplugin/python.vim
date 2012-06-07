" Syntax vars
let python_highlight_numbers = 1
let python_highlight_builtins = 1
let python_highlight_exceptions = 1
let python_highlight_space_errors = 1

if exists("+omnifunc")
    setl omnifunc=pythoncomplete#Complete
endif

setl keywordprg=pydoc
setl makeprg=pylint\ -E\ -r\ n\ -f\ parseable\ %:p
setl efm=%A%f:%l:\ [%t%.%#]\ %m,%Z%p^^,%-C%.%#

" tagbar settings
let g:tagbar_type_python = {
    \ 'kinds' : [
        \ 'c:classes',
        \ 'f:functions',
        \ 'm:class members',
        \ 'v:variables:1',
        \ 'i:imports:1'
    \ ]
\ }

" Add PYTHONPATH to Vim path to enable 'gf' (also works when in a virtualenv)
if has('python')
py << EOL
import vim, os, site, sys
basedir = os.environ.get('VIRTUAL_ENV', '')
if basedir:
    pyver = 'python{0}'.format('.'.join(sys.version.split('.')[:2]))
    libdir = os.path.join(basedir, 'lib', pyver, 'site-packages')
    site.addsitedir(libdir)

paths = [i.replace(' ', r'\ ') for i in sys.path if os.path.isdir(i)]
vim.command(r'set path+={0}'.format(','.join(paths)))
EOL
endif

" TODO: (re-find and) note where this folding code comes from!
set foldmethod=expr
set foldexpr=PythonFoldExpr(v:lnum)
set foldtext=PythonFoldText()

let b:folded = 1

function! ToggleFold()
    if( b:folded == 0 )
        exec "normal! zM"
        let b:folded = 1
    else
        exec "normal! zR"
        let b:folded = 0
    endif
endfunction

function! PythonFoldText()

    let size = 1 + v:foldend - v:foldstart
    if size < 10
        let size = " " . size
    endif
    if size < 100
        let size = " " . size
    endif
    if size < 1000
        let size = " " . size
    endif
    
    if match(getline(v:foldstart), '"""') >= 0
        let text = substitute(getline(v:foldstart), '"""', '', 'g' ) . ' '
    elseif match(getline(v:foldstart), "'''") >= 0
        let text = substitute(getline(v:foldstart), "'''", '', 'g' ) . ' '
    else
        let text = getline(v:foldstart)
    endif
    
    return size . ' lines:'. text . ' '

endfunction

function! PythonFoldExpr(lnum)

    if indent( nextnonblank(a:lnum) ) == 0
        return 0
    endif
    
    if getline(a:lnum-1) =~ '^\(class\|def\)\s'
        return 1
    endif
        
    if getline(a:lnum) =~ '^\s*$'
        return "="
    endif
    
    if indent(a:lnum) == 0
        return 0
    endif

    return '='

endfunction
