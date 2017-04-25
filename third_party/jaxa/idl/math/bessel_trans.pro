function bessel_trans,f,k,r

;+
; PURPOSE:
; \int_0^{infty} f(k) J_0(kr) k dk

; the vector f  is assumed to span a subinterval k of (0,\infty)
; and is assumed to vanish outside that interval.
; No checking is done to see if f is too coarsely sampled

;INPUTS:
; k=wavenumber array
; f=function(k) to be transformed
; r=radius (scalar)
;
; outputs:
; \int_0^{infty} f(k) J_0(kr) k dk
;
; EXAMPLE:
; k=findgen(1024)/512.
; a=5.
; f=exp(-0.5*(k*a)^2)
; the transform should equal const*exp(-0.5*(r/a)^2)
;
; jt=fltarr(1024)
; r=findgen(1024)*20/1024.
; for j=0,1023 do jt(j)=bessel_trans(f,k,r[j])
; jt=jt/jt[0]
; plot,r,exp(-.5*(r/a)^2)-jt  ; should be small (< 1.e-5)

; HISTORY
; EJS aug 2002, Oct 2002  schmahl@hessi.gsfc.nasa.gov
;-

n=n_elements(f)
if n_elements(k) ne n then message,'k and f different sizes.'
kr=r*k
dk=1./(n-1.)
y=f*beselj(kr,0)*k
jtrans=total(y)*dk
;plot,k,y,psym=2
;wait,0.1

return,jtrans
end

