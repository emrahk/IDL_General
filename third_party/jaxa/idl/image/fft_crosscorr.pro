;+
; NAME: fft_crosscorr
;
; PURPOSE
; Computes the cross correlation of two real arrays A and B (same size)
;
; INPUTS:
;  A, B = floating point arrays (1-D or 2-D) of equal size
;
; OUTPUTS:
;  cc = cross correlation of (A,B) -- a complex array, size of A & B
;
; EXAMPLE:
;  a=shift(dist(256),128,128) & b=a
;  c=crosscorr(a,b)
;  tvscl,shift(c,128,128)

; VERSION HISTORY
;  schmahl@hessi.gsfc.nasa.gov 2002
;-

function fft_crosscorr,A,B

f=A-mean(A)
g=B-mean(B)
cc=fft(fft(f,1)*conj(fft(g,1)),-1)
c1=total(f^2)
c2=total(g^2)
cc=cc/sqrt(c1*c2)

return,cc
end
