#include "../archivos_punto_h/assembler.h"
int cantAux = 0;
int tieneElse = 0;
int condicionOR = 0;
int esWhile = 0;

int numEtiqWhile = 0;
int numEtiqIf = 0;

int pilaNumEtiqWhile [10];
int pilaNumEtiqIf [10];

int topePilaWhile = 0;
int topePilaIf = 0;
int addProcToAssignString = 0;
int hayFactorial = 0;

char instruccionDisplay[60];

void apilarEtiqueta(const int tipoEtiqueta) {
    if (tipoEtiqueta == ETIQUETA_IF) {
        numEtiqIf++;
        pilaNumEtiqIf[topePilaIf++] = numEtiqIf;
    }

    if (tipoEtiqueta == ETIQUETA_WHILE) {
        numEtiqWhile++;
        pilaNumEtiqWhile[topePilaWhile++] = numEtiqWhile;
    }
}

int desapilarEtiqueta(const int tipoEtiqueta) {
    if (tipoEtiqueta == ETIQUETA_IF) {
        return pilaNumEtiqIf[--topePilaIf];
    }
    if (tipoEtiqueta == ETIQUETA_WHILE) {
        return pilaNumEtiqWhile[--topePilaWhile];
    }
}

int verTopePilaEtiqueta(const int tipoEtiqueta) {
    if (tipoEtiqueta == ETIQUETA_IF) {
        return pilaNumEtiqIf[topePilaIf - 1];
    }
    if (tipoEtiqueta == ETIQUETA_WHILE) {
        return pilaNumEtiqWhile[topePilaWhile - 1];
    }
}

void generarAssembler(nodo * raiz) {
	if (generarHeader() == 1) {
		printf("Error al generar el assembler");
		return;
	}

	if (generarInstrucciones(raiz) == 1) {
		printf("Error al generar el assembler");
		return;	
	}

	if (generarData() == 1) {
		printf("Error al generar el assembler");
		return;
	}

    if (generarFooter() == 1) {
		printf("Error al generar el assembler");
		return;
	}

    if (generarArchivoAssemblerFinal() == 1) {
		printf("Error al generar el assembler");
		return;
    }
}

int generarArchivoAssemblerFinal() {
    FILE * fpFinal = fopen("./Final.asm", "w");

    char buffer[100];
	
    if (fpFinal == NULL) {
		printf("Error al abrir el archivo final.asm");
		return 1;
	}

    setFile(fpFinal, "./assembler/header.txt", buffer);
    setFile(fpFinal, "./assembler/data.txt", buffer);
    setFile(fpFinal, "./assembler/instrucciones.txt", buffer);
    setFile(fpFinal, "./assembler/footer.txt", buffer);

    fclose(fpFinal);
    return 0;
}

int setFile(FILE* fpFinal, char * nameFile, char* buffer){
    FILE * file = fopen( nameFile, "r");

	if (file == NULL) {
		printf("Error al abrir el archivo %s", nameFile);
		return 1;
	}

    while(fgets(buffer, sizeof(buffer), file)) {
        fprintf(fpFinal, "%s", buffer);
    }

    fclose(file);
}

int generarHeader() {
	FILE * fp = fopen("./assembler/header.txt", "w");
	if (fp == NULL) {
		printf("Error al abrir el archivo header");
		return 1;
	}

	fprintf(fp, "INCLUDE macros2.asm\n");
    fprintf(fp, "INCLUDE number.asm\n");
    fprintf(fp, ".MODEL LARGE\n");
    fprintf(fp, ".386\n");
    fprintf(fp, ".STACK 200h\n"); 
    fclose(fp);
    return 0;
}

