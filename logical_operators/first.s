section .text
global _start

_start:
	mov eax, 0b1010
	mov ebx, 0b1100
	and eax, ebx	;eax = eax % ebx

	mov eax, 0b1010
        mov ebx, 0b1100
        or eax, ebx    ;eax = eax | ebx

	mov eax,0b1010
	not eax
	and eax, 0xF	;will only remain the last 4 bits -> a mask

	mov eax,0b1010
        mov ebx,0b1100
        xor eax, ebx

	int 80h
