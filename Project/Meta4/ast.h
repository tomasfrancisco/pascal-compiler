typedef struct ast_node {
	char *type;
	char *value;
	int nr_children;
	int superfluo;
	struct ast_node ** children;
	int line,column;
} ast_node;

typedef struct ast_node *ast_nodeptr;

ast_nodeptr createNode(int line, int column, char *type, char *value ,int superfluo, int nr_children, ...);
int printTree(ast_nodeptr node,int treedepth);

ast_nodeptr get_func_def(ast_nodeptr tree, char* id);
