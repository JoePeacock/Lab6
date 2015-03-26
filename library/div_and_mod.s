	AREA	LAB2, CODE, READWRITE	
	EXPORT	div_and_mod
	
div_and_mod
	STMFD r13!, {r2-r12, r14}
			 
	; The dividend is passed in r0 and the divisor in r1.
	
	; Initialize counter
	MOV r2, #15
	
	; Initialize quotient
	MOV r4, #0
	
	; Initialize r5 to 0. Set LSB to 1 if result needs to be negated at the end.
	MOV r5, #0
	
	; Check if either divisor or dividend are negative. If so make them positive. If they were different, set last bit of r5 to 1, 
	; and negate result at the end
CHECK_AND_FIX_DIVIDEND_SIGN
	CMP r0, #0
	BGT CHECK_AND_FIX_DIVISOR_SIGN
	MVN r0, r0
	ADD r0, r0, #1
	MOV r5, #1
	
CHECK_AND_FIX_DIVISOR_SIGN
	CMP r1, #0
	BGT INIT_REMAINDER_AND_DIVISOR
	MVN r1, r1
	ADD r1, r1, #1
	
	; Exclusive OR r5 with 1. If it was 1 before, we don't need to flip the result at the end, so r5 should be 0.
	; If it was 0 before, we need to flip the result so it should be 1.
	EOR r5, r5, #1
	
INIT_REMAINDER_AND_DIVISOR
	; Left shift divisor 15 places
	MOV r1, r1, LSL #15
	
	; Initialize remainder to dividend
	MOV r3, r0
	
DIV_LOOP	
	; Remainder := Remainder - Divisor
	SUB r3, r3, r1
	
	; Compare remainder and 0
	CMP r3, #0
	
	; Remainder is greater than or equal to 0, so shift in a 1
	BGE SHIFT_IN_ONE
	
	; Remainder is less than 0, so shift in a 0
	BLT SHIFT_IN_ZERO

SHIFT_IN_ONE
	MOV r4, r4, LSL #1
	
	; Make LSB 1
	ORR r4, r4, #1
	
	BAL SHIFT_DIVISOR
	
SHIFT_IN_ZERO
	; Remainder was less than divisor, so add back divisor
	ADD r3, r3, r1
	MOV r4, r4, LSL #1
	BAL SHIFT_DIVISOR
	
SHIFT_DIVISOR
	MOV r1, r1, LSR #1
	
	CMP r2, #0
	
	; If counter is less than or equal to 0, we're done
	BLE ADJUST_RESULT_SIGN
	
	; Else, decrement counter and go back to DIV_LOOP
	SUB r2, r2, #1
	BAL DIV_LOOP

ADJUST_RESULT_SIGN
	; Check if we need to flip the quotient
	CMP r5, #0
	BEQ DONE
	
	MVN r4, r4
	ADD r4, r4, #1
	
DONE
	; The quotient is returned in r0 and the remainder in r1. 
	MOV r0, r4
	MOV r1, r3
	
	LDMFD r13!, {r2-r12, r14}
	BX lr      ; Return to the C program	

	END

	