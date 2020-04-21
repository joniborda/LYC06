%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <conio.h>
    #include <string.h>
    #include "y.tab.h"
    int yystopparser=0;
    FILE  *yyin;

    void printRule(const char *, const char *);
    void printTokenInfo(const char*, const char*);
    int yyerror(const char *);
    void limiteString(const char *);
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
%token C_A
%token C_C
%token PUNTO_Y_COMA
%token COMA
%token IF
%token ELSE
%token <intval> ENTERO
%token <val> FLOAT
%token <str_val>STRING
%token WHILE
%token ENTRADA
%token SALIDA
%token INICIA_DEC
%token FIN_DEC
%token TIPO_FLOAT
%token TIPO_INT
%token TIPO_STRING
%token BETWEEN
%start program

%left OP_SUMA OP_RESTA
%left OP_MUL OP_DIV
%right MENOS_UNARIO

%type <intval> expresionEntera
%type <val> expresionFlotante

%%

program: 
    bloque_declaraciones algoritmo {printf("\nCOMPILACION OK\n");}

bloque_declaraciones: 
    INICIA_DEC {printf("INI DEC\n");} declaraciones FIN_DEC {printf("FIN DEC\n");}
declaraciones:
    declaracion {printRule("DECS", "DEC");}
    | declaraciones declaracion {printRule("DECS", "DECS DEC");}
declaracion:
	TIPO_FLOAT lista_variables {printRule("DEC", "TIPO_FLOAT : LISTA_VARIABLES");}
	| TIPO_INT lista_variables {printRule("DEC", "TIPO_INT : LISTA_VARIABLES");}
	| TIPO_STRING lista_variables {printRule("DEC", "TIPO_STRING : LISTA_VARIABLES");}
lista_variables:
	ID {printRule("LISTA_VARIABLES", "ID");}
	| ID PUNTO_Y_COMA lista_variables {printRule("LISTA_VARIABLES", "ID PUNTO_Y_COMA LISTA_VARIABLES");}
algoritmo: 
    programa {printf("\nCOMPILACION OK\n");}
programa:
    programa sentencia {printRule("PROGRAMA", "PROGRAMA SENTENCIA");}; 
programa: 
    sentencia {printRule("PROGRAMA", "SENTENCIA");}; 
sentencia: 
    seleccion {printRule("SENTENCIA", "SELECCION");};
sentencia: 
    asignacion {printRule("SENTENCIA", "ASIGNACION");};
sentencia: 
    iteracion {printRule("SENTENCIA", "ITERACION");};
sentencia: 
    entrada PUNTO_Y_COMA {printRule("SENTENCIA", "ENTRADA");};
sentencia: 
    salida PUNTO_Y_COMA {printRule("SENTENCIA", "SALIDA");};
entrada: 
    ENTRADA ID {printRule("ENTRADA", "ID");};
salida: 
    SALIDA STRING {printRule("SALIDA", "STRING");} 
    | SALIDA ID {printRule("SALIDA", "ID");};
seleccion: 
    IF P_A condicion P_C L_A programa L_C {printRule("SELECCION", "SENTENCIA IF SIMPLE");};
seleccion: 
    IF P_A condicion P_C L_A programa L_C ELSE L_A programa L_C {printRule("SELECCION", "SENTENCIA IF SIMPLE CON ELSE");}; 
iteracion: 
    WHILE P_A condicion P_C L_A programa L_C {printRule("ITERACION", "WHILE");};
condicion: 
    comparacion {printRule("CONDICION", "COMPARACION");};
condicion: 
    OP_NOT comparacion {printRule("CONDICION", "CONDICION NEGADA");};
condicion: 
    comparacion OP_AND comparacion {printRule("CONDICION", "COMPARACION ANIDADA AND");};
condicion: 
    comparacion OP_OR comparacion {printRule("CONDICION", "COMPARACION ANIDADA OR");};
comparacion: 
    BETWEEN P_A ID COMA C_A expresion PUNTO_Y_COMA expresion C_C P_C {printRule("COMPARACION", "BETWEEN");};
