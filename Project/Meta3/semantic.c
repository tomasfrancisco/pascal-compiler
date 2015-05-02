#include "semantic.h"

int analizeTree(ast_nodeptr node,Table table,char * type){
    int i;
    if(!strcmp(node->type,"Program")){
        Table insert=insert_table(NULL,"Program");
        for(i=0;i<node->nr_children;i++){
            analizeTree(node->children[i],insert,NULL);
        }
    }

    if(!strcmp(node->type,"VarPart")){
        for(i=0;i<node->nr_children;i++){
            analizeTree(node->children[i],table,NULL);
        }
    }

    if(!strcmp(node->type,"VarDecl")){
        for(i=0;i<node->nr_children-1;i++){
            varDeclTree(node->children[i],table,node->children[node->nr_children-1]->value);
        }
    }


    return 0;
}

int varDeclTree(ast_nodeptr node,Table table,char * type){
    int i;

    if(!strcmp(node->type,"Id")){
        insert_info(table, node->value, type,0, NULL);
    }

    return 0;
}
