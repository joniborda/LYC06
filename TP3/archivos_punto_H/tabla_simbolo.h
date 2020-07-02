#ifndef TABLA_SIMBOLO_H
#define TABLA_SIMBOLO_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "constantes.h"

// Tabla de simbolos
struct struct_tablaSimbolos {
    char nombre[100];
    int tipo;
    char valor[100];
    char longitud[100];
};
int getPosicionTS();

struct struct_tablaSimbolos tablaSimbolos[1000];

void tsInsertarToken(int, char *, char *, int);
int tsCrearArchivo();
void tsActualizarTipos(char *, int);
int tsObtenerTipo(char *);
char * obtenerNombreTipo(int);
char *aConstante(const char *);
int resolverTipo(const int, const int);
#endif