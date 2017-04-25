function ratio, nom, denom, blank=blank
; $Id: ratio.pro,v 1.5 2007/02/26 18:32:42 nathan Exp $
; 
; Project:	STEREO - SECCHI
;
; Form the ratio of 2 images/cubes
; Written by A. Vourlidas 02/05
;
; $Log: ratio.pro,v $
; Revision 1.5  2007/02/26 18:32:42  nathan
; reinstate rev 1.2 with denom=scalar change
;
; Revision 1.2  2007/01/31 19:28:10  nathan
; add error message for denom=0; allow denom=scalar
;

   IF NOT keyword_set(blank) THEN blank = 0 ;default blanking value
   tmp = denom*0.
   ind = where((denom NE 0.) AND (abs(denom) GT blank))
    IF ind[0] LT 0 THEN BEGIN
    	message,'cannot divide by zero - returning -1',/inform
	print
	wait,2
	return,-1
    ENDIF ELSE IF n_elements(denom) EQ 1 THEN $
    	tmp=nom/denom ELSE $
    	tmp(ind) = nom(ind)/denom(ind)
   
   return, tmp
END
