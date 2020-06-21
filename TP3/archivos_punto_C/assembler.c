#include "../archivos_punto_h/assembler.h"
int cantAux = 0;
int tieneElse = 0;
int condicionOR = 0;
int esWhile = 0;

int numEtiqWhile = 0;
int numEtiqIf = 0;

int pilaNumEtiqWhile [10];
int pilaNumEtiqIf [10];

int topePilaWhile = 0;
int topePilaIf = 0;

void apilarEtiqueta(const int tipoEtiqueta);

int desapilarEtiqueta(const int tipoEtiqueta);

int verTopePilaEtiqueta(const int tipoEtiqueta);

void apilarEtiqueta(const int tipoEtiqueta) {
    if (tipoEtiqueta == ETIQUETA_IF) {
        numEtiqIf++;
        pilaNumEtiqIf[topePilaIf++] = numEtiqIf;
    }

    if (tipoEtiqueta == ETIQUETA_WHILE) {
        numEtiqWhile++;
        pilaNumEtiqWhile[topePilaWhile++] = numEtiqWhile;
    }
}

int desapilarEtiqueta(const int tipoEtiqueta) {
    if (tipoEtiqueta == ETIQUETA_IF) {
        return pilaNumEtiqIf[--topePilaIf];
    }
    if (tipoEtiqueta == ETIQUETA_WHILE) {
        return pilaNumEtiqWhile[--topePilaWhile];
    }
}

int verTopePilaEtiqueta(const int tipoEtiqueta) {
    if (tipoEtiqueta == ETIQUETA_IF) {
        return pilaNumEtiqIf[topePilaIf - 1];
    }
    if (tipoEtiqueta == ETIQUETA_WHILE) {
        return pilaNumEtiqWhile[topePilaWhile - 1];
    }
}

void generarAssembler(nodo * raiz) {
	if (/*generarHeader()*/ 0 == 1) {
		printf("Error al generar el assembler");
		return;
	}

	if (/*generarData()*/ 0 == 1) {
		printf("Error al generar el assembler");
		return;
	}

	if (generarInstrucciones(raiz) == 1) {
		printf("Error al generar el assembler");
		return;	
	}
}

int generarHeader() {
	FILE * fp = fopen("./assembler/header.txt", "w");
	if (fp == NULL) {
		printf("Error al abrir el archivo header");
		return 1;
	}

	fprintf(fp, "INCLUDE macros2.asm\n");
    fprintf(fp, "INCLUDE number.asm\n");
    fprintf(fp, ".MODEL LARGE\n");
    fprintf(fp, ".386\n");
    fprintf(fp, ".STACK 200h\n"); 
    fclose(fp);
    return 0;
}

int generarData() {
	FILE * fp = fopen("./assembler/data.txt", "wt+");
	if (fp == NULL) {
		printf("Error al abrir el archivo data");
		return 1;
	}

	fprintf(fp, "\t.DATA");    
    fprintf(fp, "\tTRUE equ 1\n");
    fprintf(fp, "\tFALSE equ 0\n");
    fprintf(fp, "\tMAXTEXTSIZE equ %d\n", 200);

    //Aca va la tabla de simbolo con todos los auxiliares

    fclose(fp);
    return 0;
}

int generarInstrucciones(nodo * raiz) {
	FILE * fp = fopen("./assembler/instrucciones.txt", "wt+");
	if (fp == NULL) {
		printf("Error al abrir el archivo instrucciones");
		return 1;
	}
	recorreArbolAsm(fp, raiz);
	fclose(fp);
	return 0;

}
void recorreArbolAsm(FILE * fp, nodo* raiz) {
    if (raiz != NULL) {
        int nodoActualIf = 0;
        int nodoActualWhile = 0;

        if(strcmp(raiz->dato, "IF") == 0) {
            tieneElse = 0;
            nodoActualIf = 1;
            // pido nueva etiqueta porque estoy empezando a recorrer un IF
            apilarEtiqueta(ETIQUETA_IF);
            
            if (strcmp(raiz->hijoDer->dato, "CUERPO") == 0) {
                tieneElse = 1;
            }
            if (strcmp(raiz->hijoIzq->dato, "OR") == 0) {
                condicionOR = 1;
            }
        }

        //WHILE
        if(strcmp(raiz->dato, "WHILE") == 0) {
            nodoActualWhile = 1;
            esWhile = 1;
            apilarEtiqueta(ETIQUETA_WHILE);
            fprintf(fp, "condicionWhile%d:\n", verTopePilaEtiqueta(ETIQUETA_WHILE));
            if (strcmp(raiz->hijoIzq->dato, "OR") == 0) {
                condicionOR = 1;
            }
        }

        // RECORRO LA IZQUIERDA
        recorreArbolAsm(fp, raiz->hijoIzq);
        // PASE POR LA IZQUIERDA

        printf("dato padre %s", raiz->dato);

        if(nodoActualIf) {
            fprintf(fp, "startIf%d:\n", verTopePilaEtiqueta(ETIQUETA_IF));
        }

        if(strcmp(raiz->dato, "CUERPO") == 0) {
            fprintf(fp, "JMP endif%d\n", verTopePilaEtiqueta(ETIQUETA_IF));
            fprintf(fp, "else%d:\n", verTopePilaEtiqueta(ETIQUETA_IF));
        }

        if(nodoActualWhile) {
            fprintf(fp, "startWhile%d:\n", verTopePilaEtiqueta(ETIQUETA_WHILE));
            esWhile = 0; // No sería necesario la variable cambiarNombre
        }
        
        // RECORRO LA DERECHA
        recorreArbolAsm(fp, raiz->hijoDer);
        // PASE POR LA DERECHA

        if (nodoActualIf) {
            fprintf(fp, "endif%d:\n", desapilarEtiqueta(ETIQUETA_IF));
        }

        //while 
        if(nodoActualWhile) {
            fprintf(fp, "JMP condicionWhile%d\n", verTopePilaEtiqueta(ETIQUETA_WHILE));
            fprintf(fp, "endwhile%d:\n", desapilarEtiqueta(ETIQUETA_WHILE));
        }
        
        if (esHoja(raiz->hijoIzq) && esHoja(raiz->hijoDer)) {
            // soy nodo mas a la izquierda con dos hijos hojas
            printf("DATO2 : %s\n", raiz -> dato);
            determinarOperacion(fp, raiz);
            
            // reduzco arbol
            raiz->hijoIzq = NULL;
            raiz->hijoDer = NULL;
        }
    }
}

