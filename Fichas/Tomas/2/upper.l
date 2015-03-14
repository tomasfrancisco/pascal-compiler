string				[a-z]
other				[^a-z]

%%
{other}		{printf("%s", yytext);}
{string}	{printf("%c", (char) (atoi(yytext) - 32));}

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