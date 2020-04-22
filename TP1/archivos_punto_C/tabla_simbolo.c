#include "../archivos_punto_H/tabla_simbolo.h"

int posicion_en_ts = 0; // Incremento Longitud en la estructura tabla de simbolos

void insertarTokenEnTS(char *tipo, char *nombre, int longitud, char *valor)
{
	int i;

	for (i = 0; i < posicion_en_ts; i++)
	{
		if (strcmp(tablaSimbolos[i].nombre, nombre) == 0)
		{
			// En caso que el valor exista, sale de la funcion.
			return;
		}
	}
	// En caso que el valor no exista, se agrega a la estructura
	strcpy(tablaSimbolos[posicion_en_ts].tipo, tipo);
	strcpy(tablaSimbolos[posicion_en_ts].nombre, nombre);
	strcpy(tablaSimbolos[posicion_en_ts].valor, valor);

	char longitudStr[10];
	sprintf(longitudStr, "%d", longitud); 
	if(strcmp(tablaSimbolos[i].tipo, "CONST_STR") == 0)
	{
		strcpy(tablaSimbolos[posicion_en_ts].longitud, longitudStr);
	}
	posicion_en_ts++;
}

int crearArchivoTS()
{
	FILE *archivo;
	int i;
	archivo = fopen("tabla_simbolo.txt", "w");
	if (!archivo)
	{
		return ERROR;
	}

	// Cabecera del archivo
	fprintf(archivo, "%-30s%-12s%-30s%-12s\n", "Nombre", "Tipo", "Valor", "Longitud");

	// Se escribe linea por linea
	for (i = 0; i < posicion_en_ts; i++)
	{
		if(tablaSimbolos[i].nombre[0] != '_')
		{
			if ((strcmp(tablaSimbolos[i].tipo, "INTEGER") == 0)
			|| (strcmp(tablaSimbolos[i].tipo, "FLOAT") == 0) 
			|| (strcmp(tablaSimbolos[i].tipo, "STRING") == 0))
			{
				fprintf(archivo, "%-30s%-12s\n", tablaSimbolos[i].nombre, tablaSimbolos[i].tipo);
			}
			else
			{
				fprintf(archivo, "%-29s%-12s%-30s%-12s\n",
				tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
			}
		}
	}
	fclose(archivo);

	return TODO_OK;
}