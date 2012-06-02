FUNCTION rmc_radius,dim 
;+
; NAME: rad
;
;
;
; PURPOSE: creates a dim X dim array fo the radius of the different
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
; OUTPUTS:  radi: array containing radiusvalues for array with
;           dimension dim in pixel units
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
; EXAMPLE:   radius = rad(10)
;             
;
;
; MODIFICATION HISTORY:
;   Version 1.0, 2001.09.05, Slawomir Suchy, slawo@astro.uni-tuebingen.de
;       Initial Revision.
;   $Log: rmc_radius.pro,v $
;   Revision 1.2  2002/05/21 13:13:30  slawo
;   Add $Log$ in Modification history
;
;-   
   ;; erstellt array der Dimension dim 
   radi = dblarr(dim,dim) 
   
   ;; drehi,drehk sind positionen der Drehachse
   drehi = dim - 0.5
   drehk = (dim/2.) - 0.5
   

   kt=drehk-findgen(dim)
   it=drehi-findgen(dim)

   ;; Schleife geht durch komplettes Array und berechnet einzelne
   ;; Radien
   ;; i ist vertikal, k ist horizontal
   FOR k = 0,dim-1 DO BEGIN
       radi[k,*]=sqrt(kt[k]^2.+it[*]^2.)
   END
   ;; output in  pixeleinheiten
   return,radi
   stop
END






