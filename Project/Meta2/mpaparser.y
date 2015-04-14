%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>

    extern int line, col;
    extern char *yytext;
    extern int yyleng;
    int yylex();
    void yyerror(char *s);

    typedef struct ast_node {
        char *type;
        char *value;
        int nr_children;
        int superfluo;
        struct ast_node ** children;
    } ast_node;

    typedef struct ast_node *ast_nodeptr;

    ast_nodeptr rootptr;

    ast_nodeptr createNode(char *type, char *value ,int superfluo, int nr_children, ...){
        va_list valist;

        if(nr_children==0){
            ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
            node->type= strdup(type); //duplicar yylval senão dá merda
            node->value= strdup(value); //duplicar yylval senão dá merda
            node->nr_children=0;
            node->superfluo=0;
            return node;
        }else{
            ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
            node->type= type; //duplicar yylval senão dá merda
            node->value= value; //duplicar yylval senão dá merda
            node->nr_children=nr_children;
            node->superfluo=superfluo;
            node->children= (ast_nodeptr*) malloc(nr_children*sizeof(ast_nodeptr));
            int i,j,indice=0;
            ast_nodeptr temp;

            va_start(valist , nr_children);
            for (i=0;i<nr_children; i++){
                temp= va_arg(valist,ast_nodeptr);
                if(temp!=NULL){
                    if(temp->superfluo){
                        node->nr_children+=(temp->nr_children-1);
                        //printf("Incrementing nr_children of %s to %d\n",node->type,node->nr_children);
                        node->children = (ast_nodeptr*) realloc (node->children,node->nr_children*sizeof(ast_nodeptr));
                        for(j=0;j<temp->nr_children;j++){
                            //printf("Putting %s of value %s in index %d of node %s coming from %s\n",temp->children[j]->type,temp->children[j]->value,indice,node->type,temp->type);
                            node->children[indice]=temp->children[j];
                            indice++;
                        }
                        //Pode-se fazer aqui um free, mas não nos pagam para isso, por isso fuck it
                    }else{
                        //printf("Putting %s of value %s in index %d of node %s\n",temp->type,temp->value,indice,node->type);
                        node->children[indice]=temp;
                        indice++;
                    }
                }else{
                    (node->nr_children)--;
                    //printf("Decrementing nr_children of %s to %d\n",node->type,node->nr_children);
                    //Caso em que se recebe um nó a NULL como argumento(no caso da regra puder devolver empty)
                    //Decrementa-se o nr de children para depois bater certo
                }
            }
            va_end(valist);
            return node;
        }
        /*
        -criar node (se nr_children == 0, criar no terminal (ignorar os passos abaixo))
        -MALLOC de array de nodes com nr_children
        -percorrer cada child e ver se é no superfluo:
        se sim: reallocar o array, não colocar esse nó no array, mas colocar os filhos
        se não: colocar logo no array

        é importante fazer isto por ordem pois para imprimir tem de estar ordenado ou seja se houverem 3 args
        e arg1 tiver 3 filhos e for superfluo a imprimir fica:
        filho1 filho2 filho3 arg2 arg3
        -devolver node*/

    }

    int printTree(ast_nodeptr node,int treedepth){
        int i;
        for(i=0;i<treedepth;i++){
            printf("..");
        }
        printf("%s",node->type);
        if(node->value!=NULL){
            printf("(%s)",node->value);
        }
        printf("\n");
        for(i=0;i<node->nr_children;i++){
            printTree(node->children[i],treedepth+1);
        }
        return 0;
    }

%}


%union{
    char ch;
    int i;
    char* str;
    void * ptr;
}

%token PROGRAM OUTPUT VAR FUNCTION BEGINTOKEN IF THEN ELSE WHILE DO REPEAT UNTIL PARAMSTR NOT RESERVED ASSIGN END VAL FORWARD WRITELN AND OR MOD DIV DIFF MOREEQUAL LESSEQUAL
%token SEMIC COLON DOT LBRAC RBRAC COMMA
%token <str> ID STRING REALLIT
%token <i> INTLIT

