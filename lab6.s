	AREA interrupts, CODE, READWRITE
	EXPORT lab6
	EXPORT FIQ_Handler
	IMPORT print_string
	IMPORT uart_setup
	IMPORT interrupt_setup
	IMPORT input_char
	IMPORT output_char
    IMPORT timer_setup
	IMPORT div_and_mod

TIMER0_INTERRUPT_REG EQU 0xE0004000
ASCII_STAR EQU 0x2A
ASCII_SPACE EQU 0x20
ROW_OFFSET EQU 17
	ALIGN

quit_prompt = 0xC, "You Lose! Score: 000",0
	ALIGN
game_board = 0xC, "    SCORE: 000   ", 0xD, 0xA, \
			  "|---------------|", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|               |", 0xD, 0xA, \
			  "|---------------|", 0
	ALIGN
input_command = "a", 0
	ALIGN
direction = 1 			            ; 0: Don't Move, 1: Up, 2: Down, 3: Left, 4: Right
	ALIGN
score_string = "000"
	ALIGN
score = 0x00000000
	ALIGN
x_pos = 7
	ALIGN
y_pos = 7
    ALIGN
timer_time = 0x000000FA				; initialized to 250.
	ALIGN
move_count = 0x00000000
	ALIGN

lab6	 	
	STMFD SP!, {lr}

	BL uart_setup               ; Setup UART input 
	BL interrupt_setup          ; Setup our UART interrupts, and set them to Fast interrupts.
	
	LDR R0, =timer_time
	LDR R0, [R0]
    BL timer_setup              ; Setup our timer for moving our little star

	LDR R0, =game_board         ; Load the input commands string to R0.
	BL print_string             ; Call our print_string subroutine to print what is in R0 (null-terminated)
    
    BL reset_game

loop
    ;BL timer
    B loop

    LDMFD SP!, {lr}
    BX lr

reset_game
    STMFD SP!, {lr, R0-R10}

	MOV R4, #0             ; Score is set to 0

    MOV R0, #7
    LDR R1, =x_pos         ; Reset x_pos to 7
    STR R0, [R1]

    LDR R1, =y_pos         ; Rest y_pos to 7
    STR R0, [R1]

    MOV R0, #7
    MOV R1, #7
    BL get_location

    MOV R2, #ASCII_STAR

    LDMFD SP!, {lr, R0-R10}
    BX lr

; Accepts an X and Y value, and calculate the character
; location of the X, Y value on the board.
; Inputs:
;   R0: X Value
;   R1: Y Value
; Returns:
;   R0: Character location
get_location
    STMFD SP!, {lr, R4-R12}

	ADD R5, R1, #1
	MOV R9, #19
    MUL R1, R5, R9					 
    ADD R0, R0, R1
	ADD R0, R0, #1

    LDR R4, =game_board
    ADD R0, R0, R4

    LDMFD SP!, {lr, R4-R12}
    BX lr

double_speed
	STMFD SP!, {lr, R0-R12}

	LDR R4, =timer_time
	LDR R0, [R4]
	MOV R1, #2
	BL div_and_mod

	STR R0, [R4]
	BL timer_setup

	LDMFD SP!, {lr, R0-R12}
    BX lr
	
