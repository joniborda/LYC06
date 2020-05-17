%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <conio.h>
    #include <string.h>
    #include "y.tab.h"
    #include "archivos_punto_H/tabla_simbolo.h"
    #include "archivos_punto_H/constantes.h"
    #include "archivos_punto_H/arbol_sintactico.h"
    #include "archivos_punto_H/comparador.h"
    int yystopparser=0;
    int yylineno;
    FILE  *yyin;
    
    nodo* algortimoPtr = NULL;
    nodo* factorPtr = NULL;
    nodo* terminoPtr = NULL;
    nodo* expresionPtr = NULL;
    nodo* funcionPtr = NULL;
    nodo* condicionPtr = NULL;
    nodo* programaPtr = NULL;
    nodo* seleccionPtr = NULL;
    nodo* sentenciaPtr = NULL;
    nodo* comparadorPtr = NULL;
    nodo* comparacionPtr = NULL;
    nodo* asignacionPtr = NULL;
    nodo* iteracionPtr = NULL;
    nodo* entradaPtr = NULL;
    nodo* salidaPtr = NULL;

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
    void mostrarEstadoPila();
    char * obtenerComparadorOpuesto(nodo* );

    nodo* apilar(nodo*);
    nodo* desapilar();
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
        printf("\t\nCOMPILACION OK\n");
        tsCrearArchivo();
    };

bloque_declaraciones: 
    INICIA_DEC declaraciones FIN_DEC {
        printRule("<BLOQUE_DECLARACIONES>", "INICIA_DEC <DECLARACIONES> FIN_DEC");
    }
	;

declaraciones:
    declaracion {
        printRule("<DECLARACIONES>", "<DECLARACION>");
    }
    | declaraciones declaracion {
        printRule("<DECLARACIONES>", "<DECLARACIONES> <DECLARACION>");
    }
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
    programa {
        algortimoPtr = programaPtr;
        escribirArbol(algortimoPtr);
        escribirGragh(algortimoPtr);
        printRule("<ALGORITMO>", "<PROGRAMA>");
    }
	;

programa:
    sentencia {
        programaPtr = sentenciaPtr;
        printf("\tprogramaPtr -> sentenciaPtr\n");
        apilar(programaPtr);
        printRule("<PROGRAMA>", "<SENTENCIA>");
    }
    | programa sentencia { 
        programaPtr = desapilar();
        programaPtr = crearNodo("PROGRAMA", programaPtr, sentenciaPtr); 
        printf("\tprogramaPtr -> PROGRAMA, pila, sentenciaPtr\n"); 
        apilar(programaPtr);
        printRule("<PROGRAMA>", "<PROGRAMA> <SENTENCIA>");}
    ;

sentencia: 
    seleccion {
        sentenciaPtr = seleccionPtr; 
        printf("\tsentenciaPtr -> Pila\n"); 
        printRule("<SENTENCIA>", "<SELECCION>");
    }
    | asignacion {
        sentenciaPtr = asignacionPtr; 
        printf("\tsentenciaPtr -> asignacionPtr\n");
        printRule("<SENTENCIA>", "<ASIGNACION>");
    }
    | iteracion {
        sentenciaPtr = iteracionPtr;
        printf("\tsentenciaPtr -> Pila\n");
        printRule("<SENTENCIA>", "<ITERACION>");
    }
    | entrada PUNTO_Y_COMA {
        sentenciaPtr = entradaPtr;
        printRule("<SENTENCIA>", "<ENTRADA>");
    }
    | salida PUNTO_Y_COMA {
        sentenciaPtr = salidaPtr;
        printRule("<SENTENCIA>", "<SALIDA>");
    }
    ;

entrada: 
    ENTRADA ID {
        verificarIdDeclarado(tsObtenerTipo($2));
        entradaPtr = crearNodo("ASIG", crearHoja($2), crearHoja("@STDIN"));
        printRule("<ENTRADA>", "ID");
    };

salida: 
    SALIDA STRING {
        printRule("<SALIDA>", "STRING");
        salidaPtr = crearNodo("ASIG", crearHoja("@STDOUT"), crearHoja($2));
    } 
    | SALIDA ID {
        verificarIdDeclarado(tsObtenerTipo($2));
        salidaPtr = crearNodo("ASIG", crearHoja("@STDOUT"), crearHoja($2));
        printRule("<SALIDA>", "ID");
    }
    ;

seleccion: 
    IF P_A condicion P_C L_A programa L_C {
        programaPtr = desapilar();
        seleccionPtr = crearNodo("IF", desapilar(), programaPtr);
        printf("\tseleccionPtr -> IF, condicionPtr, programaPtr\n"); 
        printRule("<SELECCION>", "IF P_A <CONDICION> P_C L_A <PROGRAMA> L_C");}
    | IF P_A condicion P_C L_A programa L_C ELSE L_A programa L_C {
        programaPtr = desapilar();
        seleccionPtr = crearNodo("IF", desapilar(), crearNodo("CUERPO", desapilar(), programaPtr));
        printf("\tseleccionPtr -> IF, Pila, nodo\n"); 
        printRule("<SELECCION>", "IF P_A <CONDICION> P_C L_A <PROGRAMA> L_C ELSE L_A <PROGRAMA> L_C");
    }
    ;

