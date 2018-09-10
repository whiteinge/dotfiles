" Diff two registers
"
" Open a diff of two registers in a new tabpage. Close the tabpage when
" finished. If no registers are specified it diffs the most recent yank with
" the most recent deletion.
" Usage:
"   :DiffRegs
"   :DiffRegs @a @b

fu! diffregs#DiffRegsFunc(...)
    let l:left = a:0 == 2 ? a:1 : "@0"
    let l:right = a:0 == 2 ? a:2 : "@1"

    tabnew
    exe 'put! ='. l:left
    vnew
    exe 'put! ='. l:right

    windo call scratch#Scratch()
    windo diffthis
    winc t
endfu
