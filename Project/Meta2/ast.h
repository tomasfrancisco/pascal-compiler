typedef struct ast_node *ast_nodeptr;

typedef struct ast_node {
	char *type;
	int nr_children;
	int superfluo;
	ast_node ** children;
} ast_node;
