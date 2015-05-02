#include "symbol_table.h"
#include "ast.h"

int analizeTree(ast_nodeptr node,Table table,char * type);
int varDeclTree(ast_nodeptr node,Table table,char * type);
