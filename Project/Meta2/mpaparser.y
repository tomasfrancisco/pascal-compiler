%{

#include <stdio.h>
#include <stdlib.h>

extern int line, col;
extern char *token;
int yylex();
void yyerror(char *s);
%}

%union{
    char ch;
    int i;
    char* str;
}

%token PROGRAM OUTPUT VAR FUNCTION BEGINTOKEN IF THEN ELSE WHILE DO REPEAT UNTIL PARAMSTR NOT RESERVED ASSIGN END VAL FORWARD WRITELN AND OR MOD DIV DIFF MOREEQUAL LESSEQUAL
%token <ch> SEMIC COLON DOT LBRAC RBRAC COMMA
%token <str> ID STRING REALLIT
%token <i> INTLIT

%right ELSE THEN
%left '=' DIFF '<' LESSEQUAL '>' MOREEQUAL
%left OR '+' '-'
%left '*' '/' DIV MOD AND
%left NOT

%%

Prog                :   ProgHeading SEMIC ProgBlock DOT                     {;}
ProgHeading         :   PROGRAM ID LBRAC OUTPUT RBRAC                       {;}
ProgBlock           :   VarPart FuncPart StatPart                           {;}
VarPart             :   VAR VarDeclaration SEMIC VarPartAux                 {;}
                    |   /*%empty*/                                          {;}
VarPartAux          :   VarDeclaration SEMIC VarPartAux                     {;}
                    |   /*%empty*/                                          {;}
VarDeclaration      :   IDList COLON ID                                     {;}
IDList              :   ID IDAux                                            {;}
IDAux               :   COMMA ID IDAux                                      {;}
                    |   /*%empty*/                                          {;}
FuncPart            :   FuncDeclaration SEMIC FuncPart                      {;}
                    |   /*%empty*/                                          {;}
FuncDeclaration     :   FuncHeading SEMIC FORWARD                           {;}
FuncDeclaration     :   FuncIdent SEMIC FuncBlock                           {;}
FuncDeclaration     :   FuncHeading SEMIC FuncBlock                         {;}
FuncHeading         :   FUNCTION ID FormalParamList COLON ID                {;}
                    |   FUNCTION ID COLON ID                                {;}
FuncIdent           :   FUNCTION ID                                         {;}
FormalParamList     :   LBRAC FormalParams FormalParamListAux RBRAC         {;}
FormalParamListAux  :   SEMIC FormalParams FormalParamListAux               {;}
                    |   /*%empty*/                                          {;}
FormalParams        :   VAR IDList COLON ID                                 {;}
                    |   IDList COLON ID                                     {;}
FuncBlock           :   VarPart StatPart                                    {;}
StatPart            :   CompStat                                            {;}
CompStat            :   BEGINTOKEN StatList END                             {;}
StatList            :   Stat StatListAux                                    {;}
StatListAux         :   SEMIC Stat StatListAux                              {;}
                    |   /*%empty*/                                          {;}
Stat                :   CompStat                                            {;}
                    |   IF Expr THEN Stat ELSE Stat                         {;}
                    |   IF Expr THEN Stat                                   {;}
                    |   WHILE Expr DO Stat                                  {;}
                    |   REPEAT StatList UNTIL Expr                          {;}
                    |   VAL LBRAC PARAMSTR LBRAC Expr RBRAC COMMA ID RBRAC  {;}
                    |   ID ASSIGN Expr                                      {;}
                    |   WRITELN WritelnPList                                {;}
                    |   WRITELN                                             {;}
                    |   /*%empty*/                                          {;}
WritelnPList        :   LBRAC WritelnPListAux1 WritelnPListAux2 RBRAC       {;}
WritelnPListAux1    :   Expr                                                {;}
                    |   STRING                                              {;}
WritelnPListAux2    :   COMMA WritelnPListAux1 WritelnPListAux2             {;}
                    |   /*%empty*/                                          {;}
Expr                :   Expr OR Expr                                        {;}
                    |   Expr AND Expr                                       {;}
                    |   Expr DIFF Expr                                      {;}
                    |   Expr DIV Expr                                       {;}
                    |   Expr MOREEQUAL Expr                                 {;}
                    |   Expr LESSEQUAL Expr                                 {;}
                    |   Expr MOD Expr                                       {;}
                    |   Expr '=' Expr                                       {;}
                    |   Expr '+' Expr                                       {;}
                    |   Expr '-' Expr                                       {;}
                    |   Expr '/' Expr                                       {;}
                    |   Expr '*' Expr                                       {;}
                    |   Expr '<' Expr                                       {;}
                    |   Expr '>' Expr                                       {;}
                    |   '+' Expr                                            {;}
                    |   '-' Expr                                            {;}
                    |   NOT Expr                                            {;}
                    |   LBRAC Expr RBRAC                                    {;}
                    |   INTLIT                                              {;}
                    |   REALLIT                                             {;}
                    |   ID ParamList                                        {;}
                    |   ID                                                  {;}
ParamList           :   LBRAC Expr ParamListAux RBRAC                       {;}
ParamListAux        :   COMMA Expr ParamListAux                             {;}
                    |   /*%empty*/                                          {;}
                    
%%

void yyerror (char *s) {

    printf ("Line %d, col %d: %s: %s\n", line, col, s, token);
}
int main()
{
    yyparse();
    //printf("Terminating process...");
    return 0;
}
