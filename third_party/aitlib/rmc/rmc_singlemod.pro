FUNCTION rmc_singlemod,radius=radius,dim=dim,numpt=messpunkte,resolution=w, $
                       anticlock=anticlock,fov=fov,shift=v,alpha=alpha, $
                       omegat=omegat
;+
; NAME: singlemod
; 
;
;
; PURPOSE: creates a lightcurve for a specific radius
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE:
;             radius,dim=dim,messpunkte,resolution=w,
;             anticlock=anticlock,fov=fov
;
;
;
; INPUTS:
;           radius: radius for the lightcurve (pixel distance)
;           messpunkte: number of points of the lightcurve
;
; OPTIONAL INPUTS:
;           
;
;
; KEYWORD PARAMETERS:
;           dim: size of array 
;           resolution: resolution of the rmc system 
;           fov: Field of view of the RMC
;           anticlock: for left or light circulation of the RMC
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
;
;-   
   
    radgra=radius*fov/dim

    ;; fuer rot. gegen Uhrzeigersinn:
    IF (keyword_set(anticlock)) THEN OmegaT = 360. - OmegaT
    
    ;; geht in function rmc_modcurve zur Berrechnung der lichtkurve
    drp = rmc_modcurve(radius=radgra,alpha=alpha,resolution=w, $
                       fov=fov,shift=v, $
                       omegat=omegat)
       
   return,drp
END








