%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include "semantic.h"

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

Prog                :   ProgHeading SEMIC ProgBlock DOT                     {rootptr=createNode(line,col - ((int)strlen(yytext) - 1),"Program",NULL,0,2,$1,$3);}
ProgHeading         :   PROGRAM Id LBRAC OUTPUT RBRAC                       {$$=createNode(line,col - ((int)strlen(yytext) - 1),"ProgHeading",NULL,1,1,$2);}
ProgBlock           :   VarPart FuncPart StatPart                           {$$=createNode(line,col - ((int)strlen(yytext) - 1),"ProgBlock",NULL,1,3,$1,$2,$3);}
VarPart             :   VAR VarDeclaration SEMIC VarPartAux                 {$$=createNode(line,col - ((int)strlen(yytext) - 1),"VarPart",NULL,0,2,$2,$4);}
                    |   /*%empty*/                                          {$$=createNode(-1,-1,"VarPart",NULL,0,0);}
VarPartAux          :   VarDeclaration SEMIC VarPartAux                     {$$=createNode(line,col - ((int)strlen(yytext) - 1),"VarPartAux",NULL,1,2,$1,$3);}
                    |   /*%empty*/                                          {$$=NULL;}
VarDeclaration      :   IDList COLON Id                                     {$$=createNode(line,col - ((int)strlen(yytext) - 1),"VarDecl",NULL,0,2,$1,$3);}
IDList              :   Id IDAux                                            {$$=createNode(line,col - ((int)strlen(yytext) - 1),"IdList",NULL,1,2,$1,$2);}
IDAux               :   COMMA Id IDAux                                      {$$=createNode(line,col - ((int)strlen(yytext) - 1),"IDAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}
FuncPart            :   FuncDeclaration SEMIC FuncPartAux                   {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncPart",NULL,0,2,$1,$3);}
                    |   /*%empty*/                                          {$$=createNode(-1,-1,"FuncPart",NULL,0,0);}

FuncPartAux         :   FuncDeclaration SEMIC FuncPartAux                   {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncPart",NULL,1,2,$1,$3);}
                    |   /*%empty*/                                          {$$=createNode(-1,-1,"FuncPart",NULL,1,0);}

FuncDeclaration     :   FuncHeading SEMIC FORWARD                           {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncDecl",NULL,0,1,$1);}
                    |   FuncIdent SEMIC FuncBlock                           {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncDef2",NULL,0,2,$1,$3);}
                    |   FuncHeading SEMIC FuncBlock                         {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncDef",NULL,0,2,$1,$3);}

FuncHeading         :   FUNCTION Id FormalParamList COLON Id                {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncHeading",NULL,1,3,$2,$3,$5);}
                    |   FUNCTION Id COLON Id                                {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncHeading2",NULL,1,3,$2,createNode(line,col - ((int)strlen(yytext) - 1),"FuncParams",NULL,0,0),$4);}

FuncIdent           :   FUNCTION Id                                         {$$=$2;}
FormalParamList     :   LBRAC FormalParams FormalParamListAux RBRAC         {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncParams",NULL,0,2,$2,$3);}
FormalParamListAux  :   SEMIC FormalParams FormalParamListAux               {$$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncParamsAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}

FormalParams        :   VAR IDList COLON Id                                 {$$=createNode(line,col - ((int)strlen(yytext) - 1),"VarParams",NULL,0,2,$2,$4);}
                    |   IDList COLON Id                                     {$$=createNode(line,col - ((int)strlen(yytext) - 1),"Params",NULL,0,2,$1,$3);}

FuncBlock           :   VarPart StatPart                                    {   if((!strcmp(((ast_nodeptr)$2)->type,"StatPart")) && (((ast_nodeptr)$2)->nr_children==0)){
                                                                                    $$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncBlock",NULL,1,2,$1,createNode(-1,-1,"StatList","Folha",0,0));
                                                                                } else $$=createNode(line,col - ((int)strlen(yytext) - 1),"FuncBlock",NULL,1,2,$1,$2);
                                                                            ;}


StatPart            :   CompStat                                            {$$=createNode(line,col - ((int)strlen(yytext) - 1),"StatPart",NULL,1,1,$1);}
CompStat            :   BEGINTOKEN StatList END                             {$$=createNode(line,col - ((int)strlen(yytext) - 1),"CompStat",NULL,1,1,$2);}
StatList            :   Stat StatListAux                                    {$$=createNode(line,col - ((int)strlen(yytext) - 1),"StatList",NULL,0,2,$1,$2);}
StatListAux         :   SEMIC Stat StatListAux                              {$$=createNode(line,col - ((int)strlen(yytext) - 1),"StatListAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}
Stat                :   CompStat                                            {$$=createNode(line,col - ((int)strlen(yytext) - 1),"Stat",NULL,1,1,$1);}
                    |   IF Expr THEN Stat ELSE Stat                         {   if($4!=NULL && !(!strcmp(((ast_nodeptr)$4)->type, "Stat") && ((ast_nodeptr)$4)->nr_children == 0) && $6!=NULL && !(!strcmp(((ast_nodeptr)$6)->type, "Stat") && ((ast_nodeptr)$6)->nr_children == 0)){
                                                                                    $$=createNode(line,col - ((int)strlen(yytext) - 1),"IfElse",NULL,0,3,$2,$4,$6);
                                                                                }else{
                                                                                    ast_nodeptr n1= $4;
                                                                                    ast_nodeptr n2= $6;
                                                                                    if($4==NULL||(!strcmp(((ast_nodeptr)$4)->type, "Stat") && ((ast_nodeptr)$4)->nr_children == 0)){
                                                                                        n1=createNode(-1,-1,"StatList","Folha",0,0);
                                                                                    }
                                                                                    if($6==NULL||(!strcmp(((ast_nodeptr)$6)->type, "Stat") && ((ast_nodeptr)$6)->nr_children == 0)){
                                                                                        n2=createNode(-1,-1,"StatList","Folha",0,0);
                                                                                    }
                                                                                    $$=createNode(line,col - ((int)strlen(yytext) - 1),"IfElse",NULL,0,3,$2,n1,n2);
                                                                                }
                                                                            ;}
                    |   IF Expr THEN Stat                                   {   if($4!=NULL && !(!strcmp(((ast_nodeptr)$4)->type, "Stat") && ((ast_nodeptr)$4)->nr_children == 0)){
                                                                                    $$=createNode(line,col - ((int)strlen(yytext) - 1),"IfElse",NULL,0,3,$2,$4,createNode(-1,-1,"StatList","Folha",0,0));
                                                                                }else $$=createNode(line,col - ((int)strlen(yytext) - 1),"IfElse",NULL,0,3,$2,createNode(-1,-1,"StatList","Folha",0,0),createNode(-1,-1,"StatList","Folha",0,0));
                                                                            ;}
                    |   WHILE Expr DO Stat                                  {   if($4!=NULL && ((ast_nodeptr)$4)->nr_children!=0) {
                                                                                    $$=createNode(line,col - ((int)strlen(yytext) - 1),"While",NULL,0,2,$2,$4);
                                                                                }else
                                                                                    $$=createNode(line,col - ((int)strlen(yytext) - 1),"While",NULL,0,2,$2,createNode(-1,-1,"StatList","Folha",0,0));
                                                                            ;}
                    |   REPEAT StatList UNTIL Expr                          {   if ($2==NULL ||(!strcmp(((ast_nodeptr)$2)->type, "StatList") && ((ast_nodeptr)$2)->nr_children == 0)){
                                                                                        $$=createNode(line,col - ((int)strlen(yytext) - 1),"Repeat",NULL,0,2,createNode(-1,-1,"StatList","Folha",0,0),$4);
                                                                                }else $$=createNode(line,col - ((int)strlen(yytext) - 1),"Repeat",NULL,0,2,$2,$4);}
                    |   VAL LBRAC PARAMSTR LBRAC Expr RBRAC COMMA Id RBRAC  {$$=createNode(line,col - ((int)strlen(yytext) - 1),"ValParam",NULL,0,2,$5,$8);}
                    |   Id ASSIGN Expr                                      {$$=createNode(line,col - ((int)strlen(yytext) - 1),"Assign",NULL,0,2,$1,$3);}
                    |   WRITELN WritelnPList                                {$$=createNode(line,col - ((int)strlen(yytext) - 1),"WriteLn",NULL,0,1,$2);}
                    |   WRITELN                                             {$$=createNode(line,col - ((int)strlen(yytext) - 1),"WriteLn",NULL,0,0);}
                    |   /*%empty*/                                          {$$=NULL;}
WritelnPList        :   LBRAC WritelnPListAux1 WritelnPListAux2 RBRAC       {$$=createNode(line,col - ((int)strlen(yytext) - 1),"WritelnPList",NULL,1,2,$2,$3);}
WritelnPListAux1    :   Expr                                                {$$=createNode(line,col - ((int)strlen(yytext) - 1),"WritelnPListAux1Expr",NULL,1,1,$1);}
                    |   STRING                                              {$$=createNode(line,col - ((int)strlen(yytext) - 1),"String",$1,0,0);}
WritelnPListAux2    :   COMMA WritelnPListAux1 WritelnPListAux2             {$$=createNode(line,col - ((int)strlen(yytext) - 1),"WritelnPListAux2",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}

Expr:				    SimpleExpr '=' SimpleExpr						    {$$=createNode(line,col - ((int)strlen(yytext) - 1),"Eq",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr DIFF SimpleExpr						    {$$=createNode(line,col - ((int)strlen(yytext) - 1),"Neq",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr '<' SimpleExpr							{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Lt",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr '>' SimpleExpr							{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Gt",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr LESSEQUAL SimpleExpr						{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Leq",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr MOREEQUAL SimpleExpr						{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Geq",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr											{$$=createNode(line,col - ((int)strlen(yytext) - 1),"SimpleExpr",NULL, 1, 1, $1);}

SimpleExpr:				Term											    {$$=createNode(line,col - ((int)strlen(yytext) - 1),"Term",NULL, 1, 1, $1);}
                    |   AddOP												{$$=createNode(line,col - ((int)strlen(yytext) - 1),"AddOP",NULL, 1, 1, $1);}

AddOP:					SimpleExpr '+' Term								    {$$=createNode(line,col - ((int)strlen(yytext) - 1),"Add",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr '-' Term									{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Sub",NULL, 0, 2, $1, $3);}
                    |	SimpleExpr OR Term									{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Or",NULL, 0, 2, $1, $3);}
                    |	'-' Term											{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Minus",NULL, 0, 1, $2);}
                    |	'+' Term											{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Plus",NULL, 0, 1, $2);}

Term:					Term '/' Factor										{$$=createNode(line,col - ((int)strlen(yytext) - 1),"RealDiv",NULL, 0, 2, $1, $3);}
                    |	Term '*' Factor										{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Mul",NULL, 0, 2, $1, $3);}
                    |	Term AND Factor										{$$=createNode(line,col - ((int)strlen(yytext) - 1),"And",NULL, 0, 2, $1, $3);}
                    |	Term DIV Factor										{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Div",NULL, 0, 2, $1, $3);}
                    |   Term MOD Factor										{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Mod",NULL, 0, 2, $1, $3);}
                    |	Factor												{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Factor",NULL, 1, 1, $1);}

Factor:					Id      											{$$=$1;}
                    |	NOT Factor											{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Not",NULL, 0, 1, $2);}
                    |	LBRAC Expr RBRAC									{$$=createNode(line,col - ((int)strlen(yytext) - 1),"LbracRbrac",NULL, 1, 1, $2);}
                    |	Id ParamList										{$$=createNode(line,col - ((int)strlen(yytext) - 1),"Call",NULL, 0, 2, $1, $2);}
                    |	INTLIT												{$$=createNode(line,col - ((int)strlen(yytext) - 1),"IntLit",$1, 0,0);}
                    |	REALLIT												{$$=createNode(line,col - ((int)strlen(yytext) - 1),"RealLit",$1, 0,0);}



ParamList           :   LBRAC Expr ParamListAux RBRAC                       {$$=createNode(line,col - ((int)strlen(yytext) - 1),"ParamList",NULL,1,2,$2,$3);}
ParamListAux        :   COMMA Expr ParamListAux                             {$$=createNode(line,col - ((int)strlen(yytext) - 1),"ParamListAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}

//regra auxiliar para criar nó com ID
Id                  :   ID                                                  {$$=createNode(line,col - ((int)strlen(yytext) - 1),"Id",$1,0,0);}

%%

void yyerror (char *s) {
    errors = 1;
    printf("Line %d, col %d: %s: %s\n", line, col - ((int)strlen(yytext) - 1), s, yytext);
}
int main(int argc, char **argv)
{
    init_semantic_tables();
    yyparse();
    if(argc > 1 && strcmp(argv[1], "-t") == 0 && errors == 0) {
       printTree(rootptr,0);
       printf("\n");
    }

    if(((argc > 2 && strcmp(argv[2], "-s")== 0) || (argc > 1 && strcmp(argv[1], "-s")== 0))  && errors == 0) {
        errors=analizeTree(rootptr,root_semantic_tables,NULL);
        if(errors==0)
            show_tables(root_semantic_tables);
    }
    return 0;
}
