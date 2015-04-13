ast_struct ast_create() {
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
}