%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;
int yydebug = 0;

#ifdef YYDEBUG
  yydebug = 1;
#endif

void printRule(const char *, const char *);
void printTokenInfo(const char*, const char*);
int yyerror(const char *);

%}

%union {
int intval;
double val;
char *str_val;
}

%token <str_val>ID
%token <int>ENTERO
%token <double>FLOAT
%token <str_val>STRING

%token ASIG
%token OP_SUMA
%token OP_RESTA
%token OP_MUL
%token OP_DIV
%token OP_AND
%token OP_OR
%token OP_NOT
%token CMP_MAYOR
%token CMP_MENOR
%token CMP_MAYOR_IGUAL
%token CMP_MENOR_IGUAL
%token CMP_IGUAL
%token P_A
%token P_C
%token L_A
%token L_C
%token PUNTO_Y_COMA
%token IF
%token ELSE
%token WHILE
%token ENTRADA
%token SALIDA
%start program

%%

program : programa {printf("\nCOMPILACION OK\n");}
programa: programa sentencia {printRule("PROGRAMA", "PROGRAMA SENTENCIA");}; 
programa: sentencia {printRule("PROGRAMA", "SENTENCIA");}; 
sentencia: seleccion {printRule("SENTENCIA", "SELECCION");};
sentencia: asignacion {printRule("SENTENCIA", "ASIGNACION");};
sentencia: iteracion {printRule("SENTENCIA", "ITERACION");};
sentencia: entrada PUNTO_Y_COMA {printRule("SENTENCIA", "ENTRADA");};
sentencia: salida PUNTO_Y_COMA {printRule("SENTENCIA", "SALIDA");};
entrada: ENTRADA ID {printRule("ENTRADA", "ID");};
salida: 
      SALIDA STRING {printRule("SALIDA", "STRING");} 
    | SALIDA ID {printRule("SALIDA", "ID");};
seleccion: IF P_A condicion P_C L_A programa L_C {printRule("SELECCION", "SENTENCIA IF SIMPLE");};
seleccion: IF P_A condicion P_C L_A programa L_C ELSE L_A programa L_C {printRule("SELECCION", "SENTENCIA IF SIMPLE CON ELSE");}; 
iteracion: WHILE P_A condicion P_C L_A programa L_C {printRule("ITERACION", "WHILE");};
condicion: comparacion {printRule("CONDICION", "COMPARACION");};
condicion: OP_NOT comparacion {printRule("CONDICION", "CONDICION NEGADA");};
condicion: comparacion OP_AND comparacion {printRule("CONDICION", "COMPARACION ANIDADA AND");};
condicion: comparacion OP_OR comparacion {printRule("CONDICION", "COMPARACION ANIDADA OR");};
comparacion: expresion comparador expresion {printRule("COMPARACION", "EXPRESION COMPARADOR COMPARADOR EXPRESION");};
comparador: 
      CMP_MAYOR {printRule("COMPARADOR", "OP_CMP_MAYOR");} 
    | CMP_MENOR {printRule("COMPARADOR", "OP_CMP_MENOR");} 
    | CMP_MAYOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MAYOR_IGUAL");} 
    | CMP_MENOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MENOR_IGUAL");} 
    | CMP_IGUAL  {printRule("COMPARADOR", "OP_CMP_IGUAL");};
expresion: asignacion {printRule("EXPRESION", "ASIGNACION");};
asignacion: ID ASIG expresion PUNTO_Y_COMA {printRule("ASIGNACION", "ID ASIG EXPRESION PUNTO_Y_COMA");};
expresion: expresion OP_SUMA termino {printRule("EXPRESION", "EXPRESION OP_SUMA TERMINO");};
expresion: expresion OP_RESTA termino {printRule("EXPRESION", "EXPRESION OP_RESTA TERMINO");};
expresion: termino  {printRule("EXPRESION", "TERMINO");};
termino: termino OP_MUL factor {printRule("TERMINO", "TERMINO OP_MUL FACTOR");};
termino: termino OP_DIV factor {printRule("TERMINO", "TERMINO OP_DIV FACTOR");};
termino: factor {printRule("TERMINO", "FACTOR");};
factor: 
    P_A expresion P_C {printRule("FACTOR", "(EXPRESION)");}
    | ID {printRule("FACTOR", "ID");}
    | ENTERO {printRule("FACTOR", "ENTERO");}
    | FLOAT  {printRule("FACTOR", "FLOAT");}
    | STRING {printRule("FACTOR", "STRING");};

%%

void printRule(const char *lhs, const char *rhs) {
    if (yydebug){
      printf("%s -> %s\n", lhs, rhs);
    }
    return;
}

void printTokenInfo(const char* tokenType, const char* lexeme) {
    printf("TOKEN: %s LEXEME: %s\n", tokenType, lexeme);
}

int yyerror(const char *s) {
    printf("Syntax Error\n");
    printf("%s\n", s);
    return(1);
}

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL){
	 printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else{
	 yyparse();
  }

  fclose(yyin);
  return 0;
}

