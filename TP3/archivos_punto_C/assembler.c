#include "../archivos_punto_h/assembler.h"
int cantAux = 0;

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

int recorreArbolAsm(FILE * fp, nodo* raiz) {
    if (raiz != NULL) {
        int izq = recorreArbolAsm(fp, raiz->hijoIzq);
        if (izq == 1) {
            if (esHoja(raiz->hijoDer)) {
                // la izquierda ya esta, y la derecha es hoja
                printf("DATO1 : %s", raiz -> dato);
                int cantidad = determinarOperacion(fp, raiz);
                // reduzco arbol
                sprintf(raiz->dato, "@aux%d", cantidad);

                raiz->hijoIzq = NULL;
                raiz->hijoDer = NULL;

                return 1;
            }
            // estoy pasando de izquierda a derecha (ya dibuje la izquierda)
            // fprintf(archivo, "%s  ", raiz->dato);
        }
        printf("dato padre %s", raiz->dato);
        int iff = 0;
        int elseiff = 0;
        if(strcmp(raiz->dato, "IF") == 0) {
            iff = 1;
            if (strcmp(raiz->hijoDer->dato, "CUERPO") == 0) {
                fprintf(fp, "jna else\n");
            } else {
                fprintf(fp, "jna endif\n");
            }
        }

        if(strcmp(raiz->dato, "CUERPO") == 0) {
            elseiff = 1;
            fprintf(fp, "jump endif\n");
            fprintf(fp, "else\n");

        }


        recorreArbolAsm(fp, raiz->hijoDer);
        if (iff == 1) {
            fprintf(fp, "endif\n");
        }

        if (esHoja(raiz->hijoIzq) && esHoja(raiz->hijoDer)) {
            // soy nodo mas a la izquierda con dos hijos hojas
            printf("DATO2 : %s\n", raiz -> dato);
            int cantidad = determinarOperacion(fp, raiz);
            // reduzco arbol
            sprintf(raiz->dato, "@aux%d", cantidad);
            raiz->hijoIzq = NULL;
            raiz->hijoDer = NULL;

            return 1;
        }
    }
    // porque estoy a la izquierda pero soy hoja y mi padre todavia no me imprimio
    return 0;
}

int determinarOperacion(FILE * fp, nodo * raiz) {
   	printf("DATO : %s\n", raiz -> dato);

    if(strcmp(raiz->dato, "+") == 0) {
        fprintf(fp, "fld %s\n", raiz->hijoIzq);
        fprintf(fp, "fld %s\n", raiz->hijoDer);
        fprintf(fp, "fadd\n");
        fprintf(fp, "fstp @aux%d\n", nuevoAux());
        return cantAux;
    }

    if(strcmp(raiz->dato, "-") == 0) {
        fprintf(fp, "fld %s\n", raiz->hijoIzq);
        fprintf(fp, "fld %s\n", raiz->hijoDer);
        fprintf(fp, "fsub\n");
        fprintf(fp, "fstp @aux%d\n", nuevoAux());
        return cantAux;
    }

    if(strcmp(raiz->dato, "*") == 0) {
        fprintf(fp, "fld %s\n", raiz->hijoIzq);
        fprintf(fp, "fld %s\n", raiz->hijoDer);
        fprintf(fp, "fmul\n");
        fprintf(fp, "fstp @aux%d\n", nuevoAux());
        return cantAux;
    }

    if(strcmp(raiz->dato, "/") == 0) {
        fprintf(fp, "fld %s\n", raiz->hijoIzq);
        fprintf(fp, "fld %s\n", raiz->hijoDer);
        fprintf(fp, "fdiv\n");
        fprintf(fp, "fstp @aux%d\n", nuevoAux());
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

int nuevoAux() {
    return ++cantAux;
}