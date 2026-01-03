; src/kernel/main.asm
ORG 0x0
BITS 16

start:
    MOV si, os_boot_msg
    CALL print
    HLT

halt:
    JMP halt

print:
	PUSH si
	PUSH ax
	PUSH bx

print_loop:
	LODSB		; load string byte (1 byte) from [ds:si] to al, the physical address is at (ds * 16 + si), LODSB will auto increase the si for one byte
			; LODSB same as "MOV al, [si], INC si"
	OR al, al	; means is al is 0 (null terminator)?
	JZ done_print	; jump to done_print if al is 0

	MOV ah, 0x0E	; ah: 0x0E means print a char to the screen (teletype mode)
	MOV bh, 0	; page number, means display at screen 0
	INT 0x10	; video service interrupt (bios)
	JMP print_loop

done_print:
	POP bx
	POP ax
	POP si
	RET		; return to the next line of CALL print (HALT)

os_boot_msg: DB 'Our JazzOS has booted!', 0x0D, 0x0A, 0	; 0x0D: (Carriage Return, CR), 0x0A: (Line Feed, LF), 0 (Null Terminator)