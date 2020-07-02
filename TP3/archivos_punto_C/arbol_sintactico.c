#include "../archivos_punto_H/arbol_sintactico.h"

nodo* crearNodo(const char *d, nodo* hI, nodo* hD, const int tipo) {
	nodo* nuevoNodo = (nodo*)malloc(sizeof(nodo));
    if(nuevoNodo == NULL) {
        printf("No hay memoria disponible");
        exit(1);
    }
    strcpy(nuevoNodo->dato, d);
    nuevoNodo->tipo = tipo;
    nuevoNodo->hijoDer = hD;
    nuevoNodo->hijoIzq = hI;
    escribeLog(nuevoNodo->dato, nuevoNodo->hijoIzq->dato, nuevoNodo->hijoDer->dato);
    return nuevoNodo;
}

nodo* crearHoja(const char *d, const int tipo) {
	nodo* nuevoNodo = (nodo*)malloc(sizeof(nodo));
    if(nuevoNodo == NULL) {
        printf("No hay memoria disponible");
        exit(1);
    }
    strcpy(nuevoNodo->dato, d);
    nuevoNodo->tipo = tipo;
    nuevoNodo->hijoDer = NULL;
    nuevoNodo->hijoIzq = NULL;
    /* 
    Inserta en la tabla los auxiliares utilizados en el sintactico
    */
    if(strncmp(nuevoNodo->dato, "@", 1) == 0) {
        tsInsertarToken(tipo, nuevoNodo->dato, "", strlen(nuevoNodo->dato));
    }
    return nuevoNodo;
}

void liberarMemoria(nodo* padre) {
    if(padre == NULL) {
        return;
    }
    liberarMemoria(padre->hijoDer);
    liberarMemoria(padre->hijoIzq);
    free(padre);
    return;
}

void llenarGragh(nodo* padre, FILE *arch, int numNodo) {
    if(padre == NULL) {
        return;
    }
    int numHI = numNodo*2+1;
    int numHD = numNodo*2+2;
    
    if(padre->hijoIzq) {
        fprintf(arch, "\t\" %s@%d %s\" -> \" %s@%d %s\"\n", 
        padre->dato, numNodo, obtenerNombreTipo(typeDecorator(padre->tipo)), padre->hijoIzq->dato, numHI, obtenerNombreTipo(typeDecorator(padre->hijoIzq->tipo)));
    }
    if(padre->hijoDer) {
        fprintf(arch, "\t\" %s@%d %s\" -> \" %s@%d %s\"\n", 
        padre->dato, numNodo, obtenerNombreTipo(typeDecorator(padre->tipo)), padre->hijoDer->dato, numHD, obtenerNombreTipo(typeDecorator(padre->hijoDer->tipo)));
    }
    llenarGragh(padre->hijoIzq, arch, numHI);
    llenarGragh(padre->hijoDer, arch, numHD);
    return;
}

void escribirGragh(nodo* padre) {
    FILE *archivo;

	archivo = fopen("gragh.dot", "w");
	if (archivo == NULL) {
		return;
	}
    //escribir la plantilla para dibujar el grafo
    fprintf(archivo, "%s\n", "digraph G {");
    llenarGragh(padre, archivo, 0);
    fprintf(archivo, "%s", "}");
    
    fclose(archivo);
    return;
}

void escribirArbol(nodo *padre) {
    FILE *archivo = fopen(ARCHIVO_INSTRUCCIONES, "w");
    if (archivo == NULL) {
        return;
    }
    inOrden(archivo, padre);
    fclose(archivo);
}

int inOrden(FILE * archivo, struct nodo* raiz) {
    if (raiz != NULL) {
        int izq = inOrden(archivo, raiz->hijoIzq);
        if (izq == 1) {
            if (esHoja(raiz->hijoDer)) {
                // la izquierda ya esta, y la derecha es hoja
                fprintf(archivo, "%s  ", raiz->hijoIzq);
                fprintf(archivo, "%s  ", raiz->dato);
                fprintf(archivo, "%s  ", raiz->hijoDer);
                fprintf(archivo, "\n");
                return 1;
            }
            // estoy pasando de izquierda a derecha (ya dibuje la izquierda)
            // fprintf(archivo, "%s  ", raiz->dato);
        }

        inOrden(archivo, raiz->hijoDer);

        if (esHoja(raiz->hijoIzq) && esHoja(raiz->hijoDer)) {
            // soy nodo mas a la izquierda con dos hijos hojas 
            fprintf(archivo, "%s  ", raiz->hijoIzq);
            fprintf(archivo, "%s  ", raiz->dato);
            fprintf(archivo, "%s  ", raiz->hijoDer);
            fprintf(archivo, "\n");  
            return 1;
        }

        if (izq == 1) {
            // porque a la izquierda imprimi y seguro la derecha va encontrar dibujarse
            return 1;
        }

        if (izq == 0 && raiz->hijoIzq != NULL) {
            // resulta que mi hijo de la derecha tiene mas prioridad y al subir tengo que imprimirme
            fprintf(archivo, "%s  ", raiz->hijoIzq);
            fprintf(archivo, "%s  ", raiz->dato);
            fprintf(archivo, "%s  ", raiz->hijoDer);
            fprintf(archivo, "\n");
            return 1;
        }
    }
    // porque estoy a la izquierda pero soy hoja y mi padre todavia no me imprimio
    return 0;
}

int esHoja(nodo *hoja) {
    if (hoja == NULL) {
        return 0;
    }
    return hoja->hijoIzq == NULL && hoja->hijoDer == NULL;
}

void escribeLog(const char *padre, const char *hIzq, const char *hDer) {
    FILE *log = fopen(ARCHIVO_LOG, "a");
    if (log == NULL) {
        return;
    }
    fprintf(log, "\tNODO [%s]\n\tIZQ[%s], DER[%s]\n", padre, hIzq, hDer);
    fclose(log);
}

void crear_pila(t_pila *pp)
{
    *pp = NULL;
}

int apilarDinamica(t_pila *PP, const t_dato *pd)
{
    t_nodo *pnue= (t_nodo *)malloc(sizeof(t_nodo));
    if(!pnue)
        return 0;

    pnue->dato = *pd;
    pnue->psig = *PP;
    *PP=pnue;
    return 1;

}

int desapilarDinamica(t_pila *pp, t_dato *pd)
{
    t_nodo *aux;
    if(*pp==NULL)
        return 0;

    aux = *pp;
    *pd = aux->dato; //== (*pp)->dato
    *pp = aux->psig;
    free(aux);
    return 1;

}

int verTopeDinamica(t_pila *PP, t_dato *pd)
{

    if(!*PP)
        return 0;
    *pd=(*PP)->dato;

}
