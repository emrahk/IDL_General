;+
; NAME: mean_stdev
; PURPOSE:
;   Find first, second and third moments of a set of data points
; Input:
;  x - x values corresponding to f array
;  f - array of values at each x
; Output keywords:
;  me - mean
;  st - standard deviation
;  kurt - kurtosis
;  
; WRITTEN: ~May 2008, Kim Tolbert 
;-
pro mean_stdev, x,f,me=me,st=st, kurt=kurt

;mom = moment (x * f / total(f) )
;me1 = mom[0] * n_elements(x)
;st1 = sqrt(mom[1])

me = total(x*f)/total(f)
mom = moment ( (x - me)*f/max(f) )
;st2 = sqrt(mom[1])

p = f/total(f)
var = total((x-mean(x))^2d*p)
st = sqrt(var)

nx = n_elements(x)
a = ( total ( (x-me)^3.d * f/max(f) ) / nx)
kurt = abs(a) ^ (1./3.)
if a lt 0. then kurt = -kurt
;help,me1,st1,me,st2,st3
;st3 = sqrt ( total ( (x-me)^2.d * f/max(f) ) / nx)

end
