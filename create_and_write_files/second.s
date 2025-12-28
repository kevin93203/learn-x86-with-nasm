section .data
    pathname db "./test.txt", 0       ; 使用 db，結尾補 0 (Null terminator)
    msg      db "Hello World!", 0Ah   ; 使用 db，0Ah 是換行
    msg_len  equ $ - msg              ; 自動計算長度，而不是手動數 15

section .text
global _start
_start:
	; open and create the file
	mov eax, 5
	mov ebx, pathname
	mov ecx, 101o
	mov edx, 700o
	int 80h

	; write the file
	mov ebx, eax
	mov eax, 4
	mov ecx, msg
	mov edx, msg_len
	int 80h

	; eixt
	mov eax, 1
	mov ebx, 0
	int 80h
