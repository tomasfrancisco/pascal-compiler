digit 		[0-9]
letter 		[a-z]
exponent	"e"[+-]?{digit}+

%option case-insensitive

%%


"abs"|"arctan"|"array"|"case"|"char"|"chr"|"const"|"cos"|"dispose"|"downto"|"eof"|"eoln"|"exp"|"file"|"for"|"get"|"goto"|"in"|"input"|"label"|"ln"|"maxint"|"new"|"nil"|"odd"|"of"|"ord"|"pack"|"packed"|"page"|"pred"|"procedure"|"put"|"read"|"readln"|"record"|"reset"|"rewrite"|"round"|"set"|"sin"|"sqr"|"sqrt"|"succ"|"text"|"to"|"trunc"|"type"|"unpack"|"with"|"write" {printf("RESERVED(%s)\n", yytext);}

":="											{printf("ASSIGN\n");}
"begin"											{printf("BEGIN\n");}
":"												{printf("COLON\n");}
","												{printf("COMMA\n");}
"do"											{printf("DO\n");}
"."												{printf("DOT\n");}
"else"											{printf("ELSE\n");}
"end"											{printf("END\n");}
"forward"										{printf("FORWARD\n");}
"function"										{printf("FUNCTION\n");}
"if"											{printf("IF\n");}
"("												{printf("LBRAC\n");}
"not"											{printf("NOT\n");}
"output"										{printf("OUTPUT\n");}
"paramstr"										{printf("PARAMSTR\n");}
"program"										{printf("PROGRAM\n");}
")"												{printf("RBRAC\n");}
"repeat"										{printf("REPEAT\n");}
";"												{printf("SEMIC\n");}
"then"											{printf("THEN\n");}
"until"											{printf("UNTIL\n");}
"val"											{printf("VAL\n");}
"var"											{printf("VAR\n");}
"while"											{printf("WHILE\n");}
"writeln"										{printf("WRITELN\n");}
"and"|"or"										{printf("OP1(%s)\n", yytext);}
"<"|">"|"="|"<>"|"<="|">="						{printf("OP2(%s)\n", yytext);}
"+"|"-"											{printf("OP3(%s)\n", yytext);}
"*"|"/"|"mod"|"div"								{printf("OP4(%s)\n", yytext);}
{letter}+[{digit}|{letter}]*					{printf("ID(%s)\n", yytext);}
{digit}+(.{digit}+{exponent}?)|({exponent})		{printf("REALLIT\n");}
{digit}+										{printf("INTLIT\n");}
"'"(.|("''"."''"))*"'"							{printf("STRING(%s)\n", yytext);}
[\t\n\r]										;
.												;


%%
int main() {
	yylex();
	return 0;
}

int yywrap() {
	return 1;
}