%type <ptr> Id Prog ProgHeading ProgBlock VarPart VarPartAux VarDeclaration IDList IDAux FuncPart FuncDeclaration FuncHeading FuncIdent FormalParamList FormalParamListAux FormalParams FuncBlock StatPart CompStat StatList StatListAux Stat WritelnPList WritelnPListAux1 WritelnPListAux2 Expr ParamList ParamListAux

%right ELSE THEN
%left '=' DIFF '<' LESSEQUAL '>' MOREEQUAL
%left OR '+' '-'
%left '*' '/' DIV MOD AND
%left NOT

%%

Prog                :   ProgHeading SEMIC ProgBlock DOT                     {printf("What the fuck 1\n");rootptr=createNode("Program",NULL,0,2,$1,$3);}
ProgHeading         :   PROGRAM Id LBRAC OUTPUT RBRAC                       {printf("What the fuck 2\n");$$=createNode("ProgHeading",NULL,1,1,$2);}
ProgBlock           :   VarPart FuncPart StatPart                           {printf("What the fuck 3\n");$$=createNode("ProgBlock",NULL,1,3,$1,$2,$3);}
VarPart             :   VAR VarDeclaration SEMIC VarPartAux                 {printf("What the fuck 4\n");$$=createNode("VarPart",NULL,0,2,$2,$4);}
                    |   /*%empty*/                                          {printf("What the fuck 5\n");$$=NULL;}
VarPartAux          :   VarDeclaration SEMIC VarPartAux                     {printf("What the fuck 6\n");$$=createNode("VarPartAux",NULL,1,2,$1,$3);}
                    |   /*%empty*/                                          {printf("What the fuck 7\n");$$=NULL;}
