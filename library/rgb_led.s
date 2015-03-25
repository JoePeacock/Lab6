	AREA	LIBRARY, CODE, READWRITE
	EXPORT 	illuminate_rgb_led
	EXPORT 	rgb_set_color

PIN_SELECT_ONE EQU 0xE002C004
PORT_ZERO_DIRECTION EQU 0xE0028008
PORT_ZERO_SET EQU 0xE0028004
PORT_ZERO_CLEAR EQU 0xE002800C

; Seven Segment Lookup Table
RGB_COLORS 
	DCD 0x0				; 0 OFF
	DCD 0x00020000		; 1 RED 
	DCD 0x00200000	    ; 2 GREEN
	DCD 0x00040000		; 3 BLUE
	DCD 0x00060000		; 4 PURPLE
	DCD 0x00220000		; 5 YELLOW
	DCD 0x00260000		; 6 WHITE

	ALIGN

rgb_set_color
	STMFD SP!, {lr, R4-R11}
	
	MOV R4, R0		  						; Input From Caller
	LDR R7, =RGB_COLORS					    ; Load in the Letter lookup for displaying 
	MOV R4, R4, LSL #2						; Shift input to proper location in the lookup
	LDR R6, [R7, R4]				   		; Loads the value from the lookup table

	MOV R0, R6
	BL illuminate_rgb_led

	LDMFD SP!, {lr, R4-R11}
	BX lr

; Illuminates a selected set of leds
; Input:
; 	R0: Lower three bits indicate desired state of rgb LED (bit 0 = green, bit 1 = blue, bit 2 = red)
;
illuminate_rgb_led
	STMFD SP!, {lr, R4-R11}

	MOV R4, R0
	;AND R4, R4, #0x00000007		; Clear upper 29 bits
	 
	;MOV R5, R4, LSL #2 			; Make a copy of input bits, shifted over two places
	;AND R5, R5, #0x00000010		; Clear every bit except the 5th

	;AND R4, R4, #0x00000003		; Clear upper 30 bits
	;ORR R4, R4, R5				; We have now effectively shifted the green bit (bit 2) over two places to the left (ie (lower 8 bits of R4) 0000 0101 -> 0001 0001)
	;MOV R4, R4, LSL #17 		; Shift the red, blue, and green bits into the 17th, 18th, and 21st bit positions so we can use them to turn on/off the proper GPIOs	

	LDR R5, =PORT_ZERO_CLEAR
	STR R4, [R5]				; Clearing turns on this led, so we clear pin locations we want to turn on 

	EOR R4, R4, #0x00260000		; Flip bits 17, 18, and 21
	LDR R5, =PORT_ZERO_SET
	STR R4, [R5]

	LDMFD SP!, {lr, R4-R11}
	BX LR

	END
