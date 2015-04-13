typedef struct ast_node *ast_struct;

typedef struct ast_node {
	char *data;
	ast_struct children;
	int num_children;
} ast_node;