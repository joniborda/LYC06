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
_1                              	dd	1
_2                              	dd	2
@aux1                           	dd	?
fld _1
fld _2
fmul
fistp @aux1
MOV a, @aux1
ffree
mov ax, 4c00h
int 21h
End
