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
_2_39                           	dd	2.39
_33                             	dd	33
@STDOUT                         	dd	?

.CODE

START:
MOV AX,@DATA
MOV DS,AX
MOV es,ax
FINIT
FFREE

MOV eax, _2_39
MOV fl, eax
MOV eax, _33
MOV b, eax
MOV eax, fl
MOV @STDOUT, eax
DisplayFloat @STDOUT,2
MOV eax, b
MOV @STDOUT, eax
DisplayInteger @STDOUT
ffree
mov ax, 4c00h
int 21h
End START
