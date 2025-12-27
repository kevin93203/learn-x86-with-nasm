section .data
	x DD 3.14	;32 bits (single-precision) -> 3.1400001
	y DD 2.1	; 2.0999999

section .text
global _start

_start:
	movss xmm0, [x]	;scaler(one value) single-precision, xmm0~xmm15 is for decimal value
	movss xmm1, [y]
	ucomiss xmm0, xmm1	; compare single-precision
	;jb, jbe, ja, jae, je	; floating point jump
	ja greater
	jmp end

greater:
	mov ecx, 1
end:
	addss xmm0, xmm1	; 5.23999977
	mov eax,1
	mov ebx,1
	int 80h
