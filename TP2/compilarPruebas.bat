flex Lexico.l
pause
bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c archivos_punto_C/* -o Segunda.exe 

pause

@cd pruebas_sin_error
@for %%x in (*) do @(
	@echo --------------------- %%x ---------------------
	
	@if	 "ts.txt" NEQ "%%x" (
		@..\Segunda.exe %%x || (
		  	@cd ..\
		  	@echo .
		  	@echo /****************** ERROR ***************/
		  	delete.bat
		  	exit 0
		)
	)
)

@del gragh.dot
@cd ../pruebas_con_error
@for %%x in (*) do @(
	@echo .
	@echo --------------------- %%x ---------------------
	
	@if	 "ts.txt" NEQ "%%x" (
		..\Segunda.exe %%x
		..\Segunda.exe %%x && (
			@del gragh.dot
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
@del gragh.dot
@cd ..\
@delete.bat
@pause
