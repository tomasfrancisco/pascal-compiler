#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>


typedef struct table* Table;
typedef struct symbols_line* Info;

Table root_semantic_tables;

typedef struct table {
	char name[32];
	Table next;
	Info info;
} table;

typedef struct symbols_line {
	char value[128];
	char type[128];
	int constant;
	char return_params[128];
	Info next;
} symbols_line;

Table init_semantic_tables();
Table insert_table(char* name);
void show_tables(Table semantic_table);
Info insert_info(Table semantic_table, char* value, char* type, int constant, char* return_params);
Info search_info(Table semantic_tables, char* value);
Table search_table(char* value);
char* to_lower(char* value);
int check_decl(Table semantic_table, char* value, char* type);
Info get_info_scope(Table semantic_table, char* value);
int exists_decl(Table semantic_table, char* value);
Info get_info_func(char* value);
Table get_func_table(char* value);
