;+
;
; NAME: 
;	DBL2ARRAY
;
; PURPOSE:
;	Convert a 64 bit flag word to a byte array of 1's and 0's.  
;
; CATEGORY:
;	SMM Catalog
;
; CALLING SEQUENCE:
;	result = DBL2ARRAY(DBL=DBL)
;
; CALLED BY:
;	SMMCAT
;
; CALLS TO:
;	none
;
; INPUTS:
;       DBL 	Double precision word array containing 64 bit flags to convert
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       Returns a byte array (64 x n_elements(dbl)) containing 1s or 0s
;	corresponding to the bits of DBL. 
;
; OPTIONAL OUTPUTS:
;	none
;
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Convert double values into 2 by n long array, and identify which
;	bits are set.
;
; MODIFICATION HISTORY:
;	Mar 15, 1994 - Kim Tolbert (HSTX)
;	May '94      - Elaine Einfalt (HSTX) - Changed procedure into function
;					     - Added array input
;					     - Removed ONFLAGS return variable
;-

function dbl2array, dbl=dbl

 n_el = n_elements(dbl) 
 lon = long(dbl, 0, 2, n_el)		; take the doubles and put them into
					; two longs, (for the entire array DBL)

 array = bytarr(64, n_el)

 for i=0,31 do begin 
	w = where((lon(1,*) and 2l^i) ne 0, count)
	if count ne 0 then array(i,w) = 1b

	w = where((lon(0,*) and 2l^i) ne 0, count)
	if count ne 0 then array(i+32,w) = 1b
 endfor


return, array
end