iteracion: 
    WHILE P_A condicion P_C L_A programa L_C {
        programaPtr = desapilar();
        iteracionPtr = crearNodo("WHILE", desapilar(), programaPtr);
        printf("\titeracionPtr -> WHILE, Pila, programaPtr\n"); 
        printRule("<ITERACION>", "WHILE P_A <CONDICION> P_C L_A <PROGRAMA> L_C");
    }
    ;

condicion: 
    comparacion {
        condicionPtr = comparacionPtr;
        printf("\tcondicionPtr -> comparacionPtr\n");
        printRule("<CONDICION>", "<COMPARACION>");}
    | OP_NOT comparacion { 
        strcpy(comparacionPtr->dato, obtenerComparadorOpuesto(comparacionPtr));
        condicionPtr = comparacionPtr;
        printf("\tcondicionPtr -> comparacionPtr");
        printRule("<CONDICION>", "OP_NOT <COMPARACION>");}
    | comparacion OP_AND comparacion {
        condicionPtr = crearNodo("AND", desapilar(), desapilar());
        printf("\tcondicionPtr -> AND, Pila, Pila");
        apilar(condicionPtr);
        printRule("<CONDICION>", "<COMPARACION> OP_AND <COMPARACION>");}
    | comparacion OP_OR comparacion {
        condicionPtr = crearNodo("OR", desapilar(), desapilar());
        printf("\tcondicionPtr -> OP_OR, Pila, Pila");
        apilar(condicionPtr);
        printRule("<CONDICION>", "<COMPARACION> OP_OR <COMPARACION>");}
    ;

comparacion: 
    BETWEEN P_A ID {validarIdNumerico(tsObtenerTipo($3));} COMA C_A expresion PUNTO_Y_COMA expresion C_C P_C 
        {
            if (validarExpresionReal() == ERROR) {
                yyerror("Tipo de datos no compatible (Expresion real)");
            } 
            comparacionPtr = crearNodo("AND", crearNodo("=>", crearHoja($3), desapilar()), crearNodo("=<", crearHoja($3), desapilar()));
            apilar(comparacionPtr);
            printRule("<COMPARACION>", "BETWEEN P_A ID COMA C_A <EXPRESION> PUNTO_Y_COMA <EXPRESION> C_C P_C");
        }
    | expresion comparador expresion { 
        validarComparacion(); 
        comparacionPtr = crearNodo(comparadorPtr->dato, desapilar(), desapilar()); 
        printf("\tcomparacionPtr -> comparadorPtr, Pila, Pila\n"); 
        apilar(comparacionPtr); 
        printRule("<COMPARACION>", "<EXPRESION> <COMPARADOR> <EXPRESION>");}
    ;

comparador: 
    CMP_MAYOR {
        comparadorPtr = crearHoja(">");
        printf("\tcomparadorPtr -> >\n");
        printRule("<COMPARADOR>", "OP_CMP_MAYOR");
    } 
    | CMP_MENOR {
        comparadorPtr = crearHoja("<");
        printf("\tcomparadorPtr -> <\n");
        printRule("<COMPARADOR>", "OP_CMP_MENOR");
    } 
    | CMP_MAYOR_IGUAL {
        comparadorPtr = crearHoja(">=");
        printf("\tcomparadorPtr -> >=\n");
        printRule("<COMPARADOR>", "OP_CMP_MAYOR_IGUAL");
    } 
    | CMP_MENOR_IGUAL {
        comparadorPtr = crearHoja("<=");
        printf("\tcomparadorPtr -> <=\n");
        printRule("<COMPARADOR>", "OP_CMP_MENOR_IGUAL");
    } 
    | CMP_IGUAL  {
        comparadorPtr = crearHoja("==");
        printf("\tcomparadorPtr -> ==\n");
        printRule("<COMPARADOR>", "OP_CMP_IGUAL");
    };

asignacion:
    ID ASIG expresion PUNTO_Y_COMA {
        asignacionPtr = crearNodo(":=", crearHoja($1), desapilar());
        printf("\tasignacionPtr -> :=, ID, Pila\n");
        
        verificarIdDeclarado(tsObtenerTipo($1)); 
        validarTiposDatoAsignacion(tsObtenerTipo($1)); 
        printRule("<ASIGNACION>", "ID ASIG <EXPRESION> PUNTO_Y_COMA");}
	| ID ASIG STRING PUNTO_Y_COMA {
        asignacionPtr = crearNodo(":=", crearHoja($1), crearHoja($3));
        printf("\tasignacionPtr -> :=, ID, %s\n", $3);
        
        verificarIdDeclarado(tsObtenerTipo($1));
        printRule("<ASIGNACION>", "ID ASIG STRING PUNTO_Y_COMA");
        if (tsObtenerTipo($1) != T_STRING) {
            yyerror("Asignacion no permitidad: La variable no es de tipo String");
        }
    }
    ;

