#include "semantic.h"

int insertIds(ast_nodeptr node, Table table,char * type,int constant,char * returntype){
    if(!strcmp(node->type,"Id")){
        if(!exists_decl(table, node->value)) {
            insert_info(table, node->value, type, constant, returntype);
        } else {
            // Duplicated var
            char error_reason[128];
            sprintf(error_reason, "Symbol %s already defined", node->value);
            set_error(node, error_reason);
        }


    }

    return 0;
}

int analizeTree(ast_nodeptr node, Table table, char * type){
    int i;

    if(!strcmp(node->type,"Program")){
        Table insert = insert_table("Program");
        for(i = 0; i < node->nr_children; i++){
            programTree(node->children[i], insert, NULL);
        }
    }

    if(!strcmp(node->type, "FuncDecl")) {
        Table insert = insert_table("Function");
        insertIds(node->children[0],insert,node->children[2]->value,0,"return");
        funcParamsTree(node->children[1], insert,NULL);
    }

    if(!strcmp(node->type,"FuncDef")){
        Table insert=insert_table("Function");
        insertIds(node->children[0],insert,node->children[2]->value,0,"return");
        funcParamsTree(node->children[1], insert,NULL);
        funcVarTree(node->children[3], insert, NULL);
    }



    if(!strcmp(node->type, "FuncDef2")) {
        Table insert = search_table(node->children[0]->value);
        if(insert != NULL) {
            for(i = 0; i < node->nr_children; i++)
                funcVarTree(node->children[i], insert, NULL);
        }
        else
            insert = insert_table("Function");
    }

    /*if(!strcmp(node->type, "WriteLn")) {
        checkWriteLn(node);
    }*/

    for(i=0;i<node->nr_children;i++){
        analizeTree(node->children[i],root_semantic_tables,NULL);
    }

    return 0;
}

int programTree(ast_nodeptr node, Table table,char * type){
    int i;

    if(!strcmp(node->type,"VarPart")){
        for(i=0;i<node->nr_children;i++){
            varDeclTree(node->children[i], table, NULL);
        }
    }

    if(!strcmp(node->type,"FuncPart")){
        for(i=0;i<node->nr_children;i++){
            funcIdInsert(node->children[i],table,node->children[node->nr_children-1]->value);
        }
    }
    return 0;
}

int funcVarTree(ast_nodeptr node,Table table,char * type){
    int i;

    if(!strcmp(node->type,"VarPart")){
        for(i=0;i<node->nr_children;i++){
            varDeclTree(node->children[i],table,NULL);
        }
    }

    return 0;
}

int funcParamsTree(ast_nodeptr node,Table table,char * type){
    int i,j;
    for(i=0;i<node->nr_children;i++){
        if(!strcmp(node->children[i]->type,"Params")){
            Info info = get_info(table, node->children[i]->children[node->children[i]->nr_children-1]->value);
            if(info != NULL) {
                //printf("\nvalue:%s-type:%s\n", info->value, info->type);
                if(strcmp(info->type, "_type_") != 0) {
                    // Erro type expected
                    set_error(node->children[i]->children[node->children[i]->nr_children-1], "Type identifier expected");
                } else {
                    for(j=0;j<node->children[i]->nr_children-1;j++){
                        insertIds(node->children[i]->children[j],table,info->value,0,"param");                    }
                }
            } else {
                // Symbol not defined
                char error_reason[128];
                sprintf(error_reason, "Symbol %s not defined", node->children[i]->children[node->children[i]->nr_children-1]->value);
                set_error(node->children[i]->children[node->children[i]->nr_children-1], error_reason);
            }
        }

        if(!strcmp(node->children[i]->type,"VarParams")){
            Info info = get_info(table, node->children[i]->children[node->children[i]->nr_children-1]->value);
            if(info != NULL) {
                //printf("\nvalue:%s-type:%s\n", info->value, info->type);
                if(strcmp(info->type, "_type_") != 0) {
                    // Erro type expected
                    set_error(node->children[i]->children[node->children[i]->nr_children-1], "Type identifier expected");
                } else {
                    for(j=0;j<node->children[i]->nr_children-1;j++){
                        insertIds(node->children[i]->children[j],table,info->value,0,"varparam");
                    }
                }
            } else {
                // Symbol not defined
                char error_reason[128];
                sprintf(error_reason, "Symbol %s not defined", node->children[i]->children[node->children[i]->nr_children-1]->value);
                set_error(node->children[i]->children[node->children[i]->nr_children-1], error_reason);
            }
        }
    }
    return 0;
}

int funcIdInsert(ast_nodeptr node,Table table,char * type){
    if(!strcmp(node->type,"FuncDef")){
        insert_info(table, node->children[0]->value, "function",0,NULL);
    }

    if(!strcmp(node->type, "FuncDecl")) {
        insert_info(table, node->children[0]->value, "function",0, NULL);
    }




    return 0;
}

int varDeclTree(ast_nodeptr node,Table table,char * type){
    int i;
    if(!strcmp(node->type,"VarDecl")){
        Info info = get_info(table, node->children[node->nr_children-1]->value);
        //printf("TYPE: %s - INFO: %s\n", node->children[node->nr_children-1]->value, info->value, info->type, info->constant, info->return_params);
        //printf("%s\t%s", info->value, info->type);
        /*if(info->constant==1)
            printf("\t%s", "constant");

        if(strcmp(info->return_params,""))
            printf("\t%s",info->return_params);


            printf("\n");*/

        if(info != NULL) {
            //printf("\nvalue:%s-type:%s\n", info->value, info->type);
            if(strcmp(info->type, "_type_") != 0) {
                // Erro type expected
                set_error(node, "Type identifier expected");
            } else {
                for(i=0;i<node->nr_children-1;i++) {
                    insertIds(node->children[i], table, node->children[node->nr_children-1]->value,0,NULL);
                }
            }
        } else {
            // Symbol not defined
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->children[node->nr_children-1]->value);
            set_error(node, error_reason);
        }
    }

    return 0;
}


void set_error(ast_nodeptr node, char* reason) {
    printf("Line %d, col %d: %s\n", node->line, node->column, reason);
    exit(0);
}

/*int checkWriteLn(ast_nodeptr node){
    int i;
    for(i=0;i<node->nr_children;i++){
        if(!strcmp(node->children[i]->value,"Call")){
            //Verificar return type da function que está a ser chamada
            node->children[i]->children[0]->value;
        }
    }
}*/
