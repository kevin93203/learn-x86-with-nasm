section .data

section .text
global _start

_start:
	mov eax, 3
	mov ebx, 5
	sub eax, ebx	; eax = eax - ebx, carry(borrow) and sign flags will be 1
	mov ebx, 2
	add eax, ebx
	int 80h
