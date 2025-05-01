;Program for overlapped block transfer

;Assignment 7
;Name: Anish Kaler
;Roll No: 7211
;Date: 25 March, 2025


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
    source dq 0x123456789ABCDEF0, \
       0x0FEDCBA987654321, \
       0xA1B2C3D4E5F60718, \
       0xFFFFFFFF00000000, \
       0x7F8E9DA1BC2D3E4F

    msg1 db "Source: ",10
    msg1len equ $-msg1

    msg2 db "Destination: ",10
    msg2len equ $-msg2

    menu db "0. Exit",10,"1. Overlapped block transfer w/o string instructions"\
    ,10, "2. Overlapped block transfer with string instructions",10
    menulen equ $-menu

    newline db 10
    arrow db "  --->   "
    arrowlen equ $-arrow

section .bss
    ascii64 resb 16
    choice resb 2

section .text
    global _start
    _start:

    io 1,1,menu,menulen
    io 0,0,choice,2

    cmp byte[choice], "1"
    je opt1

    cmp byte[choice], "2"
    je opt2

    exit                            ; default option exit

    opt1:
        call print_src
        io 1,1,msg2,msg2len
        mov rsi,source
        add rsi,20h
        mov rdi,source
        add rdi,30h
        mov rcx,5
        lp1:
            mov rbx,[rsi]
            mov [rdi],rbx
            sub rsi, 8
            sub rdi, 8
            loop lp1
        call print_dest
        exit

    opt2:
        call print_src
        io 1,1,msg2,msg2len
        mov rsi,source
        add rsi,20h
        mov rdi,source
        add rdi,30h
        std
        mov rcx,5
        rep movsq
        call print_dest
        exit


print_src:
    io 1,1,msg1,msg1len    
    mov rsi,source
    add rsi,20h
    mov rcx, 5
    next:
        mov rbx,rsi
        push rcx
        push rsi
        call hex_ascii64
        io 1,1,arrow,arrowlen
        pop rsi
        mov rbx,[rsi]
        push rsi
        call hex_ascii64
        io 1,1,newline,1
        pop rsi
        pop rcx
        sub rsi, 8
        loop next
    ret


print_dest:
    mov rdi,source
    add rdi,30h
    mov rcx,5
    next2:
        mov rbx,rdi
        push rcx
        push rdi
        call hex_ascii64
        io 1,1,arrow,arrowlen
        pop rdi
        mov rbx,[rdi]
        push rdi
        call hex_ascii64
        io 1,1,newline,1
        pop rdi
        pop rcx
        sub rdi, 8
        loop next2
    ret

hex_ascii64:
        mov rsi, ascii64                ; Address of output buffer
        mov rcx, 16                     ; Loop for 16 characters
    next3:
        rol rbx, 4                      ; Get the most significant nibble
        mov al, bl                      ; Isolate the nibble
        and al, 0Fh                     ; Mask the lower 4 bits
        cmp al, 9
        jbe add30h                      ; Convert to '0'-'9'
        add al, 7h                      ; Convert to 'A'-'F'
    add30h: 
        add al, 30h                     ; Convert to ASCII
        mov [rsi], al                   ; Store in output buffer
        inc rsi                         ; Move to next character
        loop next3
        io 1,1, ascii64, 16             ; io 1,1, the converted number
        ret

 
