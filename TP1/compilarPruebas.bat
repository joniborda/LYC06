flex Lexico.l
pause
bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c archivos_punto_C/tabla_simbolo.c -o Primera.exe
pause

@cd pruebas
@for %%x in (*) do @(
	@echo --------------------- %%x ---------------------
	
	@if	 "ts.txt" NEQ "%%x" (
		@..\Primera.exe %%x noImprimir || (
		  	@cd ..\
		  	@echo .
		  	@echo /****************** ERROR ***************/
		  	delete.bat
		)
	)
)
@cd ..\
@delete.bat

@pause
