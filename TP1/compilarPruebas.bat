flex Lexico.l
pause
bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c archivos_punto_C/tabla_simbolo.c -o Primera.exe
pause

@cd pruebas_sin_error
@for %%x in (*) do @(
	@echo --------------------- %%x ---------------------
	
	@if	 "ts.txt" NEQ "%%x" (
		@..\Primera.exe %%x noImprimir || (
		  	@cd ..\
		  	@echo .
		  	@echo /****************** ERROR ***************/
		  	delete.bat
		  	exit 0
		)
	)
)

@cd ../pruebas_con_error
@for %%x in (*) do @(
	@echo .
	@echo --------------------- %%x ---------------------
	
	@if	 "ts.txt" NEQ "%%x" (
		..\Primera.exe %%x noImprimir
		..\Primera.exe %%x noImprimir && (
		  	@echo .
		  	@echo /***************** DEBERIA ARROJAR ERROR ***************/
		  	@cd ..\
			@delete.bat
			@pause
			exit 0

		)
	)
)
@echo .
@echo /****************** PRUEBAS OK ***************/
@cd ..\
@delete.bat
@pause
