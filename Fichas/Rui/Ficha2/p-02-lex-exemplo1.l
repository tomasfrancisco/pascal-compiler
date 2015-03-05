%{
int numints; 
%}
%%
[0-9]+  {numints++;}
[0-9]+"."[0-9]+	;
.	;
\n	;
%%
int main()
{
yylex();
printf("Numero de inteiros encontrados=%d", numints);
return 0;
}

int yywrap()
{
return 1;
}
