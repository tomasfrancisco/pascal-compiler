#include "semantic.h"

typedef struct label* Label;

Label root_label;

typedef struct label {
    int nr;
    char body[3000];
    int preds[1000];
    Label next_label;

} label;

void compiler(ast_nodeptr tree, Table table);
void global_variables(Table table);
void functions(ast_nodeptr tree, Table table);
void func_declaration(ast_nodeptr tree, Table func_table);
char* type_converter(char* type);
int type_assign(char* type);