comparacion: 
    expresion comparador expresion {printRule("COMPARACION", "EXPRESION COMPARADOR COMPARADOR EXPRESION");};
comparador: 
      CMP_MAYOR {printRule("COMPARADOR", "OP_CMP_MAYOR");} 
    | CMP_MENOR {printRule("COMPARADOR", "OP_CMP_MENOR");} 
    | CMP_MAYOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MAYOR_IGUAL");} 
    | CMP_MENOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MENOR_IGUAL");} 
    | CMP_IGUAL  {printRule("COMPARADOR", "OP_CMP_IGUAL");};

asignacion: 
    ID ASIG expresion PUNTO_Y_COMA {printRule("ASIGNACION", "ID ASIG EXPRESION PUNTO_Y_COMA");};
asignacion: 
    ID ASIG factor PUNTO_Y_COMA {printRule("ASIGNACION", "ID ASIG EXPRESION PUNTO_Y_COMA");};

expresion:  
    expresionEntera {printf("resultado %d ....", $1);}
    | expresionFlotante {printf("resultado %f ....", $1);}
    ;

expresionEntera : 
    ENTERO { printf("res = %d ", $$);printRule("exp ent", "entero");}
    | OP_RESTA expresionEntera %prec MENOS_UNARIO {$<intval>$ = $<intval>2 * -1;printRule("exp", "exp int neg");}
    | expresionEntera OP_SUMA expresionEntera {$$ = $1 + $3;printf("%d = %d + %d ", $$, $1, $3);printRule("exp ent", "suma");}
    | expresionEntera OP_RESTA expresionEntera {$$ = $1 - $3;printf("%d = %d - %d ", $$, $1, $3);printRule("exp ent", "resta");}
    | expresionEntera OP_MUL expresionEntera {$$ = $1 * $3;printf("%d = %d * %d ", $$, $1, $3);printRule("exp ent", "multi");}
    | expresionEntera OP_DIV expresionEntera {$$ = $1 / $3;printf("%d = %d / %d ", $$, $1, $3);printRule("exp ent", "div");}
    | P_A expresionEntera P_C {$$ = $2;printRule("EXP", "(EXP_ENT)");}
    ;

expresionFlotante:
    FLOAT {printf("res = %f ", $$); printRule("exp float", "float");}
    | OP_RESTA expresionFlotante %prec MENOS_UNARIO { $<val>$ = -$<val>2; printRule("exp", "exp float neg");}
    | expresionFlotante OP_SUMA expresionFlotante {$$ = $1 + $3; printRule("exp float", "suma");}
    | expresionFlotante OP_RESTA expresionFlotante {$$ = $1 - $3; printRule("exp float", "resta");}
    | expresionFlotante OP_MUL expresionFlotante {$$ = $1 * $3; printRule("exp float", "multi");}
    | expresionFlotante OP_DIV expresionFlotante {$$ = $1 / $3; printRule("exp float", "div");}
    | P_A expresionFlotante P_C {$$ = $2; printRule("EXP", "(EXP_FLOAT)");}
    ;

factor: 
    ID {printRule("FACTOR", "ID");}
    |STRING { limiteString($1); $<str_val>$ = $<str_val>1; printRule("FACTOR", "STRING");}
    ;  

%%

void printRule(const char *lhs, const char *rhs) {
    if (YYDEBUG) {
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
    exit(1);
    return(1);
}

void limiteString(const char *str) {
    //Se resta dos a la longitud del string por las comillas
    if(strlen(str) - 2 > 30) {
    printf("Error: El string supero los 30 caracteres\nvariable: %s", str);
    exit(1);
    }
    return;
}

int main(int argc,char *argv[]) {
    if((yyin = fopen(argv[1], "rt")) == NULL) {
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
    } else {
        // si al ejecutar Primera.exe paso un tercer parametro, no va a imprimir
        if (argc > 2) {
            noImprimir();
        }
        yyparse();
    }

    fclose(yyin);
    return 0;
}

