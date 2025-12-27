section .data

section .text
global _start

_start:
	mov al, 0b11111111
	mov bl, 0b0001
	add al, bl	; al = al + bl, carry flag will be 1 (eflags first bit will be 1)
	adc ah, 0	; ah = ah + 0 + carry
	int 80h
