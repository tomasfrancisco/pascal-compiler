digit 		[0-9]
letter 		[a-z]
exponent	"e"[+-]?{digit}+

%{
	#include "stdio.h"
	#include "y.tab.h"
	#include "string.h"

	#define YY_USER_ACTION col += yyleng; token = yytext;

 	int line = 1, col = 1;
	char * token ="";
	int start_line_commment = 1, start_column_comment = 1;

%}
%option case-insensitive

%X COMMENT_STATE

%%

"(*"|"{"										{start_column_comment = col; start_line_commment = line; BEGIN(COMMENT_STATE);}
<COMMENT_STATE>("*)"|"}")						{BEGIN(0);}
<COMMENT_STATE>.								{;}
<COMMENT_STATE>\n 								{line++; col = 1;}
<COMMENT_STATE><<eof>>							{printf("Line %d, col %d: unterminated comment\n", start_line_commment, start_column_comment); BEGIN(0);}

"abs"|"arctan"|"array"|"case"|"char"|"chr"|"const"|"cos"|"dispose"|"downto"|"eof"|"eoln"|"exp"|"file"|"for"|"get"|"goto"|"in"|"input"|"label"|"ln"|"maxint"|"new"|"nil"|"odd"|"of"|"ord"|"pack"|"packed"|"page"|"pred"|"procedure"|"put"|"read"|"readln"|"record"|"reset"|"rewrite"|"round"|"set"|"sin"|"sqr"|"sqrt"|"succ"|"text"|"to"|"trunc"|"type"|"unpack"|"with"|"write" {printf("RESERVED(%s)\n", yytext);}

":="											{return ASSIGN;																		}
"begin"											{																return BEGINTOKEN;	}
":"												{yylval.ch=yytext[0]; 											return COLON;		}
","												{yylval.ch=yytext[0];											return COMMA;		}
"do"											{			 													return DO;			}
"."												{yylval.ch=yytext[0];											return DOT;			}
"else"											{			 													return ELSE;		}
"end"											{			 			 										return END;			}
"forward"										{				 		 										return FORWARD;		}
"function"										{				 												return FUNCTION;	}
"if"											{			 			 										return IF;			}
"("												{yylval.ch=yytext[0];											return LBRAC;		}
"not"											{			 			 										return NOT; 		}
"output"										{				 		 										return OUTPUT;		}
"paramstr"										{				 												return PARAMSTR;	}
"program"										{				 		 										return PROGRAM;		}
")"												{yylval.ch=yytext[0]; 											return RBRAC;		}
"repeat"										{				 		 										return REPEAT; 		}
";"												{yylval.ch=yytext[0];											return SEMIC;		}
"then"											{			 													return THEN;		}
"until"											{				 												return UNTIL;		}
"val"											{			 			 										return VAL; 		}
"var"											{			 			 										return VAR;			}
"while"											{				 		 										return WHILE; 		}
"writeln"										{				 		 										return WRITELN; 	}
"and"											{yylval.str=strdup(yytext);										return AND;			}
"or"											{yylval.str=strdup(yytext);										return OR;			}
"<>"											{yylval.str=strdup(yytext);										return DIFF;		}
"<="											{yylval.str=strdup(yytext);										return LESSEQUAL;	}
">="											{yylval.str=strdup(yytext); 									return MOREEQUAL;	}
"+"|"-"|"<"|">"|"="|"*"|"/"						{yylval.str=strdup(yytext); 	yylval.ch=yytext[0]; 			return yytext[0];	}
"mod"											{yylval.str=strdup(yytext);										return MOD;			}
"div"											{yylval.str=strdup(yytext);										return DIV;			}
{letter}+({digit}|{letter})*					{yylval.str=strdup(yytext); 									return ID;			}
{digit}+(("."{digit}+{exponent}?)|({exponent}))	{yylval.str=strdup(yytext); 									return REALLIT;		}
'([^'\n]|'')*'									{yylval.str=strdup(yytext);										return STRING;		}
{digit}+										{yylval.i=atoi(yytext);											return INTLIT;		}
'([^'\n]|'')*									{printf("Line %d, col %d: unterminated string\n", line, col); 						}
\n 												{line++; 					col = 0;												}
[ \t]											{;																					}
.												{printf("Line %d, col %d: illegal character ('%c')\n", line, col, yytext[0]);		}
%%

int yywrap() {
	return 1;
}
