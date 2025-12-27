section .data

section .text
global _start

_start:
	mov eax, 3
	mov ebx, 2
	cmp eax, ebx	; eax - ebx -> positive? zero? negative?
	jl lesser	; jump if less than
	; je(equal), jne(not equal), jg(greater), jle(less or equal), jge(greater or equal), jz(zero), jnz(not zero)
	jmp end		; always jump
lesser:
	mov ecx,1
end:
	int 80h
