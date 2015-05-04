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

int analizeTree(Table current_table,ast_nodeptr node, Table table, char * type){
    int i;

    if(!strcmp(node->type,"Program")){
        Table insert = insert_table("Program");
        current_table= insert;
        for(i = 0; i < node->nr_children; i++){
            programTree(node->children[i], insert, NULL);
        }
    }

    if(!strcmp(node->type, "FuncDecl")) {
        Table insert = insert_table("Function");
        current_table= insert;
        insertIds(node->children[0],insert,node->children[2]->value,0,"return");
        funcParamsTree(node->children[1], insert,NULL);
    }

    if(!strcmp(node->type,"FuncDef")){
        Table insert=insert_table("Function");
        current_table= insert;
        insertIds(node->children[0],insert,node->children[2]->value,0,"return");
        funcParamsTree(node->children[1], insert,NULL);
        funcVarTree(node->children[3], insert, NULL);
    }



    if(!strcmp(node->type, "FuncDef2")) {
        Table insert = search_table(node->children[0]->value);
        if(insert != NULL) {
            current_table= insert;
            for(i = 0; i < node->nr_children; i++)
                funcVarTree(node->children[i], insert, NULL);
        }
        else
            set_error(node->children[0],"Function identifier expected");
    }

    if(!strcmp(node->type, "WriteLn")) {
        checkWriteLn(node,current_table);
    }

    /*if(!strcmp(node->type, "Assign")) {
        checkAssign(node,current_table);
    }*/

    if(!strcmp(node->type, "Call")) {
        checkCall(node,current_table);
    }

    for(i=0;i<node->nr_children;i++){
        analizeTree(current_table,node->children[i],root_semantic_tables,NULL);
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
            Info info = get_info_scope(table, node->children[i]->children[node->children[i]->nr_children-1]->value);
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
            Info info = get_info_scope(table, node->children[i]->children[node->children[i]->nr_children-1]->value);
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
        Info info = get_info_scope(table, node->children[node->nr_children-1]->value);
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

int checkWriteLn(ast_nodeptr node,Table current_table){
    int i;
    for(i=0;i<node->nr_children;i++){

        if(!strcmp(node->children[i]->type,"Call")){
            //Verificar return type da function que está a ser chamada
            ast_nodeptr funcIdNode=node->children[i]->children[0];
            if(!exists_decl(root_semantic_tables->next->next,funcIdNode->value)){
                char error_reason[128];
                sprintf(error_reason, "Symbol %s not defined", funcIdNode->value);
                set_error(funcIdNode,error_reason);
            }else{
                Info info = get_info_scope(root_semantic_tables->next->next,funcIdNode->value);
                if(strcmp(info->type,"_function_")){
                    set_error(funcIdNode,"Function identifier expected");
                }
                checkCall(node->children[i],current_table);
            }
        }else if (!strcmp(node->children[i]->type,"Id")){
            //printf("Table %s: %s\n",current_table->name,current_table->info->value);
            //printf("Value: %s\n",node->children[i]->value);
            Info info;
            if((info=get_info_scope(current_table,node->children[i]->value))==NULL){
                char error_reason[128];
                sprintf(error_reason, "Symbol %s not defined", node->children[i]->value);
                set_error(node->children[i],error_reason);
            }else{
                //printf("%s",current_table->name);
                if(!strcmp(info->type,"_function_")){
                    //Quer dizer que encontrou uma função com 0 argumentos;
                    int nr_arguments=0;
                    Table func_table= get_func_table(NULL,info->value);
                    info=func_table->info;
                    while(info!=NULL){
                        if(!strcmp(info->return_params,"param")||!strcmp(info->return_params,"varparam"))
                            nr_arguments++;
                            info=info->next;
                        }
                        //printf("Nr arguments: %d",nr_arguments);
                        if(nr_arguments!=0){
                            char error_reason[128];
                            sprintf(error_reason, "Wrong number of arguments in call to function %s (got %d, expected %d)", node->children[0]->value,0,nr_arguments);
                            set_error(node->children[0],error_reason);
                        }
                }
                else if(!strcmp(info->type,"_type_")){
                    set_error(node->children[i],"Cannot write values of type _type_");
                }
            }
        }
    }
}

int checkAssign(ast_nodeptr node,Table current_table){
    ast_nodeptr expected = node->children[0];
    ast_nodeptr gotten = node->children[1];
        Info info;
        printf("What\n");
        if((info=get_info_scope(current_table,expected->value))==NULL){
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", expected->value);
            set_error(expected,error_reason);
        }else{
            char * type = checkExpression(gotten,current_table);
            if(strcmp(type,info->type)){
                char error_reason[128];
                sprintf(error_reason, "Incompatible type in assigment to %s (got %s expected %s)",expected->value,type,info->type);
                set_error(expected,error_reason);
            }
        }
}

char * checkExpression(ast_nodeptr node, Table current_table){

    char * left, *right;

    if(node->nr_children>0 && node->children[0]!=NULL){
        left = checkExpression(node->children[0],current_table);
    }
    if(node->nr_children>=2){
        if(node->children[1]!=NULL){
            right = checkExpression(node->children[1],current_table);
        }
    }

    if(!strcmp(node->type,"Id")){
        Info info;
        if((info=get_info_scope(current_table,node->value))==NULL){
            char error_reason[128];
            sprintf(error_reason, "Symbol %s not defined", node->value);
            set_error(node,error_reason);
        }else{
            return info->type;
        }
    }

    if(!strcmp(node->type,"Eq") ||!strcmp(node->type,"Neq") || !strcmp(node->type,"Eq") || !strcmp(node->type,"Lt") || !strcmp(node->type,"Gt")
        || !strcmp(node->type,"Leq") || !strcmp(node->type,"Geq")){
        return "_boolean_";
    }

    return "";
}

int checkCall(ast_nodeptr node ,Table current_table){
    Info info;
    Table func_table;
    //printf("Func: %s\n",node->children[0]->value);
    if((info=get_info_func(current_table,node->children[0]->value))==NULL){
        char error_reason[128];
        sprintf(error_reason, "Symbol %s not defined", node->children[0]->value);
        set_error(node->children[0],error_reason);
    }else{
        int nr_arguments=0;
        func_table= get_func_table(NULL,node->children[0]->value);
        info=func_table->info;
        while(info!=NULL){
            if(!strcmp(info->return_params,"param")||!strcmp(info->return_params,"varparam"))
                nr_arguments++;
            info=info->next;
        }
        //printf("Nr arguments: %d",nr_arguments);
        if(nr_arguments!=node->nr_children-1){
            char error_reason[128];
            sprintf(error_reason, "Wrong number of arguments in call to function %s (got %d, expected %d)", node->children[0]->value,node->nr_children-1,nr_arguments);
            set_error(node->children[0],error_reason);
        }
    }
}
