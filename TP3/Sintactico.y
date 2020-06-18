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
    #include "archivos_punto_H/assembler.h"

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
    nodo* factPtr = NULL;
    t_pila pila = NULL;
    int cantVarFact = 0;

    char * idsAsignacionTipo[100]; // Array de ids para asignarles el tipo en la declaracion de variables
    int indexAsignacionTipo = 0; // Index para la asignacion de tipos a los ids
    int expresionesTipoDato[100]; // Array de tipos de datos para validar que las asignaciones y comparaciones son compatibles a nivel tipo de dato
    int indexExpresionesTipoDato = 0; // Index para la validacion de las asignaciones y comparaciones a nivel tipo de dato

    int yyerror(const char *);
    void printRule(const char *, const char *);
    void printLog(const char *, const char *);
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
    nodo* semanticaFactorial(nodo*);

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
        printLog("\nCOMPILACION OK", "");
        escribirArbol(algortimoPtr);
        escribirGragh(algortimoPtr);
        tsCrearArchivo();
        generarAssembler(algortimoPtr);
    }
    ;

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
        printRule("<ALGORITMO>", "<PROGRAMA>");
    }
	;

programa:
    sentencia {
        programaPtr = sentenciaPtr;
        printLog("\tprogramaPtr -> sentenciaPtr", "");
        apilar(programaPtr);
        printRule("<PROGRAMA>", "<SENTENCIA>");
    }
    | programa sentencia { 
        programaPtr = desapilar();
        programaPtr = crearNodo("PROGRAMA", programaPtr, sentenciaPtr, resolverTipo(programaPtr->tipo, sentenciaPtr->tipo)); 
        printLog("\tprogramaPtr -> PROGRAMA, pila, sentenciaPtr", ""); 
        apilar(programaPtr);
        printRule("<PROGRAMA>", "<PROGRAMA> <SENTENCIA>");}
    ;

sentencia: 
    seleccion {
        sentenciaPtr = seleccionPtr; 
        printLog("\tsentenciaPtr -> Pila", ""); 
        printRule("<SENTENCIA>", "<SELECCION>");
    }
    | asignacion {
        sentenciaPtr = asignacionPtr; 
        printLog("\tsentenciaPtr -> asignacionPtr", "");
        printRule("<SENTENCIA>", "<ASIGNACION>");
    }
    | iteracion {
        sentenciaPtr = iteracionPtr;
        printLog("\tsentenciaPtr -> Pila", "");
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
        int tipo2 = tsObtenerTipo($2);
        verificarIdDeclarado(tipo2);
        entradaPtr = crearNodo(":=", crearHoja($2, tipo2), crearHoja("@STDIN", CTE_STRING), resolverTipo(tipo2, CTE_STRING));
        printRule("<ENTRADA>", "ID");
    };

salida: 
    SALIDA STRING {
        printRule("<SALIDA>", "STRING");
        salidaPtr = crearNodo(":=", crearHoja("@STDOUT", CTE_STRING), crearHoja($2, CTE_STRING), CTE_STRING);
    } 
    | SALIDA ID {
        int tipo2 = tsObtenerTipo($2);
        verificarIdDeclarado(tipo2);
        salidaPtr = crearNodo(":=", crearHoja("@STDOUT", CTE_STRING), crearHoja($2, tipo2), resolverTipo(CTE_STRING, tipo2));
        printRule("<SALIDA>", "ID");
    }
    ;

seleccion: 
    IF P_A condicion P_C L_A programa L_C {
        programaPtr = desapilar();
        seleccionPtr = crearNodo("IF", desapilar(), programaPtr, CTE_STRING);
        printLog("\tseleccionPtr -> IF, condicionPtr, programaPtr", ""); 
        printRule("<SELECCION>", "IF P_A <CONDICION> P_C L_A <PROGRAMA> L_C");}
    | IF P_A condicion P_C L_A programa L_C ELSE L_A programa L_C {
        programaPtr = desapilar();
        seleccionPtr = crearNodo("IF", desapilar(), crearNodo("CUERPO", desapilar(), programaPtr, CTE_STRING), CTE_STRING);
        printLog("\tseleccionPtr -> IF, Pila, nodo", ""); 
        printRule("<SELECCION>", "IF P_A <CONDICION> P_C L_A <PROGRAMA> L_C ELSE L_A <PROGRAMA> L_C");
    }
    ;

iteracion: 
    WHILE P_A condicion P_C L_A programa L_C {
        programaPtr = desapilar();
        iteracionPtr = crearNodo("WHILE", desapilar(), programaPtr, CTE_STRING);
        printLog("\titeracionPtr -> WHILE, Pila, programaPtr", ""); 
        printRule("<ITERACION>", "WHILE P_A <CONDICION> P_C L_A <PROGRAMA> L_C");
    }
    ;

