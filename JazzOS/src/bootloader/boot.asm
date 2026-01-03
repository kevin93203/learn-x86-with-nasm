; src/bootloader/boot.asm
ORG 0x7C00	; the code will be load to memory address: 0x7C00
BITS 16		; means 16 bit real mode

JMP SHORT main ; JMP SHORT  (for small, nearby jumps)
NOP			;  No Operation (to force memory alignment)

; BIOS Parameter Block (BPB)
bdb_oem: DB 'MSWIN4.1'
bdb_bytes_per_sector: DW 512
bdb_sectors_per_cluster: DB 1	; cluster means the unit of storage in FAT file system, each cluster is a contiguous block of sectors
bdb_reserved_sectior: DW 1
bdb_fat_count: DB 2
bdb_dir_entries_count: DW 0E0h	; 224
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
	
	;FAT 12 has 4 segments
	;1. reserved segment: 1 sector
	;2. FAT segment: 9 * 2 = 18 sectors (sectors per fat * fat count)
	;3. root directory segment
	;4. data segment

	; calculate the start sector of root directory segment (LBA)
	MOV ax, [bdb_sectors_per_fat]
	MOV bl, [bdb_fat_count]
	XOR bh,bh	; bh = 0
	MUL bx		; ax = ax * bx (sectors per fat * fat count)
	ADD ax, [bdb_reserved_sectior] ; ax = ax + bdb_reserved_sectior , ax will be the start sector of root directory segment (LBA)
	PUSH ax

	; calculate the number of sectors needed to store all directory entries
	; what is directory entries?
	; directory entries are the entries in the root directory that describe the files and directories in the file system
	MOV ax, [bdb_dir_entries_count]
	SHL ax, 5 ; ax = ax * 32 (dir entry size)
	XOR dx, dx
	DIV word [bdb_bytes_per_sector] ; ax = (32 * dir entries count) / bytes per sector
	TEST dx, dx ; compare dx with 0 (remainder is 0?)
	JZ rootDirAfter
	INC ax
	; ax will be the number of sectors needed to store all directory entries

; read the data from the root directory from the disk
rootDirAfter:
	MOV cl, al ; cl = al (number of sectors needed to store all directory entries)
	POP ax ; ax = start sector of root directory segment (LBA)
	MOV dl, [ebr_drive_number] ; dl = drive number
	MOV bx, buffer
	CALL disk_read

	XOR bx, bx ; bx = 0 (buffer offset)
	MOV di, buffer ; di = buffer address

searchKernel:
	MOV si, file_kernel_bin
	MOV cx, 11 ; cx = 11 (file_kernel_bin length)
	PUSH di
	REPE CMPSB ; compare string byte (1 byte) from [ds:si] to [es:di], the physical address is at (ds * 16 + si) and (es * 16 + di), CMPSB will auto increase the si and di for one byte
	POP di
	JE foundKernel

	ADD di, 32 ; di = di + 32 (next dir entry)
	INC bx ; bx = bx + 1 (next dir entry offset)
	CMP bx, [bdb_dir_entries_count]	; compare bx with bdb_dir_entries_count
	JL searchKernel	; if bx is less than bdb_dir_entries_count, continue search

	JMP kernelNotFound

kernelNotFound:
	MOV si, msg_kernel_not_found
	CALL print
	HLT
	JMP halt

foundKernel:
	MOV ax, [di+26] ; di is the address of the kernel.bin, 26 is the offset to the first logical cluster field
	MOV [kernel_cluster], ax
	
	; load the FAT segment into memory
	MOV ax, [bdb_reserved_sectior] ; ax = ax + bdb_reserved_sectior , ax will be the start sector of root directory segment (LBA)
	MOV bx, buffer
	MOV cl, [bdb_sectors_per_fat]
	MOV dl, [ebr_drive_number]

	CALL disk_read ;initial load the file allocation table from the disk into memory

	MOV bx, kernel_load_segment ; kernel target address
	MOV es, bx
	MOV bx, kernel_load_offset

loadKernelLoop:
	MOV ax, [kernel_cluster]
	ADD ax, 31	; 1 + (9 * 2) + (224 * 32 / 512) = 33, cluster #0 and #1 are reserved, 33 - 2 = 31
	MOV dl, [ebr_drive_number]

	CALL disk_read ; read the kernel cluster from the disk into memory

	ADD bx, [bdb_bytes_per_sector]	; next kernel cluster target address

	; (kernel cluster * 3) / 2
	MOV ax, [kernel_cluster] 
	MOV cx, 3
	MUL cx
	MOV cx, 2
	DIV cx

	MOV si, buffer	; buffer is the address of the FAT segment
	ADD si, ax	; add the offset to the FAT segment, ax is the offset to the kernel cluster in the FAT segment
	MOV ax, [ds:si] ; load 16 bits from the FAT segment
	
	OR dx, dx ; check if the remainder is 0 (if ax is even)
	JZ even

odd:
	SHR ax, 4 ; ax = ax >> 4 (shift right 4 bits)
	JMP nextClusterAfter
even:
	AND ax, 0x0FFF ; ax = ax & 0x0FFF (mask the upper 4 bits)
nextClusterAfter:
	CMP ax, 0x0FF8
	JAE readFinish

	MOV [kernel_cluster], ax
	JMP loadKernelLoop

readFinish:
	MOV dl, [ebr_drive_number]
	MOV ax, kernel_load_segment
	MOV ds, ax
	MOV es, ax

	JMP kernel_load_segment:kernel_load_offset

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

os_boot_msg: DB 'Loading...', 0x0D, 0x0A, 0	; 0x0D: (Carriage Return, CR), 0x0A: (Line Feed, LF), 0 (Null Terminator)
read_failure: DB 'Failed to read disk!', 0x0D, 0x0A, 0
file_kernel_bin DB 'KERNEL  BIN'	; in 8.3 filename, the first 8 bytes are the filename, the last 3 bytes are the extension, it is case-insensitive, and padding with spaces
msg_kernel_not_found DB 'KERNEL.BIN not found!'
kernel_cluster DW 0;
kernel_load_segment EQU 0x2000
kernel_load_offset EQU 0

TIMES 510-($-$$) DB 0	; TIMES 510-($-$$) means repeat 510-($-$$) times, $ means the address of this line, $$ means the beginning address of this section
DW 0AA55h	; 2 bytes, x86 is little-endian, BIOS checks whether a sector is bootable, it looks at the last two bytes to see if they are 0x55AA

buffer:
