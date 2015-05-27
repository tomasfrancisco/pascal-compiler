all: mpacompiler.zip mpacompiler

mpacompiler.zip: mpacompiler.y mpacompiler.l semantic.c semantic.h ast.c ast.h symbol_table.c symbol_table.h compiler.c compiler.h
	zip mpacompiler.zip mpacompiler.y mpacompiler.l semantic.c semantic.h ast.c ast.h symbol_table.c symbol_table.h compiler.c compiler.h

mpacompiler: lex.yy.c y.tab.c ast.c symbol_table.c semantic.c compiler.c
	gcc -o mpacompiler y.tab.c lex.yy.c ast.c symbol_table.c semantic.c compiler.c -ll -ly

y.tab.c: mpacompiler.y
	yacc -v -o y.tab.c -d mpacompiler.y

lex.yy.c: mpacompiler.l
	lex -o lex.yy.c mpacompiler.l
