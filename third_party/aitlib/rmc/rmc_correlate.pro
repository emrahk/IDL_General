PRO RMC_CORRELATE,cormess=cormess,resolution=w,fov=fov, $
                  dim=dim,alpha=alpha, $
                  cortab=cortab,shift=v,radius=radius,omegat=omegat
   
;+
; NAME: rmc_correlate
;
;
;
; PURPOSE: correlate a lightcurve from a rmk and search for sources
;
;
;
; CATEGORY: IAAT RMC tools
;
;
;
;
; KEYWORD PARAMETERS:
;           resolution: resolution of the rmc system 
;           fov: Field of view of the RMC
;           cormess: copy of original lightcurve   
;           dim: dimension of correlation array
;           alpha, radius: angle and radius tables with dimension dim
;           for calculations
;           shift: shift of the grids 
;           omegat: position of the rmc in angles
;   
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;           cortab: correlation table
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
;   Version 1.0, 2001.09.11, Slawomir Suchy, slawo@astro.uni-tuebingen.de
;       Initial Revision.
;   $Log: rmc_correlate.pro,v $
;   Revision 1.2  2002/05/21 09:09:56  slawo
;   Add comments
;
;-
    
  
   
    ;; Zahl der Messpunkte
    messpkte=n_elements(cormess)

    ;; erstelle Correlationskarte
    cortab = dblarr(dim,dim)
    
    cm=cormess-mean(cormess)
    messum=sqrt(total(cm^2.))
    FOR k = 0,dim-1 DO BEGIN
        FOR i = 0,dim-1 DO BEGIN
           
            ;;berechnet die modulationskurve mit genauem radius 
            ;;zum jeweiligen pixel
            
            mk=rmc_singlemod(radius=radius[k,i],dim=dim,numpt=messpkte, $
                             resolution=w,fov=fov,shift=v,alpha=alpha[k,i], $
                             omegat=omegat)
                        
            ;; Berechnet die Kreuzkorrelation von Messung und Modulationskurve
            mk=mk-mean(mk)
            
            cortab[k,i]=total(cm*mk)/(messum*sqrt(total(mk^2.)))
        ENDFOR 
    ENDFOR
END 





