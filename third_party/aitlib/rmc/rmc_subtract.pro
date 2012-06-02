PRO rmc_subtract,messung=messung,xmax=xmax,ymax=ymax,$
                 resolution=w,fov=fov,shift=v,dim=dim,$
                 cortab=cortab,neumessung=neumessung,omegat=omegat, $
                 numpt=messpkte,estpow=estpow,alpha=alpha,radius=radius
;+
; NAME: rmc_subtract
;
;
;
; PURPOSE: subtract lightcurve with given parameters from
; original datas and calculate a new lightcurve and also a new
; correlation table
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
; CALLING SEQUENCE: rmc_subtract,messung=messung,xmax=xmax,ymax=ymax,$
;                 resolution=w,fov=fov,shift=v,dim=dim,$
;                 cortab=cortab,neumessung=neumessung,omegat=omegat, $
;                 numpt=messpkte,estpow=estpow,alpha=alpha,radius=radius
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS: messung: measured or simulated datas
;                     xmax,ymax: position of the lightcurve to
;                     subtract with
;                     resolution: resolution of the rmc system 
;                     fov:  Field of view of the RMC 
;                     shift: shift of the grids 
;                     dim: dimension of correlation array
;                     cortab: original correlation datas with dimXdim
;                     (not scaled)
;                     neumessung: new lightcurve after subtraction
;                     omegat: position of the rmc in angles
;                     numpt: Number of Datapoints
;                     estpow: estimated power of the lightcurve
;                     alpha,radius: array with radius and angle values
;                     for picture size  
;                     
;
;
; OUTPUTS:
;
;
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
; $Log: rmc_subtract.pro,v $
; Revision 1.2  2002/05/21 13:55:26  slawo
; Add comments
;
;-
   
   
    ;; Erzeugt eine einzelne Lichtkurve fuer den gewaehlten 
    ;; Maximalpunkt
    
    curve = dblarr(messpkte)
    
    radgra=*(radius)*fov/dim
    
    curve = rmc_modcurve(radius=radgra[xmax,ymax], $
                         alpha=-(*alpha)[xmax,ymax],$
                         resolution=w,omegat=*(omegat),$
                         fov=fov,shift=v,power=estpow)

    ;;Zieht Original Messkurve von angeklickter Messkurve ab
    neumessung=*messung-curve

    ;; Berechnet eine erneute Kreuzkorrelation der neuen Messkurve
    rmc_correlate,cormess=neumessung,resolution=w,fov=fov,dim=dim, $
      cortab=cortab,shift=v,omegat=*omegat,radius=*radius, $
      alpha=*alpha

    cortab = rotate(cortab,2)

END

















