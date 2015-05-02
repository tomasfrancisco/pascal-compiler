#include "symbol_table.h"

// Initilize table linked list with default tables
Table init_semantic_tables() {
	int i;
	char init_tables[2][128];
	strcpy(init_tables[0], "===== Outer Symbol Table =====");
	strcpy(init_tables[1], "===== Function Symbol Table =====");


	Table new_semantic_tables = insert_table(NULL, init_tables[0]);
	insert_info(new_semantic_tables, "boolean", "_type_", 1, "_boolean_");
	insert_info(new_semantic_tables, "integer", "_type_", 1, "_integer_");
	insert_info(new_semantic_tables, "real", "_type_", 1, "_real_");
	insert_info(new_semantic_tables, "false", "_boolean_", 1, "_false_");
	insert_info(new_semantic_tables, "true", "_true_", 1, "_true_");
	insert_info(new_semantic_tables, "paramcount", "_function_", 0, NULL);
	insert_info(new_semantic_tables, "program", "_program_", 0, NULL);
	
	Table function = insert_table(new_semantic_tables, init_tables[1]);
	insert_info(function, "paramcount", "integer", 0, "return");

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

	while(semantic_table_copy->next != NULL)
		semantic_table_copy = semantic_table_copy->next;

	semantic_table_copy->next = new_table;

	if(new_table != NULL) {
		sprintf(new_table->name, "%s", name);
		new_table->info = NULL;
		new_table->next = NULL;
	} else printf("Error inserting %s table.\n", name);
	return new_table;
}

// Print every information of semantic tables
void show_tables(Table semantic_table) {
	for(Table next_table = semantic_table; next_table != NULL; next_table = next_table->next) {
		printf("%s\n", next_table->name);
		for(Info next_info = next_table->info; next_info != NULL; next_info = next_info->next)
			printf("%s\t%s\t%d\t%s\n", next_info->value, next_info->type, next_info->constant, next_info->return_params);
	}
}

// Insert new node at correspondent table
Info insert_info(Table semantic_table, char* value, char* type, int constant, char* return_params) {
	Table semantic_table_copy = semantic_table;
	Info info_copy;
	Info new_info = (Info) malloc(sizeof(symbols_line));

	if(new_info != NULL) {
		if(semantic_table_copy != NULL) {
			if(semantic_table_copy->info == NULL) 
				semantic_table_copy->info = new_info;
			else {
				info_copy = semantic_table_copy->info;
				while(info_copy->next != NULL)
					info_copy = info_copy->next;
				info_copy->next = new_info;
			}
		} else printf("Error inserting info, semantic table is null\n");

		sprintf(new_info->value, "%s", value);
		sprintf(new_info->type, "%s", type);
		new_info->constant = constant;
		sprintf(new_info->return_params, "%s", return_params);
		new_info->next = NULL;

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