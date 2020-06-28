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
fl                              	dd	?
_5                              	dd	5
_2                              	dd	2
@NUMFACT                        	dd	?
_1                              	dd	1
@SUM0                           	dd	?
@SUM1                           	dd	?
@SUM2                           	dd	?
@STDOUT                         	dd	?
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

MOV eax, _5
MOV @NUMFACT, eax
MOV eax, _1
MOV @SUM2, eax
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
MOV eax, @aux1
MOV @SUM2, eax
fild @NUMFACT
fild _1
fsub
fistp @aux2
MOV eax, @aux2
MOV @NUMFACT, eax
JMP condicionWhile1
endwhile1:
MOV eax, _2
MOV @NUMFACT, eax
MOV eax, _1
MOV @SUM0, eax
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
MOV eax, @aux3
MOV @SUM0, eax
fild @NUMFACT
fild _1
fsub
fistp @aux4
MOV eax, @aux4
MOV @NUMFACT, eax
JMP condicionWhile2
endwhile2:
fild _5
fild _2
fsub
fistp @aux5
MOV eax, @aux5
MOV @NUMFACT, eax
MOV eax, _1
MOV @SUM1, eax
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
MOV eax, @aux6
MOV @SUM1, eax
fild @NUMFACT
fild _1
fsub
fistp @aux7
MOV eax, @aux7
MOV @NUMFACT, eax
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
MOV eax, @aux9
MOV b, eax
MOV eax, b
MOV @STDOUT, eax
DisplayInteger @STDOUT
newLine 1
ffree
mov ax, 4c00h
int 21h
End START