int generarData() {
	FILE * fp = fopen("./assembler/data.txt", "wt+");
	if (fp == NULL) {
		printf("Error al abrir el archivo data");
		return 1;
	}

	fprintf(fp, "\t.DATA\n");    
    fprintf(fp, "\tTRUE equ 1\n");
    fprintf(fp, "\tFALSE equ 0\n");
    fprintf(fp, "\tMAXTEXTSIZE equ %d\n", 200);

    //Aca va la tabla de simbolo con todos los auxiliares
    int i;
    int a = getPosicionTS();
    for (i = 0; i < a; i++) {
        if (tablaSimbolos[i].tipo == CTE_STRING)
            fprintf(fp, "%-32s\tdb\t%s,'$', %s dup (?)\n", getNombre(i), tablaSimbolos[i].valor,
                    tablaSimbolos[i].longitud);
        else
            fprintf(fp, "%-32s\tdd\t%s\n", getNombre(i), verSiVaInterrogacion(tablaSimbolos[i].valor));
    }

    fprintf(fp, "\n.CODE\n");
    if (addProcToAssignString == 1) {
        // Agrego los procesimiento para asginar string
        fprintf(fp, "strlen proc\n");
        fprintf(fp, "\tmov bx, 0\n");
        fprintf(fp, "\tstrLoop:\n");
        fprintf(fp, "\t\tcmp BYTE PTR [si+bx],'$'\n");
        fprintf(fp, "\t\tje strend\n");
        fprintf(fp, "\t\tinc bx\n");
        fprintf(fp, "\t\tjmp strLoop\n");
        fprintf(fp, "\tstrend:\n");
        fprintf(fp, "\t\tret\n");
        fprintf(fp, "strlen endp\n");

        fprintf(fp, "assignString proc\n");
        fprintf(fp, "\tcall strlen\n");
        fprintf(fp, "\tcmp bx , MAXTEXTSIZE\n");
        fprintf(fp, "\tjle assignStringSizeOk\n");
        fprintf(fp, "\tmov bx , MAXTEXTSIZE\n");
        fprintf(fp, "\tassignStringSizeOk:\n");
        fprintf(fp, "\t\tmov cx , bx\n");
        fprintf(fp, "\t\tcld\n");
        fprintf(fp, "\t\trep movsb\n");
        fprintf(fp, "\t\tmov al , '$'\n");
        fprintf(fp, "\t\tmov byte ptr[di],al\n");
        fprintf(fp, "\t\tret\n");
        fprintf(fp, "assignString endp\n");
    }

    fclose(fp);
    return 0;
}

int generarFooter() {
	FILE * fp = fopen("./assembler/footer.txt", "w");
	if (fp == NULL) {
		printf("Error al abrir el archivo fotter");
		return 1;
	}

    
    fprintf(fp, "\nliberar:\n");
    fprintf(fp, "\tffree\n");
	fprintf(fp, "\tmov ax, 4c00h\n");
    fprintf(fp, "\tint 21h\n");
    fprintf(fp, "\tjmp fin\n");

    if (hayFactorial) {
        fprintf(fp, "showErrorFact:\n");
        fprintf(fp, "\tDisplayString __errorFact\n");
        fprintf(fp, "\tjmp liberar\n");
    }

    fprintf(fp, "fin:\n");
    fprintf(fp, "\tEnd START\n"); 

    fclose(fp);
    return 0;
}

char *getNombre(const int i) {
    if (tablaSimbolos[i].tipo == T_INTEGER || 
        tablaSimbolos[i].tipo == T_FLOAT ||
        tablaSimbolos[i].tipo == T_STRING
    ) {
        return tablaSimbolos[i].nombre;
    }
    return aConstante(tablaSimbolos[i].nombre);
}

char * verSiVaInterrogacion(char *valor) {
    if (strcmp(valor, "") == 0) {
        return "?";
    }
    return valor;
}

int generarInstrucciones(nodo * raiz) {
	FILE * fp = fopen("./assembler/instrucciones.txt", "wt+");
	if (fp == NULL) {
		printf("Error al abrir el archivo instrucciones");
		return 1;
	}

    
    fprintf(fp, "\nSTART:\nMOV AX,@DATA\nMOV DS,AX\nMOV es,ax\nFINIT\nFFREE\n\n");
	recorreArbolAsm(fp, raiz);
	fclose(fp);
	return 0;

}

void recorreArbolAsm(FILE * fp, nodo* raiz) {
    if (raiz != NULL) {
        int nodoActualIf = 0;
        int nodoActualWhile = 0;

        if(strcmp(raiz->dato, "IF") == 0) {
            tieneElse = 0;
            nodoActualIf = 1;
            // pido nueva etiqueta porque estoy empezando a recorrer un IF
            apilarEtiqueta(ETIQUETA_IF);
            
            if (strcmp(raiz->hijoDer->dato, "CUERPO") == 0) {
                tieneElse = 1;
            }
            if (strcmp(raiz->hijoIzq->dato, "OR") == 0) {
                condicionOR = 1;
            }
        }

        //WHILE
        if(strcmp(raiz->dato, "WHILE") == 0) {
            nodoActualWhile = 1;
            esWhile = 1;
            apilarEtiqueta(ETIQUETA_WHILE);
            fprintf(fp, "condicionWhile%d:\n", verTopePilaEtiqueta(ETIQUETA_WHILE));
            if (strcmp(raiz->hijoIzq->dato, "OR") == 0) {
                condicionOR = 1;
            }
        }

        // RECORRO LA IZQUIERDA
        recorreArbolAsm(fp, raiz->hijoIzq);
        // PASE POR LA IZQUIERDA

        if(nodoActualIf) {
            fprintf(fp, "startIf%d:\n", verTopePilaEtiqueta(ETIQUETA_IF));
        }

        if(strcmp(raiz->dato, "CUERPO") == 0) {
            fprintf(fp, "JMP endif%d\n", verTopePilaEtiqueta(ETIQUETA_IF));
            fprintf(fp, "else%d:\n", verTopePilaEtiqueta(ETIQUETA_IF));
        }

        if(nodoActualWhile) {
            fprintf(fp, "startWhile%d:\n", verTopePilaEtiqueta(ETIQUETA_WHILE));
            esWhile = 0; // No sería necesario la variable cambiarNombre
        }
        
        // RECORRO LA DERECHA
        recorreArbolAsm(fp, raiz->hijoDer);
        // PASE POR LA DERECHA

        if (nodoActualIf) {
            fprintf(fp, "endif%d:\n", desapilarEtiqueta(ETIQUETA_IF));
        }

        //while 
        if(nodoActualWhile) {
            fprintf(fp, "JMP condicionWhile%d\n", verTopePilaEtiqueta(ETIQUETA_WHILE));
            fprintf(fp, "endwhile%d:\n", desapilarEtiqueta(ETIQUETA_WHILE));
        }
        
        if (esHoja(raiz->hijoIzq) && esHoja(raiz->hijoDer)) {
            // soy nodo mas a la izquierda con dos hijos hojas
            determinarOperacion(fp, raiz);
            
            // reduzco arbol
            raiz->hijoIzq = NULL;
            raiz->hijoDer = NULL;
        }
    }
}

