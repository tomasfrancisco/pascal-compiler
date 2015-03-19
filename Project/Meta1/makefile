all: mpascanner.zip mpascanner

mpascanner.zip: mpascanner.l
	zip mpascanner.zip mpascanner.l

mpascanner: mpascanner.c
	gcc -o mpascanner mpascanner.c -ll

mpascanner.c: mpascanner.l
	lex -o mpascanner.c mpascanner.l