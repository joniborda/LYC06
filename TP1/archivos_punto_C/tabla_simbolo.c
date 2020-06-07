#include "../archivos_punto_H/tabla_simbolo.h"

int posicion_en_ts = 0; // Incremento Longitud en la estructura tabla de simbolos

void tsInsertarToken(int tipo, char *nombre, int longitud, char *valor) {
	int i;

	for (i = 0; i < posicion_en_ts; i++) {
		if (strcmp(tablaSimbolos[i].nombre, nombre) == 0) {
			// En caso que el valor exista, sale de la funcion.
			return;
		}
	}
	// En caso que el valor no exista, se agrega a la estructura
	tablaSimbolos[posicion_en_ts].tipo = tipo;
	strcpy(tablaSimbolos[posicion_en_ts].nombre, nombre);
	strcpy(tablaSimbolos[posicion_en_ts].valor, valor);

	char longitudStr[10];
	sprintf(longitudStr, "%d", longitud); 
	if (tablaSimbolos[i].tipo == CTE_STRING) {
		strcpy(tablaSimbolos[posicion_en_ts].longitud, longitudStr);
	}
	posicion_en_ts++;
}

int tsCrearArchivo() {
	int i;
	FILE *archivo;

	archivo = fopen("ts.txt", "w");
	if (!archivo) {
		return ERROR;
	}

	// Cabecera del archivo
	fprintf(archivo, "%-32s%-13s%-31s%-12s\n", "Nombre", "Tipo", "Valor", "Longitud");

	// Se escribe linea por linea
	for (i = 0; i < posicion_en_ts; i++) {
		if (tablaSimbolos[i].tipo == T_INTEGER || 
			tablaSimbolos[i].tipo == T_FLOAT ||
			tablaSimbolos[i].tipo == T_STRING
		) {
			fprintf(archivo, "%-32s%-13s\n", tablaSimbolos[i].nombre, obtenerNombreTipo(tablaSimbolos[i].tipo));
		} else {
			fprintf(archivo, "%-32s%-13s%-31s%-12s\n",
			aConstante(tablaSimbolos[i].nombre), obtenerNombreTipo(tablaSimbolos[i].tipo), tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
		}
	}
	fclose(archivo);

	return TODO_OK;
}

/**
 * Busca el ID en la tabla de simbolos y actualiza su tipo de dato
 */
void tsActualizarTipos(char * identificador, int tipoDato) {
	int i;
	for (i = 0; i < posicion_en_ts; i++) {
		if (strcmp(tablaSimbolos[i].nombre, identificador) == 0) {
			tablaSimbolos[i].tipo = tipoDato;
			//printf("Guardando %s=%s\n", tablaSimbolos[i].nombre, obtenerNombreTipo(tablaSimbolos[i].tipo));
		}
	}		
}

int tsObtenerTipo(char * identificador) {
	int i;
	for (i = 0; i < posicion_en_ts; i++) {
		if (strcmp(tablaSimbolos[i].nombre, identificador) == 0) {
			//printf("Guardando %s=%s\n", tablaSimbolos[i].nombre, obtenerNombreTipo(tablaSimbolos[i].tipo));
			return tablaSimbolos[i].tipo;
		}
	}
	return -1;
}

char * obtenerNombreTipo(const int tipo) {
	switch(tipo) {
		case T_INTEGER:
			return "INTEGER";
		case T_FLOAT:
			return "FLOAT";
		case T_STRING:
			return "STRING";
		case CTE_INTEGER:
			return "CTE_INTEGER";
		case CTE_FLOAT:
			return "CTE_FLOAT";
		case CTE_STRING:
			return "CTE_STRING";
		case T_ID:
			return "IDENTIFICADOR";
	}
}

char * aConstante(const char * valor) {
	char nombre[32] = "_";
	strcat(nombre, valor);
	return strdup(nombre);
}