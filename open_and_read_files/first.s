section .data
	pathname DD "./hello.txt"

section .bss
	buffer: resb 1024	; reserve 1024 bytes

section .text
global main
main:
	; open the file
	mov eax, 5		; sys_open
	mov ebx, pathname	; file path
	mov ecx, 0		; read only
	int 80h			; perform system call -> file descriptor will be move to eax

	; read the file
	mov ebx, eax		; file descriptor move to ebx
	mov eax, 3		; sys_read
	mov ecx, buffer		; read buffer
	mov edx, 1024		; number of bytes to read
	int 80h

	; print the buffer
	mov eax, 4		; sys_write
	mov ebx, 1		; stdout
	mov ecx, buffer		; write buffer
	mov edx, 1024		; number of bytes to write
	int 80h

	; exit
	mov eax, 1		; sys_exit
	mov ebx, 0		; exit status 0
	int 80h
