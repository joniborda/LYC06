%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <conio.h>
    #include <string.h>
    #include "y.tab.h"
    #include "archivos_punto_H/tabla_simbolo.h"
    #include "archivos_punto_H/constantes.h"
    int yystopparser=0;
    FILE  *yyin;
    char *ids[100]; // Ids para guardar el tipo
    int idIndex = 0; // max numero de Ids guardados

    void printRule(const char *, const char *);
    void printTokenInfo(const char*, const char*);
    int yyerror(const char *);
    void agregarVariable();
    void actualizarTipo(int);
    void verificarNumerico(void *);
    void verificarIdDeclarado(void *);
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
%token DECS_2PTOS
%token BETWEEN
%token FACT
%token COMB


%left OP_SUMA OP_RESTA
%left OP_MUL OP_DIV
%right MENOS_UNARIO

%start program

%%

program: 
    bloque_declaraciones algoritmo {
        printf("\nCOMPILACION OK\n");
        tsCrearArchivo();
    }
	| algoritmo {
        printf("\nCOMPILACION OK\n");
        tsCrearArchivo();
    };

bloque_declaraciones: 
    INICIA_DEC {printf("INI DEC\n");} declaraciones FIN_DEC {
        printf("FIN DEC\n");
    }
	;

declaraciones:
    declaracion {printRule("DECS", "DEC");}
    | declaraciones declaracion {printRule("DECS", "DECS DEC");}
	;

declaracion:
	TIPO_INT DECS_2PTOS lista_variables {
        printRule("DEC", "TIPO_INT : LISTA_VARIABLES");
        actualizarTipo(T_INTEGER);
    }
	| TIPO_FLOAT DECS_2PTOS lista_variables {
        printRule("DEC", "TIPO_FLOAT : LISTA_VARIABLES");
        printf("ultimo tipo de variable %s\n", "float");
        actualizarTipo(T_FLOAT);
    }
	| TIPO_STRING DECS_2PTOS lista_variables {
        printRule("DEC", "TIPO_STRING : LISTA_VARIABLES");
        printf("ultimo tipo de variable %s\n", "string");
        actualizarTipo(T_STRING);
    }
	;

lista_variables:
	ID {
        printRule("LISTA_VARIABLES", "ID");
        agregarVariable();
    }
	| lista_variables PUNTO_Y_COMA ID  {
        printRule("LISTA_VARIABLES", "ID PUNTO_Y_COMA LISTA_VARIABLES");
        agregarVariable();
    }
	;

algoritmo: 
    programa {printRule("ALGORITMO", "PROGRAMA");}
	;

programa:
    sentencia {printRule("PROGRAMA", "SENTENCIA");}
    | programa sentencia {printRule("PROGRAMA", "PROGRAMA SENTENCIA");}
    ;

sentencia: 
    seleccion {printRule("SENTENCIA", "SELECCION");}
    | asignacion {printRule("SENTENCIA", "ASIGNACION");}
    | iteracion {printRule("SENTENCIA", "ITERACION");}
    | entrada PUNTO_Y_COMA {printRule("SENTENCIA", "ENTRADA");}
    | salida PUNTO_Y_COMA {printRule("SENTENCIA", "SALIDA");}
    ;

entrada: 
    ENTRADA ID {verificarIdDeclarado($2);} {printRule("ENTRADA", "ID");};

salida: 
    SALIDA STRING {printRule("SALIDA", "STRING");} 
    | SALIDA ID {verificarIdDeclarado($2);} {printRule("SALIDA", "ID");}
    ;

seleccion: 
    IF P_A condicion P_C L_A programa L_C {printRule("SELECCION", "SENTENCIA IF SIMPLE");}
    | IF P_A condicion P_C L_A programa L_C ELSE L_A programa L_C {
        printRule("SELECCION", "SENTENCIA IF SIMPLE CON ELSE");
    }
    ;

iteracion: 
    WHILE P_A condicion P_C L_A programa L_C {printRule("ITERACION", "WHILE");};

condicion: 
    comparacion {printRule("CONDICION", "COMPARACION");}
    | OP_NOT comparacion {printRule("CONDICION", "CONDICION NEGADA");}
    | comparacion OP_AND comparacion {printRule("CONDICION", "COMPARACION ANIDADA AND");}
    | comparacion OP_OR comparacion {printRule("CONDICION", "COMPARACION ANIDADA OR");}
    ;

