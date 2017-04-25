;+
; Project     : SDAC
;                   
; Name        : PL_SCALE
;               
; Purpose     : This function  scales distance in graphics output and multiplot environment.
;
; Use         : Result = pl_scale( d, xcorr = xcorr, ycorr=ycorr)
;
; INPUTS:
;	D	-distance in normal units for full scale plot.
; KEYWORD INPUTS:
;	YCORR	-Keyword indicating y axis scaling.
;	XCORR   -Keyword indicating x axis scaling.
;
; Examples    :
;    y1 = y1 - pl_scale(.025,/y)
;    nx1lab = nx1 + pl_scale(.0081,/xc)
;    ylab = t - pl_scale(.04,/yc)
;
; CALLS       : FCHECK
;
; Category    : GRAPHICS
; 
; MODIFICATION HISTORY:
;       Modified 8/29/94 by AES.  checks for existence of variable global
;       in scalecom.  If it exists, output multiplied by global.  Put in
;       to scale up graph labels in multiple plot.
;	Version 3, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;-

function pl_scale, d, xcorr = xcorr, ycorr=ycorr
common scalecom,global
if keyword_set(xcorr) then multiscale = 1. / (!p.multi(1) > 1) 
if keyword_set(ycorr) then multiscale = 1. / (!p.multi(2) > 1)

return, d * multiscale * fcheck(global,1)
end
