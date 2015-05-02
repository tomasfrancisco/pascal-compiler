all: mpasemantic.zip mpasemantic

mpasemantic.zip: mpasemantic.y mpasemantic.l semantic.c semantic.h ast.c ast.h symbol_table.c symbol_table.h
	zip mpasemantic.zip mpasemantic.y mpasemantic.l semantic.c semantic.h ast.c ast.h symbol_table.c symbol_table.h

mpasemantic: lex.yy.c y.tab.c ast.c symbol_table.c semantic.c
	gcc -o mpasemantic y.tab.c lex.yy.c ast.c symbol_table.c semantic.c -ll -ly

y.tab.c: mpasemantic.y
	yacc -v -o y.tab.c -d mpasemantic.y

lex.yy.c: mpasemantic.l
	lex -o lex.yy.c mpasemantic.l
