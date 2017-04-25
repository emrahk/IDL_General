FUNCTION Centroid, array, invert=invert
;
;+
;   Name: centroid
;
;   Purpose: calculate the centroid ("center of mass") of 2D array
;
;   Input Parameters:
;      array - 2D array
;
;   Output:
;      function returns centroid [xc,yc]
;
;   Keyword Parameters:
;      invert - if set, operate on the inverted array (ie, dark vs light...) 
; 
;   Calling Example:
;       center=centroid(array)
;
;   History:
;      S.L.Freeland - using Dave Fannings example available at: 
;                     http://www.dfanning.com/tip_examples/centroid.pro
;                     added /INVERT and a couple of ssw-isms  
;
;-

IF data_chk(array,/ndim) NE 2 THEN BEGIN
   Message, 'Array must be two-dimensional. Returning...', /Informational
   RETURN, -1
ENDIF

case 1 of 
   keyword_set(invert): marray=(max(array) - array)*(array ne 0) 
   else: marray=array
endcase

totalMass = Total(marray)

xcm = Total( Total(marray, 2) * lindgen(data_chk(marray,/nx)) ) / totalMass
ycm = Total( Total(marray, 1) * lindgen(data_chk(marray,/ny)) ) / totalMass
RETURN, [xcm, ycm]
END
