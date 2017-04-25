;+
; Name: make_xarr
; 
; Purpose: Make an array with specified lo and high values, and number of steps or stepsize, evenly 
;   spaced linearly or logarithmically
; 
; Input keywords:
;  xlo - low value for x array. Default is 1.
;  xhi - high value for x array. Default is 1000.
;  xstep - step size. Default is 1.
;  nx - number of values (if set, this takes precedence over xstep)
;  log - if set, values are evenly spaced in log space. Default is 0
;  
; Output:
;  Returns an array of values
;  
; Written: 8-Jul-2014, Kim Tolbert
; 
;-

function make_xarr, xlo=xlo, xhi=xhi, xstep=xstep, nx=nx, log=log

checkvar, xlo, 1.
checkvar, xhi, 1000.
checkvar, xstep, 1.
checkvar, log, 0

if keyword_set(log) then begin
  if keyword_set(nx) then xstep = (alog10(xhi) - alog10(xlo)) / nx else nx = 1. + (alog10(xhi) - alog10(xlo)) / xstep
  xarr = 10.^(alog10(xlo) + findgen(nx)*xstep)  
endif else begin
  if keyword_set(nx) then xstep = (xhi - xlo) / (nx-1) else nx = 1. + (xhi - xlo) / xstep
  xarr = xlo + findgen(nx)*xstep
endelse

return, xarr
end