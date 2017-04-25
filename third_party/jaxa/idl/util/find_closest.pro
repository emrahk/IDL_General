;** keyword /LESS returns closest subscript for arr that is less than or equal  to num

FUNCTION FIND_CLOSEST, num, arr, LESS=less, QUIET=quiet
;+
; $Id: find_closest.pro,v 1.6 2011/03/09 18:42:22 nathan Exp $
; NAME:
;	FIND_CLOSEST
;
; PURPOSE:
;	This function finds the subscript of an array that is closest to
;	a given number.
;
; CATEGORY:
;	LASCO UTIL
;
; CALLING SEQUENCE:
;	Result = FIND_CLOSEST (Num, Arr)
;
; INPUTS:
;	Num:	Number for which the array will be searched
;	Arr:	An array of points in ascending or descending order
;
; KEYWORD PARAMETERS:
;	LESS:	Returns the closest subscript for arr that is LEFT OF num 
;   	    	(i.e., for descending array, value is GT than num)
;   	    	Otherwise the subscript of the point closest to num is returned. 
;
; OUTPUTS:
;	This function returns the subscript of an array closest to the given
;	number.
;
; RESTRICTIONS:
;   	arr most be sorted
;
; $Log: find_closest.pro,v $
; Revision 1.6  2011/03/09 18:42:22  nathan
; ensure return correct value for /less and descending array if no value <num
;
; Revision 1.5  2011/02/08 18:59:02  mcnutt
; returns 0 if no value in array less than num
;
; Revision 1.4  2010/11/10 22:12:03  nathan
; fix logic error for case num is outside of range
;
; Revision 1.3  2010/11/02 19:01:55  nathan
; had to mostly re-write; added /QUIET
;
; Revision 1.2  2010/10/20 18:45:45  nathan
; allow descending arrays and missing values
;
; MODIFICATION HISTORY:
; 	Written by:	Scott Passwaters, NRL, Feb, 1997
;	24 Sep 1998, N Rich	changed /LESS keyword to include equal-to
;	31 Jan 2000, N Rich	Allow for MOSTLY (except for isolated stray elements) sorted arr, but must still be ascending order
;	12 Apr 2005, N.Rich	Return -1 in one case.     
;
;	@(#)find_closest.pro	1.5 02/13/07 LASCO IDL LIBRARY
;-

    x0=where_not_missing(arr)
    arr=arr[x0]
    
   len = N_ELEMENTS(arr)


    l=where(arr LE num, len2)

    IF len2 EQ 0 and keyword_set(LESS) THEN BEGIN
    	IF ~keyword_set(QUIET) THEN $
	message,'WARNING: no value in array less than '+trim(num),/info
    ENDIF
    IF arr[0] GT arr[len-1] THEN BEGIN
    ; descending values
    	IF len2 EQ 0 THEN ind=len-1 ELSE $
	IF len2 EQ len THEN ind=0 ELSE $
	ind = l[0]-1	; value to the left
    ENDIF ELSE BEGIN
    ; ascending values
    	IF len2 EQ 0 THEN ind=0 ELSE $
	IF len2 EQ len THEN ind=len-1 ELSE $
	ind = l[len2-1]
    ENDELSE

    IF datatype(arr) EQ 'STR' THEN BEGIN
    	IF ~keyword_set(LESS) and ~keyword_set(QUIET) THEN message,'Assuming /LESS for datatype STR.',/info
	RETURN, x0[ind] 
    ENDIF ELSE $
    IF len2 EQ len or len2 EQ 0 THEN return,x0[ind] ELSE $
    BEGIN
    	diff1 = ABS(num - arr(ind))
    	diff2 = ABS(num - arr((ind+1)<(len-1)))
    	IF keyword_set(LESS) OR (diff1 LT diff2) THEN RETURN, x0[ind] ELSE return, x0[ind+1]
    ENDELSE
END
