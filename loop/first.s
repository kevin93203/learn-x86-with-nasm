section .data
	list DB 1,2,3,4

section .text
global _start
_start:
	mov eax, 0
	mov cl, 0
loop:
	mov bl, [list + eax]
	add cl,bl
	inc eax		; eax += 1
	cmp eax, 4
	je end
	jmp loop
end:
	mov eax, 1
	mov bl, cl
	int 80h
