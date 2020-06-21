#ifndef ASSEMBLER_H
#define ASSEMBLER_H
#include "arbol_sintactico.h"

void apilarEtiqueta(const int tipoEtiqueta);
int desapilarEtiqueta(const int tipoEtiqueta);
int verTopePilaEtiqueta(const int tipoEtiqueta);
char *determinarCargaPila(const nodo *, const nodo *);
char *determinarDescargaPila(const nodo *);
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