expresion: 
    asignacion {
        printRule("<EXPRESION>", "<ASIGNACION>");
    }
    | expresion OP_SUMA termino {
        apilar(crearNodo("+", desapilar(), terminoPtr)); 
        printf("\tPila -> +, pila, terminoPtr\n");
        printRule("<EXPRESION>", "<EXPRESION> OP_SUMA <TERMINO>");
    }
    | expresion OP_RESTA termino {
        apilar(crearNodo("-", desapilar(), terminoPtr));
        printf("\tPila -> -, pila, terminoPtr\n");
        printRule("<EXPRESION>", "<EXPRESION> OP_RESTA <TERMINO>");
    }
    | termino {
        apilar(terminoPtr); 
        printf("\tPila -> terminoPtr\n");
        printRule("<EXPRESION>", "<TERMINO>");
    }
    ;

termino:
    termino OP_MUL {
            apilar(terminoPtr);
            printRule("<TERMINO>", "<TERMINO> OP_MUL ...");
            // esta a mitad de la regla
        } factor {
            terminoPtr = crearNodo("*", desapilar(), factorPtr); 
            printf("\tterminoPtr -> *, pila, factorPtr\n");
            printRule("<TERMINO>", "<TERMINO> OP_MUL <FACTOR>");
        }
    | termino OP_DIV {
            apilar(terminoPtr);
            printRule("<TERMINO>", "<TERMINO> OP_DIV ...");
            // esta a mitad de la regla
        } factor {
            terminoPtr = crearNodo("/", desapilar(), factorPtr);
            printf("\tterminoPtr -> /, pila, factorPtr\n");
            printRule("<TERMINO>", "<TERMINO> OP_DIV <FACTOR>");
        }
    | factor {
        terminoPtr = factorPtr; 
        printf("\tterminoPtr -> factorPtr\n");
        printRule("<TERMINO>", "<FACTOR>");
    }
    ;

factor: 
    P_A expresion P_C {
        printf("\tfactorPtr -> pila\n");
        factorPtr = desapilar();
        printRule("<FACTOR>", "(<EXPRESION>)");
    }
    | ID {
        printf("\tfactorPtr -> %s\n", $1);
        factorPtr = crearHoja($1);
        verificarIdDeclarado(tsObtenerTipo($1));
        agregarTipoDatoArray(tsObtenerTipo($1));
        printRule("<FACTOR>", "ID");
    }
    | ENTERO {
        printf("\tfactorPtr -> %s\n", $1);
        factorPtr = crearHoja($1);
        agregarTipoDatoArray(tsObtenerTipo($1));
        printRule("<FACTOR>", "ENTERO");
    }
    | FLOAT {
        printf("\tfactorPtr -> %s\n", $1);
        factorPtr = crearHoja($1);
        agregarTipoDatoArray(tsObtenerTipo($1));
        printRule("<FACTOR>", "FLOAT");
    }
	| funcion {
        printf("\tfactorPtr -> funcionPtr\n");
        factorPtr = funcionPtr;
        printRule("<FACTOR>", "<FUNCION>");
    }
	;
	
funcion:
	FACT P_A expresion P_C {
        funcionPtr = desapilar();
        printRule("<FUNCION>", "FACTORIAL(<EXPRESION>)");
    }
	| COMB P_A expresion COMA expresion P_C	{
        printRule("<FUNCION>", "COMBINATORIO(<EXPRESION>, <EXPRESION>)");
    }
	;
%%

void printRule(const char *lhs, const char *rhs) {
    if (YYDEBUG) {
        printf("%s -> %s\n\n", lhs, rhs);
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

    compararArchivo(argv[1]);
    return 0;
}

nodo * apilar(nodo *arg) {
    printf("\tApila el valor %s\n", arg->dato);
    pilaTest[pilaTope] = arg;
    pilaTope++;
    mostrarEstadoPila();
}

nodo * desapilar() {
    pilaTope--;
    nodo * ret = pilaTest[pilaTope];
    printf("\tDesapile el valor %s\n", ret->dato);
    mostrarEstadoPila();
    return ret;
}

void mostrarEstadoPila() {
    int i = 0;
    printf("\t\tEstado de Pila = ");
    for (i = 0; i < pilaTope; i++) {
        printf("%s ", pilaTest[i]->dato);
    }
    printf("\n");
}

char * obtenerComparadorOpuesto(nodo* raiz) {
    if(strcmp(raiz->dato, "==") == 0) {
        return "!=";
    } else if (strcmp(raiz->dato, "!=") == 0) {
        return "==";
    } else if (strcmp(raiz->dato, "<") == 0) {
        return ">=";
    } else if (strcmp(raiz->dato, "<=") == 0) {
        return ">";
    } else if (strcmp(raiz->dato, ">") == 0) {
        return "<=";
    } else if (strcmp(raiz->dato, ">=") == 0) {
        return "<";
    }
}
