    AREA timer, CODE, READWRITE
    EXPORT timer_setup
	IMPORT div_and_mod

PCLK EQU 18432000

INTERRUPT_ENABLE_REG EQU 0xFFFFF010
INTERRUPT_SELECT_REG EQU 0xFFFFF00C

TIMER0_MCR EQU 0xE0004014
MATCH_REG_1 EQU 0xE000401C
TIMER0_CONTROL_REG EQU 0xE0004004

; Sets up timer interrupts to occur at specified interval.
; Input:
;   R0: interval in milliseconds
;
timer_setup
    STMFD SP!, {R4-R12, LR}

    LDR R5, =INTERRUPT_ENABLE_REG
    LDR R4, [R5]
    ORR R4, R4, #0x10               ; bit 4 = 1 to enable timer interrupt
    STR R4, [R5]

    ; select reg bit 4 = 1
    LDR R5, =INTERRUPT_SELECT_REG
    LDR R4, [R5]
    ORR R4, R4, #0x10               ; bit 4 = 1 to make timer interrupt FIQ
    STR R4, [R5]

    LDR R5, =TIMER0_MCR
    LDR R4, [R5]
    ORR R4, R4, #0x18               ; bit 3 and 4 = 1 to generate interrupt and reset timer when timer = MR1 
    AND R4, R4, #0xFFFFFFDF         ; bit 5 = 0 so timer does not step when timer = MR1
    STR R4, [R5]

	LDR R6, =PCLK
    MUL R4, R0, R6	               ; r4 = PCLK * r0
    MOV R0, R4                      
    MOV R1, #1000                    
    BL div_and_mod                  ; r0 = r4 / 1000
    MOV R4, R0
    LDR R5, =MATCH_REG_1
    STR R4, [R5]

    LDR R5, =TIMER0_CONTROL_REG
    LDR R4, [R5]	
	ORR R4, R4, #0x02		  		; bit 1 = 1 to reset timer
	STR R4, [R5]
	BIC R4, R4, #0x02				; bit 1 = 0 so we're not continuously resetting timer
    ORR R4, R4, #0x01               ; bit 0 = 1 to enable timer 
    STR R4, [R5]

    LDMFD SP!, {R4-R12, LR}
    BX LR

	END