condicion: 
    comparacion {
        condicionPtr = comparacionPtr;
        printLog("\tcondicionPtr -> comparacionPtr", "");
        printRule("<CONDICION>", "<COMPARACION>");}
    | OP_NOT comparacion { 
        strcpy(comparacionPtr->dato, obtenerComparadorOpuesto(comparacionPtr));
        condicionPtr = comparacionPtr;
        printLog("\tcondicionPtr -> comparacionPtr", "");
        printRule("<CONDICION>", "OP_NOT <COMPARACION>");}
    | comparacion OP_AND comparacion {
        condicionPtr = crearNodo("AND", desapilar(), desapilar(), CTE_STRING);
        printLog("\tcondicionPtr -> AND, Pila, Pila", "");
        apilar(condicionPtr);
        printRule("<CONDICION>", "<COMPARACION> OP_AND <COMPARACION>");}
    | comparacion OP_OR comparacion {
        condicionPtr = crearNodo("OR", desapilar(), desapilar(), CTE_STRING);
        printLog("\tcondicionPtr -> OP_OR, Pila, Pila", "");
        apilar(condicionPtr);
        printRule("<CONDICION>", "<COMPARACION> OP_OR <COMPARACION>");}
    ;

comparacion: 
    BETWEEN P_A ID {validarIdNumerico(tsObtenerTipo($3));} COMA C_A expresion PUNTO_Y_COMA expresion C_C P_C 
        {
            if (validarExpresionReal() == ERROR) {
                yyerror("Tipo de datos no compatible (Expresion real)");
            }
            int tipo3 = tsObtenerTipo($3);
            nodo *nodo1 = desapilar();
            nodo *nodo2 = desapilar();
            comparacionPtr = crearNodo(
                "AND", 
                crearNodo("=>", crearHoja($3, tipo3), nodo1, resolverTipo(tipo3, nodo1->tipo)), 
                crearNodo("=<", crearHoja($3, tipo3), nodo2, resolverTipo(tipo3, nodo2->tipo)), 
                CTE_STRING
            );
            apilar(comparacionPtr);
            printRule("<COMPARACION>", "BETWEEN P_A ID COMA C_A <EXPRESION> PUNTO_Y_COMA <EXPRESION> C_C P_C");
        }
    | expresion comparador expresion { 
        validarComparacion(); 
        nodo *nodo1 = desapilar();
        nodo *nodo2 = desapilar();
            
        comparacionPtr = crearNodo(
            comparadorPtr->dato, 
            nodo1, 
            nodo2,
            resolverTipo(nodo1->tipo, nodo2->tipo)
        ); 
        printLog("\tcomparacionPtr -> comparadorPtr, Pila, Pila", ""); 
        apilar(comparacionPtr); 
        printRule("<COMPARACION>", "<EXPRESION> <COMPARADOR> <EXPRESION>");}
    ;

comparador: 
    CMP_MAYOR {
        comparadorPtr = crearHoja(">", CTE_STRING);
        printLog("\tcomparadorPtr -> >", "");
        printRule("<COMPARADOR>", "OP_CMP_MAYOR");
    } 
    | CMP_MENOR {
        comparadorPtr = crearHoja("<", CTE_STRING);
        printLog("\tcomparadorPtr -> <", "");
        printRule("<COMPARADOR>", "OP_CMP_MENOR");
    } 
    | CMP_MAYOR_IGUAL {
        comparadorPtr = crearHoja(">=", CTE_STRING);
        printLog("\tcomparadorPtr -> >=", "");
        printRule("<COMPARADOR>", "OP_CMP_MAYOR_IGUAL");
    } 
    | CMP_MENOR_IGUAL {
        comparadorPtr = crearHoja("<=", CTE_STRING);
        printLog("\tcomparadorPtr -> <=", "");
        printRule("<COMPARADOR>", "OP_CMP_MENOR_IGUAL");
    } 
    | CMP_IGUAL  {
        comparadorPtr = crearHoja("==", CTE_STRING);
        printLog("\tcomparadorPtr -> ==", "");
        printRule("<COMPARADOR>", "OP_CMP_IGUAL");
    };

