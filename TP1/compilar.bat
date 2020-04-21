flex Lexico.l
pause
bison -dyv --debug Sintactico.y
pause
gcc.exe lex.yy.c y.tab.c archivos_punto_C/tabla_simbolo.c -o Primera.exe 
pause
pause
Primera.exe prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Primera.exe

pause
