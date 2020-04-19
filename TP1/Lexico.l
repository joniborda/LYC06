%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
FILE  *yyin;
int imprimir = 1;
void noImprimir() {
	imprimir = 0;
}
%}

%option noyywrap  
%option yylineno 


DIGITO		[0-9]
LETRA		[a-zA-Z]
ID			{LETRA}({LETRA}|{DIGITO}|_)*
CARACTER 	[a-z,A-Z,0-9,=,>,<,!,:,+,\-,*,/,¿,?,_,","]
TEXTO 		\"({CARACTER}|" ")+\"

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
";"			{ return PUNTO_Y_COMA;}
"IF"		{ return IF;}
"ELSE"		{ return ELSE;}
"WHILE"		{ return WHILE;}
"DISPLAY"	{ return SALIDA;}
"GET"		{ return ENTRADA;}

{TEXTO}			{ yylval.str_val = yytext; if (imprimir) printf("Flex: String (%s)\n", yytext); return STRING;}

{ID}			{ yylval.str_val = yytext; if (imprimir) printf("Flex: ID (%s)\n", yytext); return ID;}

{DIGITO}+		{ yylval.intval = atoi(yytext); if (imprimir) printf("Flex Entero: %s (%d)\n", yytext,yylval.intval); return ENTERO;}

{DIGITO}+"."{DIGITO}* { yylval.val = atof(yytext); if (imprimir) printf("Flex Float: %s (%f)\n", yytext,yylval.val); return FLOAT;}


"\n"      		
"\t"
" "		


