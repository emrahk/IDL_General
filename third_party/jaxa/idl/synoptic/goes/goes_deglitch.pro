;+
; PROJECT:
;	SDAC
; NAME: 
;	GOES_DEGLITCH
;
; PURPOSE:
;	This function finds and replaces telemetry spikes in GOES data.
;
; CATEGORY:
;	SMM, HXRBS
;
; CALLING SEQUENCE:
;	new_counts = goes_deglitch( old_flux,  RECUR=RECUR] )
;
; CALLS:
;	F_DIV, RESISTANT_MEAN,
;
; INPUTS:
;	TIME     - Time of observation, a vector, any units, any reference.
;		Used to parameterize spline interpolation.	
;       OLD_FLUX - Array of 2 chan goes fluxes with possible glitches.
;		data may be dimensioned 2 x nbins or nbins x 2
;
; OPTIONAL INPUTS:
;	WIDTH	
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORD OUTPUTS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	richard.schwartz@hxrbs.nascom.nasa.gov, 
;	based on numerous routines.  24-nov-1997.
;-


function goes_deglitch, time, old_flux, width,  ch1_bad=ch1_bad, ch2_bad=ch2_bad

checkvar, width, 5
sgoes = size(old_flux)
nchan = sgoes(0)
temp  = old_flux
if sgoes(2) eq 2 then temp = transpose( temp ) ; nchans x nbins
mask = byte((temp(0,*))(*)*0.0) + 1b
for i=0,1 do begin
	stemp = smooth( temp(i,*), width, /edge)
	resistant_mean, abs(f_div(temp(i,*)-stemp, stemp)), 3, mean, sigma, nr, wuse=wgd
	mask(0) = mask*0b
	mask(wgd) = 1b
	wbd     = where( mask ne 1, nbd )
	ngd     = n_elements(wgd)
	if ngd gt 5 and nbd ge 1 then $
	temp(i,wbd) = interpol(  (temp(i,wgd))(*), time(wgd), time(wbd))
	stemp = smooth( temp(i,*), width, /edge)
	resistant_mean, abs(f_div(temp(i,*)-stemp, stemp)), 3, mean, sigma, nr, wuse=wgd
	mask(0) = mask*0b
	mask(wgd) = 1b
	wbd     = where( mask ne 1, nbd )
	ngd     = n_elements(wgd)
	if ngd gt 5 and nbd ge 1 then $
	temp(i,wbd) = interpol(  (temp(i,wgd))(*), time(wgd), time(wbd))
	
endfor

ratio = f_div( temp(0,*), temp(1,*))
wbd  = where( ratio lt 1.0 or ratio gt 200.0, nbd)
mask(0) = mask*0b + 1b
if nbd ge 1 then mask(wbd) = 0b
wgd  = where( mask, ngd )


if ngd gt 5 and nbd ge 1 then begin
	for i=0,1 do begin
	temp(i,wbd) = interpol(  (temp(i,wgd))(*), time(wgd), time(wbd))
	endfor
	endif
return, temp
end

