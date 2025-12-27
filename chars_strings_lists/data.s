section .data
	char DB 'A'
	list DB 1,2,3,4
	string1 DB "ABA", 0	; 0 is null terminator
	string2 DB "CDE", 0

section .text
global _start

_start:
	;mov bl,[string1]
	mov bl,[list]
	mov eax, 1
	int 80h
