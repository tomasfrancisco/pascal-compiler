typedef struct ast_node {
	char *type;
	char *value;
	int nr_children;
	int superfluo;
	struct ast_node ** children;
} ast_node;

typedef struct ast_node *ast_nodeptr;

ast_nodeptr createNode(char *type, char *value ,int superfluo, int nr_children, ...);
int printTree(ast_nodeptr node,int treedepth);
