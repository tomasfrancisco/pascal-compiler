#include "semantic.h"

void analize(ast_nodeptr node, Table table) {
    int i;

    if(!strcmp(node->type, "Program")) {
        Table insert = insert_table("Program");
        for(i = 0; i < node->nr_children; i++) {
            program(node->children[i], insert);
        }
    }
}

void program(ast_nodeptr node, Table table) {
    int i;

    if(!strcmp(node->type, "VarPart")) {
        for(i = 0; i < node->nr_children; i++)
            varpart(node->children[i], table);
    }
    if(!strcmp(node->type, "FuncPart")) {
        for(i = 0; i < node->nr_children; i++)
            funcpart(node->children[i], table);
    }
    else {
        other(node, table);
    }
}

void other(ast_nodeptr node, Table table) {
    int i;

    if(!strcmp(node->type, "Assign")) {
        for(i = 0; i < node->nr_children; i++) {
            assign(node->children[i], table);
        }
    }

    if(!strcmp(node->type, "IfElse")) {
        for(i = 0; i < node->nr_children; i++) {
            ifelse(node->children[i], table);
        }
    }

    if(!strcmp(node->type, "Repeat")) {
        for(i = 0; i < node->nr_children; i++) {
            repeat(node->children[i], table);
        }
    }

    if(!strcmp(node->type, "ValParam")) {
        valparam(node->children[i], table);
    }

    if(!strcmp(node->type, "While")) {
        whiles(node->children[i], table);
    }

    if(!strcmp(node->type, "WriteLn")) {
        for(i = 0; i < node->nr_children; i++) {
            writeln(node->children[i], table);
        }
    }
}

void assign(ast_nodeptr node, Table table) {

    
}

void add(ast_nodeptr node, Table table) {
    
}

void repeat(ast_nodeptr node, Table table) {
    int i;

    other(node, table);
    
}

void whiles(ast_nodeptr node, Table table) {
    int i;

    other(node, table);
}



void varpart(ast_nodeptr node, Table table) {
    int i;
    Info info = get_info_scope(table, node->children[node->nr_children - 1]->value);

    if(info != NULL) {
        if(strcmp(info->type, "_type_") != 0) {
            // Erro type expected
            set_error(node, "Type identifier expected");
        } else {
            for(i=0;i<node->nr_children-1;i++) {
                vardecl(node->children[i], table, node->children[node->nr_children-1]->value);
            }
        }
    } else {
        // Symbol not defined
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[node->nr_children-1]->value);
        set_error(node, error_reason);
    }
}

void vardecl(ast_nodeptr node, Table table, char* type) {
    insert_id(node, table, type, 0, NULL);
}

void insert_id(ast_nodeptr node, Table table, char* type, int constant, char* return_type) {
    if(!exists_decl(table, node->value)) {
        insert_info(table, node->value, type, constant, return_type);
    } else {
        // Duplicated var
        char error_reason[128];
        sprintf(error_reason, "Symbol %s already defined", node->value);
        set_error(node, error_reason);
    }
}

void funcpart(ast_nodeptr node, Table table) {
    if(!strcmp(node->type, "FuncDecl")) {
        funcdecl(node, table);
    }
    if(!strcmp(node->type, "FuncDef")) {
        funcdef(node, table);
    }
    if(!strcmp(node->type, "FuncDef2")) {
        funcdef2(node, table);
    }
}

void funcdecl(ast_nodeptr node, Table table) {
    int i;

    insert_id(node->children[0], table, "function", 0, NULL);

    Table insert = insert_table("Function");
    insert_id(node->children[0], insert, node->children[2]->value, 0, "return");
    for(i = 0; i < node->children[1]->nr_children; i++)    
        funcparams(node->children[1]->children[i], insert);
}

void funcparams(ast_nodeptr node, Table table) {
    int i;
    
    if(!strcmp(node->type, "Params")) {
        Info info = get_info_scope(table, node->children[node->nr_children - 1]->value);
  
        if(info != NULL) {
            if(strcmp(info->type, "_type_") != 0) {
                // Erro type expected
                set_error(node, "Type identifier expected");
            } else {
                for(i=0;i<node->nr_children-1;i++) {
                    insert_id(node->children[i], table, node->children[node->nr_children-1]->value, 0, "param");
                }
            }
        } else {
            // Symbol not defined
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[node->nr_children-1]->value);
            set_error(node, error_reason);
        }
    }
    if(!strcmp(node->type, "VarParams")) {
        Info info = get_info_scope(table, node->children[node->nr_children - 1]->value);
  
        if(info != NULL) {
            if(strcmp(info->type, "_type_") != 0) {
                // Erro type expected
                set_error(node, "Type identifier expected");
            } else {
                for(i=0;i<node->nr_children-1;i++) {
                    insert_id(node->children[i], table, node->children[node->nr_children-1]->value, 0, "varparam");
                }
            }
        } else {
            // Symbol not defined
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[node->nr_children-1]->value);
            set_error(node, error_reason);
        }
    }
}

void funcdef(ast_nodeptr node, Table table) {
    int i;

    insert_id(node->children[0], table, "function", 0, NULL);

    Table insert = insert_table("Function");
    insert_id(node->children[0], insert, node->children[2]->value, 0, "return");

    for(i = 0; i < node->children[1]->nr_children; i++)    
        funcparams(node->children[1]->children[i], insert);
    
    for(i = 0; i < node->children[3]->nr_children; i++)
        varpart(node->children[3]->children[i], insert);
}

void funcdef2(ast_nodeptr node, Table table) {
    int i;

    Table insert = search_table(node->children[0]->value);
    if(insert == NULL) {
        insert = insert_table("Function");
    }

    for(i = 0; i < node->children[1]->nr_children; i++)
        varpart(node->children[1]->children[i], insert);
}

void ifelse(ast_nodeptr node, Table table) {
    int i; 

    if(!strcmp(node->type, "StatList")) {
        for(i = 0; i < node->nr_children; i++) {
            statlist(node->children[i], table);
        }
    }
}

void statlist(ast_nodeptr node, Table table) {
    int i;

    if(!strcmp(node->type, "WriteLn")) {
        for(i = 0; i < node->nr_children; i++) {
            writeln(node->children[i], table);
        }
    }
    if(!strcmp(node->type, "ValParam")) {
        valparam(node, table);
    }
}

void writeln(ast_nodeptr node, Table table) {
    int i;

    if(!strcmp(node->type, "Call")) {
        call(node, table);
    }
}

//TODO
void valparam(ast_nodeptr node, Table table) {

}

void call(ast_nodeptr node, Table table) {
    Table func_table;
    Info info = get_info_func(node->children[0]->value);
  
    if(info != NULL) {
        int n_arguments = 0;

        func_table = get_func_table(node->children[0]->value);

        info = func_table->info;

        while(info != NULL) {
            if(!strcmp(info->return_params,"param") || !strcmp(info->return_params,"varparam"))
                n_arguments++;
            info = info->next;
        }
       
        if(n_arguments != node->nr_children - 1){

            char error_reason[128];
            sprintf(error_reason, "Wrong number of arguments in call to function %s (got %d, expected %d)", node->children[0]->value, node->nr_children-1, n_arguments);
            set_error(node->children[0],error_reason);
        }
    } else {
        // Symbol not defined
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[node->nr_children-1]->value);
        set_error(node, error_reason);
    }
}

void set_error(ast_nodeptr node, char* reason) {
    printf("Line %d, col %d: %s\n", node->line, node->column, reason);
    exit(0);
}