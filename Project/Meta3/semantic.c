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
        for(i = 0; i < node->nr_children; i++)
            statement(node->children[i], table);
    }
}

void statement(ast_nodeptr node, Table table) {
    int i;
    //printf("node-type: %s\n", node->type);
    if(!strcmp(node->type, "Assign")) {
        assign(node, table);
    }
    
    if(!strcmp(node->type, "IfElse")) {
        ifelse(node, table);
    }
    
    if(!strcmp(node->type, "Repeat")) {
        repeat(node, table);
    }
    if(!strcmp(node->type, "StatList")) {
        for(i = 0; i < node->nr_children; i++) {
            statement(node->children[i], table);
        }
    }
    
    if(!strcmp(node->type, "ValParam")) {
        valparam(node, table);
    }

    if(!strcmp(node->type, "While")) {
        whiles(node, table);
    }
    
    if(!strcmp(node->type, "WriteLn")) {
        writeln(node, table);
    }
}

void assign(ast_nodeptr node, Table table) {
    //printf("Assign\n");
    Info first = get_info_scope(table, node->children[0]->value);

    if(first == NULL) {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
        set_error(node->children[0], error_reason);
    }

    Info second = operation(node->children[1], table);

    if(second == NULL) {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[1]->value);
        set_error(node->children[1], error_reason);
    }

    if(strcmp(first->type, second->type)) {
        if(!strcmp(first->type, "_real_") && !strcmp(second->type, "_integer_")) {
           return;
        }
        char error_reason[128];
        sprintf(error_reason, "Incompatible type in assigment to %s (got %s, expected %s)", first->value, second->type, first->type);
        set_error(node, error_reason);
    }
}

void ifelse(ast_nodeptr node, Table table) {    
    Info first = operation(node->children[0], table);

    if(first == NULL) {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
        set_error(node->children[0], error_reason);
    }

    if(strcmp(first->type, "_boolean_")) {
        char error_reason[128];
        sprintf(error_reason, "Incompatible type in %s statement (got %s, expected %s)", node->value, first->type, "_boolean_");
        set_error(node->children[0], error_reason);
    }

    statement(node->children[1], table);
    statement(node->children[2], table);
}

void repeat(ast_nodeptr node, Table table) {
    statement(node->children[0], table);
    Info second = operation(node->children[1], table);

    if(second == NULL) {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[1]->value);
        set_error(node->children[1], error_reason);
    }

    if(strcmp(second->type, "_boolean_")) {
        char error_reason[128];
        sprintf(error_reason, "Incompatible type in %s statement (got %s, expected %s)", "repeat-until", second->type, "_boolean_");
        set_error(node->children[1], error_reason);
    }
}

void valparam(ast_nodeptr node, Table table) {
    Info first = operation(node->children[0], table);

    if(first == NULL) {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
        set_error(node->children[0], error_reason);
    }
    Info second = operation(node->children[1], table);

    if(second == NULL) {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[1]->value);
        set_error(node->children[1], error_reason);
    }
}

void whiles(ast_nodeptr node, Table table) {
    Info first = operation(node->children[0], table);

    if(first == NULL) {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
        set_error(node->children[0], error_reason);
    }

    if(strcmp(first->type, "_boolean_")) {
        char error_reason[128];
        sprintf(error_reason, "Incompatible type in %s statement (got %s, expected %s)", node->value, first->type, "_boolean_");
        set_error(node->children[0], error_reason);
    }
    statement(node->children[1], table);
}

void writeln(ast_nodeptr node, Table table) {
    int i;

    for(i = 0; i < node->nr_children; i++) {
        Info first = operation(node->children[i], table);


        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[i]->value);
            set_error(node->children[i], error_reason);
        }

        if(strcmp(first->type, "_real_")
        || strcmp(first->type, "_integer_")
        || strcmp(first->type, "_boolean_")) {
            char error_reason[128];
            sprintf(error_reason, "Cannot write values of type %s", first->type);
            set_error(node->children[i], error_reason);
        }
    }
}

