
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
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


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ID = 258,
     ENTERO = 259,
     FLOAT = 260,
     STRING = 261,
     ASIG = 262,
     OP_SUMA = 263,
     OP_RESTA = 264,
     OP_MUL = 265,
     OP_DIV = 266,
     OP_AND = 267,
     OP_OR = 268,
     CMP_MAYOR = 269,
     CMP_MENOR = 270,
     CMP_MAYOR_IGUAL = 271,
     CMP_MENOR_IGUAL = 272,
     CMP_IGUAL = 273,
     P_A = 274,
     P_C = 275,
     L_A = 276,
     L_C = 277,
     PUNTO_Y_COMA = 278,
     IF = 279,
     ELSE = 280
   };
#endif
/* Tokens.  */
#define ID 258
#define ENTERO 259
#define FLOAT 260
#define STRING 261
#define ASIG 262
#define OP_SUMA 263
#define OP_RESTA 264
#define OP_MUL 265
#define OP_DIV 266
#define OP_AND 267
#define OP_OR 268
#define CMP_MAYOR 269
#define CMP_MENOR 270
#define CMP_MAYOR_IGUAL 271
#define CMP_MENOR_IGUAL 272
#define CMP_IGUAL 273
#define P_A 274
#define P_C 275
#define L_A 276
#define L_C 277
#define PUNTO_Y_COMA 278
#define IF 279
#define ELSE 280




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 15 "Sintactico.y"

int intval;
double val;
char *str_val;



/* Line 1676 of yacc.c  */
#line 110 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


