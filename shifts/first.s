section .text
global _start

_start:
	mov eax,2
	shr eax,1	; shift right by 1 -> means divide by 2 -> faster
	shl eax,1	; shift left by 1 -> means mul by 2 -> faster
	; sar -> signed shift right
	; sal -> signed shift left
