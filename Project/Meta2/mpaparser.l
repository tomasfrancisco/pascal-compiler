digit 		[0-9]
letter 		[a-z]
exponent	"e"[+-]?{digit}+

%{
	#include "stdio.h"
	#include "y.tab.h"
	#include "string.h"
 	int line = 1, col = 1;
	char * token ="";
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

":="											{token="ASSIGN"; col += yyleng;  return ASSIGN;}
"begin"											{ token="BEGINTOKEN"; col += yyleng;  return BEGINTOKEN;}
":"												{ token="COLON"; yylval.ch=yytext[0]; col += yyleng;  return COLON;}
","												{ token="COMMA"; yylval.ch=yytext[0]; col += yyleng; return COMMA;}
"do"											{ token="DO"; col += yyleng; return DO;}
"."												{ token="DOT"; yylval.ch=yytext[0]; col += yyleng; return DOT;}
"else"											{ token="ELSE"; col += yyleng; return ELSE;}
"end"											{ token="END"; col += yyleng; return END;}
"forward"										{ token="FORWARD"; col += yyleng; return FORWARD;}
"function"										 token="FUNCTION"; col += yyleng; {return FUNCTION;}
"if"											{ token="IF"; col += yyleng; return IF;}
"("												{ token="LBRAC"; yylval.ch=yytext[0]; col += yyleng; return LBRAC;}
"not"											{token="NOT"; col += yyleng; return NOT; }
"output"										{ token="OUTPUT"; col += yyleng; return OUTPUT;}
"paramstr"										{ token="PARAMSTR"; col += yyleng; return PARAMSTR;}
"program"										{ token="PROGRAM"; col += yyleng; return PROGRAM;}
")"												{ token="RBRAC"; yylval.ch=yytext[0]; col += yyleng; return RBRAC;}
"repeat"										{token="REPEAT"; col += yyleng; return REPEAT; }
";"												{ token="SEMIC"; yylval.ch=yytext[0]; col += yyleng; return SEMIC;}
"then"											{ token="THEN"; col += yyleng; return THEN;}
"until"											{ token="UNTIL"; col += yyleng; return UNTIL;}
"val"											{token="VAL"; col += yyleng; return VAL; }
"var"											{ token="VAR"; col += yyleng; return VAR;}
"while"											{token="WHILE"; col += yyleng; return WHILE; }
"writeln"										{token="WRITELN"; col += yyleng; return WRITELN; }
"and"											{ token="AND"; yylval.str=strdup(yytext); col += yyleng; return AND;}
"or"											{ token="OR"; yylval.str=strdup(yytext); col += yyleng; return OR;}
"<>"											{ token="DIFF"; yylval.str=strdup(yytext); col += yyleng; return DIFF;}
"<="											{ token="LESSEQUAL"; yylval.str=strdup(yytext); col += yyleng; return LESSEQUAL;}
">="											{ token="MOREEQUAL"; yylval.str=strdup(yytext); col += yyleng; return MOREEQUAL;}
"+"|"-"|"<"|">"|"="|"*"|"/"						{ yylval.str=strdup(yytext); yylval.ch=yytext[0]; col += yyleng; return yytext[0];}
"mod"											{ token="MOD"; yylval.str=strdup(yytext); col += yyleng; return MOD;}
"div"											{token="DIV"; yylval.str=strdup(yytext);; col += yyleng; return DIV; }
{letter}+({digit}|{letter})*					{token="ID"; yylval.str=strdup(yytext); col += yyleng; return ID; }
{digit}+(("."{digit}+{exponent}?)|({exponent}))	{ token="REALLIT"; yylval.str=strdup(yytext); col += yyleng; return REALLIT;}
'([^'\n]|'')*'									{ token="STRING"; yylval.str=strdup(yytext); col += yyleng; return STRING;}
{digit}+										{ token="INTLIT"; yylval.i=atoi(yytext); col += yyleng; return INTLIT;}
'([^'\n]|'')*									{printf("Line %d, col %d: unterminated string\n", line, col); col += yyleng; }
\n 												{line++; col = 1;}
[ \t]											{col++;}
.												{printf("Line %d, col %d: illegal character ('%c')\n", line, col, yytext[0]); col += yyleng;}


%%

int yywrap() {
	return 1;
}
