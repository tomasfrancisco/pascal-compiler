numero				[0-9]+
%%
{numero}                        {printf(" Inteiro ");}
{numero}"."{numero}		{printf(" Real ");}
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

