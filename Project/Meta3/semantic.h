#include "symbol_table.h"
#include "ast.h"


int analizeTree(Table current_table,ast_nodeptr node, Table table, char * type);
int programTree(ast_nodeptr node, Table table, char * type);
int funcTree(ast_nodeptr node,Table table,char * type);
int varDeclTree(ast_nodeptr node,Table table,char * type);
int insertIds(ast_nodeptr node, Table table ,char * type,int constant,char * returntype);
int funcIdInsert(ast_nodeptr node,Table table,char * type);
int funcVarTree(ast_nodeptr node,Table table,char * type);
int funcParamsTree(ast_nodeptr node,Table table,char * type);
void set_error(ast_nodeptr node, char* reason);
