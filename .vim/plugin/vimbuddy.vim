" Description: VimBuddy statusline character
" Author:      Flemming Madsen <vim@themadsens.dk>
" Modified:    August 2007
" Version:     0.9.2
"
" Usage:       Insert %{VimBuddy()} into your 'statusline'
"
function! VimBuddy()
    " Take a copy for others to see the messages
    if ! exists("s:vimbuddy_msg")
        let s:vimbuddy_msg = v:statusmsg
    endif
    if ! exists("s:vimbuddy_warn")
        let s:vimbuddy_warn = v:warningmsg
    endif
    if ! exists("s:vimbuddy_err")
        let s:vimbuddy_err = v:errmsg
    endif
    if ! exists("s:vimbuddy_onemore")
        let s:vimbuddy_onemore = ""
    endif

    if g:actual_curbuf != bufnr("%")
        " Not my buffer, sleeping
        return "|-o"
    elseif s:vimbuddy_err != v:errmsg
        let v:errmsg = v:errmsg . " "
        let s:vimbuddy_err = v:errmsg
        return ":-("
    elseif s:vimbuddy_warn != v:warningmsg
        let v:warningmsg = v:warningmsg . " "
        let s:vimbuddy_warn = v:warningmsg
        return "(-:"
    elseif s:vimbuddy_msg != v:statusmsg
        let v:statusmsg = v:statusmsg . " "
        let s:vimbuddy_msg = v:statusmsg
        let test = matchstr(v:statusmsg, 'lines *$')
        let num = substitute(v:statusmsg, '^\([0-9]*\).*', '\1', '') + 0
        " How impressed should we be
        if test != "" && num > 20
            let str = ":-O"
        elseif test != "" && num
            let str = ":-o"
        else
            let str = ":-/"
        endif
		  let s:vimbuddy_onemore = str
		  return str
	 elseif s:vimbuddy_onemore != ""
		let str = s:vimbuddy_onemore
		let s:vimbuddy_onemore = ""
		return str
    endif

    if ! exists("b:lastcol")
        let b:lastcol = col(".")
    endif
    if ! exists("b:lastlineno")
        let b:lastlineno = line(".")
    endif
    let num = b:lastcol - col(".")
    let b:lastcol = col(".")
    if (num == 1 || num == -1) && b:lastlineno == line(".")
        " Let VimBuddy rotate his nose
        let num = b:lastcol % 4
        if num == 0
            let ch = '/'
         elseif num == 1
            let ch = '-'
        elseif num == 2
            let ch = '\'
        else
            let ch = '|'
        endif
        return ":" . ch . ")"
    endif
    let b:lastlineno = line(".")

    " Happiness is my favourite mood
    return ":-)"
endfunction
