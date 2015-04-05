%{

#include<stdio.h>
%}
%token NUMBER

%% 
calc: 		expression 			{printf("%d\n", $1);}

expression:	expression '+' expression   	{$$=$1+$3;}
	| 	expression '-' expression  	{$$=$1-$3;}
	| 	expression '/' expression  	{$$=$1/$3;}
	| 	expression '*' expression  	{$$=$1*$3;}
	| 	NUMBER				{$$=$1;}
	;

%%
int main()
{
yyparse();

}
