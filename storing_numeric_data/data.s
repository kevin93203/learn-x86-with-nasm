section .data
	; DB(1 byte), DW(word, 2 bytes), DD(4 bytes), DQ(8 bytes), DT(10 bytes)
	num DD 5

section .text
global _start

_start:
	mov eax, 1
	mov ebx, [num]	; [] means get the value of the address
	int 80h
