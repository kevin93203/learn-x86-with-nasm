section .text
global _start

_start:
	mov al,0xFF
	mov bl,2
	mul bl		; mul only provide one operand -> it will use 'a' register ->  al = al * bl
			; the result is 0x1fe -> mul will auto expand the result to ah (ah: 0x01, al:0xfe)
	;imul bl  :imul is signed mul -> 0xff will be -1
	int 80h
