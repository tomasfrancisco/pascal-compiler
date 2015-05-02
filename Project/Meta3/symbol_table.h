#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct table* Table;
typedef struct symbols_line* Info;

typedef struct table {
	char name[32];
	Table next;
	Info info;
} table;

typedef struct symbols_line {
	char* value;
	char* type;
	int constant;
	char* return_params;
	Info next;
} symbols_line;

Table init_semantic_tables();
Table insert_table(Table semantic_table, char* name);
void show_table(Table semantic_table);
Info insert_info(Table semantic_table, char* value, char* type, int constant, char* return_params);
Info search_info(Table semantic_tables, char* value);