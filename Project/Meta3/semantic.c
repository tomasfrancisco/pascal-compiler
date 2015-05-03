#include "semantic.h"

int analizeTree(ast_nodeptr node, Table table, char * type){
    int i;

    if(!strcmp(node->type,"Program")){
        Table insert = insert_table(NULL,"Program");
        for(i = 0; i < node->nr_children; i++){
            programTree(node->children[i], insert, NULL);
        }
    }

    if(!strcmp(node->type, "FuncDecl")) {
        Table insert = insert_table(NULL, "Function");
        insert_info(insert,node->children[0]->value,node->children[2]->value,0,"return");
        funcParamsTree(node->children[1], insert,NULL);
    }

    if(!strcmp(node->type,"FuncDef")){
        Table insert=insert_table(NULL,"Function");
        insert_info(insert,node->children[0]->value,node->children[2]->value,0,"return");
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
            insert = insert_table(NULL, "Function");
    }

    for(i=0;i<node->nr_children;i++){
        analizeTree(node->children[i],root_semantic_tables,NULL);
    }
    return 0;
}

int programTree(ast_nodeptr node,Table table,char * type){
    int i;

    if(!strcmp(node->type,"VarPart")){
        for(i=0;i<node->nr_children;i++){
            varDeclTree(node->children[i],table,NULL);
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
            for(j=0;j<node->children[i]->nr_children-1;j++){
                insert_info(table,node->children[i]->children[j]->value,node->children[i]->children[node->children[i]->nr_children-1]->value,0,"param");
            }
        }

        if(!strcmp(node->children[i]->type,"VarParams")){
            for(j=0;j<node->children[i]->nr_children-1;j++){
                insert_info(table,node->children[i]->children[j]->value,node->children[i]->children[node->children[i]->nr_children-1]->value,0,"varparam");
            }
        }
    }
    return 0;
}

int funcIdInsert(ast_nodeptr node,Table table,char * type){
    if(!strcmp(node->type,"FuncDef")){
        insert_info(table, node->children[0]->value, "function",0, NULL);
    }

    if(!strcmp(node->type, "FuncDecl")) {
        insert_info(table, node->children[0]->value, "function", 0, NULL);
    }

    return 0;
}

int varDeclTree(ast_nodeptr node,Table table,char * type){
    int i;
    if(!strcmp(node->type,"VarDecl")){
        for(i=0;i<node->nr_children-1;i++){
            insertIds(node->children[i],table,node->children[node->nr_children-1]->value);
        }
    }

    return 0;
}

int insertIds(ast_nodeptr node,Table table,char * type){
    if(!strcmp(node->type,"Id")){
        insert_info(table, node->value, type, 0, NULL);
    }

    return 0;
}
