section .data

section .text
global _start
_start:
	mov eax, 1	; sys_exit
	mov ebx, 1	; exit status 1
	int 80h		; h: hex, system interrupt
