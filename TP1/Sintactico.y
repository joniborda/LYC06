%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <conio.h>
    #include <string.h>
    #include "y.tab.h"
    #include "archivos_punto_H/tabla_simbolo.h"
    #include "archivos_punto_H/constantes.h"
    int yystopparser=0;
    int yylineno;
    FILE  *yyin;
    
    char * idsAsignacionTipo[100]; // Array de ids para asignarles el tipo en la declaracion de variables
    int indexAsignacionTipo = 0; // Index para la asignacion de tipos a los ids
    int expresionesTipoDato[100]; // Array de tipos de datos para validar que las asignaciones y comparaciones son compatibles a nivel tipo de dato
    int indexExpresionesTipoDato = 0; // Index para la validacion de las asignaciones y comparaciones a nivel tipo de dato

    int yyerror(const char *);
    void printRule(const char *, const char *);
    void agregarVariable();
    void actualizarTipoDeclaracionID(int); //ok
    void validarIdNumerico(const int); // ok
    void verificarIdDeclarado(const int); //ok
    void agregarTipoDatoArray(const int); //ok
    void validarTiposDatoAsignacion(const int); // ok
    int validarExpresionEntera(); // ok
    int validarExpresionReal(); // ok
    int validarExpresionString(); // ok
    void validarComparacion(); // ok
%}

%union {
    int intval;
    float val;
    char *str_val;
}