int determinarOperacion(FILE * fp, nodo * raiz) {
   	printf("DATO : %s\n", raiz -> dato);

    if(esAritmetica(raiz->dato)) {
        if(strcmp(raiz->dato, ":=") == 0) {
            fprintf(fp, "MOV %s, %s\n", raiz->hijoIzq, raiz->hijoDer);
            return 0;
        } else {
            fprintf(fp, "fld %s\n", raiz->hijoIzq);
            fprintf(fp, "fld %s\n", raiz->hijoDer);
            fprintf(fp, "%s\n", obtenerInstruccionAritmetica(raiz->dato));
            fprintf(fp, "fstp @aux%d\n", pedirAux());
            // Guardo en el arbola el dato del resultado, si uso un aux
            sprintf(raiz->dato, "@aux%d", cantAux);
            return cantAux;
        }
    }

    if(esComparacion(raiz->dato)) {
        // esto funciona para comparaciones simples
        fprintf(fp, "fld %s\n", raiz->hijoIzq); //st0 = izq
        fprintf(fp, "fld %s\n", raiz->hijoDer); //st0 = der st1 = izq
        fprintf(fp, "fxch\n");
        fprintf(fp, "fcom\n"); // compara ST0 con ST1"
        fprintf(fp, "fstsw ax\n");
        fprintf(fp, "sahf\n");
        if (esWhile)
            fprintf(fp, "%s %s%d\n", obtenerInstruccionComparacion(raiz->dato), obtenerSalto(), verTopePilaEtiqueta(ETIQUETA_WHILE));
        else
            fprintf(fp, "%s %s%d\n", obtenerInstruccionComparacion(raiz->dato), obtenerSalto(), verTopePilaEtiqueta(ETIQUETA_IF));
        return 0;
    }

    if(strcmp(raiz->dato, "IF") == 0) {
        // no sabemos todavia
        return 0;
    }

    return 0;
}

int pedirAux() {
    return ++cantAux;
}

int auxActual() {
    return cantAux;
}

int esAritmetica(const char *operador) {
    // siendo aritmetica hay un lote de instrucciones predefinido, igual si es comparacion
    return strcmp(operador, "+") == 0 ||
    strcmp(operador, "-") == 0 ||
    strcmp(operador, "*") == 0 ||
    strcmp(operador, "/") == 0 ||
    strcmp(operador, ":=") == 0;
}

int esComparacion(const char *comparador) {
    // es necesaria esta funcion para que no entren los nodos AND, OR, NOR, etc que no tienen accion
    return strcmp(comparador, ">") == 0 ||
    strcmp(comparador, ">=") == 0 ||
    strcmp(comparador, "<") == 0 ||
    strcmp(comparador, "<=") == 0 ||
    strcmp(comparador, "==") == 0 ||
    strcmp(comparador, "!=") == 0;
}

char* obtenerInstruccionAritmetica(const char *operador) {
    if (strcmp(operador, "+") == 0)
        return "fadd";
    if (strcmp(operador, "-") == 0)
        return "fsub";
    if (strcmp(operador, "*") == 0)
        return "fmul";
    if (strcmp(operador, "/") == 0)
        return "fdiv";
}

char* obtenerInstruccionComparacion(const char *comparador) {
    // Esto nos va a servir para cuando venga un OR, ya que hay que invertir la primer comparacion
    // para que pueda evaluar las dos, sin hacer tantos if
    if(condicionOR) {
        condicionOR = 0;
        if (strcmp(comparador, ">") == 0)
            return "JNBE";
        if (strcmp(comparador, ">=") == 0)
            return "JNB";
        if (strcmp(comparador, "<") == 0)
            return "JNAE";
        if (strcmp(comparador, "<=") == 0)
            return "JNA";
        if (strcmp(comparador, "==") == 0)
            return "JE";
        if (strcmp(comparador, "!=") == 0)
            return "JNE";
    } else {
        if (strcmp(comparador, ">") == 0)
            return "JNA";
        if (strcmp(comparador, ">=") == 0)
            return "JNAE";
        if (strcmp(comparador, "<") == 0)
            return "JNB";
        if (strcmp(comparador, "<=") == 0)
            return "JNBE";
        if (strcmp(comparador, "==") == 0)
            return "JNE";
        if (strcmp(comparador, "!=") == 0)
            return "JE";
    }
}

char* obtenerSalto() {
    if(condicionOR) {
        if(esWhile)
            return "startWhile";
        return "startIf";
    } else {
        if(esWhile)
            return "endwhile";
        if (tieneElse) {
            return "else";
        } else {
            return "endif";
        }
    }
}