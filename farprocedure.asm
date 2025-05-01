Far Procedure
;far.asm

 %include "macro.asm"
 section .data
    msg_space db "Number of spaces: ", 0
    msg_space_len equ $-msg_space
    msg_line db "Number of lines: ", 0
    msg_line_len equ $-msg_line
    msg_char db "Number of occurrences of character: ", 0
    msg_char_len equ $-msg_char
    dispbuff db 0, 0
    nl db 10
 section .bss
    scount resb 1
    ncount resb 1
    ccount resb 1
 section .text
 global far_procedure
 extern buffer, buf_len, character
 far_procedure:
    xor rcx, rcx
    xor rbx, rbx
    xor rdx, rdx
    mov rsi, buffer
    mov rcx, [buf_len]
    mov bl, byte [character]
 .count_loop:
    cmp rcx, 0
    je display_results
    mov al, [rsi]
    cmp al, 0x20
    jne .check_line
    inc byte [scount]
 .check_line:
    cmp al, 0x0A
    jne .check_char
    inc byte [ncount]
 .check_char:
    cmp al, bl
    jne .next
    inc byte [ccount]
 .next:
    inc rsi
    dec rcx
    jmp .count_loop
 display_results:
    ; Display space count
    Print msg_space, msg_space_len
    mov bl, [scount]
    call display8num
    ; Display line count
    Print msg_line, msg_line_len
    mov bl, [ncount]
    call display8num
    ; Display character count
    Print msg_char, msg_char_len
    mov bl, [ccount]
    call display8num
    ret
 display8num:
    mov rsi, dispbuff
    mov rcx, 2
 .next_digit:
    rol bl, 4
    mov al, bl
    and al, 0x0F
    cmp al, 9
    jbe .add30
    add al, 0x37
    jmp .store
 .add30:
    add al, 0x30
 .store:
    mov [rsi], al
    inc rsi
    loop .next_digit
    Print dispbuff, 2
    Print nl, 1
    ret
 
