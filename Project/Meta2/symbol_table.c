#include "symbol_table.h"

Table init_semantic_tables() {
	int i;
	char init_tables[2][32];
	strcpy(init_tables[0], "outer");
	strcpy(init_tables[1], "function");


	Table new_semantic_tables = insert_table(NULL, init_tables[0]);

	for(i = 1; i < 2; i++) {
		insert_table(new_semantic_tables, init_tables[i]);
	}
	return new_semantic_tables;
}

Table insert_table(Table semantic_table, char* name) {
	Table semantic_table_copy = semantic_table;
	Table new_table = (table*) malloc(sizeof(Table));

	// First insert
	if(semantic_table_copy == NULL) {
		semantic_table_copy = (Table) malloc(sizeof(table));
		if(semantic_table_copy != NULL) {
			sprintf(semantic_table_copy->name, "%s", name);
		} else printf("Error inserting %s table.\n", name);
		return semantic_table_copy;
	}

	if(new_table != NULL) {
		new_table->name = name;
		new_table->info = NULL;
		while(semantic_table_copy->next != NULL)
			semantic_table_copy = semantic_table_copy->next;
		semantic_table_copy->next = new_table;
	} else printf("Error inserting %s table.\n", name);
	return new_table;
}

void show_table(Table semantic_table) {
	for(Info next = semantic_table->info; next; next = next->next)
		printf("Symbol %s, type %s.\n", next->value, next->type);
}

Info insert_info(Table semantic_table, char* value, char* type, int constant, char* return_params) {
	Info new_info = (symbols_line*) malloc(sizeof(Info));

	if(new_info != NULL) {
		new_info->value = value;
		new_info->type = type;
		new_info->constant = constant;
		new_info->return_params = return_params;
	} else printf("Error inserting %s type. \n", type);
	return new_info;
}

Info search_info(Table semantic_tables, char* value) {
	for(Table next = semantic_tables; next; next = next->next)
		for(Info line = next->info; line; line = line->next)
			if(strcmp(line->value, value) == 0)
				return line;
	return NULL;
}