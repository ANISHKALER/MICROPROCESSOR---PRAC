;Write an X86/64 ALP to accept five hexadecimal numbers from user and store them in an array and display the accepted numbers.
%macro io 4
    mov rax,%1          ; System call number (1 for write, 0 for read)
    mov rdi,%2          ; File descriptor (1 for stdout, 0 for stdin)
    mov rsi,%3          ; Buffer address
    mov rdx,%4          ; Buffer size
    syscall             ; Invoke system call
%endmacro

%macro exit 0
    mov rax,60          ; System call number for exit
    mov rdi,0           ; Exit status code (0 for success)
    syscall             ; Invoke system call
%endmacro

section .data
    msg1 db "Write an x86/64 ALP to accept 5 hexadecimal numbers from user and store them in an array and display the accepted numbers",10, \
        'Name - Abhinav Choudhary', 10, 'Roll No - 7204', 10 , 'Date Of Performance- 21 Jan 2025', 10
    msg1len equ $-msg1

    msg2 db "Enter 5 64-bit hexadecimal numbers (0-9, A-F only): ", 10
    msg2len equ $-msg2

    msg3 db "5 64-bit hexadecimal numbers are: ", 10
    msg3len equ $-msg3

    error_msg db "Invalid input! Please enter exactly 16 valid hexadecimal digits.", 10
    error_msglen equ $-error_msg

    newline db 10

section .bss
    asciinum resb 17    ; Buffer for user input (16 characters + 1 for null terminator)
    hexnum resq 5       ; Array to store 5 64-bit hexadecimal numbers

section .text
global _start
_start:
    ; Display initial message
    io 1, 1, msg1, msg1len
    io 1, 1, msg2, msg2len

    ; Input 5 hexadecimal numbers
    mov rcx, 5          ; Loop counter for 5 inputs
    mov rsi, hexnum     ; Address to store the converted numbers

    next1:
        push rsi            ; Save registers
        push rcx

        io 0, 0, asciinum, 17   ; Read input from user (up to 16 characters)

        ; Validate input
        call validate_input
        test rax, rax
        jz invalid_input

        ; Convert ASCII to hexadecimal
        call ascii_hex64

        ; Store the converted number
        pop rcx
        pop rsi
        mov [rsi], rbx
        add rsi, 8          ; Move to the next storage slot
        loop next1          ; Repeat for 5 numbers

    ; Display stored hexadecimal numbers
    io 1, 1, msg3, msg3len
    mov rsi, hexnum     ; Start address of stored numbers
    mov rcx, 5          ; Loop counter
    next2:
        push rsi            ; Save registers
        push rcx

        mov rbx, [rsi]      ; Load the stored number
        call hex_ascii64    ; Convert it back to ASCII and print

        pop rcx
        pop rsi
        add rsi, 8          ; Move to the next number
        loop next2

        exit                ; Exit the program

    ; Function to validate input
    validate_input:
        mov rsi, asciinum   ; Address of input buffer
        mov rcx, 16         ; Number of expected characters
    validate_loop:
        mov al, [rsi]       ; Load a character
        cmp al, 0           ; Check for null terminator
        je invalid          ; If null terminator found early, invalid
        cmp al, '0'
        jl invalid          ; Check if less than '0'
        cmp al, '9'
        jle valid           ; Valid if between '0' and '9'
        cmp al, 'A'
        jl invalid          ; Check if less than 'A'
        cmp al, 'F'
        jg invalid          ; Invalid if greater than 'F'
    valid:
        inc rsi             ; Move to next character
        loop validate_loop
        mov rax, 1          ; Input is valid
        ret
    invalid:
        mov rax, 0          ; Input is invalid
        ret

    invalid_input:
        io 1, 1, error_msg, error_msglen
        jmp next1           ; Retry input

    ; Function to convert ASCII to hexadecimal
    ascii_hex64:
        mov rsi, asciinum   ; Address of input buffer
        mov rbx, 0          ; Clear rbx to store the number
        mov rcx, 16         ; Loop for 16 characters
    next3:
        rol rbx, 4          ; Make space for the next nibble
        mov al, [rsi]       ; Load a character
        cmp al, '9'
        jbe sub30h          ; Convert '0'-'9'
        sub al, 7h          ; Adjust 'A'-'F'
    sub30h:
        sub al, 30h         ; Convert ASCII to numeric value
        add bl, al          ; Add to rbx
        inc rsi             ; Move to next character
        loop next3
    ret

    ; Function to convert hexadecimal to ASCII and print
    hex_ascii64:
        mov rsi, asciinum   ; Address of output buffer
        mov rcx, 16         ; Loop for 16 characters
    next4:
        rol rbx, 4          ; Get the most significant nibble
        mov al, bl          ; Isolate the nibble
        and al, 0Fh         ; Mask the lower 4 bits
        cmp al, 9
        jbe add30h          ; Convert to '0'-'9'
        add al, 7h          ; Convert to 'A'-'F'
    add30h:
        add al, 30h         ; Convert to ASCII
        mov [rsi], al       ; Store in output buffer
        inc rsi             ; Move to next character
        loop next4
        io 1, 1, asciinum, 16 ; Print the converted number
        io 1, 1, newline, 1 ; Print newline
        ret
