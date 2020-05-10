%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <conio.h>
    #include <string.h>
    #include "y.tab.h"
    #include "archivos_punto_H/tabla_simbolo.h"
    #include "archivos_punto_H/constantes.h"
    #include "archivos_punto_H/arbol_sintactico.h"
    int yystopparser=0;
    int yylineno;
    FILE  *yyin;
    
    nodo* algortimoPtr=NULL;
    nodo* factorPtr=NULL;
    nodo* T=NULL;
    nodo* E=NULL;
    nodo* FUN=NULL;
    nodo* COND=NULL;
    nodo* PROG=NULL;
    nodo* SELECCION=NULL;
    nodo* SENTENCIA=NULL;
    nodo* COMPARADOR=NULL;
    nodo* COMPARACION=NULL;
    nodo* ASIGNACION=NULL;

    nodo* pilaTest[100]; //por el momento con longitud fija, cambiar a dinamica...
    int pilaTope = 0;

    char * idsAsignacionTipo[100]; // Array de ids para asignarles el tipo en la declaracion de variables
    int indexAsignacionTipo = 0; // Index para la asignacion de tipos a los ids
    int expresionesTipoDato[100]; // Array de tipos de datos para validar que las asignaciones y comparaciones son compatibles a nivel tipo de dato
    int indexExpresionesTipoDato = 0; // Index para la validacion de las asignaciones y comparaciones a nivel tipo de dato

    int yyerror(const char *);
    void printRule(const char *, const char *);
    void agregarVariable();
    void actualizarTipoDeclaracionID(int);
    void validarIdNumerico(const int);
    void verificarIdDeclarado(const int);
    void agregarTipoDatoArray(const int);
    void validarTiposDatoAsignacion(const int);
    int validarExpresionEntera();
    int validarExpresionReal();
    int validarExpresionString();
    void validarComparacion();

    nodo* meter_pila(nodo*);
    nodo* sacar_pila();
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
    INICIA_DEC declaraciones FIN_DEC {
        printRule("<BLOQUE_DECLARACIONES>", "INICIA_DEC <DECLARACIONES> FIN_DEC");
    }
	;

declaraciones:
    declaracion {printRule("<DECLARACIONES>", "<DECLARACION>");}
    | declaraciones declaracion {printRule("<DECLARACIONES>", "<DECLARACIONES> <DECLARACION>");}
	;

declaracion:
	TIPO_INT DECS_2PTOS lista_variables {
        printRule("<DECLARACION>", "TIPO_INT : <LISTA_VARIABLES>");
        actualizarTipoDeclaracionID(T_INTEGER);
    }
	| TIPO_FLOAT DECS_2PTOS lista_variables {
        printRule("<DECLARACION>", "TIPO_FLOAT : <LISTA_VARIABLES>");
        actualizarTipoDeclaracionID(T_FLOAT);
    }
	| TIPO_STRING DECS_2PTOS lista_variables {
        printRule("<DECLARACION>", "TIPO_STRING : <LISTA_VARIABLES>");
        actualizarTipoDeclaracionID(T_STRING);
    }
	;

lista_variables:
	ID {
        printRule("<LISTA_VARIABLES>", "ID");
        agregarVariable();
    }
	| lista_variables PUNTO_Y_COMA ID  {
        printRule("<LISTA_VARIABLES>", "<LISTA_VARIABLES> PUNTO_Y_COMA ID");
        agregarVariable();
    }
	;

algoritmo: 
    programa {algortimoPtr = PROG; escribirGragh(algortimoPtr); printRule("<ALGORITMO>", "<PROGRAMA>");}
	;

programa:
    sentencia {
        PROG = SENTENCIA; printf("PROG -> SENTENCIA"); printRule("<PROGRAMA>", "<SENTENCIA>");
    }
    | programa sentencia { PROG = crearNodo("PROGRAMA", PROG, SENTENCIA); printf("PROG -> PROGRAMA, PROG, SENTENCIA\n"); printRule("<PROGRAMA>", "<PROGRAMA> <SENTENCIA>");}
    ;

