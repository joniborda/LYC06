%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <math.h>
#include "y.tab.h"
#include "archivos_punto_H/tabla_simbolo.h"
#include "archivos_punto_H/constantes.h"
#include "archivos_punto_H/arbol_sintactico.h"
FILE  *yyin;
int imprimir = 0;

void textoFuncion();
void idFuncion();
void enteroFuncion();
void floatFuncion();

void setImprimir() {
	imprimir = 1;
}
%}

%option noyywrap  
%option yylineno 


DIGITO		[0-9]
LETRA		[a-zA-Z]
ID			{LETRA}({LETRA}|{DIGITO}|_)*
CARACTER 	[a-z,A-Z,0-9,=,>,),(,<,!,:,+,".",-,\-,*,/,�,?,_,",",";"]
TEXTO 		\"({CARACTER}|" ")+\"
SUBCOMENTARIO   "/***"({CARACTER}|" "|\")*"***/"
COMENTARIO  "***/"({CARACTER}|"\t"|" "|\"|{SUBCOMENTARIO})*"/***"

%%
":="		{ return ASIG;}
"+"			{ return OP_SUMA;}
"-"			{ return OP_RESTA;}
"*"			{ return OP_MUL;}
"/"			{ return OP_DIV;}
"AND"		{ return OP_AND;}
"OR"		{ return OP_OR;}
"NOT"		{ return OP_NOT;}
">"			{ return CMP_MAYOR;}
"<"			{ return CMP_MENOR;}	
">="		{ return CMP_MAYOR_IGUAL;}
"<="		{ return CMP_MENOR_IGUAL;}
"=="		{ return CMP_IGUAL;}
"("			{ return P_A;}
")"			{ return P_C;}
"{"			{ return L_A;}
"}"			{ return L_C;}
"["			{ return C_A;}
"]"			{ return C_C;}
","			{ return COMA;}
";"			{ return PUNTO_Y_COMA;}
"IF"		{ return IF;}
"ELSE"		{ return ELSE;}
"WHILE"		{ return WHILE;}
"DISPLAY"	{ return SALIDA;}
"GET"		{ return ENTRADA;}
"DEFVAR"	{ return INICIA_DEC;}
"ENDVAR"	{ return FIN_DEC;}
"FLOAT"		{ return TIPO_FLOAT;}
"INT"		{ return TIPO_INT;}
"STRING"	{ return TIPO_STRING;}
":"			{ return DECS_2PTOS;}
"BETWEEN"	{ return BETWEEN;}
"FACT"		{ return FACT;}
"COMB"		{ return COMB;}

{TEXTO}			{ textoFuncion(); return STRING; }

{ID}			{ idFuncion(); return ID; }

{DIGITO}+		{ enteroFuncion(); return ENTERO; }

({DIGITO}+"."{DIGITO}*|{DIGITO}*"."{DIGITO}+) { floatFuncion(); return FLOAT; }

{COMENTARIO}
"\n"
"\t"
" "
%%

void textoFuncion() {
	int longitud = strlen(yytext)-2;
	char* subBuff = (char *) malloc(longitud + 1);
	strncpy(subBuff, yytext+1, longitud);
	subBuff[longitud] = '\0';
	yylval.str_val = strdup(subBuff);
	if (strlen(subBuff) > LIMITE_STR) {
		printf("Error: El string supero los 30 caracteres\n\tvariable: %s", yytext);
		exit(1);
	}
	if (imprimir) printf("Flex: String (%s)\n", subBuff);
	tsInsertarToken(CTE_STRING, yylval.str_val, strlen(subBuff), subBuff);
}

void idFuncion() {
	yylval.str_val = strdup(yytext);
	if (imprimir) printf("Flex: ID (%s)\n", yytext);
	tsInsertarToken(T_ID, yylval.str_val, strlen(yytext), "");
}

void enteroFuncion() {
	int aux = atoi(yytext);
	yylval.str_val = strdup(yytext);

	if (aux > LIMITE_INT) {
		printf("ERROR: La constante entera supera el máximo del límite permitido (16bits).");
		exit(1);
	}

	if (imprimir) printf("Flex Entero: %s (%d)\n", yytext, aux);
	tsInsertarToken(CTE_INTEGER, strdup(yytext), 0, yytext);
}

void floatFuncion() {
	float aux = atof(yytext);
	yylval.str_val = strdup(yytext);

	//Ver tema del limite máximo, debido a que trunca.
	if(log2f(atof(yytext)) > 32) {
		printf("ERROR: La constante float supera el máximo del límite permitido (32bits).\n");
		exit(1);
	}
	if (imprimir) printf("Flex Float: %s (%f)\n", yytext,aux);
	tsInsertarToken(CTE_FLOAT, strdup(yytext), 0, yytext);
}
