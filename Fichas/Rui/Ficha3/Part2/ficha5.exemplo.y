%{
#include <stdio.h>
#include "symtab.h"
#define NSYMS 100

symtab tab[NSYMS];

symtab *symlook(char *varname);
%}

%token <id> VAR 
%token <value> NUMBER

%union{
int value;
char* id;
}

%%
statement: expression '\n'  
	| statement expression '\n'
	;

 
expression: 
	VAR '=' NUMBER {symlook($1)->value = $3;}	/*Guarda valor da variavel*/
	| VAR	{printf("o valor da variavel %s e' %d\n", symlook($1)->name, symlook($1)->value);} /*Reproduz o valor*/
	;
%%
int yyerror (char *s)
{
printf ("%s\n", s);
}

int main()
{
yyparse();
return 0;
}

symtab *symlook(char *varname)
{
int i;
  
for(i=0; i<NSYMS; i++)
 {
        if(tab[i].name && strcmp(varname, tab[i].name)==0)   
                return &tab[i];
        if(!tab[i].name)
        {
                tab[i].name=varname;
                return &tab[i];
        }
 }

yyerror("variaveis a mais...");
exit(1);
}
