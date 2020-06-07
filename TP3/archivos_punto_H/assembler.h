#ifndef ASSEMBLER_H
#define ASSEMBLER_H
#include "arbol_sintactico.h"

void generarAssembler(nodo *);
int generarHeader();
int generarData();
int generarInstrucciones(nodo *);
int recorreArbolAsm(FILE *, nodo *);
void determinarOperacion(FILE * , nodo *);

#endif