; src/bootloader/boot.asm
ORG 0x7C00	; the code will be load to memory address: 0x7C00
BITS 16		; means 16 bit real mode

JMP SHORT main ; JMP SHORT  (for small, nearby jumps)
NOP			;  No Operation (to force memory alignment)

; BIOS Parameter Block (BPB)
bdb_oem: DB 'MSWIN4.1'
bdb_bytes_per_sector: DW 512
bdb_sectors_per_cluster: DB 1
bdb_reserved_sectior: DW 1
bdb_fat_count: DB 2
bdb_dir_entries_count: DW 0E0h
bdb_total_sectors: DW 2880
bdb_media_descriptor_type: DB 0F0h
bdb_sectors_per_fat: DW 9
bdb_sectors_per_track: DW 18
bdb_heads: DW 2
bdb_hidden_sections: DD 0
bdb_large_sector_count: DD 0

; (Extended Boot Record, EBR)
ebr_drive_number: DB 0
				  DB 0
ebr_signature:	  DB 29h
ebr_volume_id:	  DB 12h,34h,56h,78h
ebr_volume_label:  DB 'JASS OS    '	; 11 chars
ebr_system_id:	   DB 'FAT12   '	; 8 chars

main:
	MOV ax, 0		; ax is 16 bits
	MOV ds, ax		; data segment set to 0
	MOV es, ax		; extra segment set to 0
	MOV ss, ax		; stack segment set to 0
	MOV sp, 0x7C00		; stack pointer set to 0x7C00
	MOV si, os_boot_msg	; si: source index, os_boot_msg is the address of the message, also means the offset
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

os_boot_msg: DB 'Our OS has booted!', 0x0D, 0x0A, 0	; 0x0D: (Carriage Return, CR), 0x0A: (Line Feed, LF), 0 (Null Terminator)

TIMES 510-($-$$) DB 0	; TIMES 510-($-$$) means repeat 510-($-$$) times, $ means the address of this line, $$ means the beginning address of this section
DW 0AA55h	; 2 bytes, x86 is little-endian, BIOS checks whether a sector is bootable, it looks at the last two bytes to see if they are 0x55AA