Info operation(ast_nodeptr node, Table table) {
    Info info = (Info) malloc(sizeof(symbols_line));
    Info first, second;
    
    if(!strcmp(node->type, "Add") 
    || !strcmp(node->type, "Sub")
    || !strcmp(node->type, "Mul")) {
        first = operation(node->children[0], table);

        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
            set_error(node->children[0], error_reason);
        }

        second = operation(node->children[1], table);

        if(second == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[1]->value);
            set_error(node->children[1], error_reason);
        }

        if((!strcmp(first->type, "_real_") && !strcmp(second->type, "_real_"))
        || (!strcmp(first->type, "_integer_") && !strcmp(second->type, "_integer_"))) {
            sprintf(info->type, "%s", first->type);
            sprintf(info->value, "%s", node->value);
            return info;
        }
        if((!strcmp(first->type, "_integer_") && !strcmp(second->type, "_real_"))
        || (!strcmp(first->type, "_real_") && !strcmp(second->type, "_integer_"))) {
            sprintf(info->type, "%s", "_real_");
            sprintf(info->value, "%s", node->value);
            return info;
        }

        char error_reason[128];
        sprintf(error_reason, "Operator %s cannot be applied to types %s, %s", converter(node->type), first->type, second->type);
        set_error(node, error_reason);
    }
    if(!strcmp(node->type, "Plus")
    || !strcmp(node->type, "Minus")) {
        first = operation(node->children[0], table);

        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
            set_error(node->children[0], error_reason);
        }

        if(!strcmp(first->type, "_integer_") || !strcmp(first->type, "_real_")) {
            sprintf(info->type, "%s", first->type);
            sprintf(info->value, "%s", first->value);
            return info;
        }

        char error_reason[128];
        sprintf(error_reason, "Operator %s cannot be applied to type %s", converter(node->type), first->type);
        set_error(node, error_reason);
    }
    if(!strcmp(node->type, "RealDiv")) {
        first = operation(node->children[0], table);

        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
            set_error(node->children[0], error_reason);
        }

        second = operation(node->children[1], table);

        if(second == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[1]->value);
            set_error(node->children[1], error_reason);
        }

        if((!strcmp(first->type, "_real_") && !strcmp(second->type, "_real_"))
        || (!strcmp(first->type, "_integer_") && !strcmp(second->type, "_integer_"))
        || (!strcmp(first->type, "_integer_") && !strcmp(second->type, "_real_"))
        || (!strcmp(first->type, "_real_") && !strcmp(second->type, "_integer_"))) {
            sprintf(info->type, "%s", "_real_");
            sprintf(info->value, "%s", node->value);
            return info;
        }

        char error_reason[128];
        sprintf(error_reason, "Operator %s cannot be applied to types %s, %s", converter(node->type), first->type, second->type);
        set_error(node, error_reason);
    }
    if(!strcmp(node->type, "And")
    || !strcmp(node->type, "Or")) {
        first = operation(node->children[0], table);

        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
            set_error(node->children[0], error_reason);
        }    

        second = operation(node->children[1], table);

        if(second == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[1]->value);
            set_error(node->children[1], error_reason);
        }

        if(!strcmp(first->type, "_boolean_") && !strcmp(second->type, "_boolean_")) {
            sprintf(info->type, "%s", first->type);
            sprintf(info->value, "%s", node->value);
            return info;
        }

        char error_reason[128];
        sprintf(error_reason, "Operator %s cannot be applied to types %s, %s", converter(node->value), first->type, second->type);
        set_error(node, error_reason);
    }
    if(!strcmp(node->type, "Div") 
    || !strcmp(node->type, "Mod")) {
        first = operation(node->children[0], table);

        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
            set_error(node->children[0], error_reason);
        }

        second = operation(node->children[1], table);

        if(second == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[1]->value);
            set_error(node->children[1], error_reason);
        }

        if(!strcmp(first->type, "_integer_") && !strcmp(second->type, "_integer_")) {
            sprintf(info->type, "%s", first->type);
            sprintf(info->value, "%s", node->value);
            return info;
        }

        char error_reason[128];
        sprintf(error_reason, "Operator %s cannot be applied to types %s, %s", converter(node->value), first->type, second->type);
        set_error(node, error_reason);
    }
    if(!strcmp(node->type, "Not")) {
        first = operation(node->children[0], table);

        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
            set_error(node->children[0], error_reason);
        }
        
        if(!strcmp(first->type, "_boolean_")) {
            sprintf(info->type, "%s", first->type);
            sprintf(info->value, "%s", node->value);
            return info;
        }

        char error_reason[128];
        sprintf(error_reason, "Operator %s cannot be applied to types %s, %s", converter(node->value), first->type, second->type);
        set_error(node, error_reason);
    }
    if(!strcmp(node->type, "Eq")
    || !strcmp(node->type, "Gt")
    || !strcmp(node->type, "Geq")
    || !strcmp(node->type, "Leq")
    || !strcmp(node->type, "Lt")
    || !strcmp(node->type, "Neq")) {
        first = operation(node->children[0], table);

        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
            set_error(node->children[0], error_reason);
        }

        second = operation(node->children[1], table);

        if(second == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[1]->value);
            set_error(node->children[1], error_reason);
        }

        if((!strcmp(first->type, "_boolean_") && !strcmp(second->type, "_boolean_"))
        || (!strcmp(first->type, "_real_") && !strcmp(second->type, "_real_"))
        || (!strcmp(first->type, "_integer_") && !strcmp(second->type, "_integer_"))) {
            sprintf(info->type, "%s", "_boolean_");
            sprintf(info->value, "%s", node->value);
            return info;
        }

        char error_reason[128];
        sprintf(error_reason, "Operator %s cannot be applied to types %s, %s", converter(node->type), first->type, second->type);
        set_error(node, error_reason);
    }
    if(!strcmp(node->type, "Call")) {
        Info first = call(node, table);

        if(first == NULL) {
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
            set_error(node->children[0], error_reason);
        }
    }

    Info term = terminal(node, table);
    if(term != NULL) {
        return term;
    }
    else {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->value);
        set_error(node, error_reason);
    }
    return NULL;
}

