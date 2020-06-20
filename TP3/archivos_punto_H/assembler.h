#ifndef ASSEMBLER_H
#define ASSEMBLER_H
#include "arbol_sintactico.h"

void generarAssembler(nodo *);
int generarHeader();
int generarData();
int generarInstrucciones(nodo *);
void recorreArbolAsm(FILE *, nodo *);
int determinarOperacion(FILE * , nodo *);
int esAritmetica(const char *);
int esComparacion(const char *);
char* obtenerInstruccionAritmetica(const char *);
char* obtenerInstruccionComparacion(const char *);
char* obtenerSalto();

#endif