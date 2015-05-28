#include "semantic.h"

void compiler(ast_nodeptr tree, Table table);
void global_variables(Table table);
void functions(ast_nodeptr tree, Table table);
void func_declaration(ast_nodeptr tree, Table func_table);
char* type_converter(char* type);
int type_assign(char* type);