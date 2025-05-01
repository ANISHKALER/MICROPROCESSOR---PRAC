;Assignment 10
;Name:Abhinav Choudhary
;Roll No: 7204
;Date: 15 April, 2025


%include "macro.asm"

section .data
    intro_msg db "Write X86 ALP to find,", 10, \
    "a) Number of Blank spaces", 10, \
    "b) Number of lines", 10, \
    "c) Occurrence of a particular character.", 10
    intro_len equ $-intro_msg
    msg1 db "Enter file name: ", 0
    msg1len equ $-msg1
    msg2 db "Enter character to search: ", 0
    msg2len equ $-msg2
    error_msg db "Error in Opening File", 10
    error_len equ $-error_msg

section .bss
    global buffer
    global buf_len
    global character
    filename resb 100
    character resb 2
    buffer resb 1024
    buf_len resq 1
    filehandle resq 1

section .text
    global _start
    extern far_procedure
    _start:
        ; Show assignment intro
        Print intro_msg, intro_len
        ; Prompt for file name
        Print msg1, msg1len
        Accept filename, 100
        ; Replace newline with null terminator
        mov rsi, filename
        .find_newline:
            mov al, [rsi]
            cmp al, 10
            je .null_terminate
            cmp al, 0
            je .after_filename
            inc rsi
            jmp .find_newline
        .null_terminate:
            mov byte [rsi], 0
        .after_filename:
        ; Prompt for character
            Print msg2, msg2len
            Accept character, 2
            mov byte [character+1], 0 ; Ensure null termination
        ; Open file
        mov rax, 2          ; syscall: open
        mov rdi, filename   ; file name
        mov rsi, 0          ; 0-READDONLY
        syscall
        cmp rax, -1
        je open_error
        mov [filehandle], rax
        ; Read file into buffer
        mov rdi, [filehandle]
        mov rax, 0
        mov rsi, buffer
        mov rdx, 1024
        syscall
        mov [buf_len], rax
        ; Close file
        mov rax, 3
        mov rdi, [filehandle]
        syscall
        ; Call FAR procedure
        call far_procedure
        ; Exit
        mov rax, 60
        xor rdi, rdi
        syscall
        open_error:
            Print error_msg, error_len
            mov rax, 60
            mov rdi, 1
            syscall
