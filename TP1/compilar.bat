flex Lexico.l
pause
bison -dyv --debug Sintactico.y

gcc.exe lex.yy.c y.tab.c archivos_punto_C/tabla_simbolo.c -o Segunda.exe 
pause
Segunda.exe prueba.txt
delete.bat

pause
