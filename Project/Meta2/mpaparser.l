digit 		[0-9]
letter 		[a-z]
exponent	"e"[+-]?{digit}+

%{
	#include "stdio.h"
	#include "y.tab.h"
	#include "string.h"

	#define YY_USER_ACTION col += yyleng;

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

":="											{token="ASSIGN";  										return ASSIGN;		}
"begin"											{token="BEGINTOKEN"; 									return BEGINTOKEN;	}
":"												{token="COLON"; 			yylval.ch=yytext[0]; 		return COLON;		}
","												{token="COMMA"; 			yylval.ch=yytext[0];		return COMMA;		}
"do"											{token="DO"; 											return DO;			}
"."												{token="DOT"; 			 	yylval.ch=yytext[0];		return DOT;			}
"else"											{token="ELSE"; 											return ELSE;		}
"end"											{token="END"; 			 								return END;			}
"forward"										{token="FORWARD"; 		 								return FORWARD;		}
"function"										{token="FUNCTION"; 										return FUNCTION;	}
"if"											{token="IF"; 			 								return IF;			}
"("												{token="LBRAC"; 		 	yylval.ch=yytext[0];		return LBRAC;		}
"not"											{token="NOT"; 			 								return NOT; 		}
"output"										{token="OUTPUT"; 		 								return OUTPUT;		}
"paramstr"										{token="PARAMSTR"; 										return PARAMSTR;	}
"program"										{token="PROGRAM"; 		 								return PROGRAM;		}
")"												{token="RBRAC"; 			yylval.ch=yytext[0]; 		return RBRAC;		}
"repeat"										{token="REPEAT"; 		 								return REPEAT; 		}
";"												{token="SEMIC";  		 	yylval.ch=yytext[0];		return SEMIC;		}
"then"											{token="THEN"; 											return THEN;		}
"until"											{token="UNTIL"; 										return UNTIL;		}
"val"											{token="VAL"; 			 								return VAL; 		}
"var"											{token="VAR"; 			 								return VAR;			}
"while"											{token="WHILE"; 		 								return WHILE; 		}
"writeln"										{token="WRITELN"; 		 								return WRITELN; 	}
"and"											{token="AND";  			 	yylval.str=strdup(yytext);	return AND;			}
"or"											{token="OR";  			 	yylval.str=strdup(yytext);	return OR;			}
"<>"											{token="DIFF";  		 	yylval.str=strdup(yytext);	return DIFF;		}
"<="											{token="LESSEQUAL";  	 	yylval.str=strdup(yytext);	return LESSEQUAL;	}
">="											{token="MOREEQUAL";  	 	yylval.str=strdup(yytext); 	return MOREEQUAL;	}
"+"|"-"|"<"|">"|"="|"*"|"/"						{yylval.str=strdup(yytext); yylval.ch=yytext[0]; 		return yytext[0];	}
"mod"											{token="MOD";  			 	yylval.str=strdup(yytext);	return MOD;			}
"div"											{token="DIV";				yylval.str=strdup(yytext);	return DIV;			}
{letter}+({digit}|{letter})*					{token="ID";  			 	yylval.str=strdup(yytext); 	return ID;			}
{digit}+(("."{digit}+{exponent}?)|({exponent}))	{token="REALLIT"; 		 	yylval.str=strdup(yytext); 	return REALLIT;		}
'([^'\n]|'')*'									{token="STRING";  		 	yylval.str=strdup(yytext);	return STRING;		}
{digit}+										{token="INTLIT";  		 	yylval.i=atoi(yytext);		return INTLIT;		}
'([^'\n]|'')*									{printf("Line %d, col %d: unterminated string\n", line, col); 				}
\n 												{line++; 					col = 0;										}
[ \t]											{;																			}
.												{printf("Line %d, col %d: illegal character ('%c')\n", line, col, yytext[0]);}
%%

int yywrap() {
	return 1;
}
