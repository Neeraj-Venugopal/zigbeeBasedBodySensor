        ORG 00H
		CLR P2.4
		clr p2.3
		MOV P1,#00H
		MOV P0,#0FFH
		MOV R3,#00H
NEXT:	MOV TMOD,#20H
    	MOV SCON,#50H
    	MOV TH1,#-3
  		SETB TR1
		MOV DPTR,#MYCOM2
		ACALL INITLCD
		MOV DPTR,#MSG1
		ACALL DISPLAY1
		MOV DPTR,#MYCOM1
        CALL INITLCD
	
START:	ACALL CLRLCD
		MOV DPTR,#MSG
		ACALL DISPLAY
	   	CLR RI
		MOV A,#'1'
		ACALL SERIAL_SEND
RPT:    JNB RI,RPT
		MOV A,SBUF
		CJNE A,#'1',NO_OPER
		ACALL LCD_CMD
        MOV DPTR,#MYDATA3
	    ACALL LCD_DATA
		SETB P2.3
		ACALL DELAY
		ACALL DELAY
		ACALL DELAY
		CLR RI
		CLR P2.3
		
		SJMP START
NO_OPER: CJNE A,#'2',HRT
         SETB P2.3
		 ACALL LCD_CMD
         MOV DPTR,#MYDATA4
		 ACALL LCD_DATA
		 CLR P2.3
     	 CLR RI
	//	 MOV A,#'1'
	//	ACALL SERIAL_SEND
    	 SJMP START
HRT:     CJNE A,#'3',PAT
         SETB P2.3
		 ACALL LCD_CMD
         MOV DPTR,#MYDATA6
		 ACALL LCD_DATA
		 CLR P2.3
     	 CLR RI
	//	 MOV A,#'1'
	//	ACALL SERIAL_SEND
    	 SJMP START
PAT:     CJNE A,#'4',HRT
         SETB P2.4
		 ACALL LCD_CMD
         MOV DPTR,#MYDATA5
		 ACALL LCD_DATA
		 CLR P2.4
     	 CLR RI
	//	 MOV A,#'1'
	//	ACALL SERIAL_SEND
    	 SJMP START

//**** SUBROUTINE FOR DISPLAY AND SENDING THE OFF STATUS *****//



LCD_CMD:MOV DPTR,#MYCOM1
BACK4: CLR A
       MOVC A,@A+DPTR
       ACALL COMNWRT
       ACALL DELAY
       JZ AGAIN1
       INC DPTR
	   SJMP BACK4
AGAIN1: RET
//----LCD DATA SENDOUTINE----//
LCD_DATA: NOP
D2:     CLR A
        MOVC A,@A+DPTR
	    JZ AGAIN2
		ACALL DATAWRT
	    ACALL DELAY
		INC DPTR
	    SJMP D2
AGAIN2:	RET
//-----SERIAL SEND ROUTINE------//
SERIAL_SEND:NOP
D3:     MOV SBUF,A
		JNB TI,$
		CLR TI
		RET


DISPLAY1:NOP
BACK33:  MOV A,#18H
        ACALL COMNWRT
		ACALL DELAY
        CLR A
        MOVC A,@A+DPTR
        JZ LCD_DATA24
	    ACALL DATAWRT
	    ACALL DELAY
        INC DPTR
	    SJMP BACK33
LCD_DATA24:RET
;----------------------------------------------------------------------------------------------------------------------
INITLCD:CLR A
       MOVC A,@A+DPTR
       JZ LCD_DATA1
	   ACALL COMNWRT
	   ACALL DELAY
       INC DPTR
	   SJMP INITLCD 
LCD_DATA1: RET
;--------------------------------------------------------------------------------------------------------------------
DISPLAY:NOP
BACK3:  CLR A
        MOVC A,@A+DPTR
        JZ LCD_DATA2
	    ACALL DATAWRT
	    ACALL DELAY
        INC DPTR
	    SJMP BACK3
LCD_DATA2: RET

///*** LCD COMMAND WRITE ROUTINE ***///
COMNWRT :   MOV  P1,A   // SEND COMMOND TO PORT P2
    	   	CLR P3.5    // CLEAR ZERO MENS INDICATE COMMOND
	       	CLR P3.6    //R/W=0 FOR WRITE
	      	SETB P3.4   //ENABLE LCD
	       	ACALL DELAY  //GIVE SOME TIME TO LCD
	       	CLR P3.4     //DISABLE LCD
 	      	RET    

///*** LCD DATA WRITE ROUTINE ***///	 
DATAWRT :	MOV  P1,A    // SEND COMMOND TO PORT P2
    	    SETB p3.5   //  SEBT 1 MENS INDICATE DATA
	    	CLR p3.6  //R/W=0 INDICATE FOR WRITE
	        SETB p3.4    //ENABLE LCD
	      	ACALL DELAY   //GIVE SOME TIME TO LCD
	      	CLR p3.4     //DISABLE LCD
	      	RET         //RETURN FROM  SUBTOUTINE
CLRLCD:	mov a,#01h
		acall COMNWRT
		ACALL DELAY
		mov a,#80h
		acall COMNWRT
		ACALL DELAY
		RET


///*** DELAY ROUTINE ***///
DELAY: MOV R5,#250
HERE1: MOV R4,#255
HERE2: DJNZ R4,HERE2
       DJNZ R5,HERE1
	   RET
;--------------------------------------------------------------------------------------------------------------------
STEPPC:  	MOV R2,#50
             	MOV A,#11H
        BAC1:	MOV P2,A
              	ACALL DELAY  
              	RL A
              	DJNZ R2,BAC1
              	RET
;--------------------------------------------------------------------------------------------------------------------
STEPPA:  	   	MOV R2,#50
             	MOV A,#88H
        BAC11:	MOV P2,A
              	ACALL DELAY  
              	RR A
              	DJNZ R2,BAC11
              	RET


ORG 600H
MSG1 :DB '****WELCOME TO DOCTOR MONITORING SYSTEM***',0
MSG:DB 'WAITING... ',0
MYCOM1: DB 38H,0EH,06H,01H,80H,0		   ; 38H- 2Line ,5x7 matrix display ;0EH-LCD ON & CURSER ON
MYCOM2: DB 30H,0EH,06H,01H,8FH,0
MYDATA3:DB "TEMP ABOVE REF......",0 
MYDATA4:DB "HUMIDITY HIGH.....",0
MYDATA5:DB "PATIENT ALERTING",0
MYDATA6:DB "HBR HIGH",0



		END