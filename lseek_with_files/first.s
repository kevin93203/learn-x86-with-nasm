section .data
	pathname DD "./test.txt"

section .bss
	buffer: resb 10

section .text
global main

main:
	; open the file
	mov eax, 5
	mov ebx, pathname
	mov ecx, 0
	int 80h

	; lseek
	mov ebx, eax	; file descriptor
	mov eax, 19	; sys_lseek
	mov ecx, 20	; number of offset bytes
	mov edx, 0	; seek_set (from beginning of the file)
	int 80h

	; read
	mov eax, 3		; sys_read
	mov ecx, buffer
	mov edx, 10
	int 80h

	; print
	mov eax, 4
	mov ebx, 1
	int 80h

	; exit
	mov eax, 1
	mov ebx, 0
	int 80h

