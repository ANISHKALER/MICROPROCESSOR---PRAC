;	Write X86/64 ALP to convert 4-digit Hex number into its equivalent BCD number and 
; 	5- digit BCD number into its equivalent HEX number. Make your program user friendly
;	to accept the choice from user for: (a) HEX to BCD b) BCD to HEX (c) EXIT.
;	Display proper strings to prompt the user while accepting the input and displaying the result.

;Assignment 5
;Name: Anish Kaler
;Roll No: 7211
;Date: 18 March, 2025

; Macro for write
%macro write 2
	mov rax, 1
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

; Macro for read
%macro read 2
	mov rax, 0
	mov rdi, 0
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

section .data
	 msgname db "Write X86/64 ALP to convert 4-digit Hex number into \
	its equivalent BCD number and 5- digit BCD number into its equivalent \
	HEX number. Make your program user friendly to accept the choice from \
	user for: (a) HEX to BCD b) BCD to HEX (c) EXIT.", 10

    msgnamelen equ $-msgname

	msg db "------------------MENU------------------", 10
	    db "	1. Hex to BCD ", 10
	    db "	2. BCD to Hex ", 10
	    db "	3. Exit ", 10
	    db "Enter your choice : "
	msglen equ $-msg
	msg1 db "Number : "
	len equ $-msg1
	endl db 10

section .bss
	num resd 1
	
	choice resb 2
	
	a_hex resb 5
	a_bcd resb 6
	buffer resb 5
	temp resb 4
	
section .text
	global _start
_start :
	write msgname,msgnamelen
	main_menu :
		write msg, msglen
		read choice, 2
		
		
		cmp byte[choice], "1"
		je case1
		
		cmp byte[choice], "2"
		je case2
		
		cmp byte[choice], "3"
		je case3
		
	
	jmp main_menu
	
	case1 :
		write msg1, len
		read a_hex, 5
		call hex_bcd
		jmp main_menu
		
	case2 :
		write msg1, len
		read a_bcd, 6
		call bcd_hex
		jmp main_menu
	case3 :
		mov rax, 60
		mov rdi, 0
		syscall

; Procedure to convert a hexadecimal number to bcd number		
hex_bcd:
	call ascii_hex           ; first convert the number to hex form
	mov ax, bx               ; move the hex number into accumualtor
	mov bx, 0AH              ; move 0AH ie (10 in deccimal)
	
	mov rcx, 5
	
	convert :
		mov rdx, 0       	; initialize rdx with 0
		
		div bx           	; div ax with bx
		push dx          	; store the remainder in the stack, while the quotient remains in the accumualator
		
		loop convert
	mov rcx, 5
	mov rsi, buffer
	print_bcd :
		pop ax           	; pop the remainder(reverse order)
		add ax, 30h      	; add 30h to it
		mov [rsi], ax    	; move that value in the buffer
		inc rsi          	; increment the pointer
		
		loop print_bcd
	write buffer, 5         ; print the answer (BCD number)
	write endl, 1
	ret
; Procedure to convert a bcd number to a hexadecimal number
bcd_hex :
	mov rsi, a_bcd
	mov rcx, 5
	mov bx, 0AH
	mov rax, 0              ; initialize rax with 0
	b_convert :
		mul bx           	; multiply the rax with 0Ah(10 in decimal)
		mov dl, [rsi]    	; move the digit stored in buffer in dl 
		sub dl, 30h      	; subtract 30h from the digit
		
		add al, dl       	; add the number obtained to al
		inc rsi          	; increment the pointer
		loop b_convert
	mov bx, ax
	call display
	ret
		
; Procedure to convert ascii to heaxadecimal number		
ascii_hex:
	mov rbx, 0
	mov rsi, a_hex
	mov rcx, 4
	next :
		rol bx, 4
		mov al, [rsi]
		cmp al, '9'
		jbe sub30h
		sub al, 7h
		sub30h :
			sub al, 30h
		add bl, al
		inc rsi
		loop next
		ret
			
; Procedure to convert hexdecimal number to ascii
display :
	mov rsi, temp
	mov rcx, 4
	next1 :
		rol bx, 4
		mov al, bl
		and al, 0Fh
		cmp al, 9
		jbe add30h
		add al, 7h
		add30h :
			add al, 30h
			mov [rsi], al
			inc rsi
			loop next1
			write temp, 4
			write endl, 1
