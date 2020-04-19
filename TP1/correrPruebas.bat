flex Lexico.l
bison -dyv Sintactico.y
gcc.exe lex.yy.c y.tab.c -o Primera.exe
Primera.exe pruebas/if/identificadorContieneIf.txt
Primera.exe pruebas/if/ifelse.txt
Primera.exe pruebas/if/ifsimple.txt
Primera.exe pruebas/if/sentenciasAnidadas.txt
Primera.exe pruebas/while/whilesimple.txt
Primera.exe pruebas/while/identificadorContieneWhile.txt
Primera.exe pruebas/while/sentenciasAnidadas.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Primera.exe

pause
