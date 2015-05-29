#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "ast.h"

ast_nodeptr createNode(int line, int column, char *type, char *value ,int superfluo, int nr_children, ...){
	va_list valist;

	if(nr_children==0 && superfluo != 1){ //se tem 0 ou é terminal ou é uma exceção que é impressa na mesma, mesmo que não tenha filhos
		//ver enunciado as partes que têm (>=0), tipo funcpart e assim. Daí na gramática criar nós para isso
		//em alguns casos %empty
		ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
		node->type= strdup(type); //duplicar yylval senão dá porcaria
		if(value!=NULL){ //Nós tais nós excessão isto era passado a null, logo crashava por ser tentado fazer dup (o tal problema que estragava a submissao no B)
			node->value= strdup(value); //duplicar yylval senão dá porcaria
		}
		node->nr_children=0;
		node->superfluo=0;
		node->line=line;
		node->column=column;
		return node;
	}else{
		ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
		node->type= type; //duplicar yylval senão dá porcaria
		node->value= value; //duplicar yylval senão dá porcaria
		node->nr_children=nr_children;
		node->superfluo=superfluo;
		node->line=line;
		node->column=column;
		node->children= (ast_nodeptr*) malloc(nr_children*sizeof(ast_nodeptr)); //Array de filhos
		int i,j,indice=0; //Este indice é usado para manter a posição no array de filhos do nó a criar. Pk com os reallocs vamos estar a aumentar o nr de filhos e temos de manter um indice independente do indice original de filhos a percorrer
		ast_nodeptr temp;

		va_start(valist , nr_children); //Percorrer os nós filhos passados como argumentos
		for (i=0;i<nr_children; i++){
			temp= va_arg(valist,ast_nodeptr);
			if(temp!=NULL){ //Em alguns casos, alguns argumentos são passados como NULL, tipo nos empty, pois não era preciso criar nó
				//Quando isto acontece, decrementa-se o nr de filhos do nó que estamos a criar
				//Isto poderia ser verificado antes de chamar a função criarNode e chamá-la com menos argumentos mas assim é mais fácil

				/*if (!strcmp(type, "CompStat") && !strcmp(temp->type,"StatList") && temp->nr_children==0 && temp->value==NULL){
				temp->superfluo=1;
			}*/

			if(temp->superfluo){ //se o nó filho que estamos a analisar for superfluo, copiamos os filhos desse nó para o nó que estamos a criar
				node->nr_children+=(temp->nr_children-1);//-1 pk já está a contar com o nó superfluo que é um filho e vai ser descartado
				//printf("Incrementing nr_children of %s to %d\n",node->type,node->nr_children);
				node->children = (ast_nodeptr*) realloc (node->children,node->nr_children*sizeof(ast_nodeptr));
				for(j=0;j<temp->nr_children;j++){
					//printf("Putting %s of value %s in index %d of node %s coming from %s\n",temp->children[j]->type,temp->children[j]->value,indice,node->type,temp->type);
					node->children[indice]=temp->children[j];
					indice++;
				}
				//Pode-se fazer aqui um free, mas não nos pagam para isso, por isso fuck it
			}else{
				//printf("Putting %s of value %s in index %d of node %s\n",temp->type,temp->value,indice,node->type);
				node->children[indice]=temp;
				indice++;
			}
		}else{
			(node->nr_children)--;
			//printf("Decrementing nr_children of %s to %d\n",node->type,node->nr_children);
			//Caso em que se recebe um nó a NULL como argumento(no caso da regra puder devolver empty)
			//Decrementa-se o nr de children para depois bater certo
		}
	}
	if (!strcmp(type,"StatList") && value==NULL) {
		if (indice < 2) {
			node->superfluo = 1;
		}
	}
	if (!strcmp(type, "Program")) {
		if (indice < 4) {
			node->children = (ast_nodeptr*) realloc (node->children,(node->nr_children+1)*sizeof(ast_nodeptr));
			node->nr_children++;
			node->children[3] = createNode(-1,-1,"StatList",NULL,0,0);
		}
	}
	va_end(valist);
	return node;
}
/*
-criar node (se nr_children == 0, criar no terminal (ignorar os passos abaixo))
-MALLOC de array de nodes com nr_children
-percorrer cada child e ver se é no superfluo:
se sim: reallocar o array, não colocar esse nó no array, mas colocar os filhos
se não: colocar logo no array

é importante fazer isto por ordem pois para imprimir tem de estar ordenado ou seja se houverem 3 args
e arg1 tiver 3 filhos e for superfluo a imprimir fica:
filho1 filho2 filho3 arg2 arg3
-devolver node*/

}

int printTree(ast_nodeptr node,int treedepth){
	int i;
	for(i=0;i<treedepth;i++){
		printf("..");
	}
	printf("%s",node->type);
	if(node->value!=NULL && (strcmp(node->type,"StatList"))){
		if(!strcmp(node->type, "And")
		|| !strcmp(node->type, "Div")
		|| !strcmp(node->type, "Or")
		|| !strcmp(node->type, "Mod")
		|| !strcmp(node->type, "Not")
		|| !strcmp(node->type, "IfElse")) {

		}
		else {
			printf("(%s)",node->value);
		}
	}
	//printf(" Line:%d Column:%d",node->line,node->column);
	printf("\n");
	for(i=0;i<node->nr_children;i++){
		printTree(node->children[i],treedepth+1);
	}
	return 0;
}

char * itoa(int n, char * str){
	snprintf(str, 33, "%d", n);
	return str;
}


ast_nodeptr get_func_def(ast_nodeptr tree, char* id) {
	int i;
	ast_nodeptr funcpart_node, func_id;

	if(tree != NULL) {
		if((funcpart_node = tree->children[2]) != NULL) {	//FuncPart

			for(i = 0; i < funcpart_node->nr_children; i++) {
				if(!strcmp(funcpart_node->children[i]->type, "FuncDef")
				|| !strcmp(funcpart_node->children[i]->type, "FuncDef2")) {
					func_id = funcpart_node->children[i]->children[0];

					if(!strcmp(func_id->value, id)) {
						return funcpart_node->children[i]; //Devolve o nó da função correspondente a id
					}
				}
			}
		}
	}
	return NULL;
}
