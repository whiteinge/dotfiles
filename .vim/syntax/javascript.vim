" The default javascript syntax works well enough for ES2015 for my taste,
" minus the missing string template syntax. The syntax below was stolen from:
" https://github.com/othree/yajs.vim

syntax region  javascriptTemplateSubstitution  contained matchgroup=javascriptTemplateSB start=/\${/ end=/}/ contains=@javascriptExpression
syntax region  javascriptTemplateSBlock        contained start=/{/ end=/}/ contains=javascriptTemplateSBlock,javascriptTemplateSString transparent
syntax region  javascriptTemplateSString       contained start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1\|$/ extend contains=javascriptTemplateSStringRB transparent
syntax match   javascriptTemplateSStringRB     /}/ contained 
syntax region  javascriptTemplate              start=/`/  skip=/\\\\\|\\`\|\n/  end=/`\|$/ contains=javascriptTemplateSubstitution nextgroup=@javascriptComments,@javascriptSymbols skipwhite skipempty

syntax cluster javascriptTemplates             contains=javascriptTemplate,javascriptTemplateSubstitution,javascriptTemplateSBlock,javascriptTemplateSString,javascriptTemplateSStringRB,javascriptTemplateSB

hi def link javascriptTemplate             String
hi def link javascriptTemplateSubstitution Label
hi def link javascriptTemplateSStringRB    javascriptTemplateSubstitution
hi def link javascriptTemplateSB           javascriptTemplateSubstitution
