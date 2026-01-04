BITS 16

section _TEXT CLASS=CODE    ; define a code section

global _x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
    PUSH bp
    MOV bp, sp

    PUSH bx ; bx, bp, si, di are callee-saved registers, so we need to save them
             ; if we use them in our function

    ; memory layout (16-bit stack):
    ; [bp+6] = page number
    ; [bp+4] = character to print
    ; [bp+2] = return address
    ; [bp]  = old bp

    MOV ah, 0Eh        ; BIOS teletype function
    MOV al, [bp+4]     ; character to print
    MOV bh, [bp+6]     ; page number , usually 0 (the first screen)

    INT 10h

    POP bx
    MOV sp, bp
    POP bp
    RET