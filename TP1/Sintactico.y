
%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

%}

%union {
int intval;
double val;
char *str_val;
}

%token <str_val>ID
%token <int>ENTERO
%token <double>FLOAT
%token <str_val>STRING

%token OP_SUMA OP_RESTA OP_MUL OP_DIV ASIG P_A P_C PUNTO_Y_COMA

%%

	
%%
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  fclose(yyin);
  return 0;
}
int yyerror(void)
     {
       printf("Syntax Error\n");
	 system ("Pause");
	 exit (1);
     }