Info terminal(ast_nodeptr node, Table table) {
    Info info = (Info) malloc(sizeof(symbols_line));

    if(!strcmp(node->type, "Id")) {
        info = get_info_scope(table, node->value);
        //printf("INFO: value %s type %s\n", info->value, info->type);
        return info;
    }
    if(!strcmp(node->type, "IntLit")) {
        sprintf(info->type, "_integer_");
        sprintf(info->value, "%s", node->value);
        return info;
    }
    if(!strcmp(node->type, "RealLit")) {
        sprintf(info->type, "_real_");
        sprintf(info->value, "%s", node->value);
        return info;
    }
    if(!strcmp(node->type, "String")) {
        sprintf(info->type, "String");
        sprintf(info->value, "%s", node->value);
        return info;
    }
    return NULL;
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
    //printf("Statement\n");
    statement(node->children[4], insert);
}

void funcdef2(ast_nodeptr node, Table table) {
    int i;

    Table insert = search_table(node->children[0]->value);
    if(insert == NULL) {
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
        set_error(node->children[0], error_reason);
    }

    for(i = 0; i < node->children[1]->nr_children; i++)
        varpart(node->children[1]->children[i], insert);

    statement(node->children[2], insert);
}

Info call(ast_nodeptr node, Table table) {
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
        else {
            return info;
        }
    } else {
        // Symbol not defined
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
        set_error(node->children[0], error_reason);
    }
    return NULL;
}

void set_error(ast_nodeptr node, char* reason) {
    printf("Line %d, col %d: %s\n", node->line, node->column, reason);
    exit(0);
}

char* converter(char* type) {
    sprintf(return_type, "%s", type);
    if(!strcmp(type, "Add")) {
        sprintf(return_type, "+");
    }
    if(!strcmp(type, "Eq")) {
        sprintf(return_type, "=");
    }
    if(!strcmp(type, "Geq")) {
        sprintf(return_type, ">=");
    }
    if(!strcmp(type, "Gt")) {
        sprintf(return_type, ">");
    }
    if(!strcmp(type, "Leq")) {
        sprintf(return_type, "<=");
    }
    if(!strcmp(type, "Lt")) {
        sprintf(return_type, "<");
    }
    if(!strcmp(type, "Minus")) {
        sprintf(return_type, "-");
    }
    if(!strcmp(type, "Mul")) {
        sprintf(return_type, "*");
    }
    if(!strcmp(type, "Neq")) {
        sprintf(return_type, "<>");
    }
    if(!strcmp(type, "Plus")) {
        sprintf(return_type, "+");
    }
    if(!strcmp(type, "RealDiv")) {
        sprintf(return_type, "/");
    }
    if(!strcmp(type, "Sub")) {
        sprintf(return_type, "-");
    }
    // Variable Types
    if(!strcmp(type, "IntLit")) {
        sprintf(return_type, "_integer_");
    }
    if(!strcmp(type, "RealLit")) {
        sprintf(return_type, "_real_");
    }
    if(!strcmp(type, "String")) {
        sprintf(return_type, "String");
    }
    return return_type;
}
