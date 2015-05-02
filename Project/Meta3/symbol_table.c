#include "symbol_table.h"

// Initilize table linked list with default tables
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

// Insert new table at the end of table linked list
Table insert_table(Table semantic_table, char* name) {
	Table semantic_table_copy = semantic_table;
	Table new_table = (Table) malloc(sizeof(table));

	if(semantic_table_copy == NULL) {
		if(new_table != NULL) {
			sprintf(new_table->name, "%s", name);
		} else printf("Error inserting %s table.\n", name);
		return new_table;
	}

	if(new_table != NULL) {
		sprintf(new_table->name, "%s", name);
		new_table->info = NULL;
		while(semantic_table_copy->next != NULL)
			semantic_table_copy = semantic_table_copy->next;
		semantic_table_copy->next = new_table;
	} else printf("Error inserting %s table.\n", name);
	return new_table;
}

// Print every information of semantic tables
void show_table(Table semantic_table) {
	for(Table next_table = semantic_table; next_table; next_table = next_table->next) {
		printf("Table %s\n", next_table->name);
		for(Info next_info = next_table->info; next_info; next_info = next_info->next)
			printf("Symbol %s, type %s.\n", next_info->value, next_info->type);
	}
}

// Insert new node at correspondent table
Info insert_info(Table semantic_table, char* value, char* type, int constant, char* return_params) {
	Info new_info = (Info) malloc(sizeof(symbols_line));

	if(new_info != NULL) {
		new_info->value = value;
		new_info->type = type;
		new_info->constant = constant;
		new_info->return_params = return_params;
		semantic_table->info = new_info;
	} else printf("Error inserting %s type. \n", type);
	return new_info;
}

// Search the node for each table
Info search_info(Table semantic_tables, char* value) {
	for(Table next = semantic_tables; next; next = next->next)
		for(Info line = next->info; line; line = line->next)
			if(strcmp(line->value, value) == 0)
				return line;
	return NULL;
}