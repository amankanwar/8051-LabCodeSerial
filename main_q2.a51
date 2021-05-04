; THIS PROGRAM RECEIVES AND ECHOES CHARACTERS USING SERIAL
; CHANNEL 0 AND TERMINATES ONCE IT RECEIVES AN “$"

		ORG		00h
		JMP		MAIN
		
		ORG		100H
;========================= Main Subroutine =======================
	MAIN:
		MOV		P1,   #00H		; CONFIGURE P1 AS OUTPUT
		MOV		P2,   #00H		; CONFIGURE P2 AS OUTPUT
		MOV 	SCON, #00H		; CLEARING SCON for any prior set values
		
		SETB SCON.4				; ENABLE RECEPTION for serial data
		MOV	TMOD, #22H			; T0 IN MODE 2 AND T1 IN MODE 2
		MOV	TH1,  #-24 			; #-24; SET BAUD TO 1200 BPS
		MOV	TL1,  #7FH			; SET T1 AUTO RELOAD TO 7FH (TIMER 1 auto reload value)
		SETB SCON.6				; SET SERIAL PORT 0 TO MODE 1 (SM1 Bit)
		SETB TR0				; START Timer 0 by setting the T0 flag
		SETB TR1				; START Timer 1 by setting the T1 flag
	
	;----------------- Serial loop ---------------------------
	REPEAT:
		WAIT1: JNB RI, WAIT1	; WAIT for the character to be received		
		MOV	A, SBUF				; MOVE RECEIVED CHARACTER TO A
		CLR	RI					; Clear the RI reception flag, for next data
		MOV SBUF, A				; ECHO RECEIVED CHARACTER
		WAIT2: JNB TI, WAIT2	; WAIT FOR CHARACTER TO BE TRANSMITTED
		CLR TI					; Once transmitted, clear the TI flag
		CJNE A, #'$', REPEAT	; REPEAT, checking for the $ to be received
	;---------------------------------------------------------						
		; If $ is received then the execution will come here					
		

		MOV	P1, TL0 			; DISPLAY TL0 ON P1
		MOV	P2, A	 			; DISPLAY ASCII "$" ON P2
		CLR	TR0		 			; STOP T0
		CLR	TR1		 			; STOP T1		
;=======================================================================================
		END						; End of execution
