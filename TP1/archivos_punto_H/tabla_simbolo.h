#ifndef TABLA_SIMBOLO_H
#define TABLA_SIMBOLO_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "constantes.h"

// Tabla de simbolos
struct struct_tablaSimbolos
{
    char nombre[100];
    char tipo[100];
    char valor[100];
    char longitud[100];
};
struct struct_tablaSimbolos tablaSimbolos[10000];

void insertarTokenEnTS(char *, char *, int, char *);
int crearArchivoTS();

#endif