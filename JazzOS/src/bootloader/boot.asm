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
	
	MOV [ebr_drive_number], dl ; the bios will first get the drive number and move to dl, so we get the driver number from dl fitst and save to ebr_drive_number
	MOV ax, 1	; the LBA index we want to read
	MOV cl, 1	; the sector number we want to read
	MOV bx, 0x7E00 ; the disk(sector) buffer address
	call disk_read
	
	MOV si, os_boot_msg	; si: source index, os_boot_msg is the address of the message, also means the offset
	CALL print
	HLT

halt:
    JMP halt

;input: LBA index in ax
;cx [bits 0-5]: sector number
;cx [bits 6-15]: cylinder
;dh: head
lba_to_chs:
	PUSH ax
	PUSH dx

	XOR dx, dx ; DX = 0
	DIV word [bdb_sectors_per_track] ; (LBA % sectors per track) + 1 <- sector
	; word means Divisor ([bdb_sectors_per_track]) is 16bits ->  Dividend is dx:ax
	; the Quotient will be at ax, Remainder will be at dx
	INC dx ; Secotr value (remainder is mov at dx)
	MOV cx, dx


	;head: (LBA / sectors per track) % number of heads
	;cylinder: (LBA / sectors per track) / number of heads
	XOR dx, dx ; DX = 0
	DIV word [bdb_heads]

	MOV dh, dl; head
	MOV ch, al
	SHL ah, 6
	OR cl, ah ; cylinder

	POP ax
	MOV dl, al
	POP ax

	RET

disk_read:
	PUSH ax
	PUSH bx
	PUSH cx
	PUSH dx
	PUSH disk_read
	
	call lba_to_chs

	MOV ah, 02h	; means Read Disk Sectors
	MOV di, 3	; counter (retry 3 times)

retry:
	STC
	INT 13h
	JNC doneRead	; jump if no carry

	call diskReset

	DEC di
	TEST di,di		; means di bitwise and di, bit result only change flags register -> compare if di is zero
	JNZ retry

failDiskRead:
	MOV si, read_failure
	CALL print
	HLT
	JMP halt

; reset the driver of the disk
diskReset:
	PUSHA
	MOV ah, 0
	STC
	INT 13h
	JC failDiskRead ; if failed to reset
	POPA
	RET

doneRead:
	POP di
	POP dx
	POP cx
	POP bx
	POP ax

	RET

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
read_failure: DB 'Failed to read disk!', 0x0D, 0x0A, 0

TIMES 510-($-$$) DB 0	; TIMES 510-($-$$) means repeat 510-($-$$) times, $ means the address of this line, $$ means the beginning address of this section
DW 0AA55h	; 2 bytes, x86 is little-endian, BIOS checks whether a sector is bootable, it looks at the last two bytes to see if they are 0x55AA
