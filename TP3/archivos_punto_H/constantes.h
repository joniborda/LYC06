#ifndef CONSTANTES_H
#define CONSTANTES_H

// Constantes para tipo de dato.
#define LIMITE_STR 30
#define LIMITE_INT 65535
#define LIMITE_FLOAT 9999999.9999999999

// Manejo de errores
#define TODO_OK 0
#define ERROR 1

// estos tipos son solo para la declaracion
#define T_ERROR -1
#define T_NULL 0
#define T_INTEGER 1
#define T_FLOAT 2
#define T_STRING 3
// estos tipos si se usan en la tabla de simobolos
#define CTE_INTEGER 4
#define CTE_FLOAT 5
#define CTE_STRING 6
#define T_ID 7

static const int resolucionTipos [4][4] =
/*
				T_NULL 		T_INTEGER 	T_FLOAT 	T_STRING
	T_NULL		T_ERROR		T_ERROR		T_ERROR		T_ERROR
	T_INTEGER 	T_ERROR		T_INTEGER 	T_FLOAT 	T_ERROR
	T_FLOAT 	T_ERROR		T_FLOAT 	T_FLOAT 	T_ERROR
	T_STRING	T_ERROR		T_ERROR 	T_ERROR 	T_STRING
*/
{
	{ T_ERROR, 		T_ERROR, 	T_ERROR, 	T_ERROR },
	{ T_ERROR,		T_INTEGER, 	T_FLOAT, 	T_ERROR },
	{ T_ERROR,		T_FLOAT, 	T_FLOAT, 	T_ERROR },
	{ T_ERROR, 		T_ERROR, 	T_ERROR, 	T_STRING }
};

#define ARCHIVO_INSTRUCCIONES "intermedia.txt"
#define ARCHIVO_LOG "compilador.log"

#endif