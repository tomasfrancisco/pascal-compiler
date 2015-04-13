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
        int nr_children;
        int superfluo;
        struct ast_node ** children;
    } ast_node;

    typedef struct ast_node *ast_nodeptr;

    ast_nodeptr createNode(char *type, int superfluo, int nr_children, ...){
        va_list valist;

        if(nr_children==0){
            ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
            node->type= strdup(type); //duplicar yylval senão dá merda
            node->nr_children=0;
            node->superfluo=0;
            return node;
        }else{
            ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
            node->type= strdup(type); //duplicar yylval senão dá merda
            node->nr_children=nr_children;
            node->superfluo=superfluo;
            node->children= (ast_nodeptr*) malloc(nr_children*sizeof(ast_node));

            int i,j,indice=0;
            ast_nodeptr temp;

            va_start(valist , nr_children);
            for (i=0;i<nr_children; i++){

                temp= va_arg(valist,ast_nodeptr);
                if(temp->superfluo){
                    node->nr_children+= temp->nr_children;
                    node->children = (ast_nodeptr*) realloc (node->children,node->nr_children*sizeof(ast_node));
                    for(j=0;j<temp->nr_children;j++){
                        node->children[indice]=temp->children[j];
                        indice++;
                    }
                    //Pode-se fazer aqui um free, mas não nos pagam para isso, por isso fuck it
                }else{
                    node->children[indice]=temp;
                    indice++;
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
    //printf("line: %d, col: %d, len: %d, token: %s\n", line, col, yyleng, yytext);
    printf("Line %d, col %d: %s: %s\n", line, col - ((int)strlen(yytext) - 1), s, yytext);
}
int main()
{
    yyparse();
    //printf("Terminating process...");
    return 0;
}
