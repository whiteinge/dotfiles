" Vim syntax file
" Language:	Markdown
" Maintainer:	Ben Williams <benw@plasticboy.com>
" URL:		http://plasticboy.com/markdown-vim-mode/
" Version:	6
" Last Change:  2006 September 1
" Remark:	Uses HTML syntax file
" Remark:	I don't do anything with angle brackets (<>) because that would too easily
"		easily conflict with HTML syntax
" TODO: 	Do something appropriate with image syntax
" TODO: 	Handle stuff contained within stuff (e.g. headings within blockquotes)


" Read the HTML syntax to start with
if version < 600
  so <sfile>:p:h/html.vim
else
  runtime! syntax/html.vim
  unlet b:current_syntax
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" don't use standard HiLink, it will not work with included syntax files
if version < 508
  command! -nargs=+ HtmlHiLink hi link <args>
else
  command! -nargs=+ HtmlHiLink hi def link <args>
endif

syn spell toplevel
syn case ignore
syn sync linebreaks=1

"additions to HTML groups
syn region htmlBold     start=/\*\@<!\*\*\*\@!/     end=/\*\@<!\*\*\*\@!/   contains=@Spell,htmlItalic
syn region htmlItalic   start=/\*\@<!\*\*\@!/       end=/*\@<!\*\*\@!/      contains=htmlBold 
syn region htmlBold     start=/_\@<!___\@!/         end=/_\@<!___\@!/       contains=htmlItalic
syn region htmlItalic   start=/_\@<!__\@!/          end=/_\@<!__\@!/        contains=htmlBold 
syn region htmlString   start="]("ms=s+2             end=")"me=e-1
syn region htmlLink     start="\["ms=s+1            end="\]"me=e-1
syn region htmlString   start="\(\[.*]: *\)\@<=.*"  end="$"

"define Markdown groups
syn match  mkdLineContinue ".$" contained
syn match  mkdRule      /^\s*\*\s\{0,1}\*\s\{0,1}\*$/
syn match  mkdRule      /^\s*-\s\{0,1}-\s\{0,1}-$/
syn match  mkdRule      /^\s*_\s\{0,1}_\s\{0,1}_$/
syn match  mkdRule      /^\s*-\{3,}$/
syn match  mkdRule      /^\s*\*\{3,5}$/
syn match  mkdListItem  "^\s*[-*+]\s\+"
syn match  mkdListItem  "^\s*\d\+\.\s\+"
syn match  mkdCode      /^\(\s\{4,}\|[\t]\+\)[^*-+ ].*$/
syn region mkdCode      start=/`/                   end=/`/
syn region mkdCode      start=/\s*``[^`]*/ skip=/`/ end=/[^`]*``\s*/
syn region mkdBlockquote start=/^\s*>/              end=/$/                 contains=mkdLineContinue

"HTML headings
syn region htmlH1       start="#"                   end="\($\|#\+\)"
syn region htmlH2       start="##"                  end="\($\|#\+\)"
syn region htmlH3       start="###"                 end="\($\|#\+\)"
syn region htmlH4       start="####"                end="\($\|#\+\)"
syn region htmlH5       start="#####"               end="\($\|#\+\)"
syn region htmlH6       start="######"              end="\($\|#\+\)"
syn match  htmlH1       /^.\+\n=\+$/
syn match  htmlH2       /^.\+\n-\+$/

"highlighting for Markdown groups
HtmlHiLink mkdString	    String
HtmlHiLink mkdCode          String
HtmlHiLink mkdBlockquote    Comment
HtmlHiLink mkdLineContinue  Comment
HtmlHiLink mkdListItem      Identifier
HtmlHiLink mkdRule          Identifier


let b:current_syntax = "mkd"

delcommand HtmlHiLink
" vim: ts=8