sentencia: 
    seleccion {SENTENCIA = SELECCION; printf("SENTENCIA -> SELECCION\n"); printRule("<SENTENCIA>", "<SELECCION>");}
    | asignacion {SENTENCIA = ASIGNACION; printf("SENTENCIA -> ASIGNACION\n"); printRule("<SENTENCIA>", "<ASIGNACION>");}
    | iteracion {printRule("<SENTENCIA>", "<ITERACION>");}
    | entrada PUNTO_Y_COMA {printRule("<SENTENCIA>", "<ENTRADA>");}
    | salida PUNTO_Y_COMA {printRule("<SENTENCIA>", "<SALIDA>");}
    ;

entrada: 
    ENTRADA ID {verificarIdDeclarado(tsObtenerTipo($2));} {printRule("<ENTRADA>", "ID");};

salida: 
    SALIDA STRING {printRule("<SALIDA>", "STRING");} 
    | SALIDA ID {verificarIdDeclarado(tsObtenerTipo($2));} {printRule("<SALIDA>", "ID");}
    ;

seleccion: 
    IF P_A condicion P_C L_A programa L_C {SELECCION = crearNodo("IF", COND, PROG); printf("SELECCION -> IF, COND, PROG\n"); printRule("<SELECCION>", "IF P_A <CONDICION> P_C L_A <PROGRAMA> L_C");}
    | IF P_A condicion P_C L_A programa L_C ELSE L_A programa L_C {
        printRule("<SELECCION>", "IF P_A <CONDICION> P_C L_A <PROGRAMA> L_C ELSE L_A <PROGRAMA> L_C");
    }
    ;

iteracion: 
    WHILE P_A condicion P_C L_A programa L_C {printRule("<ITERACION>", "WHILE P_A <CONDICION> P_C L_A <PROGRAMA> L_C");};

condicion: 
    comparacion {COND = COMPARACION; printf("COND -> COMPARACION\n"); printRule("<CONDICION>", "<COMPARACION>");}
    | OP_NOT comparacion {printRule("<CONDICION>", "OP_NOT <COMPARACION>");}
    | comparacion OP_AND comparacion {printRule("<CONDICION>", "<COMPARACION> OP_AND <COMPARACION>");}
    | comparacion OP_OR comparacion {printRule("<CONDICION>", "<COMPARACION> OP_OR <COMPARACION>");}
    ;

comparacion: 
    BETWEEN P_A ID {validarIdNumerico(tsObtenerTipo($3));} COMA C_A expresion PUNTO_Y_COMA expresion C_C P_C 
        {
            if (validarExpresionReal() == ERROR) {
                yyerror("Tipo de datos no compatible (Expresion real)");
            } 
            printRule("<COMPARACION>", "BETWEEN P_A ID COMA C_A <EXPRESION> PUNTO_Y_COMA <EXPRESION> C_C P_C");
        }
    | expresion comparador expresion { validarComparacion(); COMPARACION = crearNodo("COMPARADOR", sacar_pila(), E); printf("COMPARCION -> COMPARADOR, Pila, E\n"); meter_pila(COMPARACION); printRule("<COMPARACION>", "<EXPRESION> <COMPARADOR> <EXPRESION>");}
    ;

comparador: 
    CMP_MAYOR {COMPARADOR = crearHoja(">");printf("COMPARADOR -> CMP_MAYOR\n"); printRule("<COMPARADOR>", "OP_CMP_MAYOR");} 
    | CMP_MENOR {COMPARADOR = crearHoja("<");printf("COMPARADOR -> CMP_MENOR\n"); printRule("<COMPARADOR>", "OP_CMP_MENOR");} 
    | CMP_MAYOR_IGUAL {COMPARADOR = crearHoja(">=");printf("COMPARADOR -> CMP_MAYOR_IGUAL\n"); printRule("<COMPARADOR>", "OP_CMP_MAYOR_IGUAL");} 
    | CMP_MENOR_IGUAL {COMPARADOR = crearHoja("<=");printf("COMPARADOR -> CMP_MENOR_IGUAL\n"); printRule("<COMPARADOR>", "OP_CMP_MENOR_IGUAL");} 
    | CMP_IGUAL  {COMPARADOR = crearHoja("==");printf("COMPARADOR -> CMP_IGUAL\n"); printRule("<COMPARADOR>", "OP_CMP_IGUAL");};

