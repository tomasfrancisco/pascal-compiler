integer             ([0-9]+)|("-"[0-9]+)
long                 ([0-9]+"l")|("-"[0-9]+"l")
unsignedint         [0-9]+"u"
unsignedlong        [0-9]+"ul"
float               (([0-9]+)"."([0-9]+))|(("-"[0-9]+)"."([0-9]+))|(([0-9]+)"f")|(("-"[0-9]+)"f")
floatingpoint       (([0-9]+)"e+"([0-9]+))|(("-"[0-9]+)"e-"([0-9]+))|(([0-9]+)"e-"([0-9]+))|(("-"[0-9]+)"e+"([0-9]+))|(([0-9]+)"."([0-9]+)"e+"([0-9]+))|(("-"[0-9]+)"."([0-9]+)"e-"([0-9]+))|(([0-9]+)"."([0-9]+)"e-"([0-9]+))|(("-"[0-9]+)"."([0-9]+)"e+"([0-9]+))

%%
"abc""bc"*                              {printf(" token!");}
"a""b"+"c"                              {printf(" token!");}

{integer}                           {printf(" integer");}
{long}                              {printf(" long");}
{unsignedint}                       {printf(" unsigned int");}
{unsignedlong}                      {printf(" unsigned long");}
{float}                             {printf(" float");}
{floatingpoint}                     {printf(" floating point");}

%%
int main()
{s
yylex();
return 0;
}

int yywrap()
{
return 1;
}
