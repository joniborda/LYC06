INCLUDE macros2.asm
INCLUDE number.asm
.MODEL LARGE
.386
.STACK 200h
	.DATA
	TRUE equ 1
	FALSE equ 0
	MAXTEXTSIZE equ 200
a                               	dd	?
b                               	dd	?
c                               	dd	?
var_string                      	dd	?
fl                              	dd	?
_ingrese_un_num                 	db	"ingrese un num",'$', 14 dup (?)
_@STDOUT                        	db	,'$', 7 dup (?)
@STDIN                          	dd	?
_1                              	dd	1
_10                             	dd	10
_el_valor_entre_1_y_10          	db	"el valor entre 1 y 10",'$', 21 dup (?)
_el_valor_no_esta_entre_1_y_10  	db	"el valor no esta entre 1 y 10",'$', 29 dup (?)
_combinatoria_de__5_3_          	db	"combinatoria de (5,3)",'$', 21 dup (?)
_5                              	dd	5
_3                              	dd	3
@NUMFACT                        	dd	?
@SUM0                           	dd	?
@SUM1                           	dd	?
@SUM2                           	dd	?
_resultado                      	db	"resultado",'$', 9 dup (?)
__errorFact                     	db	"Error factorial",'$', 16 dup (?)
_0                              	dd	0
@aux1                           	dd	?
@aux2                           	dd	?
@aux3                           	dd	?
@aux4                           	dd	?
@aux5                           	dd	?
@aux6                           	dd	?
@aux7                           	dd	?
@aux8                           	dd	?
@aux9                           	dd	?

.CODE

START:
MOV AX,@DATA
MOV DS,AX
MOV es,ax
FINIT
FFREE

displayString _ingrese_un_num
newLine 1
GetInteger a
fild _1
fild a
fcom
fstsw ax
sahf
JNAE else1
fild _10
fild a
fcom
fstsw ax
sahf
JNBE else1
startIf1:
displayString _el_valor_entre_1_y_10
newLine 1
JMP endif1
else1:
displayString _el_valor_no_esta_entre_1_y_10
newLine 1
endif1:
displayString _combinatoria_de__5_3_
newLine 1
fild _5
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild _5
fistp @NUMFACT
fild _1
fistp @SUM2
condicionWhile1:
fild _1
fild @NUMFACT
fcom
fstsw ax
sahf
JNA endwhile1
startWhile1:
fild @SUM2
fild @NUMFACT
fmul
fistp @aux1
fild @aux1
fistp @SUM2
fild @NUMFACT
fild _1
fsub
fistp @aux2
fild @aux2
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux2
fistp @NUMFACT
JMP condicionWhile1
endwhile1:
fild _3
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild _3
fistp @NUMFACT
fild _1
fistp @SUM0
condicionWhile2:
fild _1
fild @NUMFACT
fcom
fstsw ax
sahf
JNA endwhile2
startWhile2:
fild @SUM0
fild @NUMFACT
fmul
fistp @aux3
fild @aux3
fistp @SUM0
fild @NUMFACT
fild _1
fsub
fistp @aux4
fild @aux4
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux4
fistp @NUMFACT
JMP condicionWhile2
endwhile2:
fild _5
fild _3
fsub
fistp @aux5
fild @aux5
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux5
fistp @NUMFACT
fild _1
fistp @SUM1
condicionWhile3:
fild _1
fild @NUMFACT
fcom
fstsw ax
sahf
JNA endwhile3
startWhile3:
fild @SUM1
fild @NUMFACT
fmul
fistp @aux6
fild @aux6
fistp @SUM1
fild @NUMFACT
fild _1
fsub
fistp @aux7
fild @aux7
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux7
fistp @NUMFACT
JMP condicionWhile3
endwhile3:
fild @SUM0
fild @SUM1
fmul
fistp @aux8
fild @SUM2
fild @aux8
fdiv
fistp @aux9
fild @aux9
fistp c
displayString _resultado
newLine 1
DisplayInteger c
newLine 1

liberar:
	ffree
	mov ax, 4c00h
	int 21h
	jmp fin
showErrorFact:
	DisplayString __errorFact
	jmp liberar
fin:
	End START