void determinarOperacion(FILE * fp, nodo * raiz) {

    if(esAritmetica(raiz->dato)) {
        if(strcmp(raiz->dato, ":=") == 0) {
            if (raiz->tipo == T_STRING) {
                addProcToAssignString = 1; 
                fprintf(fp, "MOV si, OFFSET   %s\n", raiz->hijoDer);
                fprintf(fp, "MOV di, OFFSET  %s\n", raiz->hijoIzq);
                fprintf(fp, "CALL assignString\n");
            } else {

                if (strcmp(raiz->hijoIzq->dato, "@NUMFACT") == 0) {
                    hayFactorial = 1;
                    tsInsertarToken(CTE_STRING, "_errorFact", "\"Error factorial\"", 16);
                    tsInsertarToken(CTE_INTEGER, "0", "0", 0);
                    
                    fprintf(fp, "fild %s\n", raiz->hijoDer->dato);
                    fprintf(fp, "fild _0\n");
                    fprintf(fp, "fcom\n");
                    fprintf(fp, "fstsw ax\n");
                    fprintf(fp, "sahf\n");
                    fprintf(fp, "JNBE showErrorFact\n");
                }
                fprintf(fp, "f%sld %s\n", determinarCargaPila(raiz, raiz->hijoDer), raiz->hijoDer->dato);
                fprintf(fp, "f%sstp %s\n", determinarCargaPila(raiz, raiz->hijoIzq), raiz->hijoIzq->dato);
            }
        } else {
            fprintf(fp, "f%sld %s\n", determinarCargaPila(raiz, raiz->hijoIzq), raiz->hijoIzq->dato); //st0 = izq
            fprintf(fp, "f%sld %s\n", determinarCargaPila(raiz, raiz->hijoDer), raiz->hijoDer->dato); //st0 = der st1 = izq
            fprintf(fp, "%s\n", obtenerInstruccionAritmetica(raiz->dato));
            fprintf(fp, "f%sstp @aux%d\n", determinarDescargaPila(raiz), pedirAux(raiz->tipo));

            // Guardo en el arbol el dato del resultado, si uso un aux
            sprintf(raiz->dato, "@aux%d", cantAux);
        }
    }

    if(esComparacion(raiz->dato)) {
        // esto funciona para comparaciones simples
        fprintf(fp, "f%sld %s\n", determinarCargaPila(raiz, raiz->hijoDer), raiz->hijoDer->dato); //st0 = der
        fprintf(fp, "f%sld %s\n", determinarCargaPila(raiz, raiz->hijoIzq), raiz->hijoIzq->dato); //st0 = izq  st1 = der
        fprintf(fp, "fcom\n"); // compara ST0 con ST1"
        fprintf(fp, "fstsw ax\n");
        fprintf(fp, "sahf\n");
        if (esWhile)
            fprintf(fp, "%s %s%d\n", obtenerInstruccionComparacion(raiz->dato), obtenerSalto(), verTopePilaEtiqueta(ETIQUETA_WHILE));
        else
            fprintf(fp, "%s %s%d\n", obtenerInstruccionComparacion(raiz->dato), obtenerSalto(), verTopePilaEtiqueta(ETIQUETA_IF));
    }

    if(strcmp(raiz->dato, "GET") == 0) {
        fprintf(fp, "%s %s\n", obtenerInstruccionGet(raiz->hijoIzq), raiz->hijoIzq->dato);
    }

    if(strcmp(raiz->dato, "DISPLAY") == 0) {
        fprintf(fp, "%s\n", obtenerInstruccionDisplay(raiz->hijoDer));
        fprintf(fp, "newLine 1\n");
    }

}

