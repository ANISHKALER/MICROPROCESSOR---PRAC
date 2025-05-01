;Assignment 8
;Name: Anish Kaler
;Roll No: 7211
;Date:  1 April, 2025

; Program to multiply two 8-bit hex numbers using Successive Addition and
; Shift-Add methods
; Uses NASM syntax for Linux environment

section .data
    msg1 db "Enter first 8-bit hex number (2 digits): ", 10
    msg1len equ $ - msg1
    msg2 db "Enter second 8-bit hex number (2 digits): ", 10
    msg2len equ $ - msg2
    msg3 db "Result (Successive Addition): ", 10
    msg3len equ $ - msg3
    msg4 db "Result (Shift and Add): ", 10
    msg4len equ $ - msg4
    dispbuff db 4 dup(0)       ; Buffer for displaying 4-digit hex result
    newline db 10              ; Newline character

section .bss
    ascii_num resb 3           ; Buffer for 2-digit hex input + newline
    num1 resb 1                ; First hex number
    num2 resb 1                ; Second hex number

; Macro to print messages using sys_write 
%macro PRINT 2
    mov rax, 1          ; System call number for sys_write
    mov rdi, 1          ; File descriptor (1 = stdout)
    mov rsi, %1         ; Buffer address
    mov rdx, %2         ; Length of buffer
    syscall             ; Make system call
%endmacro

; Macro to accept input using sys_read 
%macro ACCEPT 2
    mov rax, 0          ; System call number for sys_read
    mov rdi, 0          ; File descriptor (0 = stdin)
    mov rsi, %1         ; Buffer address
    mov rdx, %2         ; Length of buffer
    syscall             ; Make system call
%endmacro

section .text
    global _start
_start:
    PRINT msg1, msg1len
    ; Accept first number
    ACCEPT ascii_num, 3        ; 2 digits + newline
    call Ascii_to_Hex          ; Convert to hex
    mov [num1], bl             ; Store first number


    PRINT msg2, msg2len
    ; Accept second number
    ACCEPT ascii_num, 3        ; 2 digits + newline
    call Ascii_to_Hex          ; Convert to hex
    mov [num2], bl             ; Store second number

    call Succ_Add
    PRINT msg3, msg3len        ; Display result header
    PRINT dispbuff, 4          ; Display result
    PRINT newline, 1           ; Newline for formatting

    call Shift_Add
    PRINT msg4, msg4len        ; Display result header
    PRINT dispbuff, 4          ; Display result
    PRINT newline, 1           ; Newline for formatting

    ; Exit program
    mov rax, 60                ; sys_exit
    mov rdi, 0                 ; Return code 0
    syscall

Succ_Add:  ; Successive Addition method 
    xor rax, rax               ; Clear RAX
    xor rbx, rbx               ; Clear RBX (result)
    xor rcx, rcx               ; Clear RCX (counter)
    mov al, [num1]             ; Load first number into AL
    mov cl, [num2]             ; Load second number into CL (counter)
    
add_loop:
    test rcx, rcx              ; Check if counter is zero
    jz done_succ               ; If zero, exit loop
    add bx, ax                 ; Add AX to BX (accumulate result)
    dec rcx                    ; Decrease counter
    jmp add_loop               ; Repeat

done_succ:
    call Hex_to_Ascii          ; Convert result to ASCII
    ret                        ; Return

Shift_Add:  ; Shift and Add method 
    xor rcx, rcx               ; Clear RCX (result)
    xor rax, rax               ; Clear RAX
    xor rbx, rbx               ; Clear RBX
    mov dx, 8                  ; Counter for 8 bits
    mov al, [num1]             ; Load first number into AL
    mov bl, [num2]             ; Load second number into BL

shift_loop:
    test dx, dx                ; Check if counter is zero
    jz done_shift              ; If zero, exit loop
    shr bl, 1                  ; Shift BL right by 1 bit
    jnc no_add                 ; If no carry, skip addition
    add cx, ax                 ; Add AX to CX (accumulate result)

no_add:
    shl ax, 1                  ; Shift AX left by 1 (next partial product)
    dec dx                     ; Decrease counter
    jmp shift_loop             ; Repeat

done_shift:
    mov bx, cx                 ; Move result to BX for display
    call Hex_to_Ascii          ; Convert result to ASCII
    ret                        ; Return

Hex_to_Ascii:  ; Convert hex result to ASCII 
    mov rsi, dispbuff          ; Load display buffer address
    mov rcx, 4                 ; Counter for 4 digits
    
convert_hex:
    rol bx, 4                  ; Rotate BX left by 4 bits
    mov al, bl                 ; Move lower byte to AL
    and al, 0Fh                ; Mask lower nibble
    cmp al, 9                  ; Compare with 9
    jbe add_30_hex             ; If <= 9, add 30h
    add al, 7                  ; If > 9, add 37h for A-F

add_30_hex:
    add al, 30h                ; Convert to ASCII
    mov [rsi], al              ; Store in buffer
    inc rsi                    ; Move to next position
    dec rcx                    ; Decrease counter
    jnz convert_hex            ; Repeat until done
    ret                        ; Return

Ascii_to_Hex:  ; Convert ASCII input to hex 
    mov rsi, ascii_num         ; Load input buffer address
    mov rcx, 2                 ; Counter for 2 digits
    xor bl, bl                 ; Clear BL (result)

convert_ascii:
    rol bl, 4                  ; Shift BL left by 4 bits
    mov al, [rsi]              ; Load ASCII digit
    cmp al, '9'                ; Compare with '9' (39h)
    jbe sub_30_ascii           ; If <= '9', subtract 30h
    sub al, 37h                ; If > '9', subtract 37h (for A-F)
    jmp combine

sub_30_ascii:
    sub al, 30h                ; Subtract 30h (for 0-9)

combine:
    add bl, al                 ; Add to result
    inc rsi                    ; Move to next digit
    dec rcx                    ; Decrease counter
    jnz convert_ascii          ; Repeat until done
    ret                        ; Return

 
