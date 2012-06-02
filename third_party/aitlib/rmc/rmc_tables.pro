PRO rmc_tables,radius=radius,alpha=alpha,radgrad=radgrad,fov=fov,$
               radint=radint,dim=dim
;+
; NAME: rmc_tables
;
;
;
; PURPOSE: calculate the tables for alpha and the radius with given dim
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE:
; rmc_tables,radius=radius,alpha=alpha,radgrad=radgrad,fov=fov,$ 
;               radint=radint,dim=dim 
;
;
;
; INPUTS:  dim: dimension of the output array
;          fov: Field of View of the RMC 
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
; OUTPUTS: radius,alpha: tables with angle and radius values for
;                        dimXdim array
;          radint: integervalues of radius
;          radgrad: values of radius in degrees (depends from the fov)
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
; $Log: rmc_tables.pro,v $
; Revision 1.2  2002/05/21 13:59:29  slawo
; Add comments
;
;-

   ;; Berechnung der Winkeltabelle

   alpha = fltarr(dim,dim) 
   
   ;; drehi,drehk sind Positionen der Drehachse
   IF (dim MOD 2) EQ 1 then BEGIN
       drehi = float(dim)  
       drehk = float(dim/2)
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
   
   ;; Berechnung der Radiustabelle fuer die einzelnen Pixel

   ;; erstellt array der Dimension dim 
   radius = dblarr(dim,dim) 
   
   ;; drehi,drehk sind positionen der Drehachse
   drehi = dim - 0.5
   drehk = (dim/2.) - 0.5
   

   kt=drehk-findgen(dim)
   it=drehi-findgen(dim)

   ;; Schleife geht durch komplettes Array und berechnet einzelne Radien
   ;; i ist vertikal, k ist horizontal
   FOR k = 0,dim-1 DO BEGIN
       radius[k,*]=sqrt(kt[k]^2.+it[*]^2.)
   END
   
   
   ;; kopiert radius in pixeleinheiten in IntegerEinheiten 
   radint = fix(radius+.5)
   
   ;; Radius der einzelnen Pixel in Grad
   radgrad = radius*fov/dim
   
END

