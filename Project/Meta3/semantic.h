#include "symbol_table.h"
#include "ast.h"


int analizeTree(ast_nodeptr node, Table table, char * type);
int programTree(ast_nodeptr node, Table table, char * type);
int funcTree(ast_nodeptr node,Table table,char * type);
int varDeclTree(ast_nodeptr node,Table table,char * type);
int insertIds(ast_nodeptr node,Table table,char * type);
int funcIdInsert(ast_nodeptr node,Table table,char * type);
int funcVarTree(ast_nodeptr node,Table table,char * type);
