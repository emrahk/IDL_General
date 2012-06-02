;+
; NAME: explabel
;
;
;
; PURPOSE: force IDL to plot labels in exponential form
;
;
;
; CATEGORY: plotting tools
;
;
;
; CALLING SEQUENCE: plot,....,xtickformat='explabel'
;
;
;
; INPUTS:
;         axis, index, value: see documentation of axis procedure for
;         the meaning of these parameters
;
;
;
; OPTIONAL INPUTS:
;         none
;
;
; KEYWORD PARAMETERS:
;         none
;
;
; OUTPUTS:
;         the function returns an exponentially formatted string of the
;         form '10^x' or '1x10^Y'
;
; OPTIONAL OUTPUTS:
;         none
;
;
; COMMON BLOCKS:
;         ...are evil :-)
;
;
; SIDE EFFECTS:
;         none
;
;
; RESTRICTIONS:
;         explabel should not be used for axes spanning less than a few
;         decades because the exponential numbers returned have only one
;         significant digit of precision
;
; PROCEDURE:
;         trivial
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;     written sometime back in 1993 or 1994 by Joern Wilms
;     $Log: explabel.pro,v $
;     Revision 1.2  2002/07/26 07:40:50  wilms
;     better check whether mantissa is different from unity (now avoids roundoff)
;
;-
FUNCTION explabel,axis,index,value
   ;; 10-exponent
   expo=fix(alog10(value))
   ;; mantissa
   mant=value*10.^(-expo)
   ;; Create format
   IF (abs(mant-fix(mant))/abs(mant) GE 1E-6) THEN BEGIN 
       return,string(format="(F3.0,5Hx10!U,I2,2H!N)",mant,expo)
   END ELSE BEGIN 
       return,string(format="(4H10!U,I2,2H!N)",expo)
   END 
END 
