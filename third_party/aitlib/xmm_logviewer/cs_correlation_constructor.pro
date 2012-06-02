;+
; NAME:
;cs_correlation_constructor
;
;
; PURPOSE:
; 
;
;
; CATEGORY:
;xmm_logviewer subroutine
;
;
; CALLING SEQUENCE:
;cs_correlation_constructor,  xwerte1, ywerte1, xwerte2, ywerte2, time_interval, xwerte=xwerte, ywerte=ywerte
;
;
; INPUTS:
;xwerte1, ywerte1, xwerte2, ywerte2, time_interval,
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;xwerte=xwerte, ywerte=ywerte
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-


PRO cs_correlation_constructor,  xwerte1, ywerte1, xwerte2, ywerte2, time_interval, xwerte=xwerte, ywerte=ywerte
length1=N_ELEMENTS(xwerte1)
length2=N_ELEMENTS(xwerte2)
xwerte=DBLARR(length1)
ywerte=DBLARR(length1)
counter_1=0L
counter_2=0L
new_length=0L

WHILE NOT ((counter_1 GE length1) OR (counter_2 GE length2)) DO BEGIN
 betrag=DOUBLE(ABS(xwerte1(counter_1) - xwerte2(counter_2)))
CASE 1 of 
   (betrag LE time_interval) : BEGIN
		xwerte(new_length)=ywerte2(counter_2)
		ywerte(new_length)=ywerte1(counter_1)
		new_length=new_length+1
		counter_2=counter_2+1
		counter_1=counter_1+1
             END
    (betrag GT time_interval) AND (xwerte1(counter_1) GT xwerte2(counter_2)): counter_2=counter_2+1
  ELSE: counter_1=counter_1+1
 ENDCASE
ENDWHILE

IF (new_length GT 0) THEN BEGIN 
xwerte=extrac(xwerte, 0, new_length-1)
ywerte=extrac(ywerte, 0, new_length-1)
ENDIF ELSE BEGIN
xwerte=0
ywerte=0
ENDELSE
END
