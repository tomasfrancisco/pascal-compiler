#include "symbol_table.h"
#include "ast.h"

char* to_lower(char* value);
int analizeTree(ast_nodeptr node, Table table, char * type);
int programTree(ast_nodeptr node, Table table, char * type);
int funcTree(ast_nodeptr node,Table table,char * type);
int varDeclTree(ast_nodeptr node,Table table,char * type);
int insertIds(ast_nodeptr node,Table table,char * type);