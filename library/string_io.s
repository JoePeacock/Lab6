	AREA	LIBRARY, CODE, READWRITE
	EXPORT	print_string
	EXPORT 	input_string
	EXPORT  input_char
	EXPORT  output_char

; Constants
UART_BASE_ADDRESS EQU 0xE000C000		   ; UART0 Base Address
UART_LINE_STATUS EQU 0xE000C014			   ; UART Line status Register
ASCII_ENTER EQU 0x0D

	ALIGN

; Prints a string given a base address over UART
; Input:
;	R0: Input string base address.
print_string
	STMFD SP!, {lr, r4-r11}
	MOV R4, R0

load_string_char
	LDRB R5, [R4]
	CMP R5, #0
	ITT EQ				   		; Check if byte is null
	LDMFDEQ SP!, {lr, r4-r11}
	BXEQ LR 			   		; If it is null we are finished & return.

	MOV R0, R5		 			; Set output byte to R0 and pass to output_char	
	BL output_char 				; If not NULL send R0 to output
	ADD R4, R4, #1 				; Move to next byte, and loop.
	B load_string_char
; print_string END


; Loads user input into a string base address.
; Input:
; 	R0: Base address of string to place input characters. 
; Return:
;	This function does not return anything but rather fills the string
;	passed into this routine with values from the user.
input_string
	STMFD SP!, {lr, r4-r11}
	MOV R4, R0					; Store the Base address of write string to R4

store_input_char
	BL input_char 				; Get the input char; returned in R0.

	CMP R0, #ASCII_ENTER 		; compare to new line character = 0x0A.
	ITT EQ

	; IF True
	LDMFDEQ SP!, {lr, r4-r11} 	; If value is equal to new line, return.
	BXEQ lr

	MOV R10, #0x00				; Store null byte into R10

	; Else
	STRB R0, [R4] 				; Store the value in input_string constant.
	ADD R4, R4, #1 				; Increment one space.

	STRB R10, [R4] 				; Store null byte at end of value every addition.

	B store_input_char 			; Loop back and check next input byte.
; END input_string 


; Print out a character (1 byte) over UART to the Terminal
; Inputs:
; 	R0 = Byte to print.
output_char
	STMFD SP!, {lr, r4-r11}
    
check_transmit_ready 
	LDR R3, =UART_LINE_STATUS
	LDRB R4, [R3]		; Get value of line status register into R3

	AND R5, R4, #0x20					; And with 0010 0000
	CMP	R5, #0			        		; Check if Able to transmit or not
	BEQ check_transmit_ready			; If not ready to transmit, go back and check line status register

	LDR R3, =UART_BASE_ADDRESS
	STRB R0, [R3]						; Store byte in R0 to UART0 Address
	
	LDMFD SP!, {lr, r4-r11}
	BX lr
; END OUTPUT_CHAR


; Reads value from user input over UART and places the value into R0
; Input: None
; Output: 
;	 R0: The chracter received from the input terminal
input_char
	STMFD SP!, {lr, r4-r11}
	LDR R8, =UART_LINE_STATUS
	LDR R9, =UART_BASE_ADDRESS

check_receive_ready
	LDRB R6, [R8] 							; Get value of line status register into R6

	AND R7, R6, #0x01 						; And with 0000 0001 to check value of first bit
	CMP R7, #0 								; Check if ready to receive data

	BEQ check_receive_ready 				; If not ready to receive data yet, go back and check line status register
	LDRB R0, [R9] 							; Load the received data into R0

	BL output_char 							; Output the newly received data in R0

	LDMFD SP!, {lr, r4-r11}
	BX lr
; input end


	END