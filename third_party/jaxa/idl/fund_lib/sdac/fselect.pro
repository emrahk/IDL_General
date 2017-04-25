;+
;
; NAME:
;	FSELECT
;
; PURPOSE:
;       Read operator selected flare numbers from the terminal and store
;       the flare numbers into an array to be used in other procedures.
;
; CATEGORY:
;       HXRBS
;
; CALLING SEQUENCE:
;	FSELECT, Flarr, Counts
;
; INPUTS:
;       none.
;
; OUTPUTS:
;       Flarr:	Array of flare numbers selected by the operator.
;       Counts:	Number of flares numbers stored in Flarr.
;
; KEYWORDS:
;	WHAT:		This string will be part of the message to the user.
;			Example: PRINT, 'Enter ',what,'single numbers and/or 
;			ranges separated by commas'
;       INSTRING:	Character string with user's list of flare numbers.  
;			If this keyword is supplied, the user is not prompted 
;			for input.
;       ERROR:		0/1 means no error/error in string. Only used when 
;			INSTRING keyword supplied, because otherwise, prompts 
;			user for corrected string.
;       OPER_STRING:	Character string with user's input.  The procedure 
;         		will return the user's input string if it cannot 
;			interpret user's input string.
;       OC_OPTIONS:	0/1 means don't print/print additional operator 
;         		data entry options in the operator communications 
;			part of the procedure.
;
; PROCEDURE:
;       Read a line of operator selected flare numbers from the terminal.
;       Determine the positions of the non-numeric characters in the line.
;       Use these characters to determine if single numbers or ranges of
;       numbers should be stored in FLARR. When the end of the line is
;       reached and if it ends with a semicolon, read another line.
;
; MODIFICATION HISTORY:
;	Written 07/11/88 by S. Kennard.
;	Mod. 07/92 by Erika Lin. (1) to return specific string that the
;		operator has inputed if procedure cannot interpret operator's 
;		input string (keyword: OPER_STRING); and (2) to indicate 
;		whether or not to print additional operator data entry 
;		options in operator communication part of the procedure 
;		(keyword: OC_OPTIONS). 
;	Mod. 04/96 by EAC. Enlarge FLARR to 10000, allows bigger search 
;		parameters
;	Mod. 05/14/96 by RCJ. Added documentation.
;-
;
PRO FSELECT,FLARR,COUNT, WHAT = WHAT, INSTRING = INSTRING, ERROR=ERROR, $
	OPER_STRING = OPER_STRING, OC_OPTIONS=OC_OPTIONS
;
ON_IOERROR, GOTERROR

ERROR = 0

FLMAX = 10000                      ;The maximum size of use specified
				;selections allowed EAC 4/96

FLARR = INTARR(FLMAX)              ; Integer array for storing flare numbers.

; Prompt user to enter flare numbers.
IF KEYWORD_SET(INSTRING) THEN BEGIN
   A = INSTRING
ENDIF ELSE BEGIN
   A =' '                            ; String to read into.
   RESTART:                          
   if not(keyword_set(what)) then what = ''
   PRINT, 'Enter ',what,'single numbers and/or ranges separated by commas, for'
   PRINT, 'example: 3,5-9,20-25,40.  End line with a semicolon to continue ',$
          'onto next line.'
   IF KEYWORD_SET(OC_OPTIONS) THEN BEGIN
      PRINT,'(To select flares by file name, time, TJD, or seconds into day: '
      PRINT,'Type INP,filename; INP,T,time; INP,F,flare#; '
      PRINT,'       INP,J,tjd[,secsofday] or INP,J,YY/MM/DD[,secsofday] .)'
   ENDIF
   READ, '?  ', A
