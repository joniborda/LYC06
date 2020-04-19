flex Lexico.l
bison -dyv Sintactico.y
gcc.exe lex.yy.c y.tab.c -o Primera.exe
Primera.exe pruebas/identificadorContieneIf.txt
Primera.exe pruebas/ifelse.txt
Primera.exe pruebas/ifsimple.txt
Primera.exe pruebas/sentenciasAnidadas.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Primera.exe

pause