asignacion:
    ID ASIG expresion PUNTO_Y_COMA {
        printf("ASIGNACION -> :=, ID, E\n");
        ASIGNACION = crearNodo(":=",crearHoja($1), E);
        sacar_pila(); // Descarta lo que tiene expresion
        verificarIdDeclarado(tsObtenerTipo($1)); 
        validarTiposDatoAsignacion(tsObtenerTipo($1)); 
        printRule("<ASIGNACION>", "ID ASIG <EXPRESION> PUNTO_Y_COMA");}
	| ID ASIG STRING PUNTO_Y_COMA {
        printRule("<ASIGNACION>", "ID ASIG STRING PUNTO_Y_COMA");
        verificarIdDeclarado(tsObtenerTipo($1));
        if (tsObtenerTipo($1) != T_STRING) {
            yyerror("Asignacion no permitidad: La variable no es de tipo String");
        }
    }
    ;

expresion: 
    asignacion {printRule("<EXPRESION>", "<ASIGNACION>");}
    | expresion OP_SUMA termino {
        printf("E->+,pila,T\n");
        E = crearNodo("+", sacar_pila(), T); meter_pila(E); printRule("<EXPRESION>", "<EXPRESION> OP_SUMA <TERMINO>");
    }
    | expresion OP_RESTA termino {
        printf("E->-,pila,T\n");
        E = crearNodo("-", sacar_pila(), T); meter_pila(E);
        printRule("<EXPRESION>", "<EXPRESION> OP_RESTA <TERMINO>");
    }
    | termino {
        printf("E->T\n");
        E = T; meter_pila(E); printRule("<EXPRESION>", "<TERMINO>");
    }
    ;

termino:
    termino OP_MUL {meter_pila(T);} factor {
        printf("T->*, pila, factorPtr\n");
        T = crearNodo("*", sacar_pila(), factorPtr); 
        printRule("<TERMINO>", "<TERMINO> OP_MUL <FACTOR>");
    }
    | termino OP_DIV {meter_pila(T);} factor {
        printf("T->/, pila, factorPtr\n");
        T = crearNodo("/", sacar_pila(), factorPtr);
        printRule("<TERMINO>", "<TERMINO> OP_DIV <FACTOR>");
    }
    | factor {
        printf("T -> factorPtr\n");
        T = factorPtr; printRule("<TERMINO>", "<FACTOR>");
    }
    ;

factor: 
    P_A expresion P_C {
        printf("factorPtr -> pila\n");
        factorPtr = sacar_pila(); printRule("<FACTOR>", "(<EXPRESION>)");
    }
    
    | ID {
        printf("factorPtr -> id\n");
        factorPtr = crearHoja($1);
        verificarIdDeclarado(tsObtenerTipo($1));
        agregarTipoDatoArray(tsObtenerTipo($1));
        printRule("<FACTOR>", "ID");
    }
    | ENTERO {
        printf("factorPtr -> ENT\n");
        factorPtr = crearHoja($1);
        agregarTipoDatoArray(tsObtenerTipo($1));
        printRule("<FACTOR>", "ENTERO");
    }
    | FLOAT {
        printf("factorPtr -> FLOAT\n");
        factorPtr = crearHoja($1);
        agregarTipoDatoArray(tsObtenerTipo($1));
        printRule("<FACTOR>", "FLOAT");
    }
	| funcion {
        printf("factorPtr -> FUN\n");
        factorPtr = FUN;
        printRule("<FACTOR>", "<FUNCION>");
    }
	;
	
funcion:
	FACT P_A expresion P_C {FUN = E;printRule("<FUNCION>", "FACTORIAL(<EXPRESION>)");}
	| COMB P_A expresion COMA expresion P_C	{printRule("<FUNCION>", "COMBINATORIO(<EXPRESION>, <EXPRESION>)");}
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
            setImprimir();
        }
        yyparse();
    }

    fclose(yyin);
    return 0;
}

nodo * meter_pila(nodo *arg) {
    printf("...Guarde...%s\n",arg->dato);
    pilaTest[pilaTope] = arg;
    pilaTope++;
}

nodo * sacar_pila() {
    pilaTope--;
    nodo * ret = pilaTest[pilaTope];
    printf("...Saque...%s\n", ret->dato);
    return ret;
}