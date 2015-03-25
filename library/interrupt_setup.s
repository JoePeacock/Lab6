	AREA	LIBRARY, CODE, READWRITE
	EXPORT	interrupt_setup

INTERRUPT_SELECT_REG EQU 0xFFFFF00C
INTERRUPT_ENABLE_REG EQU 0xFFFFF010
EXTERNAL_INTERRUPT_MODE_REG EQU 0xE01FC148
UART0_INTERRUPT_ENABLE_REG EQU 0xE000C004

PIN_SEL_ZERO EQU 0xE002C000

	ALIGN


interrupt_setup
		STMFD SP!, {r0-r12, lr}   ; Save registers

		BL external_interrupt_1_setup
		BL uart0_interrupt_setup

		LDMFD SP!, {r0-r12, lr} ; Restore registers
		BX lr             	   ; Return

external_interrupt_1_setup
		STMFD SP!, {r0-r1, lr}   ; Save registers 
		
		; Push button setup		 
		LDR r0, =PIN_SEL_ZERO
		LDR r1, [r0]
		ORR r1, r1, #0x20000000
		BIC r1, r1, #0x10000000
		STR r1, [r0]  ; PINSEL0 bits 29:28 = 10

		; Classify sources as IRQ or FIQ
		LDR r0, =INTERRUPT_SELECT_REG
		LDR r1, [r0]
		ORR r1, r1, #0x8000 ; Classify External Interrupt 1 as FIQ. Bit 15 = 1
		STR r1, [r0]

		; Enable Interrupts
		LDR r0, =INTERRUPT_ENABLE_REG
		LDR r1, [r0] 
		ORR r1, r1, #0x8000 		; Enable External Interrupt 1. Bit 15 = 1
		STR r1, [r0]

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =EXTERNAL_INTERRUPT_MODE_REG
		LDR r1, [r0]
		ORR r1, r1, #2  			; EINT1 = Edge Sensitive
		STR r1, [r0]

		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR
		BIC r0, r0, #0x40
		ORR r0, r0, #0x80
		MSR CPSR_c, r0

		LDMFD SP!, {r0-r1, lr} ; Restore registers
		BX lr             	   ; Return
	

uart0_interrupt_setup
		STMFD SP!, {r0-r12, lr}

		; Classify sources as IRQ or FIQ
		LDR r0, =INTERRUPT_SELECT_REG
		LDR r1, [r0]
		ORR r1, r1, #0x40 ; UART0 Interrupt
		STR r1, [r0]

		; Enable Interrupts
		LDR r0, =INTERRUPT_ENABLE_REG
		LDR r1, [r0] 
		ORR r1, r1, #0x40 		; UART0 Interrupt 
		STR r1, [r0]

		; Setup RDA bit in UART Interrupt enable register
		LDR r0, =UART0_INTERRUPT_ENABLE_REG
		LDR r1, [r0]
		ORR r1, r1, #0x01
		STR r1, [r0] 

		LDMFD SP!, {r0-r12, lr}
		BX lr

	END