VarDeclaration      :   IDList COLON Id                                     {printf("What the fuck 8\n");$$=createNode("VarDeclaration",NULL,0,2,$1,$3);}
IDList              :   Id IDAux                                            {printf("What the fuck 9\n");$$=createNode("IdList",NULL,1,2,$1,$2);}
IDAux               :   COMMA Id IDAux                                      {printf("What the fuck 10\n");$$=createNode("IDAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {printf("What the fuck 11\n");$$=NULL;}
FuncPart            :   FuncDeclaration SEMIC FuncPart                      {printf("What the fuck 12\n");$$=createNode("FuncPart",NULL,0,2,$1,$3);}
                    |   /*%empty*/                                          {printf("What the fuck 13\n");$$=NULL;}
FuncDeclaration     :   FuncHeading SEMIC FORWARD                           {printf("What the fuck 14\n");$$=createNode("FuncDecl",NULL,0,1,$1);}
                    |   FuncIdent SEMIC FuncBlock                           {printf("What the fuck 15\n");$$=createNode("FuncDef2",NULL,0,2,$1,$3);}
                    |   FuncHeading SEMIC FuncBlock                         {printf("What the fuck 16\n");$$=createNode("FuncDef",NULL,0,2,$1,$3);}
FuncHeading         :   FUNCTION Id FormalParamList COLON Id                {printf("What the fuck 17\n");$$=createNode("FuncHeading",NULL,1,3,$2,$3,$5);}
                    |   FUNCTION Id COLON Id                                {printf("What the fuck 18\n");$$=createNode("FuncHeading2",NULL,1,2,$2,$4);}
FuncIdent           :   FUNCTION Id                                         {$$=NULL;}
FormalParamList     :   LBRAC FormalParams FormalParamListAux RBRAC         {printf("What the fuck 19\n");$$=createNode("FuncParams",NULL,0,2,$2,$3);}
FormalParamListAux  :   SEMIC FormalParams FormalParamListAux               {$$=NULL;}
                    |   /*%empty*/                                          {$$=NULL;}
FormalParams        :   VAR IDList COLON Id                                 {printf("What the fuck 20\n");$$=createNode("VarParams",NULL,0,2,$2,$4);}
                    |   IDList COLON Id                                     {printf("What the fuck 21\n");$$=createNode("Params",NULL,0,2,$1,$3);}
FuncBlock           :   VarPart StatPart                                    {$$=NULL;}
StatPart            :   CompStat                                            {$$=NULL;}
CompStat            :   BEGINTOKEN StatList END                             {$$=NULL;}
StatList            :   Stat StatListAux                                    {$$=NULL;}
StatListAux         :   SEMIC Stat StatListAux                              {$$=NULL;}
                    |   /*%empty*/                                          {$$=NULL;}
Stat                :   CompStat                                            {$$=NULL;}
                    |   IF Expr THEN Stat ELSE Stat                         {$$=NULL;}
                    |   IF Expr THEN Stat                                   {$$=NULL;}
                    |   WHILE Expr DO Stat                                  {$$=NULL;}
                    |   REPEAT StatList UNTIL Expr                          {$$=NULL;}
                    |   VAL LBRAC PARAMSTR LBRAC Expr RBRAC COMMA Id RBRAC  {$$=NULL;}
                    |   Id ASSIGN Expr                                      {$$=NULL;}
                    |   WRITELN WritelnPList                                {$$=NULL;}
                    |   WRITELN                                             {$$=NULL;}
                    |   /*%empty*/                                          {$$=NULL;}
WritelnPList        :   LBRAC WritelnPListAux1 WritelnPListAux2 RBRAC       {$$=NULL;}
WritelnPListAux1    :   Expr                                                {$$=NULL;}
                    |   STRING                                              {$$=NULL;}
WritelnPListAux2    :   COMMA WritelnPListAux1 WritelnPListAux2             {$$=NULL;}
                    |   /*%empty*/                                          {$$=NULL;}
Expr                :   Expr OR Expr                                        {$$=NULL;}
                    |   Expr AND Expr                                       {$$=NULL;}
                    |   Expr DIFF Expr                                      {$$=NULL;}
                    |   Expr DIV Expr                                       {$$=NULL;}
                    |   Expr MOREEQUAL Expr                                 {$$=NULL;}
                    |   Expr LESSEQUAL Expr                                 {$$=NULL;}
                    |   Expr MOD Expr                                       {$$=NULL;}
                    |   Expr '=' Expr                                       {$$=NULL;}
                    |   Expr '+' Expr                                       {$$=NULL;}
                    |   Expr '-' Expr                                       {$$=NULL;}
                    |   Expr '/' Expr                                       {$$=NULL;}
                    |   Expr '*' Expr                                       {$$=NULL;}
                    |   Expr '<' Expr                                       {$$=NULL;}
                    |   Expr '>' Expr                                       {$$=NULL;}
                    |   '+' Expr                                            {$$=NULL;}
                    |   '-' Expr                                            {$$=NULL;}
                    |   NOT Expr                                            {$$=NULL;}
                    |   LBRAC Expr RBRAC                                    {$$=NULL;}
                    |   INTLIT                                              {$$=NULL;}
                    |   REALLIT                                             {$$=NULL;}
                    |   Id ParamList                                        {$$=NULL;}
                    |   Id                                                  {$$=NULL;}
ParamList           :   LBRAC Expr ParamListAux RBRAC                       {$$=NULL;}
ParamListAux        :   COMMA Expr ParamListAux                             {$$=NULL;}
                    |   /*%empty*/                                          {$$=NULL;}

//regra auxiliar para criar nó com ID
Id                  :   ID                                                  {printf("What the fuck 22\n");$$=createNode("Id",$1,0,0);}

%%

void yyerror (char *s) {
    //printf("line: %d, col: %d, len: %d, token: %s\n", line, col, yyleng, yytext);
    printf("Line %d, col %d: %s: %s\n", line, col - ((int)strlen(yytext) - 1), s, yytext);
}
int main()
{
    yyparse();
    printTree(rootptr,0);
    //printf("Terminating process...");
    return 0;
}
