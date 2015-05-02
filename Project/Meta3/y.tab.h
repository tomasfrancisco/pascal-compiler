/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
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
    AND = 278,
    OR = 279,
    MOD = 280,
    DIV = 281,
    DIFF = 282,
    MOREEQUAL = 283,
    LESSEQUAL = 284,
    SEMIC = 285,
    COLON = 286,
    DOT = 287,
    LBRAC = 288,
    RBRAC = 289,
    COMMA = 290,
    ID = 291,
    STRING = 292,
    REALLIT = 293,
    INTLIT = 294
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
#define AND 278
#define OR 279
#define MOD 280
#define DIV 281
#define DIFF 282
#define MOREEQUAL 283
#define LESSEQUAL 284
#define SEMIC 285
#define COLON 286
#define DOT 287
#define LBRAC 288
#define RBRAC 289
#define COMMA 290
#define ID 291
#define STRING 292
#define REALLIT 293
#define INTLIT 294

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 26 "mpaparser.y" /* yacc.c:1909  */

    char ch;
    int i;
    char* str;
    void * ptr; //Void pointer para se puder passar nós pela stack (é um atrofio enorme com regras do yacc,
                //não perguntes, não vale a pena, basicamente todos os tipos de coisas que queiras passar, tens de declarar aqui)
                //mas devido a outro retardamento do yacc e lex, não pode ser ast_nodeptr pk y+l declaram union antes de declarar structs por isso não era reconhecido, granda atrofio)

#line 141 "y.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
