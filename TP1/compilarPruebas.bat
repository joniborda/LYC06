flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe lex.yy.c y.tab.c -o Primera.exe
pause

cd pruebas\if
for %%x in (*) do (
	..\..\Primera.exe %%x
    @echo %%x
)
pause
cd ..\while
for %%x in (*) do (
	..\..\Primera.exe %%x
    @echo %%x
)

del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Primera.exe

pause
