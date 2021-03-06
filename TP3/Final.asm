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
d                               	dd	?
e                               	dd	?
f                               	dd	?
var_string                      	dd	?
f1                              	dd	?
_Compilador_LyC_Grupo06         	db	"Compilador LyC Grupo06",'$', 22 dup (?)
@STDOUT                         	dd	?
_Sumamos_4_y_2__se_guarda_en_a  	db	"Sumamos 4 y 2, se guarda en a",'$', 29 dup (?)
_4                              	dd	4
_2                              	dd	2
_Divido_a_por_2__se_guarda_en_b 	db	"Divido a por 2, se guarda en b",'$', 30 dup (?)
_6                              	dd	6
_5                              	dd	5
_a_mayor_a_5_y_b_menor_a_4      	db	"a mayor a 5 y b menor a 4",'$', 25 dup (?)
_6_5_por_2__menos_b__por_2_74_  	db	"6,5 por 2, menos b, por 2,74:",'$', 29 dup (?)
_6_5                            	dd	6.5
_2_74                           	dd	2.74
_8                              	dd	8
_10                             	dd	10
_3                              	dd	3
_1                              	dd	1
_El_valor_de_a_es_              	db	"El valor de a es:",'$', 17 dup (?)
_Ingrese_un_numero              	db	"Ingrese un numero",'$', 17 dup (?)
@STDIN                          	dd	?
_El_valor_entre_1_y_10          	db	"El valor entre 1 y 10",'$', 21 dup (?)
_El_valor_no_esta_entre_1_y_10  	db	"El valor no esta entre 1 y 10",'$', 29 dup (?)
_Factorial_de_4                 	db	"Factorial de 4",'$', 14 dup (?)
@NUMFACT                        	dd	?
@SUM0                           	dd	?
_Resultado_                     	db	"Resultado:",'$', 10 dup (?)
_Combinatoria_de__5_3_          	db	"Combinatoria de (5,3)",'$', 21 dup (?)
@SUM1                           	dd	?
@SUM2                           	dd	?
@SUM3                           	dd	?
@aux1                           	dd	?
@aux2                           	dd	?
@aux3                           	dd	?
@aux4                           	dd	?
@aux5                           	dd	?
@aux6                           	dd	?
@aux7                           	dd	?
@aux8                           	dd	?
__errorFact                     	db	"Error factorial",'$', 16 dup (?)
_0                              	dd	0
@aux9                           	dd	?
@aux10                          	dd	?
@aux11                          	dd	?
@aux12                          	dd	?
@aux13                          	dd	?
@aux14                          	dd	?
@aux15                          	dd	?
@aux16                          	dd	?
@aux17                          	dd	?
@aux18                          	dd	?
@aux19                          	dd	?

.CODE
strlen proc
	mov bx, 0
	strLoop:
		cmp BYTE PTR [si+bx],'$'
		je strend
		inc bx
		jmp strLoop
	strend:
		ret
strlen endp
assignString proc
	call strlen
	cmp bx , MAXTEXTSIZE
	jle assignStringSizeOk
	mov bx , MAXTEXTSIZE
	assignStringSizeOk:
		mov cx , bx
		cld
		rep movsb
		mov al , '$'
		mov byte ptr[di],al
		ret
assignString endp

START:
MOV AX,@DATA
MOV DS,AX
MOV es,ax
FINIT
FFREE

