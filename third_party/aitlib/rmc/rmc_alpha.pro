FUNCTION rmc_alpha,dim
;+
; NAME: alph
;
;
;
; PURPOSE: creates a dim X dim array fo the angles of the different
;          pixels in this array. The Base is in the middle of the
;          centerpixel at the bottem of the array.
;         
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: dim
;
;
;
; INPUTS:  dim: dimension of the pixelarray
;   
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
; OUTPUTS:  alpha: array containing anglevalues for array with
;           dimension dim 
;
;
;
; OPTIONAL OUTPUTS:
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
; EXAMPLE:   alpha = alph(10)
;            creates a 10 X 10 array including the angles of the pixels
;
;
; MODIFICATION HISTORY:
;   $Log: rmc_alpha.pro,v $
;   Revision 1.2  2002/05/10 14:09:57  slawo
;   *** empty log message ***
;
;   
;
;-   
   ;; erstellt array der Dimension dim fuer Winkel
   alpha = fltarr(dim,dim) 
   
   ;; drehi,drehk sind Positionen der Drehachse
   IF (dim MOD 2) EQ 1 then BEGIN
       drehi = float(dim)       ; - 0.5
       drehk = float(dim/2)     ; - 0.5
   ENDIF  ELSE BEGIN
       drehi = float(dim) - 0.5
       drehk = float(dim/2) - 0.5
   ENDELSE
   ;; Schleife geht durch komplettes Array und berechnet einzelne
   ;; Winkel
  
   kt=findgen(dim)-drehk
   it=drehi-findgen(dim)

   FOR i = 0,dim-1 DO BEGIN
       ;; Winkelberechnung
       alpha(*,i) = atan( kt[*] / it[i])*180./!pi 
   END

   return,alpha
   
END












