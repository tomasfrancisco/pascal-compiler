digit 		[0-9]
letter 		[a-z]
exponent	"e"[+-]?{digit}+

%{
	int line = 1, col = 1;
	int start_line_commment = 1, start_column_comment = 1;
%}

%option case-insensitive

%X COMMENT_STATE

%%

"(*"|"{"										{start_column_comment = col; start_line_commment = line; col += yyleng; BEGIN(COMMENT_STATE);}
<COMMENT_STATE>("*)"|"}")						{ col += yyleng; BEGIN(0);}
<COMMENT_STATE>.								{col += yyleng;}
<COMMENT_STATE>\n 								{line++; col = 1;}
<COMMENT_STATE><<eof>>							{printf("Line %d, col %d: unterminated comment\n", start_line_commment, start_column_comment); BEGIN(0);}

"abs"|"arctan"|"array"|"case"|"char"|"chr"|"const"|"cos"|"dispose"|"downto"|"eof"|"eoln"|"exp"|"file"|"for"|"get"|"goto"|"in"|"input"|"label"|"ln"|"maxint"|"new"|"nil"|"odd"|"of"|"ord"|"pack"|"packed"|"page"|"pred"|"procedure"|"put"|"read"|"readln"|"record"|"reset"|"rewrite"|"round"|"set"|"sin"|"sqr"|"sqrt"|"succ"|"text"|"to"|"trunc"|"type"|"unpack"|"with"|"write" {printf("RESERVED(%s)\n", yytext); col += yyleng;}

":="											{printf("ASSIGN\n"); col += yyleng;}
"begin"											{printf("BEGIN\n"); col += yyleng;}
":"												{printf("COLON\n"); col += yyleng;}
","												{printf("COMMA\n"); col += yyleng;}
"do"											{printf("DO\n"); col += yyleng;}
"."												{printf("DOT\n"); col += yyleng;}
"else"											{printf("ELSE\n"); col += yyleng;}
"end"											{printf("END\n"); col += yyleng;}
"forward"										{printf("FORWARD\n"); col += yyleng;}
"function"										{printf("FUNCTION\n"); col += yyleng;}
"if"											{printf("IF\n"); col += yyleng;}
"("												{printf("LBRAC\n"); col += yyleng;}
"not"											{printf("NOT\n"); col += yyleng;}
"output"										{printf("OUTPUT\n"); col += yyleng;}
"paramstr"										{printf("PARAMSTR\n"); col += yyleng;}
"program"										{printf("PROGRAM\n"); col += yyleng;}
")"												{printf("RBRAC\n"); col += yyleng;}
"repeat"										{printf("REPEAT\n"); col += yyleng;}
";"												{printf("SEMIC\n"); col += yyleng;}
"then"											{printf("THEN\n"); col += yyleng;}
"until"											{printf("UNTIL\n"); col += yyleng;}
"val"											{printf("VAL\n"); col += yyleng;}
"var"											{printf("VAR\n"); col += yyleng;}
"while"											{printf("WHILE\n"); col += yyleng;}
"writeln"										{printf("WRITELN\n"); col += yyleng;}
"and"|"or"										{printf("OP1(%s)\n", yytext); col += yyleng;}
"<"|">"|"="|"<>"|"<="|">="						{printf("OP2(%s)\n", yytext); col += yyleng;}
"+"|"-"											{printf("OP3(%s)\n", yytext); col += yyleng;}
"*"|"/"|"mod"|"div"								{printf("OP4(%s)\n", yytext); col += yyleng;}
{letter}+({digit}|{letter})*					{printf("ID(%s)\n", yytext); col += yyleng;}
{digit}+(("."{digit}+{exponent}?)|({exponent}))	{printf("REALLIT(%s)\n", yytext); col += yyleng;}
{digit}+										{printf("INTLIT(%s)\n", yytext); col += yyleng;}
'([^'\n]|'')*'									{printf("STRING(%s)\n", yytext); col += yyleng;}
'([^'\n]|'')*									{printf("Line %d, col %d: unterminated string\n", line, col); col += yyleng;}	
\n 												{line++; col = 1;}
[ \t]											{col++;}
.												{printf("Line %d, col %d: illegal character ('%c')\n", line, col, yytext[0]); col += yyleng;}


%%
int main() {
	yylex();
	return 0;
}

int yywrap() {
	return 1;
}