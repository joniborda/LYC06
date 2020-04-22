flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe lex.yy.c y.tab.c archivos_punto_C/tabla_simbolo.c -o Primera.exe
pause

cd pruebas
for %%x in (*) do (
	..\Primera.exe %%x noImprimir || (
	  	@echo /*********************    ERROR    ***********************/
	  	pause
	  	cd ..\
	  	del lex.yy.c
		del y.tab.c
		del y.output
		del y.tab.h
		del Primera.exe
	  	exit
	)
)
cd ..\
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Primera.exe

pause
