flex Lexico.l
pause
bison -dyv --debug Sintactico.y

gcc.exe lex.yy.c y.tab.c archivos_punto_C/* -o Primera.exe 
pause
Primera.exe prueba.txt
pause
dot -Tpng gragh.dot -o gragh.png
pause
delete.bat

pause