char *determinarCargaPila(const nodo * raiz, const nodo * hijo) {
    if (/*typeDecorator(raiz->tipo) == T_FLOAT &&*/ typeDecorator(hijo->tipo) == T_INTEGER) {
        // TODO: Ver si solo hay que verificar que el hijo sea T_INTEGER
        return "i";
    }
    return "";
}

char *determinarDescargaPila(const nodo * raiz) {
    if (typeDecorator(raiz->tipo) == T_INTEGER) {
        return "i";
    }
    return "";
}

int pedirAux(const int tipo) {
    cantAux++;
    char aux[10];
    sprintf(aux, "@aux%d", cantAux);
    tsInsertarToken(typeDecorator(tipo), aux, "", 0);
    return cantAux;
}

int auxActual() {
    return cantAux;
}

int esAritmetica(const char *operador) {
    // siendo aritmetica hay un lote de instrucciones predefinido, igual si es comparacion
    return strcmp(operador, "+") == 0 ||
    strcmp(operador, "-") == 0 ||
    strcmp(operador, "*") == 0 ||
    strcmp(operador, "/") == 0 ||
    strcmp(operador, ":=") == 0;
}

int esComparacion(const char *comparador) {
    // es necesaria esta funcion para que no entren los nodos AND, OR, NOR, etc que no tienen accion
    return strcmp(comparador, ">") == 0 ||
    strcmp(comparador, ">=") == 0 ||
    strcmp(comparador, "<") == 0 ||
    strcmp(comparador, "<=") == 0 ||
    strcmp(comparador, "==") == 0 ||
    strcmp(comparador, "!=") == 0;
}

char* obtenerInstruccionAritmetica(const char *operador) {
    if (strcmp(operador, "+") == 0)
        return "fadd";
    if (strcmp(operador, "-") == 0)
        return "fsub";
    if (strcmp(operador, "*") == 0)
        return "fmul";
    if (strcmp(operador, "/") == 0)
        return "fdiv";
}

char* obtenerInstruccionComparacion(const char *comparador) {
    // Esto nos va a servir para cuando venga un OR, ya que hay que invertir la primer comparacion
    // para que pueda evaluar las dos, sin hacer tantos if
    if(condicionOR) {
        condicionOR = 0;
        if (strcmp(comparador, ">") == 0)
            return "JNBE";
        if (strcmp(comparador, ">=") == 0)
            return "JNB";
        if (strcmp(comparador, "<") == 0)
            return "JNAE";
        if (strcmp(comparador, "<=") == 0)
            return "JNA";
        if (strcmp(comparador, "==") == 0)
            return "JE";
        if (strcmp(comparador, "!=") == 0)
            return "JNE";
    } else {
        if (strcmp(comparador, ">") == 0)
            return "JNA";
        if (strcmp(comparador, ">=") == 0)
            return "JNAE";
        if (strcmp(comparador, "<") == 0)
            return "JNB";
        if (strcmp(comparador, "<=") == 0)
            return "JNBE";
        if (strcmp(comparador, "==") == 0)
            return "JNE";
        if (strcmp(comparador, "!=") == 0)
            return "JE";
    }
}

char* obtenerSalto() {
    if(condicionOR) {
        if(esWhile)
            return "startWhile";
        return "startIf";
    } else {
        if(esWhile)
            return "endwhile";
        if (tieneElse) {
            return "else";
        } else {
            return "endif";
        }
    }
}

char* obtenerInstruccionDisplay(nodo* nodo) {
    // Los prints solo se permiten pueden IDs o strings
    int tipo = nodo->tipo;

    if (tipo == T_INTEGER) {
        sprintf(instruccionDisplay, "DisplayInteger %s", nodo);
    } else if (tipo == T_FLOAT) {
        sprintf(instruccionDisplay, "DisplayFloat %s,2", nodo);
    } else if (tipo == T_STRING) {
        sprintf(instruccionDisplay, "displayString %s", nodo);
    } else if (tipo == CTE_STRING) {
        sprintf(instruccionDisplay, "displayString %s", aConstante(nodo->dato));
    }
    return instruccionDisplay;
}

char* obtenerInstruccionGet(nodo* nodo) {
    // Solo se permite get para IDs
    if (nodo->tipo == T_INTEGER)
        return "GetInteger";
    if (nodo->tipo == T_FLOAT)
        return "GetFloat";
    if (nodo->tipo == T_STRING)
        return "getString";
}