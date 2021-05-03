;----------------------------------------------------------------------------
;  Author		: Aman Kanwar
;  Version		: 1.1.3
;  Description	: This assembly program sets the Buad Rate as per the user
;				  Swtich selection on user switch SW1 and SW2 different baud
;				  rates are selected for the given MCU and serial is initlaized
;				  Port is updated using the Timer Interrupts and the serial
;				  baud rate can be selected using user switches
;----------------------------------------------------------------------------

;~~~~~~~~~~~~~~~~~~~~~~~ MACROS DEFINITIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TH1_VAL_1200 	EQU 0E8h	; Timer values for the baud rate generation
TH1_VAL_2400 	EQU 0F4h	; Timer values for the baud rate generation	
TH1_VAL_4800 	EQU 0FAh	; Timer values for the baud rate generation
TH1_VAL_9600 	EQU 0FDh	; Timer values for the baud rate generation

BAUD_1200_M0  	EQU 0		; 0000 0000 =  00H
BAUD_2400_M1  	EQU 1		; 0000 0010 =  02H
BAUD_4800_M2  	EQU 2		; 0000 0100 =  04H
BAUD_9600_M3  	EQU 3		; 0000 0110 =  06H

TIMER_MODE  	EQU 21H		; Timer 0 Mode 1   and  Timer 1 Mode 2
SERIAL_MODE1  	EQU 50H		; Serial Mode 1, 8-Bit data, 1-Start Bit, 1- Stop Bit	

SW1				EQU P1.1	; User Input Switch 1
SW2				EQU P1.2	; User Input Switch 2
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;========================Start of program=========================
ORG 00H
		LJMP MAIN			; Jumping to main subroutine



;-----------------------Main Sub routione-------------------------
ORG 180H
MAIN:	
		MOV P2, #0FFH		; Port 2 is an input port
		MOV P0, #00H		; Port 0 is an output port
		SETB SW1			; Pin 1 is input
		SETB SW2			; Pin 2 is input
		
		
		MOV TH0, #00H		; Timer 0 with max value
		MOV TL0, #00H		; Timer 0 with max value

	
	MAIN_INNER:				; Calling to subroutines
		ACALL BCODE			; Baud rate input from the user
		ACALL CONFIG		; Configuring the Timer and serial rate
		LCALL SDISPLAY		; Displaying the results to the screen
		SJMP MAIN_INNER		; Endless loop
;-----------------------------end of main------------------------


;************************ Timer - interrupt *********************
ORG 00BH
	LCALL TIMER0H 
	RETI
;****************************************************************
	

;============================ Baud rate detection code =====================
ORG 30H						; code for the detection of switch SW1 and SW2
	BCODE:		
		MOV A, #06H			; Masking value
		ANL A, P1			; Now accumulator contains the switch data for Port1 	
							; Checking for baud rate and setting the value
		BAUD0_CHECK:		
				CJNE A, #00H, BAUD1_CHECK
				MOV B, #BAUD_1200_M0
				MOV TH1,#TH1_VAL_1200	; Loading timer TH1 Value for 1200 baud
				MOV DPTR, #B1200_MSG	; Updating the DPTR for specific message
				RET
		BAUD1_CHECK:
				CJNE A, #02H, BAUD2_CHECK
				MOV B, #BAUD_2400_M1
				MOV TH1,#TH1_VAL_2400	; Loading timer TH1 Value for 2400 baud
				MOV DPTR, #B2400_MSG	; Updating the DPTR for specific message
				RET
		BAUD2_CHECK:
				CJNE A, #04H, BAUD3_CHECK
				MOV B, #BAUD_4800_M2
				MOV TH1,#TH1_VAL_4800	; Loading timer TH1 Value for 4800 baud		
				MOV DPTR, #B4800_MSG	; Updating the DPTR for specific message
				RET
		BAUD3_CHECK:
				CJNE A, #06H, BCODE
				MOV  B, #BAUD_9600_M3
				MOV TH1,#TH1_VAL_9600	; Loading timer TH1 Value for 9600 baud			
				MOV DPTR, #B9600_MSG	; Updating the DPTR for specific message
				RET
;========================================================================

;========================= Timer/Serial Initialization ==================
ORG 80H
	CONFIG:
		MOV TMOD, #TIMER_MODE
		MOV SCON, #SERIAL_MODE1
		
		SETB IE.7				; Global Interrupt Enable
		SETB IE.1				; Enable Timer 0 interrupt
		
		SETB TR0				; Start the timer for counting
		SETB TR1				; Start the timer for baud rate generation
		RET						; Retrun to the calling function
RET


ORG 100H
	SDISPLAY:
			; code for the serial display part
			; Display message 1
			MOV R6, DPL			; Storing DPTR Low byte
			MOV R7, DPH			; Storing DPTR High byte

			MOV DPTR, #SERIAL_MSG
			ACALL DISPLAY_STRING
			
			MOV DPL, R6
			MOV DPH, R7
			ACALL DISPLAY_STRING		
	RET		
;========================================================================


;************************ Timer 0 Interrupt Handler **************************
ORG 120H
	TIMER0H:				; Interrupt subroutine
							; Reloading the timer with values to get max delay
	MOV TH0, #00H			; Timer 0 with max value
	MOV TL0, #00H			; Timer 0 with max value
	
	MOV A, P2				; Reading the data from Port 2 into accumulator
	MOV P0, A				; Sending the data from accumulator to Port 0
	
	SETB TR0				; Starting the timer again
	RET						; Return to the caller	
;********************************************************************************



;========================== Serial Display Function =============================
DISPLAY_STRING:
	CLR A					; Clear the Accumulator

AGAIN:						; Table reading subroutine

	MOVC A, @A+DPTR			; Capture data from Table into A
	CJNE A, #'$', SEND_SRL	; Keep on Jumping until '$'
	RET						; once done, return to caller

SEND_SRL:					; String display subroutine

	MOV SBUF, A
	
	WAIT: JNB TI, WAIT
	CLR TI	
	CLR A					; Clear A for next read
	INC DPTR				; increment the Data Pointer
	SJMP AGAIN				; All over again
;========================================================================


;----------LOOKUP TABLE-----------
SERIAL_MSG: 
DB	"SERIAL BAUD IS $"	
B1200_MSG:	
DB	"1200 BPS",10,13,'$' 
B2400_MSG:		
DB	"2400 BPS",10,13,'$'
B4800_MSG:		
DB	"4800 BPS",10,13,'$'
B9600_MSG:	
DB	"9600 BPS",10,13,'$'	
;---------------------------------
END			