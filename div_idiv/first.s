section .text
global _start

_start:
	mov eax,11
	mov ecx,2
	div ecx		; eax = eax / ecx, eax will be 5, edx will contain remainder (1)
	;idiv ecx 	: signed div
	int 80h
