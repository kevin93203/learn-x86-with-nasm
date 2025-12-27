extern printf
extern exit

section .data
	msg1 DD "Hello World!", 0	; 0 is null terminator
	msg2 DD "This is a test!", 0
	fmt DB "Output is: %s %s", 10, 0	; 10 is new line char
section .text
global main	;need main function work for gcc

main:
	; printf(fmt, msg1, msg2)
	; push parameters to stack (LIFO)
	push msg2
	push msg1
	push fmt
	call printf

	; exit(10)
	push 10
	call exit
