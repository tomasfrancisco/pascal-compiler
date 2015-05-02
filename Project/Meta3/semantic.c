#include "semantic.h"

char* to_lower(char* value) {
    int i;
    char* lower_value = (char*) malloc(sizeof(char) * 128);

    for(i = 0;  i < strlen(value); i++) {
        lower_value[i] = tolower(value[i]);
    }
    lower_value[i] = '\0';
    return lower_value;
}

int analizeTree(ast_nodeptr node, Table table, char * type){
    int i;
    if(!strcmp(node->type,"Program")){
        Table insert = insert_table(NULL,"Program");
        for(i = 0; i < node->nr_children; i++){
            programTree(node->children[i], insert, NULL);
        }
    }

    return 0;
}
int programTree(ast_nodeptr node, Table table, char * type){
    int i;

    if(!strcmp(node->type,"VarPart")){
        for(i=0;i<node->nr_children;i++){
            varDeclTree(node->children[i],table,NULL);
        }
    }

    if(!strcmp(node->type,"FuncPart")){
        for(i=0;i<node->nr_children;i++){
            funcTree(node->children[i],table,node->children[node->nr_children-1]->value);
        }
    }
    return 0;
}

int funcTree(ast_nodeptr node,Table table,char * type){
    if(!strcmp(node->type,"FuncDef")){
        insert_info(table, node->children[0]->value, "function",0, NULL);
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
        insert_info(table, to_lower(node->value), type, 0, NULL);
    }

    return 0;
}
