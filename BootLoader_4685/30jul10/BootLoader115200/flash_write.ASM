;//Last modified date 06Jan'11 1218 hrs	
;;;;;;;;;;;;;;;;;;;;PIC18F4685 FILE INCLUDE;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	list	 p=18f4685			;;;;;;;;;;;;;;;;;;
	#include p18f4685.inc			;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;CONFIGERATION BIT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	__CONFIG	_CONFIG1H, _OSC_HS_1H & _FCMEN_OFF_1H & _IESO_OFF_1H							;;
	__CONFIG	_CONFIG2L, _PWRT_OFF_2L & _BOREN_OFF_2L & _BORV_2_2L  				;;					
	__CONFIG	_CONFIG2H, _WDT_OFF_2H & _WDTPS_128_2H							;;
	__CONFIG	_CONFIG3H, _MCLRE_ON_3H & _LPT1OSC_ON_3H & _PBADEN_OFF_3H										;;
	__CONFIG	_CONFIG4L, _DEBUG_OFF_4L & _XINST_OFF_4L & _BBSIZ_1024_4L & _LVP_OFF_4L			;;
	__CONFIG	_CONFIG5L, _CP0_OFF_5L & _CP1_OFF_5L & _CP2_OFF_5L & _CP3_OFF_5L & _CP4_OFF_5L ;;											;;
	__CONFIG	_CONFIG5H, _CPB_OFF_5H & _CPD_OFF_5H							;;
	__CONFIG	_CONFIG6L, _WRT0_OFF_6L & _WRT1_OFF_6L & _WRT2_OFF_6L & _WRT3_OFF_6L & _WRT4_OFF_6L											;;
	__CONFIG	_CONFIG6H, _WRTB_OFF_6H & _WRTC_OFF_6H & _WRTD_OFF_6H			;;
	__CONFIG	_CONFIG7L, _EBTR0_OFF_7L & _EBTR1_OFF_7L & _EBTR2_OFF_7L & _EBTR3_OFF_7L & _EBTR4_OFF_7L     										;;
 ;	__CONFIG	_CONFIG7H, _EBTRB_OFF_7H & _DEVID1 & _IDLOC0 										;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;->THIS THE CONFIGRATION POINT IT CAN CHANG ACCRODING TO OUR REQUIRMENT			;;
;->THIS CAN'T CHANGE AT LOADING THE NORMAL PROGRAM								;;
;->CAN CHANGE ONLY WHEN THE PROGRAMING THE MICROCONTROLLER WITH THE BOOTLOADER	;;
;->p16F877a.inc CONTAIN THE MEANING OF THE CONFIGERATION WORD 					;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------------general purpose register definitions-------

DlyCnt1          equ       0019h		
DlyCnt2          equ       0020h
DlyCnt3          equ       0022h
CharValid        equ       0021h
;--------------------------------------------------------
;;;;;;;;;;;;;;;RESET PROGRAM START POINT;;;;;;;;;;;;;;;;;;;;;;;;;;
	ORG		0x0000						;;
	GOTO 	MAIN						;;
;;;;;;;;;;;;;;;INTERRUPT VECTOR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   	ORG 0x000008						;;
	RETFIE FAST		;HIGH PRIORITY INTERRUPT VECTOR	;;
								;;
	ORG 0x000018						;;
	RETFIE FAST		;LOW PRIORITY INTERRUPT VECTOR	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;BOOTLOADING START ADDRESS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;ORG		0x13EF6   	;THIS THE BOOTLOADING START POINT;
     ORG		0x17e76   	;THIS THE BOOTLOADING START POINT;
	;ORG		0x13e86   	;THIS THE BOOTLOADING START POINT;


