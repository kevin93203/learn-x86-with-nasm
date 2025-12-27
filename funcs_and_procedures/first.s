section .data

section .text
global main

add_two:
	add eax, ebx
	ret	; pop the stack and move the value(instruction address) to program counter

main:
	mov eax, 4
	mov ebx, 1
	call add_two	; it will push the next instuction address to the stack (address of mov ebx, eax)
	mov ebx, eax
	mov eax, 1
	int 80h
