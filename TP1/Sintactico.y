%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

void printRule(const char *, const char *);
void printTokenInfo(const char*, const char*);
int yyerror(const char *);

%}

%union {
int intval;
float val;
char *str_val;
}

%token <str_val>ID


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
%token ELSE
%token <intval> ENTERO
%token <val> FLOAT
%token <str_val>STRING

%start program

%left OP_SUMA OP_RESTA
%left OP_MUL OP_DIV

%type <intval> expresionentera
%type <val> expresionfloatante

%%

program : programa {printf("Compilacion OK");}
programa: programa sentencia {printRule("PROGRAMA", "PROGRAMA SENTENCIA");}; 
programa: sentencia {printRule("PROGRAMA", "SENTENCIA");}; 
sentencia: seleccion {printRule("SENTENCIA", "SELECCION");};
sentencia: asignacion {printRule("SENTENCIA", "ASIGNACION");};
seleccion: IF P_A condicion P_C L_A programa L_C {printRule("SELECCION", "SENTENCIA IF SIMPLE");};
seleccion: IF P_A condicion P_C L_A programa L_C ELSE L_A programa L_C {printRule("SELECCION", "SENTENCIA IF SIMPLE CON ELSE");}; 
condicion: comparacion {printRule("CONDICION", "COMPARACION");};
condicion: condicion OP_AND comparacion {printRule("CONDICION", "COMPARACION ANIDADA AND");};
condicion: condicion OP_OR comparacion {printRule("CONDICION", "COMPARACION ANIDADA OR");};
comparacion: expresion comparador expresion {printRule("COMPARACION", "EXPRESION COMPARADOR COMPARADOR EXPRESION");};
comparador: 
      CMP_MAYOR {printRule("COMPARADOR", "OP_CMP_MAYOR");} 
    | CMP_MENOR {printRule("COMPARADOR", "OP_CMP_MENOR");} 
    | CMP_MAYOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MAYOR_IGUAL");} 
    | CMP_MENOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MENOR_IGUAL");} 
    | CMP_IGUAL  {printRule("COMPARADOR", "OP_CMP_IGUAL");};

asignacion: ID ASIG expresion PUNTO_Y_COMA { printRule("ASIGNACION", "ID ASIG EXPRESION PUNTO_Y_COMA");};
asignacion: ID ASIG factor PUNTO_Y_COMA {printRule("ASIGNACION", "ID ASIG EXPRESION PUNTO_Y_COMA");};

expresion :  expresionentera {printf("response %d ....",$1 );}
            |expresionfloatante {printf("response %f ....",$1 );}
            ;

expresionentera : ENTERO
        | expresionentera OP_SUMA expresionentera {$$ = $1 + $3;}
        | expresionentera OP_RESTA expresionentera {$$ = $1 - $3;}
        | expresionentera OP_MUL expresionentera {$$ = $1 * $3;}
        | expresionentera OP_DIV expresionentera {$$ = $1 / $3;}
        | P_A expresionentera P_C { $$ = $2;printRule("EXPRESION", "(EXPRESIONentera)");}
        ;

expresionfloatante : FLOAT {$<val>$ = $<val>1;}
        | expresionfloatante OP_SUMA expresionfloatante {$$ = $1 + $3;}
        | expresionfloatante OP_RESTA expresionfloatante {$$ = $1 - $3;}
        | expresionfloatante OP_MUL expresionfloatante {$$ = $1 * $3;}
        | expresionfloatante OP_DIV expresionfloatante {$$ = $1 / $3;}
        | P_A expresionfloatante P_C {$$ = $2;printRule("EXPRESION", "(EXPRESION_FLOAT)");}
        ;

factor : ID {printRule("FACTOR", "ID");}
        |STRING { $<str_val>$ = $<str_val>1; printRule("FACTOR", "STRING");}
        ;  

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

