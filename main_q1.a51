; THIS PROGRAM USES EX0, EX1, T0, AND T1 INTERRUPTS. 
; The MAIN PROGRAM CONFIGURES P1 AND P2 TO OUTPUIT ALSO CONFIGURES
; T0 AND T1 AS COUNTERS IN MODE 2. IT ALSO ENABLES ALL INTERRUPTS 
;
ORG 00H							; RESET / POWER ON INTERRUPT VECTOR
	LJMP MAIN					; Here we will jump to the main

;################################################################
;#			Below memory is set aside for the					#
;#					Interrupt vectors							#
;################################################################
ORG 003H						; External INT0 Interrupt vector
	ACALL EX0H
	RETI

ORG 00BH						; Timer 0 Interrupt vector
	ACALL TIMER0H
	RETI
	
ORG 013H						;  External INT1 Interrupt vector
	ACALL EX1H
	RETI

ORG 01BH						; Timer 1 interrupt flag
	ACALL TIMER1H
	RETI
;################################################################


;================= 	Main Subroutine =============================
ORG 30H
	MAIN:
		CALL CONFIG				; Call the configure subroutine
		JMP $					; Stay here and wait for interrupts				
;=================================================================			

;================= Configure Subroutine ==========================	
	CONFIG:
		MOV P0,  #0FFH		; SET P0 as INPUT
		MOV P1,  #00H		; SET P1 TO OUTPUT
        MOV P2,  #00H		; SET P2 TO OUTPUT
        MOV TMOD,#66h 		; SET MODE 2 FOR COUNTER0 AND COUNTER1
        SETB IE.7			; SET UNIVERSAL INTERUPTS FLAG
        SETB IE.1			; ENABLE TIMER 0 INTERRUPT
		SETB IE.3			; ENABLE TIMER 1 INTERRUPT
		SETB IE.0			; ENABLE INT0 INTERRUPT
		SETB IE.2 			; ENABLE INT1 INTERRUPT
		SETB TCON.0	 		; SET INT0 FOR NEGATIVE EDGE TRIGGER
							; If 1, Interrupt 0 occurs on falling edge. 
							; If 0, Interrupt 0 occurs on low level.
        SETB TR0   			; START TIMER 0
		SETB TR1 			; START TIMER 1
		RET					; Rturn to the caller
;=================================================================			
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This subroutine will be called from the vector address 00BH		 ;
; and will be corresponding to timer 0 interrupt handler 			 ;
;																	 ;	
;~~~~~~~~~~~~~~~~~~~~~~  Timer 0 handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	TIMER0H:  
        MOV  A, P0			; Reading the Port 0 data into accumulator
		MOV  P2,A   		; UPDATE P2 as per data from accumulator
		RET					; Return to the caller
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This subroutine will be called from the vector address 01BH 		 ;
; and will be corresponding to timer 1 interrupt handler 			 ;
;																	 ;
;~~~~~~~~~~~~~~~~~~~~~~  Timer 1 handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	TIMER1H:
        MOV  A, P0			; Reading the Port 0 data into accumulator
		CPL	 A				; Compliment accumulator	
		MOV  P1, A			; Display the complimented result to the Port 1
		RET
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This subroutine will be called from the vector address 003H		 ;
; and will be called when there is an external interrupt 0 			 ;
;																	 ;
;~~~~~~~~~~~~~~~  External Interrupt 0 handler ~~~~~~~~~~~~~~~~~~~~~~~
     EX0H:
		MOV 40H, TL0		; STORE TL0 IN RAM LOCATION 40H
							; Using direct addressing mode					
		CLR TCON.0	 		; CLEAR THE EDGE TRIGGER FLAG in TCON 
		RET					; Return to the caller
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This subroutine will be called from the vector address 013H		 ;
; and will be called when there is an external interrupt 1 			 ;
;																	 ;
;~~~~~~~~~~~~~~~  External Interrupt 1 handler ~~~~~~~~~~~~~~~~~~~~~~~
	 EX1H:
        MOV 41H, TL1		; STORE TL1 IN RAM LOCATION 41H
							; Using direct addressing mode
		RET					; Return to the caller
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        END					; End of program
	