PRO deadtime_simul,time,orate,nrate,seed=seed,deadtime=deadtime, $
               nonparalyzable=nonparalyzable
   
;+
; NAME:
;            deadtime_simul
;
;
; PURPOSE:
;            modify evenly binned lightcurve (given by a time array
;            and a count rate array) to take into account counting
;            statistics; reproduce the effects of paralyzable (default)
;            or nonparalyzable deadtime of a given length on the count
;            rate; return modified count rate array 
;
;
; CATEGORY:
;            timing tools
;
;
; CALLING SEQUENCE: 
;            deadtime_simul,time,orate,nrate,seed=seed,deadtime=deadtime, $
;                       nonparalyzable=nonparalyzable
; 
; INPUTS:    time  : time array of evenly binned lightcurve
;            orate : corresponding count rate array
;
;
; OPTIONAL INPUTS:
;            none
;
;	
; KEYWORD PARAMETERS:
;            seed             : if set, the generation of random
;                               numbers for the counting noise via
;                               the idl-randomu routine, depends on the
;                               given seed value    
;            deadtime         : length of deadtime, given in the same unit as
;                               the time array; if no value is given,
;                               the deadtime length is set to 0  
;            nonparalyzable   : if set, the effects of nonparalyzable
;                               deadtime are calculated; if not set,
;                               the effects of paralyzable deadtime
;                               are calculated (for an explanation of
;                               paralyzable and nonparalyzable deadtime, see:  
;                               Zhang, W., et al. 1995, Ap.J.,499, 930-935). 
;
; OUTPUTS:   
;            nrate            : count rate array corresponding to
;                               orate but modified by counting noise
;                               and deadtime (if the deadtime length
;                               is given)     
;
;
; OPTIONAL OUTPUTS:
;            none
;
;
; COMMON BLOCKS:
;            none
;
;
; SIDE EFFECTS:
;            none
;
;
; RESTRICTIONS:
;            the input lightcurve has to be equally binned and has to be
;            given in count rates (not in photon numbers)      
;
;
; PROCEDURE: 
;            uses the rndexp function 
;
; EXAMPLE:   
;            deadtime_simul,findgen(1000),sin(2*!pi*0.005*findgen(1000))  $
;                     *80.+100.,nrate,deadtime=0.001      
;
;
; MODIFICATION HISTORY:
;            Version 1.0, 1998/03/09, Katja Pottschmidt, Joern Wilms,
;                                     Sara Benlloch
;                                     (benlloch@astro.uni-tuebingen.de)   
;            Version 2.0
;                    3.0, 1998/11/27, Sara .... abs(avgdist)
;            CVS Version 1.2, 2001/03/13 Joern Wilms
;                    removed @-include statement at top to avoid IDL 
;                    compilation error
;-           



   ;;
   ;; check if the keyword giving the deadtime length is set; if it is
   ;; not set the deadtime  length is set to zero.
   ;;
   IF (n_elements(deadtime) EQ 0) THEN deadtime=0.

   ;;
   ;; for each count rate value create start and end time of
   ;; corresponding time intervall 
   ;; 
   tiv=double(time)
   IF (n_elements(tiv) EQ n_elements(orate)) THEN BEGIN
       nn=n_elements(tiv)-1
       tiv=[tiv,2.*tiv(nn)-tiv(nn-1)]
   END 
   
   ;;
   ;; Calculate modified count rate array
   ;;
   nrate=dblarr(n_elements(orate)) ;; modified count rate array
   bin=0                           ;; number of current time intervall   
   newphot=tiv(0)                  ;; last time a photon has been registered
   nextlive=0.                     ;; next time a photon is allowed to be 
                                   ;; registered    
   IF (keyword_set(nonparalyzable)) THEN BEGIN
       nphot=0             ;; number of photons in the current time interval
       FOR bin=0L,n_elements(orate)-1 DO BEGIN 
           rr=double(orate(bin))
           avgdist=1./rr   ;; average time between photon arrivals
           inside=0
           WHILE (newphot LT tiv(bin+1)) DO BEGIN 
               newphot=newphot+rndexp(avgdist,seed)
               ;; take care of nonparalyzable deadtime
               reg=0
               IF (newphot GT nextlive) THEN BEGIN 
                   IF (newphot LT tiv(bin+1)) THEN nphot=nphot+1
                   nextlive=newphot+deadtime
                   reg=1
               ENDIF 
               inside=1
           ENDWHILE  
           IF (inside EQ 1) THEN BEGIN 
               nrate(bin)=nphot/(tiv(bin+1)-tiv(bin))
           ENDIF ELSE BEGIN 
               nrate(bin)=0.
           ENDELSE   
           ;; is there already one photon in the next bin?
           nphot=reg
       ENDFOR  
   ENDIF ELSE BEGIN 
       nphot=0              ;; number of photons in the current time interval
       FOR bin=0L,n_elements(orate)-1 DO BEGIN
           rr=double(orate(bin))
           avgdist=1./rr    ;; average time between photon arrivals
           inside=0
           WHILE (newphot LT tiv(bin+1)) DO BEGIN 
               newphot=newphot+rndexp(avgdist,seed)
               ;; take care of paralyzable deadtime
               reg=0
               IF (newphot GT nextlive) THEN BEGIN 
                   IF (newphot LT tiv(bin+1)) THEN nphot=nphot+1
                   reg=1
               ENDIF 
               nextlive=newphot+deadtime               
               inside=1
           ENDWHILE
           IF (inside EQ 1) THEN BEGIN 
               nrate(bin)=nphot/(tiv(bin+1)-tiv(bin))
           ENDIF ELSE BEGIN 
               nrate(bin)=0.
           ENDELSE  
           nphot=reg
       ENDFOR  
   ENDELSE 
 
END
    









