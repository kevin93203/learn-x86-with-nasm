section .bss		; block starting symbol
	num RESB 3	; reserve 3 bytes of memory

section .data
	num2 DB 3 DUP(2)	; init 3 bytes and init with value of 2

section .text
global _start

_start:
	mov bl,1
	mov bl,[num2]
	mov [num],bl	;bl is one byte (move to memory needs the size)
	mov [num+1],bl
	mov [num+2],bl

	mov eax, 1
	int 80h