MOV si, OFFSET   _Compilador_LyC_Grupo06
MOV di, OFFSET  var_string
CALL assignString
displayString var_string
newLine 1
displayString _Sumamos_4_y_2__se_guarda_en_a
newLine 1
fild _4
fild _2
fadd
fistp @aux1
fild @aux1
fistp a
DisplayInteger a
newLine 1
displayString _Divido_a_por_2__se_guarda_en_b
newLine 1
fild a
fild _2
fdiv
fistp @aux2
fild @aux2
fistp b
DisplayInteger b
newLine 1
fild _6
fild a
fcom
fstsw ax
sahf
JNB startIf1
fild _2
fild a
fcom
fstsw ax
sahf
JNB endif1
startIf1:
fild _5
fild a
fcom
fstsw ax
sahf
JNA endif2
fild _4
fild b
fcom
fstsw ax
sahf
JNB endif2
startIf2:
displayString _a_mayor_a_5_y_b_menor_a_4
newLine 1
endif2:
endif1:
displayString _6_5_por_2__menos_b__por_2_74_
newLine 1
fld _6_5
fild _2
fmul
fstp @aux3
fld @aux3
fild b
fsub
fstp @aux4
fld @aux4
fld _2_74
fmul
fstp @aux5
fld @aux5
fstp f1
DisplayFloat f1,2
newLine 1
fild _8
fistp f
fild _8
fild f
fcom
fstsw ax
sahf
JNE endif3
startIf3:
condicionWhile1:
fild _10
fild f
fcom
fstsw ax
sahf
JNB endwhile1
startWhile1:
fild a
fild _3
fmul
fistp @aux6
fild @aux6
fistp a
fild f
fild _1
fadd
fistp @aux7
fild @aux7
fistp f
JMP condicionWhile1
endwhile1:
endif3:
displayString _El_valor_de_a_es_
newLine 1
DisplayInteger a
newLine 1
displayString _Ingrese_un_numero
newLine 1
GetInteger c
fild _1
fild c
fcom
fstsw ax
sahf
JNAE else4
fild _10
fild c
fcom
fstsw ax
sahf
JNBE else4
startIf4:
displayString _El_valor_entre_1_y_10
newLine 1
JMP endif4
else4:
displayString _El_valor_no_esta_entre_1_y_10
newLine 1
endif4:
displayString _Factorial_de_4
newLine 1
fild _2
fild _2
fadd
fistp @aux8
fild @aux8
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux8
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
fistp @aux9
fild @aux9
fistp @SUM0
fild @NUMFACT
fild _1
fsub
fistp @aux10
fild @aux10
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux10
fistp @NUMFACT
JMP condicionWhile2
endwhile2:
fild @SUM0
fistp d
displayString _Resultado_
newLine 1
DisplayInteger d
newLine 1
displayString _Combinatoria_de__5_3_
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
fistp @SUM3
condicionWhile3:
fild _1
fild @NUMFACT
fcom
fstsw ax
sahf
JNA endwhile3
startWhile3:
fild @SUM3
fild @NUMFACT
fmul
fistp @aux11
fild @aux11
fistp @SUM3
fild @NUMFACT
fild _1
fsub
fistp @aux12
fild @aux12
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux12
fistp @NUMFACT
JMP condicionWhile3
endwhile3:
fild _3
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild _3
fistp @NUMFACT
fild _1
fistp @SUM1
condicionWhile4:
fild _1
fild @NUMFACT
fcom
fstsw ax
sahf
JNA endwhile4
startWhile4:
fild @SUM1
fild @NUMFACT
fmul
fistp @aux13
fild @aux13
fistp @SUM1
fild @NUMFACT
fild _1
fsub
fistp @aux14
fild @aux14
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux14
fistp @NUMFACT
JMP condicionWhile4
endwhile4:
fild _5
fild _3
fsub
fistp @aux15
fild @aux15
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux15
fistp @NUMFACT
fild _1
fistp @SUM2
condicionWhile5:
fild _1
fild @NUMFACT
fcom
fstsw ax
sahf
JNA endwhile5
startWhile5:
fild @SUM2
fild @NUMFACT
fmul
fistp @aux16
fild @aux16
fistp @SUM2
fild @NUMFACT
fild _1
fsub
fistp @aux17
fild @aux17
fild _0
fcom
fstsw ax
sahf
JNBE showErrorFact
fild @aux17
fistp @NUMFACT
JMP condicionWhile5
endwhile5:
fild @SUM1
fild @SUM2
fmul
fistp @aux18
fild @SUM3
fild @aux18
fdiv
fistp @aux19
fild @aux19
fistp e
displayString _Resultado_
newLine 1
DisplayInteger e
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
