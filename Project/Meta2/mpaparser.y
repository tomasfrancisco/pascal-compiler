%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    char str[33];
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

        if(nr_children==0){ //se tem 0 ou é terminal ou é uma exceção que é impressa na mesma, mesmo que não tenha filhos
                            //ver enunciado as partes que têm (>=0), tipo funcpart e assim. Daí na gramática criar nós para isso
                            //em alguns casos %empty
            ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
            node->type= strdup(type); //duplicar yylval senão dá merda
            if(value!=NULL){ //Nós tais nós excessão isto era passado a null, logo crashava por ser tentado fazer dup (o tal problema que estragava a submissao no B)
                node->value= strdup(value); //duplicar yylval senão dá merda
            }
            node->nr_children=0;
            node->superfluo=0;
            return node;
        }else{
            ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
            node->type= type; //duplicar yylval senão dá merda
            node->value= value; //duplicar yylval senão dá merda
            node->nr_children=nr_children;
            node->superfluo=superfluo;
            node->children= (ast_nodeptr*) malloc(nr_children*sizeof(ast_nodeptr)); //Array de filhos
            int i,j,indice=0; //Este indice é usado para manter a posição no array de filhos do nó a criar. Pk com os reallocs vamos estar a aumentar o nr de filhos e temos de manter um indice independente do indice original de filhos a percorrer
            ast_nodeptr temp;

            va_start(valist , nr_children); //Percorrer os nós filhos passados como argumentos
            for (i=0;i<nr_children; i++){
                temp= va_arg(valist,ast_nodeptr);
                if(temp!=NULL){ //Em alguns casos, alguns argumentos são passados como NULL, tipo nos empty, pois não era preciso criar nó
                                //Quando isto acontece, decrementa-se o nr de filhos do nó que estamos a criar
                                //Isto poderia ser verificado antes de chamar a função criarNode e chamá-la com menos argumentos mas assim é mais fácil
                    if(temp->superfluo){ //se o nó filho que estamos a analisar for superfluo, copiamos os filhos desse nó para o nó que estamos a criar
                        node->nr_children+=(temp->nr_children-1);//-1 pk já está a contar com o nó superfluo que é um filho e vai ser descartado
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

    char * itoa(int n, char * str){
        snprintf(str, 33, "%d", n);
        return str;
    }

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
%token <str> ID STRING REALLIT
%token <i> INTLIT

%type <ptr> Term Id Prog ProgHeading ProgBlock VarPart VarPartAux VarDeclaration IDList IDAux FuncPart FuncDeclaration FuncHeading FuncIdent FormalParamList FormalParamListAux FormalParams FuncBlock StatPart CompStat StatList StatListAux Stat WritelnPList WritelnPListAux1 WritelnPListAux2 Expr ParamList ParamListAux

%right ELSE THEN
%nonassoc '=' DIFF '<' LESSEQUAL '>' MOREEQUAL
%left OR '+' '-'
%left '*' '/' DIV MOD AND
%left NOT

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
FuncPart            :   FuncDeclaration SEMIC FuncPart                      {$$=createNode("FuncPart",NULL,0,2,$1,$3);}
                    |   /*%empty*/                                          {$$=createNode("FuncPart",NULL,0,0);}
FuncDeclaration     :   FuncHeading SEMIC FuncBlock                         {$$=createNode("FuncDef",NULL,0,2,$1,$3);}
                    |   FuncIdent SEMIC FuncBlock                           {$$=createNode("FuncDef2",NULL,0,2,$1,$3);}
                    |   FuncHeading SEMIC FORWARD                           {$$=createNode("FuncDecl",NULL,0,1,$1);}
FuncHeading         :   FUNCTION Id FormalParamList COLON Id                {$$=createNode("FuncHeading",NULL,1,3,$2,$3,$5);}
                    |   FUNCTION Id COLON Id                                {$$=createNode("FuncHeading2",NULL,1,2,$2,$4);}
FuncIdent           :   FUNCTION Id                                         {$$=$2;}
FormalParamList     :   LBRAC FormalParams FormalParamListAux RBRAC         {$$=createNode("FuncParams",NULL,0,2,$2,$3);}
FormalParamListAux  :   SEMIC FormalParams FormalParamListAux               {$$=createNode("FuncParamsAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=createNode("FuncParams",NULL,0,0);}
FormalParams        :   VAR IDList COLON Id                                 {$$=createNode("VarParams",NULL,0,2,$2,$4);}
                    |   IDList COLON Id                                     {$$=createNode("Params",NULL,0,2,$1,$3);}
FuncBlock           :   VarPart StatPart                                    {$$=createNode("FuncBlock",NULL,1,2,$1,$2);}
StatPart            :   CompStat                                            {$$=createNode("StatPart",NULL,1,1,$1);}
CompStat            :   BEGINTOKEN StatList END                             {$$=createNode("CompStat",NULL,1,1,$2);}
StatList            :   Stat StatListAux                                    {$$=createNode("StatList",NULL,0,2,$1,$2);}
StatListAux         :   SEMIC Stat StatListAux                              {$$=createNode("StatListAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}
Stat                :   CompStat                                            {$$=createNode("CompStat",NULL,1,1,$1);}
                    |   IF Expr THEN Stat ELSE Stat                         {$$=createNode("IfElse",NULL,0,3,$2,$4,$6);}
                    |   IF Expr THEN Stat                                   {$$=createNode("If",NULL,1,2,$2,$4);}
                    |   WHILE Expr DO Stat                                  {$$=createNode("While",NULL,0,2,$2,$4);}
                    |   REPEAT StatList UNTIL Expr                          {$$=createNode("Repeat",NULL,0,2,$2,$4);}
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
Expr                :   Expr OR Expr                                        {$$=createNode("Or",NULL,0,2,$1,$3);}
                    |   Expr AND Expr                                       {$$=createNode("And",NULL,0,2,$1,$3);}
                    |   Expr DIFF Expr                                      {$$=createNode("Neq",NULL,0,2,$1,$3);}
                    |   Expr DIV Expr                                       {$$=createNode("Div",NULL,0,2,$1,$3);}
                    |   Expr MOREEQUAL Expr                                 {$$=createNode("Geq",NULL,0,2,$1,$3);}
                    |   Expr LESSEQUAL Expr                                 {$$=createNode("Leq",NULL,0,2,$1,$3);}
                    |   Expr MOD Expr                                       {$$=createNode("Mod",NULL,0,2,$1,$3);}
                    |   Expr '=' Expr                                       {$$=createNode("Eq",NULL,0,2,$1,$3);}
                    |   Expr '+' Term                                       {$$=createNode("Add",NULL,0,2,$1,$3);}
                    |   Expr '-' Term                                       {$$=createNode("Sub",NULL,0,2,$1,$3);}
                    |   Expr '/' Expr                                       {$$=createNode("RealDiv",NULL,0,2,$1,$3);}
                    |   Expr '*' Expr                                       {$$=createNode("Mul",NULL,0,2,$1,$3);}
                    |   Expr '<' Expr                                       {$$=createNode("Lt",NULL,0,2,$1,$3);}
                    |   Expr '>' Expr                                       {$$=createNode("Gt",NULL,0,2,$1,$3);}
                    |   '+' Term                                            {$$=createNode("Plus",NULL,0,1,$2);}
                    |   '-' Term                                            {$$=createNode("Minus",NULL,0,1,$2);}
                    |   NOT Expr                                            {$$=createNode("Not",NULL,0,1,$2);}
                    |   LBRAC Expr RBRAC                                    {$$=createNode("BracketsExpr",NULL,1,1,$2);}
                    |   INTLIT                                              {$$=createNode("IntLit",itoa($1,str),0,0);}
                    |   REALLIT                                             {$$=createNode("RealLit",$1,0,0);}
                    |   Id ParamList                                        {$$=createNode("ParamListExpr",NULL,1,1,$1);}
                    |   Id                                                  {$$=$1;}



Term                :   Term OR Term                                        {$$=createNode("Or",NULL,0,2,$1,$3);}
                    |   Term AND Term                                       {$$=createNode("And",NULL,0,2,$1,$3);}
                    |   Term DIFF Term                                      {$$=createNode("Neq",NULL,0,2,$1,$3);}
                    |   Term DIV Term                                       {$$=createNode("Div",NULL,0,2,$1,$3);}
                    |   Term MOREEQUAL Term                                 {$$=createNode("Geq",NULL,0,2,$1,$3);}
                    |   Term LESSEQUAL Term                                 {$$=createNode("Leq",NULL,0,2,$1,$3);}
                    |   Term MOD Term                                       {$$=createNode("Mod",NULL,0,2,$1,$3);}
                    |   Term '=' Term                                       {$$=createNode("Eq",NULL,0,2,$1,$3);}
                    |   Term '+' Term                                       {$$=createNode("Add",NULL,0,2,$1,$3);}
                    |   Term '-' Term                                       {$$=createNode("Sub",NULL,0,2,$1,$3);}
                    |   Term '/' Term                                       {$$=createNode("RealDiv",NULL,0,2,$1,$3);}
                    |   Term '*' Term                                       {$$=createNode("Mul",NULL,0,2,$1,$3);}
                    |   Term '<' Term                                       {$$=createNode("Lt",NULL,0,2,$1,$3);}
                    |   Term '>' Term                                       {$$=createNode("Gt",NULL,0,2,$1,$3);}
                    |   NOT Term                                            {$$=createNode("Not",NULL,0,1,$2);}
                    |   LBRAC Term RBRAC                                    {$$=createNode("BracketsTerm",NULL,1,1,$2);}
                    |   INTLIT                                              {$$=createNode("IntLit",itoa($1,str),0,0);}
                    |   REALLIT                                             {$$=createNode("RealLit",$1,0,0);}
                    |   Id ParamList                                        {$$=createNode("ParamListTerm",NULL,1,1,$1);}
                    |   Id                                                  {$$=$1;}
                    |   LBRAC '-' Term RBRAC                                {$$=createNode("Minus",NULL,0,1,$3);}
                    |   LBRAC '+' Term RBRAC                                {$$=createNode("Plus",NULL,0,1,$3);}

ParamList           :   LBRAC Expr ParamListAux RBRAC                       {$$=createNode("ParamList",NULL,1,2,$2,$3);}
ParamListAux        :   COMMA Expr ParamListAux                             {$$=createNode("ParamListAux",NULL,1,2,$2,$3);}
                    |   /*%empty*/                                          {$$=NULL;}

//regra auxiliar para criar nó com ID
Id                  :   ID                                                  {$$=createNode("Id",$1,0,0);}

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