timer
    STMFD SP!, {lr, R0-R12}

	; clear timer interrupt
	LDR R5, =TIMER0_INTERRUPT_REG
	LDR R4, [R5]
	AND R4, R4, #0x02
	STR R4, [R5]

	; check move count. if it is greater than 10, reset it to 0 and double the speed
	LDR R4, =move_count
	LDR R5, [R4]
	CMP R5, #10
	BLGT double_speed
	CMP R5, #10
	MOVGT R5, #0
	STRGT R5, [R4]

    LDR R4, =direction      ; Get the currently set direction
    LDRB R5, [R4]            ; Load the integer value (0-4) into R8
    
    CMP R5, #0                  ; If we are not moving just skip everything else
    LDMFDEQ SP!, {lr, R0-R12}
    BXEQ lr

    LDR R2, =x_pos      ; Load up X
    LDR R3, =y_pos      ; Load up Y
    LDRB R0, [R2]       ; Get X Value
    LDRB R1, [R3]       ; Get Y Value

    ; First we need to clear the asterist at this location.

    BL get_location         
    MOV R6, #ASCII_SPACE    ; Load up R3 with the ASCII " " to remove the "*"
    STRB R6, [R0]            ; Store a " " at the game_board address current location

    LDR R0, [R2]
    LDR R1, [R3]

    ; Now we compare R8 to 0-4 to move our asterisk
    ; If it is equal to 0 we don't move at all, this is set aat the start before
    ; the user makes his first control move.

    CMP R5, #1                       ; User wants to move UP
    SUBEQ R1, R1, #1                 ; Subtract our Y counter by 1
    
    CMP R5, #2                       ; User wants to move DOWN
    ADDEQ R1, R1, #1                 ; Add 1 to Y_POS

    CMP R5, #3                       ; User wants to move LEFT
    SUBEQ R0, R0, #1                 ; Subtract 1 from X_POS

    CMP R5, #4                       ; User wants to move RIGHT
    ADDEQ R0, R0, #1                 ; Add 1 to X_POS

    ; Now, if we have hit the edge of the board, reset everything at this point, before we print it again.
        
    CMP R0, #15        ; If X is Greater than 15 reset game
    BLGT quit

    CMP R0, #1         ; If X is less than 1 reset game
    BLLT quit

    CMP R1, #15        ; If Y is Greater than 15 reset game
    BLGT quit

    CMP R1, #1         ; If Y is less than 1 reset game
    BLLT quit

    ; Finally we store our ascii to our new current_location value

    STRB R0, [R2]       ; Store our new X value to memory
    STRB R1, [R3]       ; Store our new Y value to memory
    
    BL get_location
    MOV R6, #ASCII_STAR  
    STRB R6, [R0]            
    
    ; We have now stored the asterisk where we wanted based on the current direction
    
    ; Now our game board can be printed as per our update cycle, this will either
    ; be a brand new board or update board from our user input
    
	; increment score
    LDR R5, =score
    LDR R6, [R5]
    ADD R6, R6, #1
    STR R6, [R5]

	;ADD R6, R6, #48
	;LDR R5, =game_board
	;STRB R6, [R5, #14]

	BL update_score_string

	MOV R7, #0   
	LDR R5, =score_string
	LDR R8, =game_board
	MOV R9, #12
score_string_update_loop
	LDRB R6, [R5, R7]
	STRB R6, [R8, R9]
	ADD R7, R7, #1
	ADD R9, R9, #1
	CMP R7, #2
	BLE score_string_update_loop

    ; Characters 12-14 are what need to be set for the score.
    ; SCORE TO ASCII

    LDR R0, =game_board    ; Load our updated Game Board
	BL print_string        ; Print it.

	BL increment_move_count
     
    LDMFD SP!, {lr, R0-R12}
	BX lr

update_score_string
	STMFD SP!, {lr, R0-R12}

	LDR R5, =score
    LDR R6, [R5]
	LDR R7, =score_string

	MOV R9, R6					; r9 is how much is left
	MOV R0, R9
	MOV R1, #100
  	BL div_and_mod
	MOV R6, #100
	MUL R10, R0, R6
	SUB R9, R9, R10				; remove how much we put in 100s place
	ADD R0, R0, #48
	STRB R0, [R7]
	ADD R7, R7, #1

	MOV R0, R9
	MOV R1, #10
	BL div_and_mod
	MOV R6, #10
	MUL R10, R0, R6
	SUB R9, R9, R10
	ADD R0, R0, #48
	STRB R0, [R7]
	ADD R7, R7, #1

 	MOV R0, R9
	ADD R0, R0, #48
	STRB R0, [R7]

	LDMFD SP!, {lr, R0-R12}
	BX lr
	

increment_move_count
	STMFD SP!, {lr, R0-R12}
	
	LDR R4, =move_count
	LDR R5, [R4]
	ADD R5, R5, #1
	STR R5, [R4]

	LDMFD SP!, {lr, R0-R12}
	BX lr

quit
	LDMFD SP!, {lr, R0-R12}

	LDR R0, =quit_prompt
	LDR R1, =score

	LDRB R2, [R1]
	ADD R2, R2, #48
	STRB R2, [R0, #18] 

	BL update_score_string
	LDR R1, =score_string
	MOV R5, #18
	MOV R6, #0
update_quit_prompt_score_loop
	LDRB R4, [R1, R6]
	ADD R6, R6, #1
	STRB R4, [R0, R5]
	ADD R5, R5, #1
	CMP R5, #20
	BLE update_quit_prompt_score_loop

	BL print_string

quit_loop
	B quit_loop

	LDMFD SP!, {lr, R0-R12}
	BX lr


FIQ_Handler
		STMFD SP!, {r0-r12, lr}   ; Save registers 
		
		; 
		LDR R5, =TIMER0_INTERRUPT_REG
		LDR R4, [R5]
		AND R4, R4, #0x02				; Check if bit 1 is 1. if so, interrupt was caused by timer reaching MR1 value
		CMP R4, #0
		BLGT timer
		CMP R4, #0						; so messy. clean this up
		BGT FIQ_Exit

; Check for EINT1 interrupt
		LDR r0, =0xE01FC140
		LDR r1, [r0]
        ;TODO HANDLE TIMING INTERRUPT
		TST r1, #2
	   	BLEQ U0FIQ

; Done handling interrupt. Clear interrupt and set PC to proper value
FIQ_Exit
		;tmp fix;ORR r1, r1, #2  		  ; Clear Interrupt
		;tmp fix;STR r1, [r0]

        ;TODO CLEAR TIMING INTERRUPT

		LDMFD SP!, {r0-r12, lr}
		SUBS pc, lr, #4
		
U0FIQ
	; This is where we handle the interrupt for a uart input
	; Call the following sub routines here.
	STMFD SP!, {r0-r12, lr}   ; Save registers

    LDR R5, =direction        ; Load up our direction memory address

	; Lets load our UART buffer into a character
	BL input_char

	LDR R1, [R5]
		
	CMP R0, #105				; Compare our input value to "i" 
    MOVEQ R1, #1                ; This is the UP command so we write a 1 to direction

	CMP R0, #106				; Compare our input value to "j"
    MOVEQ R1, #3                ; This is LEFT so we we want to write a 3.

	CMP R0, #107				; Compare our input value to "k"
    MOVEQ R1, #4                ; This is RIGHT so we write a 4.

	CMP R0, #109				; Compare our input value to "m"
    MOVEQ R1, #2                ; This is DOWN so we write a 2.

    STR R1, [R5]                ; Finally we store our updated direction value

	LDMFD SP!, {r0-r12, lr}
	BX LR 
; END U0FIQ



	END
