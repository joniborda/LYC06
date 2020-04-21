%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "y.tab.h"
#include "archivos_punto_H/tabla_simbolo.h"
#include "archivos_punto_H/constantes.h"
FILE  *yyin;
int imprimir = 1;
void idFuncion();
void noImprimir() {
	imprimir = 0;
}
%}

%option noyywrap  
%option yylineno 


DIGITO		[0-9]
LETRA		[a-zA-Z]
ID			{LETRA}({LETRA}|{DIGITO}|_)*
CARACTER 	[a-z,A-Z,0-9,=,>,<,!,:,+,".",\-,*,/,�,?,_,","]
TEXTO 		\"({CARACTER}|" ")+\"
SUBCOMENTARIO   "/***"({CARACTER}|" "|\")*"***/"
COMENTARIO  "***/"({CARACTER}|" "|\"|{SUBCOMENTARIO})*"/***"

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
"BETWEEN"	{ return BETWEEN;}

{TEXTO}			{ yylval.str_val = yytext; if (imprimir) printf("Flex: String (%s)\n", yytext); return STRING;}

{ID}			{ yylval.str_val = yytext; if (imprimir) printf("Flex: ID (%s)\n", yytext); 
					insertarTokenEnTS("ID", yylval.str_val, strlen(yytext), "");
					return ID;}

{DIGITO}+		{idFuncion();return ENTERO;}

({DIGITO}+"."{DIGITO}*|{DIGITO}*"."{DIGITO}+) { yylval.val = atof(yytext); if (imprimir) printf("Flex Float: %s (%f)\n", yytext,yylval.val); return FLOAT;}

{COMENTARIO}
"\n"      		
"\t"
" "
%%
void idFuncion() {
	yylval.intval = atoi(yytext); 
	if (imprimir) printf("Flex Entero: %s (%d)\n", yytext,yylval.intval);
	insertarTokenEnTS("CONST_INT", strdup(yytext), 0, yytext);
}
