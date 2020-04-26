flex Lexico.l
pause
bison -dyv --debug Sintactico.y

gcc.exe lex.yy.c y.tab.c archivos_punto_C/tabla_simbolo.c -o Primera.exe 
pause
Primera.exe prueba.txt Noimprimir
delete.bat

pause
