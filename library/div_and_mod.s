	AREA	LAB2, CODE, READWRITE	
	EXPORT	div_and_mod
	
div_and_mod
	STMFD r13!, {r2-r12, r14}
	; INPUT:
	; 	R0 = Input Number
	; 	R1 = Divisor

	; Let's initalize our counters
	MOV R4, #0	  ; R4 = Running divisor after subtraction.
	MOV R5, #0	  ; R5 = Counter for Quotient.
	MOV R6, #0	  ; R6 = Value for Remainder.
						 
; Now we can begin our loop.
LOOP 
	ADD R4, R4, R1   ; Add our divisor (r1) repeatedly into (r4) 
	ADD R5, R5, #1   ; Increment our divison value by 1 (r5)

	CMP R4, R0      ; Check if (r4) < (r0)
	BLE LOOP		; If True jump to LOOP   

	; Else lets fix our numbers and calculate the remainder.
	SUB R4, R4, R1	; Revert sum (r4) to be less than our input (r1)
	SUB R5, R5, #1  ; Subtract from (r5) our counter to match above command.

	; Now lets subtract to find the remainder.
	SUB R3, R0, R4  ; Subtract from input (r0) our new sum (r4)

	; Finished Calculations:
	;	R3 = Remainder
	; 	R4 = Quotient (answer)
	
	ADD R0, R5, #0		; Move values to return slot.
	ADD R1, R3, #0      
	
	; RETURN:
	; 	R0 = The quotient (answer)
	; 	R1 = Remainder
	
	LDMFD r13!, {r2-r12, r14}
	BX lr      ; Return to the C program	


	END