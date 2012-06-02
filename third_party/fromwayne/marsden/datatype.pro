;-------------------------------------------------------------
;+
; NAME:
;	DATATYPE
; PURPOSE:
;	Datatype of variable as a string (3 char or spelled out).
;
; CALLING SEQUENCE:
;	typ = datatype(var, [flag])
;
; INPUTS:
;	var = variable to examine.         in
;	flag = output format flag (def=0). in
;
; OUTPUTS:
;       typ = datatype string or number.   out
;          flag = 0       flag = 1           flag = 2       flag = 3
;          UND            Undefined          0              UND
;          BYT            Byte               1              BYT
;          INT            Integer            2              INT
;          LON            Long               3              LON
;          FLO            Float              4              FLT
;          DOU            Double             5              DBL
;          COM            Complex            6              COMPLEX
;          STR            String             7              STR
;          STC            Structure          8              STC
; MODIFICATION HISTORY:
;	Written by R. Sterner, 24 Oct, 1985.
;       RES 29 June, 1988 --- added spelled out TYPE.
;       R. Sterner, 13 Dec 1990 --- Added strings and structures.
;	R. Sterner, 19 Jun, 1991 --- Added format 3.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION DATATYPE,VAR, FLAG, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Datatype of variable as a string (3 char or spelled out).'
	  print,' typ = datatype(var, [flag])'
	  print,'   var = variable to examine.         in'
	  print,'   flag = output format flag (def=0). in'
	  print,'   typ = datatype string or number.   out'
	  print,'      flag=0    flag=1      flag=2    flag=3'
	  print,'      UND       Undefined   0         UND'
	  print,'      BYT       Byte        1         BYT'
	  print,'      INT       Integer     2         INT'
	  print,'      LON       Long        3         LON'
	  print,'      FLO       Float       4         FLT'
	  print,'      DOU       Double      5         DBL'
	  print,'      COM       Complex     6         COMPLEX'
	  print,'      STR       String      7         STR'
	  print,'      STC       Structure   8         STC'
	  return, -1
	endif 
 
	IF N_PARAMS(0) LT 2 THEN FLAG = 0	; Default flag.
 
	if n_elements(var) eq 0 then begin
	  s = [0,0]
	endif else begin
	  S = SIZE(VAR)
	endelse
 
	if flag eq 2 then return, s(s(0)+1)
 
	IF FLAG EQ 0 THEN BEGIN
	  CASE S(S(0)+1) OF
   0:	    TYP = 'UND'
   7:       TYP = 'STR'
   1:       TYP = 'BYT'
   2:       TYP = 'INT'
   4:       TYP = 'FLO'
   3:       TYP = 'LON'
   5:       TYP = 'DOU'
   6:       TYP = 'COM'
   7:       TYP = 'STR'
   8:       TYP = 'STC'
ELSE:       PRINT,'Error in DATATYPE'
	  ENDCASE
	ENDIF ELSE if flag eq 1 then BEGIN
	  CASE S(S(0)+1) OF
   0:	    TYP = 'Undefined'
   7:       TYP = 'String'
   1:       TYP = 'Byte'
   2:       TYP = 'Integer'
   4:       TYP = 'Float'
   3:       TYP = 'Long'
   5:       TYP = 'Double'
   6:       TYP = 'Complex'
   7:       TYP = 'String'
   8:       TYP = 'Structure'
ELSE:       PRINT,'Error in DATATYPE'
	  ENDCASE
	ENDif else IF FLAG EQ 3 THEN BEGIN
	  CASE S(S(0)+1) OF
   0:	    TYP = 'UND'
   7:       TYP = 'STR'
   1:       TYP = 'BYT'
   2:       TYP = 'INT'
   4:       TYP = 'FLT'
   3:       TYP = 'LON'
   5:       TYP = 'DBL'
   6:       TYP = 'COMPLEX'
   7:       TYP = 'STR'
   8:       TYP = 'STC'
ELSE:       PRINT,'Error in DATATYPE'
	  ENDCASE
	endif
 
	RETURN, TYP
 
	END
