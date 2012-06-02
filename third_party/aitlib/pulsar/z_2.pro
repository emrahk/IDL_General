pro z_2,time,n,f,z_sq,pdot=pdot,ppdot=ppdot,fdot=fdot,ffdot=ffdot
;****************************************************************
; Program calculates the Z^2_{n} statistic (Buccheri et al.,
; A&A,128,p245), which iis a good test for harmonic content
; of a data set, independent of binning. The variables are:
;    time................array of event times (s)
;       n................number of harmonics
;    z_sq................the statistic
;       f................frequency (1/s)
;    pdot................first period derivative
;   ppdot................second period derivative
;    fdot................first frequency derivative
;   ffdot................second frequency derivative
; Uses program frac_phase.pro
; Note : z-squared statistic is distributed like chi-squared for
; 2*n degrees of freedom. First do usage:
;*****************************************************************
if (n_params() eq 0)then begin
   print,'USAGE:Z_2,TIME,N,F,Z_SQ,[PDOT=],[PPDOT=],[FDOT=],[FFDOT=]'
   return
endif
;*****************************************************************
; Set some variables
;*****************************************************************
f = double(f)
len = n_elements(time)
kk = dindgen(n) + 1d
nnn = replicate(1d,n)
;*****************************************************************
; Now calculate the fractional phase and the z^2 statistic
;***************************************************************** 

tt = nnn#time
frac_phase,f,tt,frac,pd=pdot,pp=ppdot,fd=fdot,ff=ffdot,/inplace

frac = 2d*!DPI*(kk#replicate(1d,len))*temporary(frac)
c = cos(frac)#replicate(1d,len)
s = sin(frac)#replicate(1d,len)
z_sq = (2./float(len))*total(c^2 + s^2)
;;frac=' '

;*****************************************************************
; Thats all ffolks
;*****************************************************************
return
end


