#ifndef ARBOL_SINTACTICO_H
#define ARBOL_SINTACTICO_H

#include "constantes.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Tabla de simbolos
typedef struct nodo{
    char dato[20];
    struct nodo* hijoDer;
    struct nodo* hijoIzq;
}nodo;

nodo* crearNodo(const char* , nodo* , nodo* );
nodo* crearHoja(const char*);
void liberarMemoria(nodo* );
void llegarGragh(nodo* , FILE*, int );
void escribirGragh(nodo*);
int inOrden(FILE *, nodo *);
void escribirArbol(nodo *padre);
int esHoja(nodo *hoja);

#endif