ENDELSE
;
COUNT=0                           ; Initialize index for flare # integer array.
IF A EQ '' THEN GOTO,GETOUT
NST=0                             ; Initialize current position in string a.
FOR K=1,FLMAX DO BEGIN
   IF COUNT GT FLMAX THEN GOTO,FINI
   NCOM=STRPOS(A,',',NST)         ; Find position of 1st comma after nst.
   NDASH=STRPOS(A,'-',NST)        ; Find position of 1st dash after nst.
   NSCOL=STRPOS(A,';',NST)        ; Find position of semicolon after,nst.

    ; All the following case tests check the relative positions of the 
    ; 1st delimiters (',','-' and ';') that occur at or after nst.

   CASE 1 OF
                                  ; The string is 'n-m', 'n-m;' or 'n-m,'.
     ((NCOM GT NDASH) OR (NCOM EQ -1)) AND (NDASH NE -1) : BEGIN
        LEN = NDASH - NST         ; Store the value of n in the integer 
                                  ; array(i.a.).
        FLARR(COUNT) = STRMID(A, NST, LEN)
        NST =  NDASH + 1
        CASE 1 OF
          (NCOM NE -1): BEGIN     ; The string is 'n-m,'.
            LEN = NCOM - NST      ; Get the value of m.
            FLR = STRMID(A, NST, LEN)
            LAST = FLR - FLARR(COUNT)
            IF LAST LT 0 THEN GOTO,GOTERROR
                                  ; Get the values of n thru m and store them 
                                  ; in the i.a..
            FOR Q=1,LAST DO BEGIN 
              IF (COUNT + Q) GT FLMAX THEN GOTO,FINI
              FLARR(COUNT + Q) = FLARR(COUNT) + Q
            ENDFOR
                                  ; Set the i.a. index to the next vacant 
                                  ; element.
            COUNT = COUNT + LAST + 1
            NST = NCOM + 1        ; Set current postion to after the comma.

                                  ; The string was actually 'n-m,;' read 
                                  ; another line.
            IF (NSCOL EQ (NCOM+1)) THEN BEGIN
              READ,A
              NST = 0
              END
          END

                                  ; The string is 'n-;'.
          (NSCOL EQ (NDASH + 1)) :BEGIN
            READ,A                ; It is necessary to read the next line
            NST = 0               ; to get the value of m.
            NCOM=STRPOS(A,',',NST)  ; Get the postions of comma, dash and
            NDASH=STRPOS(A,'-',NST) ; semicolon from the new line.
            NSCOL=STRPOS(A,';',NST)
            CASE 1 OF
                                  ; The 1st string on the new line is 'm,'.
              ((NCOM LT NDASH) OR (NDASH EQ -1)) AND $
              ((NCOM LT NSCOL) OR (NSCOL EQ -1)) :BEGIN
                LEN = NCOM - NST  ; Get the value of m.
                FLR = STRMID(A, NST, LEN)
                LAST = FLR - FLARR(COUNT)
                IF LAST LT 0 THEN GOTO,GOTERROR
                                  ; Get the values of n thru m and store them 
                                  ; in the i.a..
                FOR Q=1,LAST DO BEGIN
                  IF (COUNT + Q) GT FLMAX THEN GOTO,FINI
                  FLARR(COUNT + Q) = FLARR(COUNT) + Q
                ENDFOR
                COUNT = COUNT + LAST + 1
                NST = NCOM + 1
              END 

                                  ; The new string is 'm;'.
              (NSCOL NE -1) AND (NCOM EQ -1):BEGIN       
                LEN = NSCOL - NST ; Get the value of m.
                FLR = STRMID(A, NST, LEN)
                LAST = FLR - FLARR(COUNT)
                IF LAST LT 0 THEN GOTO,GOTERROR
                                  ; Get the values of n thru m and store them 
                                  ; in the i.a..
                FOR Q=1,LAST DO BEGIN
                  IF (COUNT + Q) GT FLMAX THEN GOTO,FINI
                  FLARR(COUNT + Q) = FLARR(COUNT) + Q
                ENDFOR
                                  ; The semicolon at the end of the string
                                  ; indicates a new line is to be read into a.
                COUNT = COUNT + LAST + 1
                READ,A
                NST = 0
              END

            ELSE: GOTO,GOTERROR
                                  ; The new line did not start with a number,
                                  ; a condition required by this case. ask
                                  ; the operator to reenter the flare numbers.
            ENDCASE
          END

                                  ; The string is 'n-m'.
          (NCOM EQ -1) AND (NSCOL EQ -1) :BEGIN
            LEN = 5               ; Get the value of m.
            FLR = STRMID(A, NST, LEN)
            LAST = FLR - FLARR(COUNT)
            IF LAST LT 0 THEN GOTO,GOTERROR
                                  ; Get the values of n thru m and store them 
                                  ; in the i.a..
            FOR Q=1,LAST DO BEGIN
               IF (COUNT + Q) GT FLMAX THEN GOTO,FINI
               FLARR(COUNT + Q) = FLARR(COUNT) + Q
            ENDFOR
            COUNT = COUNT + LAST
            GOTO,FINI             ; Since there were no delimiters after number
                                  ; m, this must be the final string, exit the
                                  ; procedure.
          END
        
                                  ; String is 'n-m;'.
          (NSCOL GT NDASH):BEGIN
            LEN = NSCOL - NST     ; Get the value of m.
            FLR = STRMID(A, NST, LEN)
            LAST = FLR - FLARR(COUNT)
            IF LAST LT 0 THEN GOTO,GOTERROR
                                  ; Get the values of n thru m and store them 
                                  ; in the i.a..
            FOR Q=1,LAST DO BEGIN
               IF (COUNT + Q) GT FLMAX THEN GOTO,FINI
               FLARR(COUNT + Q) = FLARR(COUNT) + Q
            ENDFOR
                                  ; The semicolon at the end of the string
                                  ; indicates a new line is to be read into a.
            COUNT = COUNT + LAST + 1
            READ,A
            NST = 0
          END

        ELSE: GOTO,GOTERROR
              ; The delimiter (dash) was not followed by a number or a
              ; semicolon. instruct the operator to reenter the flare 
              ; numbers.
        ENDCASE
      END

                                  ; THe string is ',n' or just 'n'
     (NCOM EQ -1) AND (NDASH EQ -1) AND (NSCOL EQ -1) : BEGIN
        LEN = 5                   ; Get value of n and store it in the i.a..
        FLARR(COUNT) = STRMID(A, NST, LEN)
        GOTO,FINI                 ; Since there were no delimiters after number
                                  ; m, this must be the final string, exit the
                                  ; procedure.
        END
       
   ELSE:  BEGIN
      CASE 1 OF
                                  ; The string is 'n,'
        (NCOM NE -1):BEGIN
           LEN = NCOM - NST       ; Get value of n and store it in the i.a..
           FLARR(COUNT) = STRMID(A, NST, LEN)
           NST = NCOM + 1
           COUNT = COUNT + 1
                                  ; The string is actually 'n,;'. read a new
                                  ; line after storing value of n.
           IF (NSCOL EQ (NCOM+1)) THEN BEGIN
             READ,A
             NST = 0
             END
           END

      ELSE: BEGIN
                                  ; The string is 'n;'. get value of n and store
                                  ; it. read a new line.
           IF (NDASH EQ -1) AND (NSCOL NE -1) THEN BEGIN
             LEN = NSCOL - NST
             FLARR(COUNT) = STRMID(A, NST, LEN)
             NST = NSCOL + 1
             COUNT = COUNT + 1
             READ,A
             NST = 0
           ENDIF
           END
        ENDCASE
      END
   ENDCASE
   
ENDFOR

FINI:
FLARR = FLARR(0:COUNT)
COUNT=COUNT+1
GOTO, GETOUT

GOTERROR:
ERROR=1
COUNT=0
GOTO,GETOUT

;IF KEYWORD_SET(INSTRING) THEN BEGIN
;   ERROR = 1
;   GOTO,GETOUT
;ENDIF ELSE BEGIN
;   PRINT, 'Error in input--please reenter'
;   GOTO,RESTART
;ENDELSE
;

GETOUT:
OPER_STRING = A
;PRINT,'COUNT =',COUNT
RETURN
END
