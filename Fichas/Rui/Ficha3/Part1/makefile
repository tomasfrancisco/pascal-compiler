all: mycalc

mycalc: lex.yy.c y.tab.c
	cc -o mycalc y.tab.c lex.yy.c -ll -ly

y.tab.c: mycalc.y
	yacc -o y.tab.c -d mycalc.y

lex.yy.c: mycalc.l
	lex -o lex.yy.c mycalc.l
