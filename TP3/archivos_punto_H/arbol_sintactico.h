#ifndef ARBOL_SINTACTICO_H
#define ARBOL_SINTACTICO_H

#include "constantes.h"
#include "tabla_simbolo.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Estructura para el arbol sintactico
typedef struct nodo{
    char dato[20];
    int tipo;
    struct nodo* hijoDer;
    struct nodo* hijoIzq;
}nodo;

// Estructura para el dato de la pila dinamica
typedef nodo* t_dato;

// Estructura para el nodo de la pila dinamica
typedef struct s_nodo
{
    t_dato dato;
    struct s_nodo* psig;
} t_nodo;

// Estructura para la pila dinamica
typedef t_nodo* t_pila;

nodo* crearNodo(const char* , nodo* , nodo*, const int);
nodo* crearHoja(const char*, const int);
void liberarMemoria(nodo* );
void llegarGragh(nodo* , FILE*, int );
void escribirGragh(nodo*);
int inOrden(FILE *, nodo *);
void escribirArbol(nodo *padre);
int esHoja(nodo *hoja);
void escribeLog(const char *, const char *, const char *);

int apilarDinamica(t_pila *, const t_dato *);
int desapilarDinamica(t_pila *,t_dato *);
int verTopeDinamica(t_pila *,t_dato *);
#endif