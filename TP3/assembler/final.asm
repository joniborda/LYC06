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
_33                             	dd	33
_3                              	dd	3
_2.3                            	dd	2.3
_3.5                            	dd	3.5
_algo                           	dd	algo
@aux1                           	dd	?
@aux2                           	dd	?

.CODE

MOV AX,@DATA
MOV DS,AX
MOV es,ax
FINIT
FFREE

MOV b, _33
fild b
fild _3
fmul
fistp @aux1
MOV a, @aux1
fld _2.3
fld _3.5
fadd
fstp @aux2
MOV fl, @aux2
MOV var_string, _algo
ffree
mov ax, 4c00h
int 21h
End
