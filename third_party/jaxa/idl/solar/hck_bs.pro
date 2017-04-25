;+
; NAME:
;     HCK_BS
; PURPOSE:
;     Evaluate formulae in Hudson, Canfield, and Kane 
;       ("Indirect estimation of energy deposition by non-thermal 
;       electrons in solar flares", Solar Phys. 60, 137-142, 1978)
; CATEGORY:
; CALLING SEQUENCE:
;     print, hck_bs(slope)
;     print, hck_bs(3.5, /energy) * 20. will give you the ergs/s in electrons
;       for an observed slope of 3.5 and 20-keV flux of 20/cm^2.s.keV
; INPUTS:
;     slope, the slope of the observed spectral number flux
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;     thick or thin, if in doubt about the difference 
;     energy, switches to ergs instead of particle numbers
;     verbose, spells it out for you
; OUTPUTS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; MODIFICATION HISTORY:
;    Written Jan. 13, 2000 (HSH)
;    May 8, 2001, added thin-target domain (HSH) and verboseness
;    May 8, 2001, added energy formulae 
;-
function hck_bs, slope, thin = thin, verbose = verbose, energy = energy
b = slope^2 * (slope-1)^2 * beta(slope - .5, 1.5)
bigc = (slope-1) * beta(slope-2,.5)
if keyword_set(energy) eq 0 then begin
  if keyword_set(thin) eq 0 then begin
    result = 3.28e33 * b/slope
    if keyword_set(verbose) then begin
      print,''
      print,'Thick-target number case, (dn_20/dt)/Phi_20):'
      print, result
      print,''
    endif
    return, result
  endif else begin
    result = 9.4e33 * bigc / (slope-1.5)
    if keyword_set(verbose) then begin
      print,''
      print,'Thin-target number case, N_20*n_e_10/Phi_20;'
      print,'  (note that it is for n_e_10 assumed target density)'
      print,result
      print,'  
    endif
    return, result
  endelse
endif else begin
  if keyword_set(thin) eq 0 then begin
    result = 1.05e26 * b/(slope-1)
    if keyword_set(verbose) then begin
      print,''
      print,'Thick-target energy case, (P_20)/Phi_20):'
      print, result
      print,''
    endif
    return, result
  endif else begin
    result = 3.01e26 * bigc / (slope-2.5)
    if keyword_set(verbose) then begin
      print,''
      print,'Thin-target energy case, W_20*n_e_10/Phi_20;'
      print,'  (note that it is for n_e_10 assumed target density)'
      print,result
      print,'  
    endif
    return, result
  endelse
endelse
end