asignacion:
    ID ASIG expresion PUNTO_Y_COMA {
        int tipo1 = tsObtenerTipo($1);
        nodo *nodo1 = desapilar();
        asignacionPtr = crearNodo(":=", crearHoja($1, tipo1), nodo1, resolverTipo(tipo1, nodo1->tipo));
        
        printLog("\tasignacionPtr -> :=, ID, Pila", "");
        
        verificarIdDeclarado(tipo1); 
        validarTiposDatoAsignacion(tipo1); 
        printRule("<ASIGNACION>", "ID ASIG <EXPRESION> PUNTO_Y_COMA");}
	| ID ASIG STRING PUNTO_Y_COMA {
        int tipo1 = tsObtenerTipo($1);

        asignacionPtr = crearNodo(":=", crearHoja($1, tipo1), crearHoja(aConstante($3), CTE_STRING), resolverTipo(tipo1, CTE_STRING));
        printLog("\tasignacionPtr -> :=, ID, ", $3);
        
        verificarIdDeclarado(tipo1);
        printRule("<ASIGNACION>", "ID ASIG STRING PUNTO_Y_COMA");
        if (tipo1 != T_STRING) {
            yyerror("Asignacion no permitidad: La variable no es de tipo String");
        }
    }
    ;

expresion:
    asignacion {
        printRule("<EXPRESION>", "<ASIGNACION>");
    }
    | expresion OP_SUMA termino {
        nodo *nodo1 = desapilar();
        apilar(crearNodo("+", nodo1, terminoPtr, resolverTipo(nodo1->tipo, terminoPtr->tipo))); 
        printLog("\tPila -> +, pila, terminoPtr", "");
        printRule("<EXPRESION>", "<EXPRESION> OP_SUMA <TERMINO>");
    }
    | expresion OP_RESTA termino {
        nodo *nodo1 = desapilar();
        apilar(crearNodo("-", nodo1, terminoPtr, resolverTipo(nodo1->tipo, terminoPtr->tipo)));
        printLog("\tPila -> -, pila, terminoPtr", "");
        printRule("<EXPRESION>", "<EXPRESION> OP_RESTA <TERMINO>");
    }
    | termino {
        apilar(terminoPtr); 
        printLog("\tPila -> terminoPtr", "");
        printRule("<EXPRESION>", "<TERMINO>");
    }
    ;

termino:
    termino OP_MUL {
            apilar(terminoPtr);
            printRule("<TERMINO>", "<TERMINO> OP_MUL ...");
            // esta a mitad de la regla
        } factor {
            nodo *nodo1 = desapilar();
            terminoPtr = crearNodo("*", nodo1, factorPtr, resolverTipo(nodo1->tipo, factorPtr->tipo)); 
            printLog("\tterminoPtr -> *, pila, factorPtr", "");
            printRule("<TERMINO>", "<TERMINO> OP_MUL <FACTOR>");
        }
    | termino OP_DIV {
            apilar(terminoPtr);
            printRule("<TERMINO>", "<TERMINO> OP_DIV ...");
            // esta a mitad de la regla
        } factor {
            nodo *nodo1 = desapilar();
            terminoPtr = crearNodo("/", nodo1, factorPtr, resolverTipo(nodo1->tipo, factorPtr->tipo));
            printLog("\tterminoPtr -> /, pila, factorPtr", "");
            printRule("<TERMINO>", "<TERMINO> OP_DIV <FACTOR>");
        }
    | factor {
        terminoPtr = factorPtr; 
        printLog("\tterminoPtr -> factorPtr", "");
        printRule("<TERMINO>", "<FACTOR>");
    }
    ;

factor: 
    P_A expresion P_C {
        printLog("\tfactorPtr -> pila", "");
        factorPtr = desapilar();
        printRule("<FACTOR>", "(<EXPRESION>)");
    }
    | ID {
        printLog("\tfactorPtr -> ", $1);
        int tipo1 = tsObtenerTipo($1);
        factorPtr = crearHoja($1, tipo1);
        verificarIdDeclarado(tipo1);
        agregarTipoDatoArray(tipo1);
        printRule("<FACTOR>", "ID");
    }
    | ENTERO {
        printLog("\tfactorPtr -> ", $1);
        factorPtr = crearHoja(aConstante($1), CTE_INTEGER);
        agregarTipoDatoArray(CTE_INTEGER);
        printRule("<FACTOR>", "ENTERO");
    }
    | FLOAT {
        printLog("\tfactorPtr -> ", $1);
        factorPtr = crearHoja(aConstante($1), CTE_FLOAT);
        agregarTipoDatoArray(CTE_FLOAT);
        printRule("<FACTOR>", "FLOAT");
    }
	| funcion {
        printLog("\tfactorPtr -> funcionPtr", "");
        factorPtr = funcionPtr;
        printRule("<FACTOR>", "<FUNCION>");
    }
	;
	
