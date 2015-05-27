#include "symbol_table.h"
#include "ast.h"


/*int analizeTree(ast_nodeptr node, Table table, char * type);
int programTree(ast_nodeptr node, Table table, char * type);
int funcTree(ast_nodeptr node,Table table,char * type);
int varDeclTree(ast_nodeptr node,Table table,char * type);
int insertIds(ast_nodeptr node, Table table ,char * type,int constant,char * returntype);
int funcIdInsert(ast_nodeptr node,Table table,char * type);
int funcVarTree(ast_nodeptr node,Table table,char * type);
int funcParamsTree(ast_nodeptr node,Table table,char * type);*/

char return_type[128];

void analize(ast_nodeptr node, Table table);
void program(ast_nodeptr node, Table table);
void varpart(ast_nodeptr node, Table table);
void vardecl(ast_nodeptr node, Table table, char* type);
void funcpart(ast_nodeptr node, Table table);
void insert_id(ast_nodeptr node, Table table, char* type, int constant, char* return_type);
void funcdecl(ast_nodeptr node, Table table);
void funcparams(ast_nodeptr node, Table table);
void funcdef(ast_nodeptr node, Table table);
void funcdef2(ast_nodeptr node, Table table);
void ifelse(ast_nodeptr node, Table table);
void statlist(ast_nodeptr node, Table table);
void writeln(ast_nodeptr node, Table table);
void valparam(ast_nodeptr node, Table table);
Info call(ast_nodeptr node, Table table);
void assign(ast_nodeptr node, Table table);
void repeat(ast_nodeptr node, Table table);
void whiles(ast_nodeptr node, Table table);
void statement(ast_nodeptr node, Table table);
Info operation(ast_nodeptr node, Table table);
Info terminal(ast_nodeptr node, Table table);

void set_error(ast_nodeptr node, char* reason);
char* converter(char* type);
