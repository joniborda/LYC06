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
_239                            	dd	239
_33                             	dd	33
_3                              	dd	3
_5                              	dd	5
_1111                           	dd	1111
_000                            	dd	000
@STDOUT                         	dd	?
_0                              	dd	0
_6                              	dd	6
_1                              	dd	1
@aux1                           	dd	?
@aux2                           	dd	?

.CODE

START:
MOV AX,@DATA
MOV DS,AX
MOV es,ax
FINIT
FFREE

MOV eax, _239
MOV fl, eax
MOV eax, _33
MOV b, eax
fild b
fild _3
fmul
fistp @aux1
MOV eax, @aux1
MOV a, eax
fild a
fild _5
fcom
fstsw ax
sahf
JNB else1
startIf1:
MOV eax, _1111
MOV c, eax
JMP endif1
else1:
MOV eax, _000
MOV c, eax
endif1:
MOV eax, c
MOV @STDOUT, eax
DisplayInteger @STDOUT
MOV eax, _0
MOV c, eax
condicionWhile1:
fild _6
fild c
fcom
fstsw ax
sahf
JNBE endwhile1
fild _1
fild c
fcom
fstsw ax
sahf
JNAE endwhile1
startWhile1:
fild c
fild _1
fadd
fistp @aux2
MOV eax, @aux2
MOV c, eax
JMP condicionWhile1
endwhile1:
MOV eax, c
MOV @STDOUT, eax
DisplayInteger @STDOUT
ffree
mov ax, 4c00h
int 21h
End START
