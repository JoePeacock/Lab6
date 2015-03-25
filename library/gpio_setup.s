	AREA	LIBRARY, CODE, READWRITE
	EXPORT	gpio_setup

PIN_SELECT_ZERO EQU 0xE002C000
PIN_SELECT_ONE EQU 0xE002C004

PORT_ZERO_DIRECTION EQU 0xE0028008
PORT_ONE_DIRECTION EQU 0xE0028018

PORT_ONE_SET EQU 0xE0028014

INTERRUPT_SEL_REG EQU 0xFFFFF00C
INTERRUPT_ENABLE_REG EQU 0xFFFFF010

EINT1 EQU 0xE01FC148

	ALIGN

; Setup the direction and pins on GPIO
; 
; Input:
;	R0: The 1 bits will be set in Port 0 direction 0, and 0 bits will stay the same. 
;   R1: The 0 bits will be set in 
gpio_setup
	STMFD SP!, {lr, r4-r11}

	LDR R0, =0xF0003FFF
	LDR R1, =0x00003F80
									
	LDR R4, =PIN_SELECT_ZERO				; Load Pin select address into R4
	LDR R6, [R4]						    ; Load value from pin select into R6
	AND R6, R0, R6							; And Pin select value with input value R1 from caller
	STR R6, [R4]							; Store the anded value to the pin_select_0 address

	LDR R4, =PORT_ZERO_DIRECTION		    ; Load the Port 0 direction address
	LDR R6, [R4]						    ; Load in the Port0 Direction Value
	ORR R6, R1, R6							; Or the input value and the value of port 0 direction
	STR R6, [R4]							; Set the port 0 direction with the new orred value

	BL configure_binary_led
	BL configure_rgb_led
								  	
	LDMFD SP!, {lr, r4-r11}
	BX lr


configure_binary_led
	STMFD SP!, {lr, r4-r11}
	
	LDR R4, =PORT_ONE_DIRECTION
	LDR R5, [R4]
	ORR R5, R5, #0x000F0000 		; Set bits 16-19 to 1 to use GPIO pins 20-23 on port 1 as outputs
	STR R5, [R4]

	; clear the value and set them all to 0
	LDR R4, =0x000F0000 	; Flip bits 16-19 because if a 0 was input in a certain position, that should be a 1 stored in the clear register
	LDR R5, =PORT_ONE_SET
	STR R4, [R5]	
			  	
	LDMFD SP!, {lr, r4-r11}
	BX lr

; Sets up the RGB
configure_rgb_led
	STMFD SP!, {lr, R4-R11}

	LDR R4, =PIN_SELECT_ONE
	LDR R5, [R4]
	LDR R6, =0x00000C3C
	BIC R5, R5, R6 					; Set bits 2-5 and 10-11 to 0 to use port 0, pin 17, 18, and 21 as GPIO 
	STR R5, [R4] 					; Set PIN_SELECT_ONE to new value

	LDR R4, =PORT_ZERO_DIRECTION
	LDR R5, [R4]
	ORR R5, R5, #0x00260000 		; Set bits 16-19 to 1 to use GPIO pins 20-23 on port 1 as outputs
	STR R5, [R4]

	LDMFD SP!, {lr, R4-R11}
	BX LR
; END configure_leds
	

	END