	AREA	LIBRARY, CODE, READWRITE
	EXPORT	display_seven_segment

; Seven Segment Lookup Table
DIGITS_SET 
	DCD 0x00001F80		; 0x0 
	DCD 0x00001800	    ; 0x1
	DCD 0x00002D80		; 0x2
	DCD 0x00002790		; 0x3
	DCD 0x00003300		; 0x4
	DCD 0x00003680		; 0x5
	DCD 0x00003E80		; 0x6
	DCD 0x00000380		; 0x7
	DCD 0x00003F80		; 0x8
	DCD 0x00003380		; 0x9
	DCD 0x00003B80		; 0xA
	DCD 0x00003E00		; 0xB
	DCD 0x00001C80		; 0xC
	DCD 0x00002F00		; 0xD
	DCD 0x00003C80		; 0xE
	DCD 0x00003880	    ; 0xF
	DCD 0x00000000		; 0x10
		

GPIO_BASE EQU 0xE0028004	; Base address for GPIO
	ALIGN
; Displays a number 0-9 or letter A-F on the 7 segment display
; 
; Input:
;	R0: Letter/Number to Display
display_seven_segment
	STMFD SP!, {lr, r4-r11}

	BL clear_seven_segment
	
	MOV R4, R0		  						; Input From Caller
	LDR R5, =GPIO_BASE						; Load the GPIO Base Register
	LDR R7, =DIGITS_SET					    ; Load in the Letter lookup for displaying 
	MOV R4, R4, LSL #2						; Shift input to proper location in the lookup
	LDR R6, [R7, R4]				   		; Loads the value from the lookup table
	STR R6, [R5]				   			; Print the value to the display

	LDMFD SP!, {lr, r4-r11}
	BX lr

clear_seven_segment	
	STMFD SP!, {lr, r4-r11}							 ; Change to only replace sevent segment clear bits

	MOV R11, #0xFFFFFFFF   						; BEFORE DISPLAY
	LDR R10, =0xE002800C
	STR R11, [R10]

	LDMFD SP!, {lr, r4-r11}
	BX lr
	
	END