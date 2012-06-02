; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;+
; NAME:
;
;	CALC_PHASES.PRO
;
; PURPOSE:
;
;	
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;	
;
; INPUTS:
;
;       
;
; KEYWORD PARAMETERS:
;
;
;       
; OUTPUTS:
;
;       
;
; COMMON BLOCKS:
;	NONE
;
; SIDE EFFECTS:
;      
;
; RESTRICTIONS:
;	
;
; DEPENDENCIES:
;       
;
; PROCEDURE:
;        
;
; EXAMPLES:
;       
;
;
; MODIFICATION HISTORY:
;
;	Written, Peter.Woods@msfc.nasa.gov
;		(205) 544-1803
;-
;*******************************************************************************


FUNCTION  CALC_PHASES, x_in, coeff


format = SIZE(x_in)

CASE format[0] OF 
   1 : phase = DBLARR(format[1])
   2 : phase = DBLARR(format[1],format[2])
   ELSE : BEGIN
   	PRINT, ' * * * * * ERROR * * * * * '
	PRINT, ' CALC_PHASES : Incorrect times array format '
	PRINT, ' Array can be either one or two dimensions '
	PRINT, ' Halting program ...'
	stop
   END
ENDCASE

order = N_ELEMENTS(coeff) - 1

FOR i = 0, order DO BEGIN
   phase = phase + (coeff[i] * x_in^i)
ENDFOR

RETURN, phase


END
