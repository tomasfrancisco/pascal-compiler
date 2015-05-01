%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include "ast.h"
    #include "symbol_table.h"
    #include "semantics.h"

    char str[33];
    extern int line, col;
    extern char *yytext;
    extern int yyleng;
    int errors = 0;

    int yylex();
    void yyerror(char *s);



    ast_nodeptr rootptr;

%}


%union{
    char ch;
    int i;
    char* str;
    void * ptr; //Void pointer para se puder passar nós pela stack (é um atrofio enorme com regras do yacc,
                //não perguntes, não vale a pena, basicamente todos os tipos de coisas que queiras passar, tens de declarar aqui)
                //mas devido a outro retardamento do yacc e lex, não pode ser ast_nodeptr pk y+l declaram union antes de declarar structs por isso não era reconhecido, granda atrofio)
}

%token PROGRAM OUTPUT VAR FUNCTION BEGINTOKEN IF THEN ELSE WHILE DO REPEAT UNTIL PARAMSTR NOT RESERVED ASSIGN END VAL FORWARD WRITELN AND OR MOD DIV DIFF MOREEQUAL LESSEQUAL
%token SEMIC COLON DOT LBRAC RBRAC COMMA
%token <str> ID STRING REALLIT INTLIT

%type <ptr>  FuncPartAux AddOP Factor SimpleExpr Term Id Prog ProgHeading ProgBlock VarPart VarPartAux VarDeclaration IDList IDAux FuncPart FuncDeclaration FuncHeading FuncIdent FormalParamList FormalParamListAux FormalParams FuncBlock StatPart CompStat StatList StatListAux Stat WritelnPList WritelnPListAux1 WritelnPListAux2 Expr ParamList ParamListAux

%right THEN
%right ELSE
%right ASSIGN

%%

Prog                :   ProgHeading SEMIC ProgBlock DOT                     {rootptr=createNode("Program",NULL,0,2,$1,$3);}
ProgHeading         :   PROGRAM Id LBRAC OUTPUT RBRAC                       {$$=createNode("ProgHeading",NULL,1,1,$2);}
ProgBlock           :   VarPart FuncPart StatPart                           {$$=createNode("ProgBlock",NULL,1,3,$1,$2,$3);}
VarPart             :   VAR VarDeclaration SEMIC VarPartAux                 {$$=createNode("VarPart",NULL,0,2,$2,$4);}
                    |   /*%empty*/                                          {$$=createNode("VarPart",NULL,0,0);}
VarPartAux          :   VarDeclaration SEMIC VarPartAux                     {$$=createNode("VarPartAux",NULL,1,2,$1,$3);}
                    |   /*%empty*/                                          {$$=NULL;}
