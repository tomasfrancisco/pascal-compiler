all: mpaparser.zip mpaparser

mpaparser.zip: mpaparser.y mpaparser.l ast.c ast.h
	zip mpaparser.zip mpaparser.y mpaparser.l ast.c ast.h

mpaparser: lex.yy.c y.tab.c ast.c
	gcc -o mpaparser y.tab.c lex.yy.c ast.c  -ll -ly

y.tab.c: mpaparser.y
	yacc -v -o y.tab.c -d mpaparser.y

lex.yy.c: mpaparser.l
	lex -o lex.yy.c mpaparser.l
