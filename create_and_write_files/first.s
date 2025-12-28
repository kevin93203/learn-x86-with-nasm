; OAH: '\n', ODH: '\r', '$': DOS/int 21h ending of string (in linux is meaningless)
section .data
	pathname DD "./test.txt"
	msg DD "Hello World!", 0AH, 0DH, "$"

section .text
global main

main:
	; open and create the file
	mov eax, 5		; sys_open
	mov ebx, pathname
	mov ecx, 101o		; (0100o, O_CREAT) | (0001o, O_WRONLY) -> can create and write
	mov edx, 700o		; (0400o, S_IRUSR) | (0200o, S_IWUSR) | (0100o, S_IXUSR) 
	int 80h

	; write msg to the file
	mov ebx, eax	; move file descriptor to ebx
	mov eax, 4	; sys_write
	mov ecx, msg
	mov edx, 15
	int 80h

	; exit
	mov eax, 1
	mov ebx, 0
	int 80h
