PRO dsinint, time,rate,period,ft,nbins=nbins,_EXTRA=pfold_extra
;+
; NAME:
;       dsinint
;
;
; PURPOSE:
;       Sampling density corrected integration of a sine/cosine curve and a 
;       lightcurve.
;       Before folding the lightcurve is binned into a histogram
;       running over a full period of the sine curve.
;
;
; CATEGORY:
;       timing
;
;
; CALLING SEQUENCE:
;       dsinint, time,rate,period,profile,nbins=nbins
; 
; INPUTS:
;       time    : the starting time of each rate bin
;       rate    : the count rate of each bin
;       period  : period of the sine/cosine curve to integrate with
;
; OUTPUTS:
;       ft      : integration result (i.g. the fourier transform for a
;                 frequency=1/period). A 2-dim array containing the 
;                 cosine(0) and sine(1) result of the integration.
;
; OPTIONAL INPUTS:
;       nbins   : the number of bins to use. Larger bin number
;                 increases the accuracy of the folding, but 
;                 needs more cpu resource. Must be chosen not to high
;                 for each histogrogram bin must contain at least one 
;                 time entry.
;                 Default: 20
;
;
;	
; KEYWORD PARAMETERS:

;
; OPTIONAL OUTPUTS:
 
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
;       dsinint,time,counts,error,283.,nbins=128
;
;
; MODIFICATION HISTORY:
;       Version 0.1 : 03/24/2002, EG
;                     Initial Version
;
;-

pfold,time,rate, profile, phbin=phase,period=period,$
      nbins=nbins,_EXTRA=pfold_extra

sinint=total(sin(2*!DPI*phase)*profile)
cosint=total(cos(2*!DPI*phase)*profile)
;sinint=total(profile)
;cosint=total(profile)

ft=[cosint,sinint]


END 

