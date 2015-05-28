#include "compiler.h"

char i32[10] = "i32";
char i1[10] = "i1";
char double_type[10] = "double";
char error[10] = "error";

void compiler(ast_nodeptr tree, Table table) {
	Table outer = table;
	Table function = outer->next;
	Table program = NULL;
	int i;
	printf("\n");
	if(function != NULL) {
		if((program = function->next) != NULL) {
			Info program_table_ptr = program->info;
			while(program_table_ptr != NULL) {
				printf("@%s = common global %s %s, align %s\n", program_table_ptr->value, type_converter(program_table_ptr->type), 0);
				program_table_ptr = program_table_ptr->next;
			}
			
		}
	}
}

void search_for_value() {

}

char* type_converter(char* type) {
	if(!strcmp(type, "_integer_")) {
		return i32;
	}
	if(!strcmp(type, "_boolean_")) {
		return i1;
	}
	if(!strcmp(type, "_double_")) {
		return double_type;
	}
	return error;
}