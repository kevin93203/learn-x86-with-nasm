BITS 16

section _ENTRY CLASS=CODE

extern _cstart_	; declare external function _cstart_ (in main.c)

global entry

entry:
	CLI	; Clear Interrupt Flag (disable interrupts)
	MOV ax, ds
	MOV ss, ax
	MOV sp, 0
	MOV bp, sp
	STI	; Set Interrupt Flag (enable interrupts)

	CALL _cstart_

	CLI
	HLT