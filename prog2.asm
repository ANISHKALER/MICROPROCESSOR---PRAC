; Macro for system calls
%macro io 4
    mov rax, %1           ; Load syscall number (e.g., 1 for write, 0 for read)
    mov rdi, %2           ; Load file descriptor (e.g., 1 for stdout, 0 for stdin)
    mov rsi, %3           ; Load address of the buffer (e.g., where data will be written/read)
    mov rdx, %4           ; Load size of buffer or message length
    syscall               ; Invoke the system call (write/read)
%endmacro

; Macro for clean program exit
%macro exit 0
    mov rax, 60           ; sys_exit system call number
    mov rdi, 0            ; Exit code 0 (success)
    syscall               ; Invoke the exit syscall
%endmacro

section .data
    ; Messages to be printed to the user
    msg1 db "write an X86/64 ALP to accept a string and to display its length", 10, \
    'Name - Abhinav Choudhary', 10, 'Roll No - 7204', 10 , 'Date Of Performance- 28 Jan 2025', 10
    msg1len equ $ - msg1       ; Calculate the length of msg1

    msg2 db "enter the string", 10
    msg2len equ $ - msg2       ; Calculate the length of msg2

    msg3 db "the strlen without loop", 10
    msg3len equ $ - msg3       ; Calculate the length of msg3

    msg4 db "the strlen with loop", 10
    msg4len equ $ - msg4       ; Calculate the length of msg4

    strlen db 0                ; Variable to store the calculated string length
    newline db 10              ; Newline character for formatting output

section .bss
    str1 resb 20               ; Buffer to store the user input (max 20 bytes)
    asciinum resb 2            ; Buffer to store the ASCII representation of the length

section .text
global _start
_start:
    ; Display the introductory message
    io 1, 1, msg1, msg1len    ; Write msg1 to stdout

    ; Prompt the user to enter a string
    io 1, 1, msg2, msg2len    ; Write msg2 to stdout

    ; Read user input (max 20 bytes) and store it in str1
    io 0, 0, str1, 20         ; Read from stdin into str1
    dec rax                    ; Decrement rax to exclude the newline character
    mov rbx, rax               ; Store the length of input (excluding newline) in rbx

    ; Display the message for strlen without loop
    io 1, 1, msg3, msg3len     ; Write msg3 to stdout
    call hex_ascii8            ; Convert and display length in hexadecimal format

    ; Calculate string length using a loop
    mov rsi, str1              ; RSI points to the start of the string
    next1:
        mov al, [rsi]          ; Load the current character in the string
        cmp al, 10             ; Compare it with newline (10)
        je skip                ; If it's a newline, skip the rest of the loop
        inc byte [strlen]      ; Increment the length counter
        inc rsi                ; Move to the next character in the string
        loop next1             ; Continue the loop (decrement RCX and repeat)

    skip:
        ; Display the message for strlen with loop
        io 1, 1, msg4, msg4len  ; Write msg4 to stdout
        mov bl, [strlen]        ; Move the length from memory to bl register
        call hex_ascii8         ; Convert and display the length in hexadecimal format

    exit                        ; Exit the program

; Convert the byte value in BL to ASCII and print
hex_ascii8:
    mov rsi, asciinum          ; Address of the output buffer (for the ASCII characters)
    mov rcx, 2                 ; Loop for 2 characters (to represent the 8-bit length in hex)

next4:
    rol bl, 4                  ; Rotate to get the most significant nibble
    mov al, bl                 ; Copy the nibble into al
    and al, 0Fh                ; Mask to keep only the lower 4 bits
    cmp al, 9
    jbe add30h                 ; If AL <= 9, it's a digit, convert to ASCII '0' to '9'
    add al, 7h                 ; If AL > 9, it's a letter, convert to ASCII 'A' to 'F'

add30h:
    add al, 30h                ; Convert the nibble to its ASCII representation
    mov [rsi], al              ; Store the ASCII character in the output buffer
    inc rsi                    ; Move to the next character position in the buffer
    loop next4                 ; Repeat the loop until RCX = 0

    ; Print the converted number and a newline character
    io 1, 1, asciinum, 2       ; Write the converted length (2 characters) to stdout
    io 1, 1, newline, 1        ; Write a newline character to stdout
    ret                        ; Return from the function
