#include "compiler.h"

char i32[10] = "i32";
char i1[10] = "i1";
char double_type[10] = "double";
char error[10] = "error";

void compiler(ast_nodeptr tree, Table table) {
	printf("\n");
	global_variables(table);
	printf("\n");
	functions(tree, table);
}

void global_variables(Table table) {
	Table outer = table;
	Table function = outer->next;
	Table program = outer->next->next;
	int i;

	if(program != NULL) {
		Info program_table_ptr = program->info;
		while(program_table_ptr != NULL) {
			if(!strcmp(program_table_ptr->type, "_integer_")
			|| !strcmp(program_table_ptr->type, "_boolean_")
			|| !strcmp(program_table_ptr->type, "_real_")) {
				printf("@%s = common global %s 0, align %d\n", program_table_ptr->value, type_converter(program_table_ptr->type), type_assign(program_table_ptr->type));
			}
			program_table_ptr = program_table_ptr->next;
		}

	}
}

void functions(ast_nodeptr tree, Table table) {
	Table outer = table;
	Table function = outer->next;
	Table program = outer->next->next;

	if(program != NULL) {
		Info program_table_ptr = program->info;
		while(program_table_ptr != NULL) {
			if(!strcmp(program_table_ptr->type, "_function_")) {
				Table func_table = get_func_table(program_table_ptr->value);
				if(func_table != NULL)
					func_declaration(tree, func_table);
			}
			program_table_ptr = program_table_ptr->next;
		}
	}
}

void func_declaration(ast_nodeptr tree, Table func_table) {
	int comma = 0;

	if(func_table != NULL) {
		Info func_variables = func_table->info;

		if(func_variables != NULL) {
			ast_nodeptr func = get_func_def(tree, func_variables->value);
			if(func != NULL)
				printf("define");
			else
				printf("declare"); //este caso alguma vez acontece? 

			printf(" %s @%s(", type_converter(func_variables->type), func_variables->value);
			func_variables = func_variables->next;

			while(func_variables != NULL) {
				if(!strcmp(func_variables->return_params, "param")) {
					if(comma) {
						printf(", %s @%s", type_converter(func_variables->type), func_variables->value);
					} else {
						printf("%s @%s", type_converter(func_variables->type), func_variables->value);
						comma = 1;
					}
				}
				func_variables = func_variables->next;
			}
			printf(")");

			if(func != NULL)
				printf(" {\n");
			else {
				printf("\n");
			}
		}
	}
}

char* type_converter(char* type) {
	if(!strcmp(type, "_integer_")) {
		return i32;
	}
	if(!strcmp(type, "_boolean_")) {
		return i1;
	}
	if(!strcmp(type, "_real_")) {
		return double_type;
	}
	return error;
}

int type_assign(char* type) {
	if(!strcmp(type, "_integer_")) {
		return 4;
	}
	if(!strcmp(type, "_boolean_")) {
		return 2;
	}
	if(!strcmp(type, "_real_")) {
		return 8;
	}
	return 0;
}