RECIVE:								;;
WRD:								;;
	BTFSS 	PIR1,RCIF,0	;CHECK ANY NEW			;;
	BRA 	WRD		;DATA RECIVE			;;								
	BCF 	PIR1,RCIF,0	;RESET THE RX FLAG		;;
	MOVF 	RCREG,0,0	;STORE THE RECIVE DATA INTO W	;;
	RETURN							;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;TRANSMIT FUNCTION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TRANSMIT:							;;
	MOVWF 	TXREG,0		;LOAD THE TX DATA TO CONTROL REG;;
	BCF 	PIR1,TXIF,0	;RESET THE TX FLAG		;;
WTD:								;;
	BTFSS 	PIR1,TXIF,0	;CHECK DATA TRANSMISSION 	;;
	BRA 	WTD		;COMPLET			;;
	RETURN			;RETURN TO MAIN LOOP		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;FLASH WRITE & ERASE OPERATION CONTROL FUNCTION;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLASH_OPERATION:						;;
	MOVWF	EECON1,0	;SET THE REQUIRED OPERATION	;;
	MOVLW	0x55		;SET THE REQUIRED OPERATION	;; 
				;SEQUENCY			;;
	MOVWF 	EECON2,0					;;
	MOVLW	0xAA						;;
	MOVWF	EECON2,0					;;
	BSF	EECON1,WR,0	;START THE OPERATION		;;
	NOP			;WAIT				;;
	NOP							;;
	BCF	EECON1,WREN,0	;DISABLE THE WRITE		;;
	RETURN			;RETURN FROM THE FUNCTION	;;
	
;;;;;;;;;;;;;;;;;;;MAIN ROUTAIN;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;-------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;-------------------------------------------------------
MAIN:
	
	BCF 	INTCON,GIE,0	;DISABLE THE INTERRUPT		;;
;;;;;;;;;CUSTOMIZING THE BOOTLOADER FOR THE REMOTE CONTROLLER;;;;;;;;;;;;;;;;;
	MOVLW 	0xFF		;;
	MOVWF 	TRISA,0		;;
	MOVLW 	0xEF		;;
	MOVWF 	TRISB,0		;;
	MOVLW 	0xFF		;;
	MOVWF 	TRISC,0		;;
	MOVLW 	0xFF		;;
	MOVWF 	TRISD,0		;;
;;;;;;;;;SERIAL COMMUNICATION SETUP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOVLW 	0x0A		;SET BAUT RATE	115200		;;
	MOVWF 	SPBRG,0						;;
	MOVLW 	0x24		;ENABLE THE TX &		;;
	MOVWF 	TXSTA,0		;HIGH SPEED			;;
	MOVLW 	0x90		;ENABLE THE CONTINUOUS RECIVE	;;
	MOVWF 	RCSTA,0		;& SERIAL PORT ENABLE		;;
    CLRF	BAUDCON,0
	CLRF 	RCREG,0		;RESET THE RECIVER REG		;;
;;;;;;;;;;;;;;;SET UP THE PORTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CLRF	TRISE,0
	CLRF	ECCP1CON,0
;;REMOVED FOR THE REMOTE CONTROLLER;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	MOVLW 	0x20		;SET THE PORTB0 AS		;;
;	MOVWF 	TRISC,0		;INPUT AND OTHER OUTPUT		;;
;	CLRF 	PORTC,0		;RESET THE PORTB		;;
;	CLRF	LATC,0		;RESET THE LATCH OF THE PORTB	;;
;;ADDED PART FOR THE REMOTE CONTROLLER;;;;;;;;;;;;;;;;;;
	BCF TRISC,0
	BCF LATC,0
;;	BCF PORTC,0
	BCF PORTE,1			;BACK LIGHT OFF

;	nop					;devinda
;	BSF 	PORTD,4,0	;devinda
;;;;;;;;;;;;CHECK THERE IS PROGRAM MODE;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	BTFSS 	PORTD,5,0	;CHECK IT A PROGRAM MODE	;;
;	BRA 	FTERMINIT	;GOTO SUDEN EXIT_0x7FC		;;
;-----------------INITIALIZE THE TIMER OF boot mode timeout-----------------
TIMER_INIT:
	movlw	0x80			;
	movwf	DlyCnt1			;
	movlw	0x80			;
	movwf	DlyCnt2			;
	movlw	0x65			;
	movwf	DlyCnt3			;; 

