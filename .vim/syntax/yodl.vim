" Vim syntax file
" Language:	yo Yodl
" Maintainer:	Josef Spillner <josef@ggzgamingzone.org>
" URL:		http://mindx.dyndns.org/download/yodl.vim
" Email:	Subject: whatever
" Last Change:	2003 Sep 28
"
" Based on php.vim

" For version 6.x: Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'yodl'
endif

" Function names
syn match	yodlFunctions	"ADDTOCOUNTER"
syn match	yodlFunctions	"ATEXIT"
syn match	yodlFunctions	"CHAR"
syn match	yodlFunctions	"CHDIR"
syn match	yodlFunctions	"COMMENT"
syn match	yodlFunctions	"COUNTERVALUE"
syn match	yodlFunctions	"DEFINECHARTABLE"
syn match	yodlFunctions	"DEFINEMACRO"
syn match	yodlFunctions	"DEFINESYMBOL"
syn match	yodlFunctions	"DUMMY"
syn match	yodlFunctions	"ENDDEF"
syn match	yodlFunctions	"ERROR"
syn match	yodlFunctions	"IFDEF"
syn match	yodlFunctions	"IFEMPTY"
syn match	yodlFunctions	"IFSTREQUAL"
syn match	yodlFunctions	"IFSTRSUB"
syn match	yodlFunctions	"IFZERO"
syn match	yodlFunctions	"INCLUDEFILE"
syn match	yodlFunctions	"INCLUDELITERAL"
syn match	yodlFunctions	"NEWCOUNTER"
syn match	yodlFunctions	"NOEXPAND"
syn match	yodlFunctions	"NOTRANS"
syn match	yodlFunctions	"NOUSERMACRO"
syn match	yodlFunctions	"PARAGRAPH"
syn match	yodlFunctions	"PIPETHROUGH"
syn match	yodlFunctions	"POPCHARTABLE"
syn match	yodlFunctions	"PUSHCHARTABLE"
syn match	yodlFunctions	"RENAMEMACRO"
syn match	yodlFunctions	"SETCOUNTER"
syn match	yodlFunctions	"SUBST"
syn match	yodlFunctions	"STARTDEF"
syn match	yodlFunctions	"SYSTEM"
syn match	yodlFunctions	"TYPEOUT"
syn match	yodlFunctions	"UNDEFINEMACRO"
syn match	yodlFunctions	"UNDEFINESYMBOL"
syn match	yodlFunctions	"UPPERCASE"
syn match	yodlFunctions	"USECHARTABLE"
syn match	yodlFunctions	"USECOUNTER"
syn match	yodlFunctions	"WARNING"

" Operator
syn match	yodlOperator	"+"
syn match	yodlOperator	"\\"
syn match	yodlOperator	"("
syn match	yodlOperator	")"

" Macros
syn match	yodlMacro	"\<var\>"
syn match	yodlMacro	"\<tt\>"
syn match	yodlMacro	"\<example\>"
syn match	yodlMacro	"\<subsect\>"
syn match	yodlMacro	"\<sect\>"
syn match	yodlMacro	"\<chapter\>"
syn match	yodlMacro	"\<kindex\>"
syn match	yodlMacro	"\<vindex\>"
syn match	yodlMacro	"\<findex\>"
syn match	yodlMacro	"\<cindex\>"
syn match	yodlMacro	"\<item\>"
syn match	yodlMacro	"\<menu\>"
syn match	yodlMacro	"\<startmenu\>"
syn match	yodlMacro	"\<endmenu\>"
syn match	yodlMacro	"\<texinode\>"
syn match	yodlMacro	"\<ifzman\>"
syn match	yodlMacro	"\<ifnzman\>"
syn match	yodlMacro	"\<zmanref\>"
syn match	yodlMacro	"\<noderef\>"
syn match	yodlMacro	"\<startsitem\>"
syn match	yodlMacro	"\<sitem\>"
syn match	yodlMacro	"\<endsitem\>"
syn match	yodlMacro	"\<startitem\>"
syn match	yodlMacro	"\<enditem\>"
syn match	yodlMacro	"\<article\>"
syn match	yodlMacro	"\<latexcommand\>"
syn match	yodlMacro	"\<whenlatex\>"

" Define the default highlighting.
command -nargs=+ HiLink hi def link <args>

HiLink	yodlFunctions	Constant
HiLink	yodlOperator	Function
HiLink	yodlMacro	Macro

delcommand HiLink

let b:current_syntax = "yodl"

if main_syntax == 'yodl'
  unlet main_syntax
endif

" vim: ts=8
