section .data
	num DB 1
	num2 DB 2	;the address of the num2 is one byte next to num

section .text
global _start
_start:
	; mov ebx,[num]  : will move whole 32bits of the address of num -> if will get the value of num2 -> wrong!
	mov bl, [num]		; bl: the lower 1 byte of bx (bx is the lower 2 bytes of ebx)
	; mov ecx,[num2]
	mov cl, [num2]		; cl: the lower 1 byte of cx (cx is the lower 2 bytes of ecx)
	mov eax, 1
	int 80h
