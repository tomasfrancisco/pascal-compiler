#include <stdlib.h>

#define INIT_TABLES 2

typedef struct table* Table;
typedef struct symbols_line* Info;

typedef struct table {
	char* name;
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

char init_tables[INIT_TABLES][32] = {"outer", "function"};

Table init_semantic_tables();
Table insert_table(char* name);
void show_table(Table semantic_table);
Info insert_info(char* value, char* type, int constant, int return_params);
Info search_info(Table semantic_tables, char* value);
