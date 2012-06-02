function deltat,p,t,rel=rel
;+
; NAME:               
;                      DELTAT
;
;
; PURPOSE:             
;                      function which returns the expected time resolution of a
;                      periodogram or similar for a given period as
;                      derived from the total length of the
;                      observation ("timebase")
;
;
;
; CATEGORY: 
;                      helpers: estimate for fourier transform
;
;
; CALLING SEQUENCE:    
;                      result = deltat( period_of_interest, total_timebase [,/rel] )
;
;
; INPUTS:
;                      p (period_of_interest): period at which time
;                                              resolution of
;                                              periodogram is to be
;                                              evaluated  
;                      t (total_timebase):     total length of run
;                                              ("timebase") 
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;                      rel: if set, return relative resolution instead
;                           of absolute one 
;
;
; OUTPUT:
;                      time resolution if periodogram is given over
;                      period instead of over frequency (which would
;                      be the more natural way)
;                      beware that this is NOT the time resolution of
;                      the original lightcurve, i.e. the sampling
;                      rate (which would give us something like the
;                      shortest measurable period), but rather a
;                      measure of how exactly you can determine a
;                      given period!
;
; OPTIONAL OUTPUTS:
;                      relative value instead of absolute one if requested
;
;
; COMMON BLOCKS:       
;                      none
;
;
; SIDE EFFECTS:
;                      none that I can think of
;
;
; RESTRICTIONS:
;                      none that I can think of
;
;
; PROCEDURE:
;                      determine frequency resolution from timebase:
;                         deltanu = 1/t 
;                      first point: 
;                         p = 1 / (1/p) = p
;                      second point (separated by what corresponds to
;                      deltanu): 
;                         p-deltat = 1 / (1/p + deltanu) 
;                                  = 1 / (1/p + 1/t)
;                                  = p*t / (t + p)
;                      then separation is given by
;                           deltat = p - (p-deltat) 
;                                  = p - p*t / (t + p)
;                                  = p * (1-t/(t+p))
;
; EXAMPLE:
;                      t=findgen(864000)     
;                      plot,t/86400.,deltat(12116,t)
;
;           shows how delta t for a period of 12116 sec gets smaller 
;           the more days the observations has (from 1 to ten days)
;
;           similarly, 
;
;                      plot,t/86400.,deltat(12116,t,/rel)
;
;           shows how the relative error decreases (to below 3% after ten days)
;
;
; MODIFICATION HISTORY:
;                      Version 1.0 2001/07/25 Sonja L. Schuh                    
;-

  p=double(p)
  t=double(t)
  
  dt = 1.d - t/(t+p)
  IF NOT KEYWORD_SET(rel) THEN dt = dt*p 
  
  return, dt
  
END
