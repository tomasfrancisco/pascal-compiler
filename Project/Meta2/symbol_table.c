#include "symbol_table.h"

Table init_semantic_tables() {
	Table new_semantic_table = (table*) malloc(sizeof(Table));
	if(new_semantic_table != NULL)
		for(int i = 0; i < INIT_TABLES; i++) {
			if(new_semantic_table != NULL) {
				sprintf(new_semantic_table->name, init_tables[i]);
				new_semantic_table->next = NULL;
			}
		}
	else printf("Error setting new semantic table.\n");
	return new_semantic_table;
}

Table insert_table(char* name) {
	Table new_table = (table*) malloc(sizeof(Table));

	if(new_table != NULL) {
		new_table->name = name;
		new_table->info = NULL;
	} else printf("Error inserting %s table.\n", name);
	return new_table;
}

void show_table(Table semantic_table) {
	for(Info next = semantic_table->info; next; next = next->next)
		printf("Symbol %s, type %s.\n", next->value, next->type);
}

Info insert_info(char* value, char* type, int constant, int return_params) {
	Info new_info = (info*) malloc(sizeof(Info));

	if(new_info != NULL) {
		new_info->value = value;
		new_info->type = type;
		new_info->constant = constant;
		new_info->return_params = return_params;
	} else printf("Error inserting %s type. \n", type);
	return new_info;
}

Info search_info(Table semantic_tables, char* value) {
	for(Table next = semantic_table; next; next = next->next)
		if(strcmp(next->value, value) == 0)
			return next;
	return NULL;
}