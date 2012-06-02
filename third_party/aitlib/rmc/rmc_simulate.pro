FUNCTION rmc_simulate,distance=distance,azimuth=azimuth,power=staerke,$
                      resolution=w,shift=v,numpt=messpkte,fov=fov,omegat=omegat
;+
; NAME: rmc_simulate
;
;
;
; PURPOSE: simulates a modulationcurve for a number of sources to simulate
;          real datas
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: radius,azimut,staerke,resolution=w,shift=v,numpt=messpkte
;
;
;
; INPUTS:
;         radius: array of different radius for the different sources
;         azimut: array of angles for the different sources
;         staerke: array of relativ luminosity for the different
;         sources
;   
; OPTIONAL INPUTS:
;           
;
;
; KEYWORD PARAMETERS:
;           resolution: resolution of the rmc system 
;           shift: shift of the grids of the RMC
;           numpt: number of points for the modulationcurve
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
;   Version 1.0, 2001.09.05, Slawomir Suchy, slawo@astro.uni-tuebingen.de
;       Initial Revision.
;
;-
    numsrc=n_elements(distance)

    IF (n_elements(v) EQ 0) THEN BEGIN 
        v=0.
        message,'Parameter shift not given, using default of '+string(v), $
          /informational
    ENDIF 

    IF (n_elements(messpkte) EQ 0) THEN BEGIN 
        messpkte=100
        message,'Parameter numpt not set, using default of '+ $
          string(messpkte),/informational
    ENDIF 

    ;; Translationsfkt der Quellen

    ts = dblarr(messpkte)
    FOR k=0,numsrc-1 DO BEGIN 
        
        drp = rmc_modcurve(radius=distance[k],alpha=azimuth[k],$
                           resolution=w,power=staerke[k],omegat=omegat,$
                           fov=fov,shift=v)

        ts = ts + drp

    ENDFOR
    
    return,ts
END