comparacion: 
    BETWEEN P_A ID {verificarNumerico($3);} COMA C_A expresion PUNTO_Y_COMA expresion C_C P_C {printRule("COMPARACION", "BETWEEN");}
    | expresion comparador expresion {printRule("COMPARACION", "EXPRESION COMPARADOR COMPARADOR EXPRESION");}
    ;

comparador: 
    CMP_MAYOR {printRule("COMPARADOR", "OP_CMP_MAYOR");} 
    | CMP_MENOR {printRule("COMPARADOR", "OP_CMP_MENOR");} 
    | CMP_MAYOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MAYOR_IGUAL");} 
    | CMP_MENOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MENOR_IGUAL");} 
    | CMP_IGUAL  {printRule("COMPARADOR", "OP_CMP_IGUAL");};

asignacion:
    ID ASIG expresion PUNTO_Y_COMA {verificarIdDeclarado($1); printRule("ASIGNACION", "ID ASIG EXPRESION PUNTO_Y_COMA");}
	| ID ASIG STRING PUNTO_Y_COMA {verificarIdDeclarado($1); printRule("ASIGNACION", "ID ASIG STRING PUNTO_Y_COMA");}
    ;
expresion: 
    asignacion {printRule("EXPRESION", "ASIGNACION");}
    | expresion OP_SUMA termino {
        printRule("EXPRESION", "EXPRESION OP_SUMA TERMINO");
    }
    | expresion OP_RESTA termino {
        printRule("EXPRESION", "EXPRESION OP_RESTA TERMINO");
    }
    | termino {printRule("EXPRESION", "TERMINO");}
    ;

termino: 
    termino OP_MUL factor {
        printRule("TERMINO", "TERMINO OP_MUL FACTOR");
    }
    | termino OP_DIV factor {
        printRule("TERMINO", "TERMINO OP_DIV FACTOR");
    }
    | factor {printRule("TERMINO", "FACTOR");}
    ;

factor: 
      P_A expresion P_C {printRule("FACTOR", "(EXPRESION)");}
    | ID {verificarIdDeclarado($1); printRule("FACTOR", "ID");}
    | ENTERO {printRule("FACTOR", "ENTERO");}
    | FLOAT  {printRule("FACTOR", "FLOAT");}
	| funcion {printRule("FACTOR", "FUNCION");}
	;
	
funcion:
	FACT P_A expresion P_C {printRule("FUNCION", "FACTORIAL(exp)");}
	| COMB P_A expresion COMA expresion P_C	{printRule("FUNCION", "COMBINATORIO(exp,exp)");}
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
}

/**
 * Guarda la variable que se encuentra parseando en la lista de Ids
 * OJO Pide memoria
 */
void agregarVariable() {
    char * aux = (char *) malloc(sizeof(char) * (strlen(yylval.str_val) + 1));
    strcpy(aux, yylval.str_val);
    ids[idIndex] = aux;
    idIndex++;
    printf("variable %s\n", aux);
    return;
}

/**
 * Actualiza los tipo de datos de los IDs que tiene acumulado
 * Despues deberia limpia el array de IDs
 */
void actualizarTipo(int tipo) {
    printf("ultimo tipo de variable %s\n", obtenerNombreTipo(tipo));
    int i;
    for (i = 0; i < idIndex; i++) {
        tsActualizarTipos(ids[i], tipo);
    }
    idIndex = 0;
}

void verificarNumerico(void * id) {
    int tipo = tsObtenerTipo((char *)id);
    if(!(tipo == T_INTEGER || tipo == T_FLOAT)){
        printf("Error, el identificador no es numerico");
        exit(1);
    }
}

void verificarIdDeclarado(void *id) {
    char *idChar = (char *)id;

    int ret = tsObtenerTipo(idChar);
    printf("Funcion de validacion id declarado %s, retorno %d", idChar, ret);
    if (tsObtenerTipo(idChar) == T_ID) {
        printf("Identificador no se encuentra en el bloque de declaraciones.");
    }
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