%token <str_val>ID
%token <str_val> ENTERO
%token <str_val> FLOAT
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
%token C_A
%token C_C
%token PUNTO_Y_COMA
%token COMA
%token IF
%token ELSE
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
        actualizarTipoDeclaracionID(T_INTEGER);
    }
	| TIPO_FLOAT DECS_2PTOS lista_variables {
        printRule("DEC", "TIPO_FLOAT : LISTA_VARIABLES");
        printf("ultimo tipo de variable %s\n", "float");
        actualizarTipoDeclaracionID(T_FLOAT);
    }
	| TIPO_STRING DECS_2PTOS lista_variables {
        printRule("DEC", "TIPO_STRING : LISTA_VARIABLES");
        printf("ultimo tipo de variable %s\n", "string");
        actualizarTipoDeclaracionID(T_STRING);
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
    ENTRADA ID {verificarIdDeclarado(tsObtenerTipo($2));} {printRule("ENTRADA", "ID");};

salida: 
    SALIDA STRING {printRule("SALIDA", "STRING");} 
    | SALIDA ID {verificarIdDeclarado(tsObtenerTipo($2));} {printRule("SALIDA", "ID");}
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
    BETWEEN P_A ID {validarIdNumerico(tsObtenerTipo($3));} COMA C_A expresion PUNTO_Y_COMA expresion C_C P_C {
        if (validarExpresionReal() == ERROR) {
            yyerror("Tipo de datos no compatible (Expresion real)");
        } 
        printRule("COMPARACION", "BETWEEN");
    }
    | expresion comparador expresion { validarComparacion(); printRule("COMPARACION", "EXPRESION COMPARADOR EXPRESION");}
    ;

comparador: 
    CMP_MAYOR {printRule("COMPARADOR", "OP_CMP_MAYOR");} 
    | CMP_MENOR {printRule("COMPARADOR", "OP_CMP_MENOR");} 
    | CMP_MAYOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MAYOR_IGUAL");} 
    | CMP_MENOR_IGUAL {printRule("COMPARADOR", "OP_CMP_MENOR_IGUAL");} 
    | CMP_IGUAL  {printRule("COMPARADOR", "OP_CMP_IGUAL");};

asignacion:
    ID ASIG expresion PUNTO_Y_COMA {verificarIdDeclarado(tsObtenerTipo($1)); validarTiposDatoAsignacion(tsObtenerTipo($1)); printRule("ASIGNACION", "ID ASIG EXPRESION PUNTO_Y_COMA");}
	| ID ASIG STRING PUNTO_Y_COMA {
        printRule("ASIGNACION", "ID ASIG STRING PUNTO_Y_COMA");
        verificarIdDeclarado(tsObtenerTipo($1));
        if (tsObtenerTipo($1) != T_STRING) {
            yyerror("Asignacion no permitidad: La variable no es de tipo String");
        }
    }
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
    | ID {verificarIdDeclarado(tsObtenerTipo($1)); agregarTipoDatoArray(tsObtenerTipo($1)); printRule("FACTOR", "ID");}
    | ENTERO {agregarTipoDatoArray(tsObtenerTipo($1)); printRule("FACTOR", "ENTERO");}
    | FLOAT  {agregarTipoDatoArray(tsObtenerTipo($1)); printRule("FACTOR", "FLOAT");}
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

int yyerror(const char *s) {
    printf("Syntax Error\n");
    printf("Nro. de linea: %d \t %s\n", yylineno, s);
    exit(1);
}

/**
 * Guarda la variable que se encuentra parseando en la lista de Ids
 * OJO Pide memoria
 */
void agregarVariable() {
    char * aux = (char *) malloc(sizeof(char) * (strlen(yylval.str_val) + 1));
    strcpy(aux, yylval.str_val);
    idsAsignacionTipo[indexAsignacionTipo] = aux;
    indexAsignacionTipo++;
    printf("variable %s\n", aux);
    return;
}

/**
 * Actualiza los tipo de datos de los IDs que tiene acumulado en el array
 */
void actualizarTipoDeclaracionID(int tipo) {
    int i;
    for (i = 0; i < indexAsignacionTipo; i++) {
        tsActualizarTipos(idsAsignacionTipo[i], tipo);
    }
    indexAsignacionTipo = 0;
}

void validarIdNumerico(const int tipo) {
    if(!(tipo == T_INTEGER || tipo == T_FLOAT)){
        yyerror("Error, el identificador no es numerico");
    }
}

void verificarIdDeclarado(const int tipo) {
    if (tipo == T_ID) {
        yyerror("Variable indefinida");
    }
}

void agregarTipoDatoArray(const int tipo) {
    expresionesTipoDato[indexExpresionesTipoDato] = tipo;
    indexExpresionesTipoDato++;
}

/**
 * Valida que todos los datos del array de expresiones coincidan con el tipo dado
 *
 */
void validarTiposDatoAsignacion(const int tipo) {
    int ret = 0;
    switch(tipo) {
        case T_INTEGER:
            ret = validarExpresionEntera();
            break;
        case T_FLOAT:
            ret = validarExpresionReal();
            break;
        case T_STRING:
            ret = validarExpresionString();
            break;
    }
    if (ret == 1) {
        yyerror("No coinciden los tipos de datos");
    }
}

int validarExpresionEntera() {

    while(indexExpresionesTipoDato > 0) {
        if (
            expresionesTipoDato[indexExpresionesTipoDato - 1] != CTE_INTEGER && 
            expresionesTipoDato[indexExpresionesTipoDato - 1] != T_INTEGER
        ) {
            return ERROR;
        }
        indexExpresionesTipoDato--;
    }
    return TODO_OK;
}

int validarExpresionReal() {
    while(indexExpresionesTipoDato > 0) {
        if (!(
                expresionesTipoDato[indexExpresionesTipoDato - 1] == CTE_FLOAT || 
                expresionesTipoDato[indexExpresionesTipoDato - 1] == T_FLOAT || 
                expresionesTipoDato[indexExpresionesTipoDato - 1] == CTE_INTEGER || 
                expresionesTipoDato[indexExpresionesTipoDato - 1] == T_INTEGER
            )
        ) {
            return ERROR;
        }
        indexExpresionesTipoDato--;
    }
    return TODO_OK;
}

int validarExpresionString() {
    while(indexExpresionesTipoDato > 0) {
        if (
            expresionesTipoDato[indexExpresionesTipoDato - 1] != T_STRING || 
            expresionesTipoDato[indexExpresionesTipoDato - 1] != CTE_STRING
        ) {
            return ERROR;
        }
        indexExpresionesTipoDato--;
    }
    return TODO_OK;
}


void validarComparacion() {

    int longArray = indexExpresionesTipoDato;
    if (validarExpresionString() == TODO_OK) {
        if (longArray > 2 ) {
            yyerror("La comparacion de String es incorrecta");
        }
    }

    indexExpresionesTipoDato = longArray;
    if (validarExpresionReal() == ERROR) {
        yyerror("Tipo de datos no compatible (Expresion real)");
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
