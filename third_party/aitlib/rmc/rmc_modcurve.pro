FUNCTION rmc_modcurve,radius=radius,alpha=alpha,resolution=w, $
                      fov=fov,shift=v, $
                      power=power,omegat=omegat
;+
; NAME: rmc_modcurve
; 
;
;
; PURPOSE: creates a lightcurve for a specific radius and 
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE:
;                   radius=radius,alpha=alpha,resolution=w, $
;                   anticlock=anticlock,fov=fov,shift=v,messung=messung, $
;                   power=power
;
;
; INPUTS:
;           radius: radius for the lightcurve (pixel distance)
;           messpkte: number of points of the lightcurve
;
; OPTIONAL INPUTS:
;           
;
;
; KEYWORD PARAMETERS:
;           resolution: resolution of the rmc system 
;           fov: Field of view of the RMC
;           anticlock: for left or light circulation of the RMC
;           alpha: azimut angle for the lightcurve
;           power: power of the lightcurve 
;   
; OUTPUTS:
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
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;   Version 1.0, 2001.09.12, Slawomir Suchy, slawo@astro.uni-tuebingen.de
;       Initial Revision.
; $Log: rmc_modcurve.pro,v $
; Revision 1.2  2002/05/21 12:27:00  slawo
; Add comments
;
;-   
   IF n_elements(power) EQ 0 THEN BEGIN
       power=100.
   ENDIF
     
   ;; Berechnung der Mod.-kurve fuer alle Messpunkte 

   y = radius*sin( (!pi/180.)*(alpha-(OmegaT))) 
   drp =(0.25 + ((2./(!pi*!pi))*cos(!pi*((y/w)-v))))*power

   drepro=drp

   return,drepro
END





