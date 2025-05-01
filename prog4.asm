

%macro io 4
    mov rax, %1          ; System call number (1 for write, 0 for read)
    mov rdi, %2          ; File descriptor (1 for stdout, 0 for stdin)
    mov rsi, %3          ; Buffer address
    mov rdx, %4          ; Buffer size
    syscall              ; Invoke system call
%endmacro

%macro exit 0
    mov rax, 60          ; System call number for exit
    mov rdi, 0           ; Exit status code (0 for success)
    syscall              ; Invoke system call
%endmacro

section .data
    msg1 db "Write an x86/64 ALP to accept 5 hexadecimal numbers from user and store them in an array and display the count of positive and negative numbers", 10, \
       'Name - Abhinav Choudhary', 10, 'Roll No - 7204', 10 , 'Date Of Performance- 4 MARCH 2025', 10
    msg1len equ $-msg1

    msg2 db "Enter 5 64-bit hexadecimal numbers (0-9, A-F only): ", 10
    msg2len equ $-msg2

    msg3 db "The count of positive numbers is: ", 10
    msg3len equ $-msg3

    msg4 db "The count of negative numbers is: ", 10
    msg4len equ $-msg4

    newline db 10

section .bss
    asciinum resb 17     ; Buffer for user input (16 characters + 1 for null terminator)
    hexnum resq 5        ; Array to store 5 64-bit hexadecimal numbers
    pcount resb 1        ; Positive count
    ncount resb 1        ; Negative count

section .text
global _start
_start:
    ; Display initial message
    io 1, 1, msg1, msg1len
    io 1, 1, msg2, msg2len

    ; Input 5 hexadecimal numbers
    mov rcx, 5           ; Loop counter for 5 inputs
    mov rsi, hexnum      ; Address to store the converted numbers
    xor byte [pcount], 0 ; Initialize positive count
    xor byte [ncount], 0 ; Initialize negative count
next_input:
    push rsi             ; Save registers
    push rcx

    io 0, 0, asciinum, 17 ; Read input from user (up to 16 characters)
    call ascii_hex64      ; Convert ASCII to hexadecimal

    ; Store the converted number
    pop rcx
    pop rsi
    mov [rsi], rbx
    add rsi, 8           ; Move to the next storage slot
    loop next_input       ; Repeat for 5 numbers

    ; Count positive and negative numbers
    mov rcx, 5
    mov rsi, hexnum
check_numbers:
    mov rax, [rsi]       ; Load the number
    bt rax, 63           ; Test bit 63 (sign bit)
    jnc is_positive      ; Jump if no carry (positive number)
    inc byte [ncount]    ; Increment negative count
    jmp skip_check
is_positive:
    inc byte [pcount]    ; Increment positive count
skip_check:
    add rsi, 8           ; Move to the next number
    loop check_numbers

    ; Display positive count
    io 1, 1, msg3, msg3len
    mov bl, [pcount]
    call hex_ascii8

    ; Display negative count
    io 1, 1, msg4, msg4len
    mov bl, [ncount]
    call hex_ascii8

    ; Exit program
    exit

; Function to convert a single byte to ASCII and print
hex_ascii8:
    mov rsi, asciinum    ; Address of output buffer
    mov rcx, 2           ; Loop for 2 characters to convert to hexadecimal

next_digit:
    rol bl, 4            ; Get the most significant nibble
    mov al, bl           ; Isolate the nibble
    and al, 0Fh          ; Mask the lower 4 bits
    cmp al, 9
    jbe add_0            ; Convert to '0'-'9'
    add al, 7h           ; Convert to 'A'-'F'
add_0:
    add al, 30h          ; Convert to ASCII
    mov [rsi], al        ; Store in output buffer
    inc rsi              ; Move to next character
    loop next_digit

    io 1, 1, asciinum, 2 ; Print the converted number
    io 1, 1, newline, 1  ; Print newline
    ret

; Function to convert ASCII to 64-bit hexadecimal
ascii_hex64:
    mov rsi, asciinum    ; Address of input buffer
    xor rbx, rbx         ; Clear rbx to store the number
    mov rcx, 16          ; Loop for 16 characters

next_char:
    rol rbx, 4           ; Make space for the next nibble
    mov al, [rsi]        ; Load a character
    cmp al, '9'
    jbe convert_digit    ; Convert '0'-'9'
    sub al, 7h           ; Adjust 'A'-'F'
convert_digit:
    sub al, 30h          ; Convert ASCII to numeric value
    add bl, al           ; Add to rbx
    inc rsi              ; Move to next character
    loop next_char
    ret