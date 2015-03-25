	AREA	LIBRARY, CODE, READWRITE
	EXPORT	uart_setup

uart_setup
	STMFD sp!, {lr, r4-r11}

	LDR r0, =0xE002C000  ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]

uart_init_registers
	LDR R4, =0xE000C00C
	LDR R5, =0xE000C000
	LDR R6, =0xE000C004

	MOV R7, #131
	MOV R8, #120
	MOV R9, #0
	MOV R10, #3

	STR R7, [R4]
	STR R8, [R5]
	STR R9, [R6]
	STR R10, [R4]
	
	LDMFD SP!, {lr, r4-r11}
	BX lr
	END