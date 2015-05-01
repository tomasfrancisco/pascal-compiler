all: mpaparser.zip mpaparser

mpaparser.zip: mpaparser.y mpaparser.l
	zip mpaparser.zip mpaparser.y mpaparser.l

mpaparser: lex.yy.c y.tab.c ast.c symbol_table.c semantic.c
	gcc -o mpaparser y.tab.c lex.yy.c ast.c symbol_table.c semantic.c -ll -ly

y.tab.c: mpaparser.y
	yacc -v -o y.tab.c -d mpaparser.y

lex.yy.c: mpaparser.l
	lex -o lex.yy.c mpaparser.l
