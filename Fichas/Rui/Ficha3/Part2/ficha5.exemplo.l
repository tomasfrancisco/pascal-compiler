%{
#include "y.tab.h"
%}
%%
[0-9]+		{yylval.value=atoi(yytext);
		return NUMBER;}
[A-z][A-z0-9_]*  {yylval.id=(char*)strdup(yytext); 
                  return VAR;}  
[ \t]	;
\n	| 
. 	return yytext[0];
%%
int yywrap()
{
return 1;
}


