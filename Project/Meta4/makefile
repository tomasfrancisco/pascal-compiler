all: mpacompiler.zip mpacompiler

mpacompiler.zip: mpacompiler.y mpacompiler.l semantic.c semantic.h ast.c ast.h symbol_table.c symbol_table.h
	zip mpacompiler.zip mpacompiler.y mpacompiler.l semantic.c semantic.h ast.c ast.h symbol_table.c symbol_table.h

mpacompiler: lex.yy.c y.tab.c ast.c symbol_table.c semantic.c
	gcc -o mpacompiler y.tab.c lex.yy.c ast.c symbol_table.c semantic.c -ll -ly

y.tab.c: mpacompiler.y
	yacc -v -o y.tab.c -d mpacompiler.y

lex.yy.c: mpacompiler.l
	lex -o lex.yy.c mpacompiler.l