;	BSF 	PORTD,4,0       ; indicator that the pic is working
DELAY_LOOP1:
	BTFSC 	PIR1,RCIF,0	;CHECK ANY NEW			;(1)
	GOTO	FIRST_CHAR_RECEICED   				;(2)
	decfsz	DlyCnt1,1,0       					;(1) 
	GOTO DELAY_LOOP1							;(2)
	movlw	0x80								;(1)
	movwf	DlyCnt1								;(1)
	decfsz	DlyCnt2,1,0       					;(1) 
	GOTO DELAY_LOOP1							;(2)
	movlw	0x80								;(1)
	movwf	DlyCnt2								;(1)
	decfsz	DlyCnt3,1,0      					;(1)
	GOTO DELAY_LOOP1;			;;
								;;(((1+2+1+2)*128 + 1+1+1+2)*128 + 1+1+1)*255*200ns = 5.046 sec
								;;(((1+2+1+2)*128 + 1+1+1+2)*128 + 1+1+1)*101*200ns = 1.998 sec

	goto    FTERMINIT;			;;TIMEOUT HAS OCCURED ,SO EXIT BOOTLOAD MODE

FIRST_CHAR_RECEICED:
	BCF 	PIR1,RCIF,0	;RESET THE RX FLAG		;;
	MOVF 	RCREG,0,0	;STORE THE RECIVE DATA INTO W	;;	
	XORLW 	0x62		;CHECK IS IT VALID START CHAR 'b'
	BTFSC 	STATUS,Z,0					;;
	goto	DELAY_LOOP2	;			start LOOKING FOR THE SECOND CHAR
	goto	DELAY_LOOP1	;			INCORRECT CHAR CAME; GO BACK TO THE TIMER

DELAY_LOOP2:
	BTFSC 	PIR1,RCIF,0	;CHECK ANY NEW			;; NOW THE TIME WILL B COUNTED FROM THE STOPPED POINT 
	GOTO	SECOND_CHAR_RECEICED   ;
	decfsz	DlyCnt1,1,0       ; 
	GOTO DELAY_LOOP2;
	movlw	0x80			;
	movwf	DlyCnt1			;
	decfsz	DlyCnt2,1,0       ; 
	GOTO DELAY_LOOP2;
	movlw	0x80			;
	movwf	DlyCnt2		;
	decfsz	DlyCnt3,1,0       ;
	GOTO DELAY_LOOP2;			;;255*255*255*200ns = 3.31 sec

	goto    FTERMINIT;			;;TIMEOUT HAS OCCURED ,SO EXIT BOOTLOAD MODE

SECOND_CHAR_RECEICED:
;;	MOVLW 	0x61		;test point ;;---------------------------------------------------------------------------------
;;	RCALL 	TRANSMIT	;;
	
	;RCALL 	RECIVE		;RECIVE THE LINE TYPE DATA
	BCF 	PIR1,RCIF,0	;RESET THE RX FLAG		;;
	MOVF 	RCREG,0,0	;STORE THE RECIVE DATA INTO W	;;	
	XORLW 	0x6c		;CHECK IS IT VALID START CHAR 'l'
	BTFSC 	STATUS,Z,0					;;
	goto	START_BOOT	;	CORRECT SECOND CHAR RECEIVED;start boot loader
	goto	DELAY_LOOP2	;   INCORRECT SECOND CHAR; GO BACK TO THE TIMER

;------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;RECIVE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;INDICATER OF PROGRAM MODE;;;;;;;;;;;;;;;;;;;;;;;;;;;
START_BOOT
;	BSF 	PORTD,4,0	;PROGRAM MODE INDICATER		;;
;	BSF 	PORTC,1,0	;PROGRAM MODE INDICATER		;;
;;;;;;;;;;;;SEND THE XON DATA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOVLW 	0x11		;STORE THE XON CHAR IN THE W REG;;		
	RCALL 	TRANSMIT	;TRANSMITE THAT DATA		;;