VarDeclaration      :   IDList COLON Id                                     {$$=createNode("VarDecl",NULL,0,2,$1,$3);}
IDList              :   Id IDAux                                            {$$=createNode("IdList",NULL,1,2,$1,$2);}
IDAux               :   COMMA Id IDAux                                      {$$=createNode("IDAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}
FuncPart            :   FuncDeclaration SEMIC FuncPartAux                   {$$=createNode("FuncPart",NULL,0,2,$1,$3);}
                    |   /*%empty*/                                          {$$=createNode("FuncPart",NULL,0,0);}

FuncPartAux         :   FuncDeclaration SEMIC FuncPartAux                   {$$=createNode("FuncPart",NULL,1,2,$1,$3);}
                    |   /*%empty*/                                          {$$=createNode("FuncPart",NULL,1,0);}

FuncDeclaration     :   FuncHeading SEMIC FORWARD                           {$$=createNode("FuncDecl",NULL,0,1,$1);}
                    |   FuncIdent SEMIC FuncBlock                           {$$=createNode("FuncDef2",NULL,0,2,$1,$3);}
                    |   FuncHeading SEMIC FuncBlock                         {$$=createNode("FuncDef",NULL,0,2,$1,$3);}

FuncHeading         :   FUNCTION Id FormalParamList COLON Id                {$$=createNode("FuncHeading",NULL,1,3,$2,$3,$5);}
                    |   FUNCTION Id COLON Id                                {$$=createNode("FuncHeading2",NULL,1,3,$2,createNode("FuncParams",NULL,0,0),$4);}

FuncIdent           :   FUNCTION Id                                         {$$=$2;}
FormalParamList     :   LBRAC FormalParams FormalParamListAux RBRAC         {$$=createNode("FuncParams",NULL,0,2,$2,$3);}
FormalParamListAux  :   SEMIC FormalParams FormalParamListAux               {$$=createNode("FuncParamsAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}

FormalParams        :   VAR IDList COLON Id                                 {$$=createNode("VarParams",NULL,0,2,$2,$4);}
                    |   IDList COLON Id                                     {$$=createNode("Params",NULL,0,2,$1,$3);}

FuncBlock           :   VarPart StatPart                                    {   if((!strcmp(((ast_nodeptr)$2)->type,"StatPart")) && (((ast_nodeptr)$2)->nr_children==0)){
                                                                                    $$=createNode("FuncBlock",NULL,1,2,$1,createNode("StatList","Folha",0,0));
                                                                                } else $$=createNode("FuncBlock",NULL,1,2,$1,$2);
                                                                            ;}


StatPart            :   CompStat                                            {$$=createNode("StatPart",NULL,1,1,$1);}
CompStat            :   BEGINTOKEN StatList END                             {$$=createNode("CompStat",NULL,1,1,$2);}
StatList            :   Stat StatListAux                                    {$$=createNode("StatList",NULL,0,2,$1,$2);}
StatListAux         :   SEMIC Stat StatListAux                              {$$=createNode("StatListAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}
Stat                :   CompStat                                            {$$=createNode("Stat",NULL,1,1,$1);}
                    |   IF Expr THEN Stat ELSE Stat                         {   if($4!=NULL && !(!strcmp(((ast_nodeptr)$4)->type, "Stat") && ((ast_nodeptr)$4)->nr_children == 0) && $6!=NULL && !(!strcmp(((ast_nodeptr)$6)->type, "Stat") && ((ast_nodeptr)$6)->nr_children == 0)){
                                                                                    $$=createNode("IfElse",NULL,0,3,$2,$4,$6);
                                                                                }else{
                                                                                    ast_nodeptr n1= $4;
                                                                                    ast_nodeptr n2= $6;
                                                                                    if($4==NULL||(!strcmp(((ast_nodeptr)$4)->type, "Stat") && ((ast_nodeptr)$4)->nr_children == 0)){
                                                                                        n1=createNode("StatList","Folha",0,0);
                                                                                    }
                                                                                    if($6==NULL||(!strcmp(((ast_nodeptr)$6)->type, "Stat") && ((ast_nodeptr)$6)->nr_children == 0)){
                                                                                        n2=createNode("StatList","Folha",0,0);
                                                                                    }
                                                                                    $$=createNode("IfElse",NULL,0,3,$2,n1,n2);
                                                                                }
                                                                            ;}
                    |   IF Expr THEN Stat                                   {   if($4!=NULL && !(!strcmp(((ast_nodeptr)$4)->type, "Stat") && ((ast_nodeptr)$4)->nr_children == 0)){
                                                                                    $$=createNode("IfElse",NULL,0,3,$2,$4,createNode("StatList","Folha",0,0));
                                                                                }else $$=createNode("IfElse",NULL,0,3,$2,createNode("StatList","Folha",0,0),createNode("StatList","Folha",0,0));
                                                                            ;}
                    |   WHILE Expr DO Stat                                  {   if($4!=NULL && ((ast_nodeptr)$4)->nr_children!=0) {
                                                                                    $$=createNode("While",NULL,0,2,$2,$4);
                                                                                }else
                                                                                    $$=createNode("While",NULL,0,2,$2,createNode("StatList","Folha",0,0));
                                                                            ;}
                    |   REPEAT StatList UNTIL Expr                          {   if ($2==NULL ||(!strcmp(((ast_nodeptr)$2)->type, "StatList") && ((ast_nodeptr)$2)->nr_children == 0)){
                                                                                        $$=createNode("Repeat",NULL,0,2,createNode("StatList","Folha",0,0),$4);
                                                                                }else $$=createNode("Repeat",NULL,0,2,$2,$4);}
                    |   VAL LBRAC PARAMSTR LBRAC Expr RBRAC COMMA Id RBRAC  {$$=createNode("ValParam",NULL,0,2,$5,$8);}
                    |   Id ASSIGN Expr                                      {$$=createNode("Assign",NULL,0,2,$1,$3);}
                    |   WRITELN WritelnPList                                {$$=createNode("WriteLn",NULL,0,1,$2);}
                    |   WRITELN                                             {$$=createNode("WriteLn",NULL,0,0);}
                    |   /*%empty*/                                          {$$=NULL;}
WritelnPList        :   LBRAC WritelnPListAux1 WritelnPListAux2 RBRAC       {$$=createNode("WritelnPList",NULL,1,2,$2,$3);}
WritelnPListAux1    :   Expr                                                {$$=createNode("WritelnPListAux1Expr",NULL,1,1,$1);}
                    |   STRING                                              {$$=createNode("String",$1,0,0);}
WritelnPListAux2    :   COMMA WritelnPListAux1 WritelnPListAux2             {$$=createNode("WritelnPListAux2",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}

Expr:				    SimpleExpr '=' SimpleExpr						    {$$=createNode("Eq",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr DIFF SimpleExpr						    {$$=createNode("Neq",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr '<' SimpleExpr							{$$=createNode("Lt",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr '>' SimpleExpr							{$$=createNode("Gt",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr LESSEQUAL SimpleExpr						{$$=createNode("Leq",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr MOREEQUAL SimpleExpr						{$$=createNode("Geq",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr											{$$=createNode("SimpleExpr",NULL, 1, 1, $1);}

SimpleExpr:				Term											    {$$=createNode("Term",NULL, 1, 1, $1);}
                    |   AddOP												{$$=createNode("AddOP",NULL, 1, 1, $1);}

AddOP:					SimpleExpr '+' Term								    {$$=createNode("Add",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr '-' Term									{$$=createNode("Sub",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr OR Term									{$$=createNode("Or",NULL, 0, 2, $1, $3);}
                    |	'-' Term											{$$=createNode("Minus",NULL, 0, 1, $2);}
                    |	'+' Term											{$$=createNode("Plus",NULL, 0, 1, $2);}

Term:					Term '/' Factor										{$$=createNode("RealDiv",NULL, 0, 2, $1, $3);}
                    |	Term '*' Factor										{$$=createNode("Mul",NULL, 0, 2, $1, $3);}
                    |	Term AND Factor										{$$=createNode("And",NULL, 0, 2, $1, $3);}
                    |	Term DIV Factor										{$$=createNode("Div",NULL, 0, 2, $1, $3);}
                    |   Term MOD Factor										{$$=createNode("Mod",NULL, 0, 2, $1, $3);}
                    |	Factor												{$$=createNode("Factor",NULL, 1, 1, $1);}

Factor:					Id      											{$$=$1;}
                    |	NOT Factor											{$$=createNode("Not",NULL, 0, 1, $2);}
                    |	LBRAC Expr RBRAC									{$$=createNode("LbracRbrac",NULL, 1, 1, $2);}
                    |	Id ParamList										{$$=createNode("Call",NULL, 0, 2, $1, $2);}
                    |	INTLIT												{$$=createNode("IntLit",$1, 0,0);}
                    |	REALLIT												{$$=createNode("RealLit",$1, 0,0);}



ParamList           :   LBRAC Expr ParamListAux RBRAC                       {$$=createNode("ParamList",NULL,1,2,$2,$3);}
ParamListAux        :   COMMA Expr ParamListAux                             {$$=createNode("ParamListAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}

//regra auxiliar para criar nó com ID
Id                  :   ID                                                  {$$=createNode("Id",$1,0,0);}

%%

void yyerror (char *s) {
    errors = 1;
    printf("Line %d, col %d: %s: %s\n", line, col - ((int)strlen(yytext) - 1), s, yytext);
}
int main(int argc, char **argv)
{
    yyparse();
    if(argc > 1 && strcmp(argv[1], "-t") == 0 && errors == 0) {
       printTree(rootptr,0);
    }
    return 0;
}
