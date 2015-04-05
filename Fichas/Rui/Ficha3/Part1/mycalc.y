%{

#include<stdio.h>
int end=0;
int error=0;
%}
%token NUMBER
%token END


%left '+' '-'
%left '*' '/'

%%
calc: 		expression 			{presult($1);}

expression:	expression '+' expression   	{$$=$1+$3;}
	| 	expression '-' expression  	{$$=$1-$3;}
	| 	expression '/' expression  	{if($3==0){
										yyerror("Divide by zero!");
										error = 1;
									}else $$=$1/$3;}
	| 	expression '*' expression  	{$$=$1*$3;}
	| 	NUMBER				{$$=$1;}
	|	'-'NUMBER			{$$=-$2;}
	|  '(' expression ')' 	{$$=$2;}
	|  	END 				{end=1;}
	;

%%

int presult(int res){
	if(error){error=0;}
	else printf("%d\n",res);
}

int main()
{
	while(!end){
		yyparse();
	}
}
