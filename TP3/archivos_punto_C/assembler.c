#include "../archivos_punto_h/assembler.h"
int cantAux = 0;
int cantEtiqueta = 0;
int tieneElse = 0;

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
	recorreArbolAsm(fp, raiz, 0);
	fclose(fp);
	return 0;

}
void recorreArbolAsm(FILE * fp, nodo* raiz, int etiquetaActual) {
    if (raiz != NULL) {
        int iff = 0;
        if(strcmp(raiz->dato, "IF") == 0) {
            tieneElse = 0;
            iff = 1;
            // pido nueva etiqueta porque estoy empezando a recorrer un IF
            etiquetaActual = pedirNumEtiqueta();
            if (strcmp(raiz->hijoDer->dato, "CUERPO") == 0) {
                tieneElse = 1;
            }
        }

        // RECORRO LA IZQUIERDA
        recorreArbolAsm(fp, raiz->hijoIzq, etiquetaActual);

        printf("dato padre %s", raiz->dato);

        int elseiff = 0;
        if(strcmp(raiz->dato, "IF") == 0) {
            fprintf(fp, "startIf%d:\n", etiquetaActual);
            // ver si la comp es <= entonces el salto es por JNAE
        }

        /*
        if(strcmp(raiz->dato, "AND") == 0) {
        }
            if (tieneElse == 1) {
                fprintf(fp, "JNA else%d\n", etiquetaActual);
                // ver si la comp es <= entonces el salto es por JNAE
                tieneElse = 0;
            } else {
                fprintf(fp, "JNA endif%d\n", etiquetaActual);
                // ver si la comp es <= entonces el salto es por JNAE
            }
        }*/

        if(strcmp(raiz->dato, "CUERPO") == 0) {
            elseiff = 1;
            fprintf(fp, "JMP endif%d\n", etiquetaActual);
            fprintf(fp, "else%d:\n", etiquetaActual);
        }
        
        // RECORRO LA DERECHA
        recorreArbolAsm(fp, raiz->hijoDer, etiquetaActual);
        if (iff == 1) {
            fprintf(fp, "endif%d:\n", etiquetaActual);
        }

        if (esHoja(raiz->hijoIzq) && esHoja(raiz->hijoDer)) {
            // soy nodo mas a la izquierda con dos hijos hojas
            printf("DATO2 : %s\n", raiz -> dato);
            determinarOperacion(fp, raiz, etiquetaActual);
            
            // reduzco arbol
            raiz->hijoIzq = NULL;
            raiz->hijoDer = NULL;
        }
    }
}

int determinarOperacion(FILE * fp, nodo * raiz, int etiquetaActual) {
   	printf("DATO : %s\n", raiz -> dato);

    if(strcmp(raiz->dato, "+") == 0) {
        fprintf(fp, "fld %s\n", raiz->hijoIzq);
        fprintf(fp, "fld %s\n", raiz->hijoDer);
        fprintf(fp, "fadd\n");
        fprintf(fp, "fstp @aux%d\n", pedirAux());
        // Guardo en el arbola el dato del resultado, si uso un aux
        sprintf(raiz->dato, "@aux%d", cantAux);
        return cantAux;
    }

    if(strcmp(raiz->dato, "-") == 0) {
        fprintf(fp, "fld %s\n", raiz->hijoIzq);
        fprintf(fp, "fld %s\n", raiz->hijoDer);
        fprintf(fp, "fsub\n");
        fprintf(fp, "fstp @aux%d\n", pedirAux());
        // Guardo en el arbola el dato del resultado, si uso un aux
        sprintf(raiz->dato, "@aux%d", cantAux);
        return cantAux;
    }

    if(strcmp(raiz->dato, "*") == 0) {
        fprintf(fp, "fld %s\n", raiz->hijoIzq);
        fprintf(fp, "fld %s\n", raiz->hijoDer);
        fprintf(fp, "fmul\n");
        fprintf(fp, "fstp @aux%d\n", pedirAux());
        // Guardo en el arbola el dato del resultado, si uso un aux
        sprintf(raiz->dato, "@aux%d", cantAux);
        return cantAux;
    }

    if(strcmp(raiz->dato, "/") == 0) {
        fprintf(fp, "fld %s\n", raiz->hijoIzq);
        fprintf(fp, "fld %s\n", raiz->hijoDer);
        fprintf(fp, "fdiv\n");
        fprintf(fp, "fstp @aux%d\n", pedirAux());
        // Guardo en el arbola el dato del resultado, si uso un aux
        sprintf(raiz->dato, "@aux%d", cantAux);
        return cantAux;
    }

    if(strcmp(raiz->dato, ">") == 0) {
        // esto funciona para comparaciones simples
        fprintf(fp, "fld %s\n", raiz->hijoIzq); //st0 = izq
        fprintf(fp, "fld %s\n", raiz->hijoDer); //st0 = der st1 = izq
        fprintf(fp, "fxch\n");
        fprintf(fp, "fcom\n"); // compara ST0 con ST1"
        fprintf(fp, "fstsw ax\n");
        fprintf(fp, "sahf\n");
        if (tieneElse) {
            fprintf(fp, "JNA else%d\n", etiquetaActual);
            // ver si la comp es <= entonces el salto es por JNAE
        } else {
            fprintf(fp, "JNA endif%d\n", etiquetaActual);
            // ver si la comp es <= entonces el salto es por JNAE
        }
        return 0;
    }

    if(strcmp(raiz->dato, "<") == 0) {
        // esto funciona para comparaciones simples Ejemplo: 1 < 2
        fprintf(fp, "fld %s\n", raiz->hijoIzq); //st0 = izq  (apila 1)
        fprintf(fp, "fld %s\n", raiz->hijoDer); //st0 = der st1 = izq (apila 2)
        fprintf(fp, "fcom\n"); // compara ST0 con ST1" (resta 2 - 1)
        fprintf(fp, "fstsw ax\n");
        fprintf(fp, "sahf\n");
        if (tieneElse) {
            fprintf(fp, "JNA else%d\n", etiquetaActual);
            // ver si la comp es <= entonces el salto es por JNAE
        } else {
            fprintf(fp, "JNA endif%d\n", etiquetaActual);
            // ver si la comp es <= entonces el salto es por JNAE
        }
        return 0;
    }

    if(strcmp(raiz->dato, "IF") == 0) {
        // no sabemos todavia
        return 0;
    }

    if(strcmp(raiz->dato, ":=") == 0) {
        fprintf(fp, "MOV %s, %s\n", raiz->hijoIzq, raiz->hijoDer);
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

int pedirNumEtiqueta() {
    return ++cantEtiqueta;
}
int etiquetaActual() {
    return cantEtiqueta;
}