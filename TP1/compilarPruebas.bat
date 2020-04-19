flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe lex.yy.c y.tab.c -o Primera.exe
pause

cd pruebas
for %%x in (*) do (
	..\Primera.exe %%x
)
cd ..\
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Primera.exe

pause
