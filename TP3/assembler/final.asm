INCLUDE macros2.asm
INCLUDE number.asm
.MODEL LARGE
.386
.STACK 200h
	.DATA	TRUE equ 1
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
_algo                           	dd	algo

.CODE

MOV AX,@DATA
MOV DS,AX
MOV es,ax
FINIT
FFREE

MOV var_string, _algo
ffree
mov ax, 4c00h
int 21h
End
