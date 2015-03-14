numero				[0-9]+
numero_0			[0-9]*

%%
{numero}									{printf(" integer ");}
{numero}"l" 								{printf(" long ");}
{numero}"u" 								{printf(" unsigned int ");}
{numero}"ul"								{printf(" unsigned long ");}
{numero}["."","]{numero} 					{printf(" float ");}
{numero}(.{numero_0})?"e"[+-]{numero}		{printf(" floating point ");}
{numero}"f"									{printf(" float ");} 

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