;;;;;;;;;;;;;;;;;;RECIVE THE DATA FOR FASH WRITE;;;;;;;;;;;;;;;;;;
RECICE_DATA:	
;;;;;;;;;;;;;CHECK whether IT IS A INSTRCTION WRITE;;;;;;;;;;;;;;;;;;;;;;;
	RCALL 	RECIVE		;RECIVE THE LINE TYPE DATA	;;
	XORLW 	0x3A		;CHECK IT IS ALINE START CHAR(0x3A is :)	;;
	BTFSS 	STATUS,Z,0					;;
	BRA 	TERMINIT	;GOTO TERMINATE_0x7FA		;;
;->CHECK THAT RECIVE THE DATA FOR PROGRAMMING THE FLASH		;;
;->OR END OF THE PROGRAMMING					;;
;;;;;;;;;;;;;;;;;;;LOAD THE BYTE COUNT;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RCALL 	RECIVE		;RECIVE THE COUNT DATA		;;
	MOVWF 	0x00,0		;STORE THE COUNT FOR RECIVING	;;
	MOVWF	0x01,0		;STORE THE COUNT FOR WRITING	;;
	MOVWF 	0x02,0		;STORE IT FOR CHECK SUM		;;
;->HERE USING THE ACCESS MEMORY AREA				;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;LOAD THE INITAL ADDRESS OF THE FLASH WRITE;;;;;;;;;;;
	RCALL 	RECIVE		;RECIVE THE FALASH WRITE	;; 
				;ADDRESS MSB			;;
	ADDWF 	0x02,1,0	;ADD the data byte to 0x02 address to calculate CHECK SUM 		;;
	MOVWF 	TBLPTRU,0	;LOAD INTO THE FLASH ADDRESS 	;;
				;CONTROL REG			;;
	RCALL 	RECIVE		;RECIVE THE FALASH WRITE	;; 
				;ADDRESS 			;;
	ADDWF 	0x02,1,0	;ADD FOR CHECK SUM		;;
	MOVWF 	TBLPTRH,0	;LOAD INTO THE FLASH ADDRESS 	;;
				;CONTROL REG			;;
	RCALL 	RECIVE		;RECIVE THE FALASH WRITE	;; 
				;ADDRESS LSB			;;
	ADDWF 	0x02,1,0	;ADD FOR CHECK SUM		;;
	MOVWF	TBLPTRL,0	;LOAD INTO THE FLASH ADDRESS 	;;
				;CONTROL REG			;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;LOAD THE DATA INTO THE DATA MEMORY;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LFSR 	FSR0,0x100 	;THE DATA START POINT 		;;
DATA_RX:							;;
	RCALL 	RECIVE		;RECIVE THE DATA		;;
	ADDWF 	0x02,1,0	;ADD FOR CHECK SUM		;;
	MOVWF 	POSTINC0 	;STORE THE RECIVE DATA TO TEMP	;;
				;MEMORY & INCREASED TO NEXT 	;;
	DECFSZ 	0x00,1,0	;COUNTDOWN UPTO END		;;
	BRA 	DATA_RX		;GOTO DATA RECIVE		;;
	RCALL	RECIVE		;RECIVE THE CHECK SUM		;;
	NEGF	0x02,0		;TAKE 2'S COMP			;;
	CPFSEQ	0x02,0		;CHECK WITH CALCULATED CHECK SUM;;		
	BRA	NACK		;GOTO NACK INDICATION		;;
	BRA 	FLASH_WRITE		;GOTO FLASH WRITE		;;
