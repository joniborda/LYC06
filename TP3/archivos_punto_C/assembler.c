#include "../archivos_punto_h/assembler.h"

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
	printf("DATO : %s", raiz -> dato);
	recorreArbolAsm(fp, raiz);
	fclose(fp);
	return 0;

}

int recorreArbolAsm(FILE * fp, nodo* raiz) {
    if (raiz != NULL) {
    	printf("DATO : %s", raiz -> dato);
        int izq = recorreArbolAsm(fp, raiz->hijoIzq);
        if (izq == 1) {
            if (esHoja(raiz->hijoDer)) {
                // la izquierda ya esta, y la derecha es hoja
                printf("DATO1 : %s", raiz -> dato);
                determinarOperacion(fp, raiz);
                printf("DATO2 : %s", raiz -> dato);
                // reduzco arbol
                strcpy(raiz->dato, "@aux1");
                raiz->hijoIzq = NULL;
                raiz->hijoDer = NULL;

                return 1;
            }
            // estoy pasando de izquierda a derecha (ya dibuje la izquierda)
            // fprintf(archivo, "%s  ", raiz->dato);
        }

        recorreArbolAsm(fp, raiz->hijoDer);

        if (esHoja(raiz->hijoIzq) && esHoja(raiz->hijoDer)) {
            // soy nodo mas a la izquierda con dos hijos hojas
            printf("DATO1 : %s", raiz -> dato);
            determinarOperacion(fp, raiz);
            printf("DATO2 : %s", raiz -> dato);
            // reduzco arbol
            strcpy(raiz->dato, "@aux1");
            raiz->hijoIzq = NULL;
            raiz->hijoDer = NULL;

            return 1;
        }
    }
    // porque estoy a la izquierda pero soy hoja y mi padre todavia no me imprimio
    return 0;
}

void determinarOperacion(FILE * fp, nodo * raiz) {
   	printf("DATO : %s", raiz -> dato);
    if(strcmp(raiz->dato, "+") == 0) {
        fprintf(fp, "fld %s", raiz->hijoIzq);
        fprintf(fp, "fld %s", raiz->hijoDer);
        fprintf(fp, "fadd");
        fprintf(fp, "fstp @aux1");
    }
}