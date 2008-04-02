" UniCycle, Release 1, 2005-10-20
"
" by Jason Diamond <http://jason.diamond.name/>
"
" This document has been placed in the public domain.
"
" This script cycles through certain Unicode characters while typing. It only
" works if set encoding=utf-8.
"
" To install, drop it in your plugins directory. To use, execute the
" :UniCycleOn command. Turn turn it off, execute :UniCycleOff.
"
" When on, the hyphen (-), period (.), apostrophe ('), and quote (")
" characters are mapped to the appropriate functions within this file.
"
" When you enter two hyphen characters in a row, the first hyphen character
" will cycle to an EN DASH character. A third hyphen will turn the EN DASH
" into an EM DASH. A fourth hyphen will turn your EM DASH back into a
" HYPHEN-MINUS.
"
" Entering three periods in a row will replace all three periods with a
" HORIZONTAL ELLIPSIS character.
"
" Entering an apostrophe will try to determine if the apostrophe should be a
" LEFT SINGLE QUOTATION MARK or RIGHT SINGLE QUOTATION MARK. It does this by
" looking at the character to the left of the new character. You can cycle
" between LEFT SINGLE QUOTATION MARK, APOSTROPHE, and RIGHT SINGLE QUOTATION
" MARK by repeatedly hitting your apostrophe key.
"
" Quote characters are treated in the same manner as apostrophe characters.
" You get either a LEFT DOUBLE QUOTATION MARK, normal QUOTATION MARK, or RIGHT
" DOUBLE QUOTATION MARK based on the previous character and how many times you
" hit your quote key in a row.
"
" All of this is supposed to just work so you don't have to think about it.
" Let me know how well it does.
"
" If you set cmdheight=2 or greater, you'll see some handy messages indicating
" what special character was last inserted into the buffer.

function! UniCycleGetUTF8Char(src, start)
	let nr = char2nr(strpart(a:src, a:start, 1))
	if nr < 128
		let len = 1
	elseif nr < 192
		" Huh? This is not the start of a UTF-8 character!
		let len = 0
	elseif nr < 224
		let len = 2
	elseif nr < 240
		let len = 3
	elseif nr < 248
		let len = 4
	elseif nr < 252
		let len = 5
	else
		let len = 6
	endif
	return strpart(a:src, a:start, len)
endfunction

function! UniCycleHyphen()
	if col(".") == 1
		echo "HYPHEN-MINUS"
	else
		normal h
		let prev_char = UniCycleGetUTF8Char(getline("."), col(".") - 1)
		if prev_char == "-"
			execute "normal xr\u2013"
			echo "EN DASH"
		elseif prev_char == "\u2013"
			execute "normal xr\u2014"
			echo "EM DASH"
		elseif prev_char == "\u2014"
			normal xr-
			echo "HYPHEN-MINUS"
		else
			normal l
			echo "HYPHEN-MINUS"
		endif
	endif
endfunction

function! UniCyclePeriod()
	if col(".") < 3
		echo "FULL STOP"
	else
		normal h
		let prev1 = UniCycleGetUTF8Char(getline("."), col(".") - 1)
		if prev1 == "."
			normal h
			let prev2 = UniCycleGetUTF8Char(getline("."), col(".") - 1)
			if prev2 == "."
				execute "normal xxr\u2026"
				echo "HORIZONTAL ELLIPSIS"
			else
				normal ll
				echo "FULL STOP"
			endif
		else
			normal l
			echo "FULL STOP"
		endif
	endif
endfunction

function! UniCycleApostrophe()
	if col(".") == 1
		execute "normal r\u2018"
		echo "LEFT SINGLE QUOTATION MARK"
	else
		normal h
		let prev_char = UniCycleGetUTF8Char(getline("."), col(".") - 1)
		if stridx(" <>()[]{}", prev_char) != -1
			execute "normal lr\u2018"
			echo "LEFT SINGLE QUOTATION MARK"
		elseif prev_char == "\u2018"
			normal xr'
			echo "APOSTROPHE"
		elseif prev_char == "'"
			execute "normal xr\u2019"
			echo "RIGHT SINGLE QUOTATION MARK"
		elseif prev_char == "\u2019"
			execute "normal xr\u2018"
			echo "LEFT SINGLE QUOTATION MARK"
		else
			execute "normal lr\u2019"
			echo "RIGHT SINGLE QUOTATION MARK"
		endif
	endif
endfunction

function! UniCycleQuote()
	if col(".") == 1
		execute "normal r\u201C"
		echo "LEFT DOUBLE QUOTATION MARK"
	else
		normal h
		let prev_char = UniCycleGetUTF8Char(getline("."), col(".") - 1)
		if stridx(" <>()[]{}", prev_char) != -1
			execute "normal lr\u201C"
			echo "LEFT DOUBLE QUOTATION MARK"
		elseif prev_char == "\u201C"
			normal xr"
			echo "QUOTATION MARK"
		elseif prev_char == "\""
			execute "normal xr\u201D"
			echo "RIGHT DOUBLE QUOTATION MARK"
		elseif prev_char == "\u201D"
			execute "normal xr\u201C"
			echo "LEFT DOUBLE QUOTATION MARK"
		else
			execute "normal lr\u201D"
			echo "RIGHT DOUBLE QUOTATION MARK"
		endif
	endif
endfunction

function! UniCycleOn()
	inoremap - -<Esc>:call UniCycleHyphen()<CR>a
	inoremap . .<Esc>:call UniCyclePeriod()<CR>a
	inoremap ' x<Esc>:call UniCycleApostrophe()<CR>a
	inoremap " x<Esc>:call UniCycleQuote()<CR>a
endfunction

function! UniCycleOff()
	iunmap -
	iunmap .
	iunmap '
	iunmap "
endfunction

command UniCycleOn call UniCycleOn()
command UniCycleOff call UniCycleOff()

