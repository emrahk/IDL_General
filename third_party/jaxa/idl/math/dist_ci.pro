;+
; PROJECT: RHESSI
;
; NAME: dist_ci  
;
; PURPOSE: Given an array of distribution values, find a credible interval for the values, i.e. the range of 
;  values containing the requested fraction of the data surrounding the peak of the distribution.  Assumes 
;  that the distribution has a single peak.
;   
; EXPLANATION: Sort the distribution. Then find the value .5*CI% from beginning, and .5*CI% from the end.
;   
; CALLING SEQUENCE: 
;   dist_ci, array, ci=ci
;  
; Input:
;  array - array of values
;  
; KEYWORDS:
;  ci = credible interval criteria (as value between 0. and 1.)
;  
; OUTPUT: Range of values defining credible interval
;
; WRITTEN: Jack Ireland, September 2009
; 
; MODIFICATIONS:
;   10-Mar-2010, Kim Tolbert. Added comments.  Added check for high index < (nh-1).
;
;-

FUNCTION dist_ci,h,ci = ci
;
; get information on the distribution, and sort it
;
nh = n_elements(h)
sorted = sort(h)
hsorted = h(sorted)

;
; calculate the locations of the tails
;
eee = 0.5*(1.0d0 - ci)
low = hsorted(nint(eee*nh))
high = hsorted(nint((1.0-eee)*nh) < (nh-1))

;
; return the limits
;
return,[low,high]
END 