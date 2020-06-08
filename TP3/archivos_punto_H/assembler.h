#ifndef ASSEMBLER_H
#define ASSEMBLER_H
#include "arbol_sintactico.h"

void generarAssembler(nodo *);
int generarHeader();
int generarData();
int generarInstrucciones(nodo *);
void recorreArbolAsm(FILE *, nodo *, int);
int determinarOperacion(FILE * , nodo *);

#endif