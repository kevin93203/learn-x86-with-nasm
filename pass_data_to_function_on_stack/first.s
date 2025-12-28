section .text
add_two:
	push ebp
	mov ebp, esp
	mov eax, [ebp+8]
	mov ebx, [ebp+12]
	add eax, ebx
	pop ebp
	ret

global main
main:
	push 4
	push 1
	call add_two
	mov ebx, eax
	mov eax, 1
	int 80h
