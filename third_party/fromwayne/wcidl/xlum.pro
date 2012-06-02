function xlum, dist, flux

;
;Generic Output
;
if (n_params() eq 0) then begin
    print,'USAGE: luminosity = xlum(distance,flux)'
    print,' INPUTS:  distance, in kpc'
    print,'          flux, in ergs/cm^2/s'
    print,' OUTPUTS: luminosity, ergs/s'
    print,' '
    return, 0
endif
 


;
; dist, distance to source, kpc
; flux, source x-ray flux, 10^-10 ergs/cm^2/s
;

; convert distance to cm
;
dist_cm = double(dist)*3.08567818585d21

;
; get the area of the sphere that encompases
;  area = 4 pi r^2
;
area = 4.d * !DPI * (dist_cm)^2.d

;
; calculate the luminosity
;
lum = double(flux) * area

;
; That's all folks!
;
return,lum
end

