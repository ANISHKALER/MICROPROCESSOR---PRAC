;ass9.asm - Menu-driven TYPE, COPY, DELETE
;Assignment 9
;Name: Anish Kaler
;Roll No: 7211
;Date: 8/04/2025

%include "macro.asm"
section .data
    intro_msg db 10,"Write X86/64 ALP to implement TYPE, COPY, DELETE \
    using file operations", 10, \
    
    intro_len equ $-intro_msg
    msg db "------------------MENU------------------", 10 
        db "1. TYPE ", 10 
        db "2. COPY ", 10 
        db "3. DELETE ", 10 
        db "4. Exit ", 10
        db "Enter your choice : "

    msglen equ $-msg
    endl db 10
    m db "DONE!", 10
section .bss
    choice resb 2
    fname1 resb 50
    fname2 resb 50
    filehandle1 resq 1
    filehandle2 resq 1
    buffer resb 100
    bufferlen resq 1   ; Changed to resq for 64-bit length
section .text
global _start
_start:
    ; Command-line arguments
    pop rbx             ; argc
    pop rsi             ; skip program name
    ; Show intro
    Print intro_msg, intro_len
    ; Read first argument into fname1
    mov rdi, fname1
.mark:
    pop rsi
    mov rdx, 0
.next:
    mov al, byte [rsi + rdx]
    mov [rdi + rdx], al
    cmp al, 0
    je .next1
    inc rdx
    jmp .next
 .next1:
    cmp rdi, fname2
    je main_menu
    mov rdi, fname2
    jmp .mark
 main_menu:
    Print msg, msglen
    Accept choice, 2
    cmp byte [choice], '1'
    je case1
    cmp byte [choice], '2'
    je case2
    cmp byte [choice], '3'
    je case3
    cmp byte [choice], '4'
    je case4
    jmp main_menu
 case1:
    call type
    jmp main_menu
 case2:
    call copy
    jmp main_menu
 case3:
    call delete
    jmp main_menu
 case4:
    mov rax, 60         ; syscall: exit
    xor rdi, rdi
    syscall
 ; TYPE implementation
 type:
    fopen fname1
    cmp rax, -1
    je case4
    mov [filehandle1], rax
    fread [filehandle1], buffer, 100
    mov [bufferlen], rax
    Print endl, 1
    Print buffer, [bufferlen]
    fclose [filehandle1]
    ret
 ; COPY implementation (fixed with loop)
 copy:
    fopen fname1
    cmp rax, -1
    je case4
    mov [filehandle1], rax
    fcreate fname2
    cmp rax, -1
    je case4
    mov [filehandle2], rax
 .copy_loop:
    fread [filehandle1], buffer, 100
    cmp rax, 0              ; EOF
    je .copy_done
    mov rdi, [filehandle2]
    mov rsi, buffer
    mov rdx, rax
    mov rax, 1              ; sys_write
    syscall
    jmp .copy_loop
 .copy_done:
    fclose [filehandle1]
    fclose [filehandle2]
    Print m, 6
    ret
 ; DELETE implementation
 delete:
    fdelete fname2
    Print m, 6
    ret
 
