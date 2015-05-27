/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     PROGRAM = 258,
     OUTPUT = 259,
     VAR = 260,
     FUNCTION = 261,
     BEGINTOKEN = 262,
     IF = 263,
     THEN = 264,
     ELSE = 265,
     WHILE = 266,
     DO = 267,
     REPEAT = 268,
     UNTIL = 269,
     PARAMSTR = 270,
     NOT = 271,
     RESERVED = 272,
     ASSIGN = 273,
     END = 274,
     VAL = 275,
     FORWARD = 276,
     WRITELN = 277,
     OR = 278,
     MOD = 279,
     DIV = 280,
     DIFF = 281,
     MOREEQUAL = 282,
     LESSEQUAL = 283,
     SEMIC = 284,
     COLON = 285,
     DOT = 286,
     LBRAC = 287,
     RBRAC = 288,
     COMMA = 289,
     ID = 290,
     STRING = 291,
     REALLIT = 292,
     INTLIT = 293,
     AND = 294
   };
#endif
/* Tokens.  */
#define PROGRAM 258
#define OUTPUT 259
#define VAR 260
#define FUNCTION 261
#define BEGINTOKEN 262
#define IF 263
#define THEN 264
#define ELSE 265
#define WHILE 266
#define DO 267
#define REPEAT 268
#define UNTIL 269
#define PARAMSTR 270
#define NOT 271
#define RESERVED 272
#define ASSIGN 273
#define END 274
#define VAL 275
#define FORWARD 276
#define WRITELN 277
#define OR 278
#define MOD 279
#define DIV 280
#define DIFF 281
#define MOREEQUAL 282
#define LESSEQUAL 283
#define SEMIC 284
#define COLON 285
#define DOT 286
#define LBRAC 287
#define RBRAC 288
#define COMMA 289
#define ID 290
#define STRING 291
#define REALLIT 292
#define INTLIT 293
#define AND 294




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 24 "mpacompiler.y"
{
    char ch;
    int i;
    char* str;
    void * ptr; //Void pointer para se puder passar nós pela stack (é um atrofio enorme com regras do yacc,
                //não perguntes, não vale a pena, basicamente todos os tipos de coisas que queiras passar, tens de declarar aqui)
                //mas devido a outro retardamento do yacc e lex, não pode ser ast_nodeptr pk y+l declaram union antes de declarar structs por isso não era reconhecido, granda atrofio)
}
/* Line 1529 of yacc.c.  */
#line 136 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

