all: mpaparser mpaparser.zip

mpaparser.zip:
	zip mpaparser.zip mpaparser.y mpaparser.l

mpaparser: lex.yy.c y.tab.c
	cc -o mpaparser y.tab.c lex.yy.c -ll -ly

y.tab.c: mpaparser.y
	yacc -v -o y.tab.c -d mpaparser.y

lex.yy.c: mpaparser.l
	lex -o lex.yy.c mpaparser.l
