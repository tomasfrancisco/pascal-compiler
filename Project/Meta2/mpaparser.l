digit 		[0-9]
letter 		[a-z]
exponent	"e"[+-]?{digit}+

%{
	#include "stdio.h"
	#include "y.tab.h"
	#include "string.h"

	#define YY_USER_ACTION col += yyleng;

 	int line = 1, col = 0;
	char * token ="";
	int start_line_commment = 0, start_column_comment = 0;

%}
%option case-insensitive

%X COMMENT_STATE

%%

"(*"|"{"										{start_column_comment = col; start_line_commment = line; BEGIN(COMMENT_STATE);}
<COMMENT_STATE>"*)"|"}"							{BEGIN(INITIAL); start_line_commment = 0; start_column_comment = 0;}
<COMMENT_STATE>.								{;}
<COMMENT_STATE>\n 								{line++; col = 0;}
<COMMENT_STATE><<eof>>							{printf("Line %d, col %d: unterminated comment\n", start_line_commment, start_column_comment); BEGIN(INITIAL); start_column_comment = 0; start_line_commment = 0;}

"abs"|"arctan"|"array"|"case"|"char"|"chr"|"const"|"cos"|"dispose"|"downto"|"eof"|"eoln"|"exp"|"file"|"for"|"get"|"goto"|"in"|"input"|"label"|"ln"|"maxint"|"new"|"nil"|"odd"|"of"|"ord"|"pack"|"packed"|"page"|"pred"|"procedure"|"put"|"read"|"readln"|"record"|"reset"|"rewrite"|"round"|"set"|"sin"|"sqr"|"sqrt"|"succ"|"text"|"to"|"trunc"|"type"|"unpack"|"with"|"write" {return RESERVED;}

":="											{																return ASSIGN;		}
"begin"											{																return BEGINTOKEN;	}
":"												{			 		 											return COLON;		}
","												{			 													return COMMA;		}
"do"											{			 													return DO;			}
"."												{			 													return DOT;			}
"else"											{			 													return ELSE;		}
"end"											{			 			 										return END;			}
"forward"										{				 		 										return FORWARD;		}
"function"										{				 												return FUNCTION;	}
"if"											{			 			 										return IF;			}
"("												{			 													return LBRAC;		}
"not"											{			 			 										return NOT; 		}
"output"										{				 		 										return OUTPUT;		}
"paramstr"										{				 												return PARAMSTR;	}
"program"										{				 		 										return PROGRAM;		}
")"												{					 											return RBRAC;		}
"repeat"										{				 		 										return REPEAT; 		}
";"												{																return SEMIC;		}
"then"											{			 													return THEN;		}
"until"											{				 												return UNTIL;		}
"val"											{			 			 										return VAL; 		}
"var"											{			 			 										return VAR;			}
"while"											{				 		 										return WHILE; 		}
"writeln"										{				 		 										return WRITELN; 	}
"and"											{																return AND;			}
"or"											{																return OR;			}
"<>"											{																return DIFF;		}
"<="											{																return LESSEQUAL;	}
">="											{							 									return MOREEQUAL;	}
"+"|"-"|"<"|">"|"="|"*"|"/"						{													 			return yytext[0];	}
"mod"											{																return MOD;			}
"div"											{																return DIV;			}
{letter}+({digit}|{letter})*					{yylval.str=strdup(yytext); 									return ID;			}
{digit}+(("."{digit}+{exponent}?)|({exponent}))	{yylval.str=strdup(yytext); 									return REALLIT;		}
'([^'\n]|'')*'									{yylval.str=strdup(yytext);										return STRING;		}
{digit}+										{yylval.i=atoi(yytext);											return INTLIT;		}
'([^'\n]|'')*									{printf("Line %d, col %d: unterminated string\n", line, col - ((int)yyleng - 1)); 						}
\n 												{line++; 					col = 0;												}
[ \t]											{;																					}
.												{printf("Line %d, col %d: illegal character ('%c')\n", line, col, yytext[0]);		}
%%

int yywrap() {
	return 1;
}
