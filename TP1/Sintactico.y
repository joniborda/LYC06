%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

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

%start program

%%

program : programa {printf("Compilacion OK");}
programa: programa sentencia; 
programa: sentencia; 
sentencia: seleccion;
sentencia: expresion PUNTO_Y_COMA;
seleccion: IF P_A condicion P_C L_A programa L_C {printf("Regla de seleccion");};
condicion: comparacion;
condicion: condicion OP_AND comparacion;
condicion: condicion OP_OR comparacion;
comparacion: expresion comparador expresion;
comparador: CMP_MAYOR | CMP_MENOR | CMP_MAYOR_IGUAL | CMP_MENOR_IGUAL | CMP_IGUAL;
expresion: asignacion;
asignacion: ID ASIG expresion;
expresion: expresion OP_SUMA termino;
expresion: expresion OP_RESTA termino;
expresion: termino
termino: termino OP_MUL factor;
termino: termino OP_DIV factor;
termino: factor;
factor: P_A expresion P_C | ID | ENTERO | FLOAT;

%%

void printRule(const char *lhs, const char *rhs) {
    printf("%s -> %s\n", lhs, rhs);
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

