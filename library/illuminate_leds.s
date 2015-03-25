	AREA	LIBRARY, CODE, READWRITE
	EXPORT 	illuminate_binary_leds
	EXPORT 	string_to_binary

PORT_ONE_SET EQU 0xE0028014
PORT_ONE_CLEAR EQU 0xE002801C

	ALIGN


; Takes a string "1010" and converts it to binary
; Input:
;	R0: Base address to string withi binary value
string_to_binary
	STMFD SP!, {lr, R4-R11}

	MOV R5, #0				   ; Set our counter to 0
	MOV R7, #0				   ; Set out answer to 0
    LDRB R4, [R0]			   ; Load in the first character from our input string.
	
iterate_string	
	SUB R4, R4, #48			   ; Convert character from ASCII to decimal

	CMP R4, #1 				   ; check if Value is set to 1
	LSLEQ R4, R5			   ; If so, shift the value by our counter
	ORREQ R7, R7, R4		   ; OR this shifted value with our answer

	ADD R5, R5, #1			   ; Increment our counter

	ADD R0, R0, #1			   ; Move to the next byte in the string
	LDRB R4, [R0] 			   ; Load the next byte
	
	CMP R5, #3				   ; Check if we are done looping
	BLE iterate_string		   ; Loop until done

	MOV R0, R7 				   ; Move Answer in R7 to R0 to return.

	LDMFD SP!, {lr, R4-R11}
	BX lr
; END string_to_binary


; Illuminates a selected set of leds
; Input:
; 	R0: Lower four bits indicate desired state of LEDs (1 = on, 0 = off)
;
illuminate_binary_leds
	STMFD SP!, {lr, R4-R11}

	MOV R4, R0
	MOV R4, R4, LSL #16 		; Shift lower four bits to positions 16-19

	; Turn on proper LEDs
	LDR R5, =PORT_ONE_CLEAR
	STR R4, [R5]				; Store shifted input bits in port 1 set register

	; Turn off proper LEDs
	EOR R4, R4, #0x000F0000 	; Flip bits 16-19 because if a 0 was input in a certain position, that should be a 1 stored in the clear register
	LDR R5, =PORT_ONE_SET
	STR R4, [R5]				; Store flipped bits in clear register

	LDMFD SP!, {lr, R4-R11}
	BX LR
; END illuminate_binary_leds


	END
