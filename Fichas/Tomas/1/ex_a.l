numero				[0-9]+
%%
"-"{numero}						{printf(" Negativo ");}

""{numero}						{printf(" Positivo ");}
"+"{numero}						{printf(" Positivo ");}		

%%
int main()
{
yylex();
return 0;
}

int yywrap()
{
return 1;
}

