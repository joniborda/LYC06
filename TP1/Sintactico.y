%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

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

%%

programa': programa {printf("Compilacon OK");}; 
programa: sentencia; 
sentencia: seleccion;
seleccion: IF (condicion) L_A programa L_C;
condicion: comparacion; 
condicion: condicion OP_AND comparacion;
condicion: condicion OP_OR comparacion;
comparacion: expresion comparador expresion;
comparador: CMP_MAYOR | CMP_MENOR | CMP_MAYOR_IGUAL | CMP_MENOR_IGUAL | CMP_IGUAL;
expresion: expresion OP_SUMA termino;
expresion: expresion OP_RESTA termino;
expresion: termino
termino: termino OP_MUL factor;
termino: termino OP_DIV factor;
termino: factor;
factor: (expresion) | ID | ENTERO | FLOAT;
	
%%
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

int yyerror(void){
  printf("Syntax Error\n");
	system ("Pause");
	exit (1);
}