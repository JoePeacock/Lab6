	AREA	LIBRARY, CODE, READWRITE
	EXPORT	check_single_bit

; Checks the value of a single bit in specified register
; Input:
;	R0: Register in which you would like to check a bit
; 	R1: Number of the bit you would like to check (0-31)
; Output:
; 	R0: LSB will be the value of the bit that was checked
;
check_single_bit
	STMFD SP!, {lr, R4-R11}

	MOV R4, R0
	MOV R4, R4, LSR R1 				; Get desired bit into the LSB place
	AND R4, R4, #00000001			; Clear all bits other than LSB

	MOV R0, R4

	LDMFD SP!, {lr, R4-R11}
	BX LR

	END