NACK:								;;							
	;RCALL 	RECIVE		;NOT IMPORTANT			;;									
	MOVLW 	0xFF		;SEND NACK			;;
	RCALL 	TRANSMIT					;;
	BRA 	RECICE_DATA	;GOTO DATA RECIVE_0x7B9		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;FLASH WRITE OPERATION;;;;;;;;;;;;;;;;;;;;;;;;;0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLASH_WRITE:
	;RCALL 	RECIVE		;NOT IMPORTANT			;;	
	LFSR 	FSR0,0x100 	;THE DATA START POINT		;;
	BTFSC	TBLPTRU,5,0	;CHECK IT IS CFG WRITE		;;
	BRA	CFG_WRITE	;GOTO CFG WRITE			;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;ERASE THE FLASH MEMORY;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ERASE:								;;
			
	MOVLW	0x94		;GOTO NORMAL PROGRAM MEMORY & 	;;
				;DO THE ERASE THE MEMORY	;;  
	RCALL	FLASH_OPERATION	;DO THE OPERATION ON FLASH	;;
	TBLRD*-			;DUMMY READ	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FLASH_LOAD_DATA:							;;
	MOVF	POSTINC0,0,0	;LOAD THE DATA TO THE FLASH 	;;
				;CONTROL REG			;;
	MOVWF 	TABLAT,0	;LOAD THE DATA TO FLASH REG	;;		
	TBLWT+*				;INC THE TABLE POINTER AND DO 	;;
				;THE WRITE			;;	
	DECFSZ 	0x01,1,0	;COUNTDOWN FLASH LATH FULL	;;
	BRA	FLASH_LOAD_DATA	;GOTO DATA LOAD TO FLASH REG	;;
	MOVLW	0x84		;SET UP FOR DATA WRITE		;;
	RCALL	FLASH_OPERATION	;CALL FLASH WRITE OPERATIN	;;
	BRA	ACK		;GOTO ACK			;;



CFG_WRITE:				
	MOVF	POSTINC0,0,0	;LOAD THE DATA TO THE FLASH 	;;
				;CONTROL REG			;;
	MOVWF 	TABLAT,0	;LOAD THE DATA TO FLASH REG	;;				
	TBLWT*			;THE TABLE POINTER AND DO 	;;
				;THE WRITE			;;

	MOVLW	0xC4		;SET UP FOR CFG WRITE		;;
	RCALL	FLASH_OPERATION	;CALL FLASH WRITE OPERATIN	;;
	DECFSZ 	0x01,1,0	;COUNTDOWN FLASH LATH FULL	;;
	BRA	CFG_WRITE	;GOTO CFG WRITE			;;
	BCF	EECON1,CFGS,0	;POINT TO THE PROGRAM MEMORY	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;SEND THE ACK & GET THE DATA;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ACK:								;;
	MOVLW 	0x06		;SEND ACK			;;
	RCALL 	TRANSMIT					;;
	BRA 	RECICE_DATA	;GOTO DATA GET			;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;TERMINATE THE OPERATION AND NORMAL OPERATION;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TERMINIT;							;;
;	MOVLW 	0x13		;SEND XOFF			;; temp comment by devinda
;	RCALL 	TRANSMIT					;;
	RESET			;RESET THE PROCESSOR		;;
FTERMINIT:	
;	MOVLW 	0x33		;Leaving the bootloader added by devinda
;	GOTO 	TRANSMIT	;; temp comment by devinda
	NOP;
	NOP;
	NOP;
	NOP;
	GOTO 	MAIN		;GOTO THE MAIN			;;
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;->THIS IS THE AREA TO POINT THE MAIN FUNCTION OF THE NORMAL 	;;
;  PROGRAM							;;
;->THIS THREE INSTRUCTION ARE CHANGE WHEN THE NORMAL PROGRAMMING;;
;  LOADING							;;
;->AFTER THE LOADING THE NORMAL PROGRAMMING IT CHANGE TO POINT	;;
;  THAT PROGRAMMING MAIN POINT					;;
;->THERE ISN'T ANY NORMAL PROGRAMMING LOADED THIS AREA POINTED 	;;
;  TO THE BOOTLOADING MAIN POINT				;;
;->CAREFUL TO CHANGE THIS POINT BECAUSE IT DAMAGE THE LOADER 	;;
;  ALSO								;;   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	END