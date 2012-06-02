pro pwrlw,x,a,f,wm,pder
;***********************************************************
; Program is power law function
; Model parameters are:
; a(0).............power law normalization
; a(1).............     "    spectral index
; wm are model weights
; First construct function:
;***********************************************************
num_lines = (n_elements(a) - 2)/3
if (num_lines le 0) then num_lines = 0
pwrlaw = a(0)*x^a(1)
f = pwrlaw
nz = where(f ne 0.)
wm = replicate(1.,n_elements(x))
wm(nz) = 1./(sqrt(f(nz)))^2
;***************************************************************
; Analytic derivatives
;***************************************************************
pder = fltarr(n_elements(x),n_elements(a))
pder(*,0) = x^a(1)
pder(*,1) = pwrlaw*alog(x)
;**************************************************************
; Thats all ffolks
;**************************************************************
return
end
