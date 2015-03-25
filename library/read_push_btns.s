	AREA	LIBRARY, CODE, READWRITE
	EXPORT	read_push_btns
	EXPORT	generate_push_btn_state_string

PORT_ONE_PIN_VALUE EQU 0xE0028010
ASCII_ZERO EQU 0x30
ASCII_ONE EQU 0x31
ASCII_NULL EQU 0x0

	ALIGN

; Get the current state of the push buttons
; Input:
;	None
; Return:
; 	R0: Least significant 4 bits represent the current state of the push buttons (bit 0 is the state of GPIO port 1 pin 20)
read_push_btns
	STMFD SP!, {lr, R4-R11}

	MOV R0, #0

	LDR R4, =PORT_ONE_PIN_VALUE
	LDR R5, [R4]
	BIC R5, R5, #0xFF0FFFFF 		; Ignore bits that are not 20-23
	MOV R5, R5, LSR #20 			; Shift bits 20-23 so that they are the least significant 4 bits
	MOV R0, R5

	LDMFD SP!, {lr, R4-R11}
	BX LR

; Generate string representing current state of push buttons
; Input:
; 	R0: Address at which to store the generated string. Should be at least 4 bytes.
; Return:
; 	R0: Address of generated string.
;
generate_push_btn_state_string
	STMFD SP!, {lr, R4-R11}

	MOV R4, R0					; Store the passed in address in working register
	MOV R11, R0					; Keep base address in R11 for safekeeping
	BL read_push_btns
	MOV R5, R0					; Store current pushbutton state register in R5

	; Observe bits 1 by 1 and build output string as we do so. Start with least significant bit.
	MOV R6, #0 					; 
push_btn_string_loop

    MOV R10, #1					;
	CMP R6, #0					; 
	IT NE
	MOVNE R10, R10, LSL R6		; Shift one bit to the bit we want to examine
		
	MOV R7, R5					; Put current pushbutton state register in R7 so we can modify it
	AND R7, R7, R10				; Clear all bits except the one we want to examine
	CMP R7, #0
	ITE EQ
	MOVEQ R8, #ASCII_ONE
	MOVNE R8, #ASCII_ZERO

	STRB R8, [R4]				; Store the character in R4

	ADD R4, R4, #1
	ADD R6, R6, #1

	CMP R6, #4 					; If we've reached the 5th bit, we're done.
	 							; Let's append an ASCII null byte and call it a day.
	MOVEQ R8, #ASCII_NULL
	STRBEQ R8, [R4]
	MOVEQ R0, R11 
	LDMFDEQ SP!, {lr, R4-R11}
	BXEQ LR

	B push_btn_string_loop		; If not, keep going

	END