funcion:
	FACT P_A expresion P_C {
        funcionPtr = semanticaFactorial(desapilar());
        printRule("<FUNCION>", "FACTORIAL(<EXPRESION>)");
    }
	| COMB P_A expresion COMA expresion P_C	{
        // Definicion de numero combinatorio:
        // Combinatorio = FACT(expresion1) / ( FACT(expresion2) * FACT(expresion1 - expresion2) )
        nodo* exp2Comb = desapilar();
        nodo* exp1Comb = desapilar();
        nodo* resComb = crearNodo("-", exp1Comb, exp2Comb, resolverTipo(exp1Comb->tipo, exp2Comb->tipo));
        
        nodo* semanticaFactorial1 = semanticaFactorial(exp2Comb);
        nodo* semanticaFactorial2 = semanticaFactorial(resComb);
        nodo* mulComb = crearNodo("*", semanticaFactorial1, semanticaFactorial2, resolverTipo(semanticaFactorial1->tipo, semanticaFactorial2->tipo));

        nodo* semanticaFactorial3 = semanticaFactorial(exp1Comb);
        funcionPtr = crearNodo("/", semanticaFactorial3, mulComb, resolverTipo(semanticaFactorial3->tipo, mulComb->tipo));
        printRule("<FUNCION>", "COMBINATORIO(<EXPRESION>, <EXPRESION>)");
    }
	;
%%

void printLog(const char *s1, const char *s2) {
    FILE *log = fopen(ARCHIVO_LOG, "a");
    if (log == NULL) {
        return;
    }
    fprintf(log, "%s%s\n", s1, s2);
    fclose(log);
}

void printRule(const char *lhs, const char *rhs) {
    if (YYDEBUG) {
        char *regla = (char *) malloc(100);
        sprintf(regla, "%s -> %s", lhs, rhs);
        printf("%s\n\n", regla);
        printLog(regla, "");
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
        // Se limpia el log
        FILE *log = fopen(ARCHIVO_LOG, "w");
        if (log == NULL) {
            return ERROR;
        }
        fclose(log);

        yyparse();
    }

    fclose(yyin);
    return 0;
}

nodo * apilar(nodo *arg) {
    printLog("\tApila el valor ", arg->dato);
    apilarDinamica(&pila, &arg);
    mostrarEstadoPila();
}

nodo * desapilar() {
    nodo * ret = NULL;
    desapilarDinamica(&pila, &ret);
    printLog("\tDesapile el valor ", ret->dato);
    mostrarEstadoPila();
    return ret;
}

void mostrarEstadoPila() {
    
    char* pilaStr = (char*) malloc(100);
    strcpy(pilaStr, "\t\tEstado de Pila =");
    t_pila copiaPila = pila;

    while(copiaPila != NULL) {
        sprintf(pilaStr, "%s %s", pilaStr, (copiaPila->dato)->dato);
        copiaPila = copiaPila->psig;
    }

    printLog(pilaStr, "");
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

nodo * semanticaFactorial(nodo* exp) {
    /* Lógica de Factorial
    nroMaximo = expresion;
    factorial = 1;
    while (nroMaximo > 1) {
        factorial = factorial * nroMaximo
        nroMaximo--;
    }
    */
    
    char nomVarFact[10];
    sprintf(nomVarFact, "@SUM%d", cantVarFact);
    cantVarFact++;

    nodo* numeroFactorial = crearNodo(":=", crearHoja("@NUMFACT", CTE_INTEGER), exp, exp->tipo);
    nodo* decrementado = crearNodo(
        ":=", 
        crearHoja("@NUMFACT", CTE_INTEGER), 
        crearNodo(
            "-", 
            crearHoja("@NUMFACT", CTE_STRING), 
            crearHoja(aConstante("1"), CTE_INTEGER),
            CTE_INTEGER
        ),
        CTE_INTEGER
    );
    nodo* mulFact = crearNodo(":=", crearHoja(nomVarFact, exp->tipo), crearNodo("*", crearHoja(nomVarFact, exp->tipo), crearHoja("@NUMFACT", CTE_INTEGER), exp->tipo), exp->tipo);
    nodo* cuerpoWhileFact = crearNodo("CUERPO_WHILE", mulFact, decrementado, CTE_STRING);
    nodo* whileFact = crearNodo("WHILE", crearNodo(">", crearHoja("@NUMFACT", CTE_INTEGER), crearHoja(aConstante("1"), CTE_INTEGER), CTE_INTEGER), cuerpoWhileFact, exp->tipo);
    nodo* sumaFact = crearNodo(":=", crearHoja(nomVarFact, exp->tipo), crearHoja(aConstante("1"), CTE_INTEGER), exp->tipo);
    nodo* progFactorial = crearNodo("PROGRAMA", sumaFact , whileFact, exp->tipo);
    return crearNodo(nomVarFact, numeroFactorial, progFactorial, exp->tipo);
}