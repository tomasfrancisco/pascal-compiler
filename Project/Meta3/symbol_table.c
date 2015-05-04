#include "symbol_table.h"

char* to_lower(char* value) {
	int i;
	char* lower_value = NULL;
	if(value!=NULL){
		lower_value = (char*) malloc(sizeof(char) * 128);

		for(i = 0;  i < strlen(value); i++) {
			lower_value[i] = tolower(value[i]);
		}
		lower_value[i] = '\0';
	}
	return lower_value;
}

// Initilize table linked list with default tables
Table init_semantic_tables() {
	int i;
	char init_tables[2][128];
	strcpy(init_tables[0], "Outer");
	strcpy(init_tables[1], "Function");
	root_semantic_tables = NULL;

	Table new_semantic_tables = insert_table(init_tables[0]);
	insert_info(new_semantic_tables, "boolean", "type", 1, "_boolean_");
	insert_info(new_semantic_tables, "integer", "type", 1, "_integer_");
	insert_info(new_semantic_tables, "real", "type", 1, "_real_");
	insert_info(new_semantic_tables, "false", "boolean", 1, "_false_");
	insert_info(new_semantic_tables, "true", "boolean", 1, "_true_");
	insert_info(new_semantic_tables, "paramcount", "function", 0, NULL);
	insert_info(new_semantic_tables, "program", "program", 0, NULL);

	Table function = insert_table(init_tables[1]);
	insert_info(function, "paramcount", "integer", 0, "return");

	return new_semantic_tables;
}

// Insert new table at the end of table linked list
Table insert_table(char* name) {
	Table current_table;


	Table new_table = (Table) malloc(sizeof(table));
	if(new_table != NULL) {
		sprintf(new_table->name, "%s", name);
		new_table->info = NULL;
		new_table->next = NULL;
	}

	if(root_semantic_tables == NULL) {
		root_semantic_tables = new_table;
	} else {
		current_table = root_semantic_tables;
		while(current_table->next != NULL) 
			current_table = current_table->next;
		current_table->next = new_table;
	}
	return new_table;
}

// Print every information of semantic tables
void show_tables(Table semantic_table) {
	Table next_table;
	for(next_table = semantic_table; next_table != NULL; next_table = next_table->next) {
		printf("===== %s Symbol Table =====\n", next_table->name);
		Info next_info;
		for(next_info = next_table->info; next_info != NULL; next_info = next_info->next){
			printf("%s\t%s", next_info->value, next_info->type);
			if(next_info->constant==1)
				printf("\t%s", "constant");

			if(strcmp(next_info->return_params,""))
				printf("\t%s",next_info->return_params);


			printf("\n");
		}
		if(next_table->next!=NULL){
			printf("\n");
		}
	}
}

// Insert new node at correspondent table
Info insert_info(Table semantic_table, char* value, char* type, int constant, char* return_params) {
	value = to_lower(value);
	type = to_lower(type);
	return_params = to_lower(return_params);

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
		sprintf(new_info->type, "_%s_", type);
		new_info->constant = constant;
		if(return_params!=NULL){
			sprintf(new_info->return_params, "%s", return_params);
		}else sprintf(new_info->return_params, "%s", "");
		new_info->next = NULL;

	} else printf("Error inserting %s type. \n", type);
	return new_info;
}

// Search the node for each table
Info search_info(Table semantic_tables, char* value) {
	Table next;
	for( next = semantic_tables; next; next = next->next){
		Info line;
		for( line = next->info; line; line = line->next)
			if(strcmp(line->value, value) == 0)
				return line;
	}
	return NULL;
}

Table search_table(char* value) {
	Table copy = root_semantic_tables;
	value = to_lower(value);
	for(copy; copy; copy = copy->next) {
		if(strcmp(copy->info->value, value) == 0 && strcmp(copy->info->return_params, "return") == 0) {
			return copy;
		}
	}
	return NULL;
}

Info get_info(Table semantic_table, char* value) {
	value = to_lower(value);
	Table outer = root_semantic_tables;
	Table program = root_semantic_tables->next->next;

	if(semantic_table == NULL) {
		//printf("MERDA NA FUNÇÃO GET_INFO\n");
		return NULL;
	}

	// Function
	Info current_info;
	for(current_info = semantic_table->info; current_info; current_info = current_info->next) {
		// existe o nó já declarado com o nome value
		if(strcmp(value, current_info->value) == 0) {
			return current_info;
		}
	}

	// Programa
	for(current_info = program->info; current_info; current_info = current_info->next) {
		// existe o nó já declarado com o nome value
		if(strcmp(value, current_info->value) == 0) {
			return current_info;
		}
	}

	// Outer
	for(current_info = outer->info; current_info; current_info = current_info->next) {
		// existe o nó já declarado com o nome value
		if(strcmp(value, current_info->value) == 0) {
			return current_info;
		}
	}

	return NULL;
}

int exists_decl(Table semantic_table, char* value) {
	value = to_lower(value);

	if(semantic_table == NULL) {
		//printf("MERDA NA FUNÇÃO EXISTS_DECL\n");
		return 0;
	}

	
	Info current_info;
	for(current_info = semantic_table->info; current_info; current_info = current_info->next) {
		if(strcmp(value, current_info->value) == 0)
			return 1;
	}
	return 0;
}

/*int check_decl(Table semantic_table, char* value, char* type) {
	Table current_table = semantic_table;
	Info current_info;

	Table outer = root_semantic_tables;
	Table function = root_semantic_tables->next;
	Table program = root_semantic_tables->next->next;

	Info types = root_semantic_tables->info;

	// Check this table
	for(current_info = current_table->info; current_info; current_info = current_info->next) {
		// Check if the type exists
		printf("---%s : %s - %s---\n", current_info->value, value, type);
		if(strcmp(type, current_info->value) == 0) {
			for(types; types; types = types->next) {
				if(strcmp(current_info->type, types->value)) {
					if(strcmp(types->value, "type")) {
						return 1;
					}
				}
			}
		}
	}

	if((current_table != outer) && (current_table != function) && (current_table != program)) {
		return check_decl(program, value, type);
	} else if((current_table != outer) && (current_table != function)) {
		return check_decl(function, value, type);
	} else if(current_table != outer) {
		return check_decl(outer, value, type);
	} else {
		printf("\nNOT\n");
		return 0;
	}
}*/

