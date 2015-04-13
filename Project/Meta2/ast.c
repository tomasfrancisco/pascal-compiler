/*ast_struct ast_create() {
	ast_struct tree = (ast_struct) malloc(sizeof(ast_node));
	tree->children = NULL;
	tree->num_children = 0;
	return tree;
}

ast_struct add_ast_child(ast_struct tree, char *child_data) {
	ast_struct child = NULL;

	if(tree == NULL)
		return NULL;

	child = ast_create();
	child->data = child_data;

	tree->children = realloc(tree->children, sizeof(ast_struct) * (tree->num_children + 1));
	tree->children[tree->num_children] = child;
	tree->num_children++;
}

void ast_destroy(ast_struct tree) {
	int i;

	if(tree == NULL)
		return NULL;

	for(i = 0; i < num_children; i++) {
		if(tree->children[i] != NULL) {
			ast_destroy(tree->children[i]);
			tree->children[i] = NULL;
		}
	}
	tree->children = NULL;
	free(tree);
}*/

/* A IDEIA AQUI É CRIAR OS NÓS E PASSÁ-LOS PARA O NÓ DE CIMA USANDO O TOPO DA STACK
   POIS A ÀRVORE É CRIADA DE BAIXO PARA CIMA, A FUNÇÃO QUE CRIA OS NÓS TEM DE RECEBER O NR
   DE ARGUMENTOS QUE VAI RECEBER E O NÓ. SE O NÓ RECEBIDO DA STACK FOR UM NÓ SUPERFLUO, OS CHILDS DESTE NÓ
   PASSAM PARA O NÓ PAI */

ast_node createNode(char *type, int superfluo, int nr_children, ...){
	va_list valist;

	if(nr_children==0){
		ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
		node->type= strdup(type); //duplicar yylval senão dá merda
		node->nr_children=0;
		node->superfluo=0;
		return node;
	}else{
		ast_nodeptr node = (ast_nodeptr) malloc(sizeof(ast_node));
		node->type= strdup(type); //duplicar yylval senão dá merda
		node->nr_children=nr_children;
		node->superfluo=superfluo;
		node->children= (ast_nodeptr*) malloc(nr_children*sizeof(ast_node));

		int i,j,indice=0;
		ast_nodeptr temp=(ast_nodeptr) malloc(sizeof(ast_node));

		va_start(valist, nr_children);
		for (i = 0; i < nr_children; i++){
			temp=va_arg(valist, ast_node);
			if(temp->superfluo){
				node->nr_children+= temp->nr_children;
				node->children = (ast_nodeptr*) realloc (node->children,node->nr_children*malloc(sizeof(ast_node));
				for(j=0;j<temp->nr_children;j++){
					node->children[indice]=temp->children[j];
					indice++;
				}
				//Pode-se fazer aqui um free, mas não nos pagam para isso, por isso fuck it
			}else{
				node->children[indice]=temp;
				indice++;
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
