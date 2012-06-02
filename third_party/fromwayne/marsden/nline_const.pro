pro nline_const,x,a,f,tlive,wm,pder
;***********************************************************
; Program is n gaussian lines + constant offset
; Model parameters are:
; a(0).............constant offset
; a(i).............Line i: normalization
; a(i+1)...........  "  "  centroid
; a(i+1)...........  "  "  sigma
; tlive is the livetime for the model weights wm 
; First construct function:
;***********************************************************
num_lines = (n_elements(a) - 1)/3
if (num_lines le 0) then num_lines = 0
const = a(0)
f = replicate(0.,n_elements(x))
p = 3.1415962
s2 = sqrt(2.*p)
for i = 0,num_lines - 1 do begin
 ndx = 3*i+1
 arg = (x - a(ndx+1))/a(ndx+2)
 f = f + (1./s2)*(a(ndx)/a(ndx+2))*exp(-.5*arg^2)
endfor
f = f + const
wm = replicate(1.,n_elements(x))
nz = where(f ne 0.)
df = sqrt(abs(f)/tlive)
wm(nz) = 1./(df(nz))^2
;***************************************************************
; Analytic derivatives
;***************************************************************
pder = fltarr(n_elements(x),n_elements(a))
pder(*,0) = 1.
for i = 0,num_lines-1 do begin
 ndx = 3*i + 1
 arg = (x - a(ndx+1))/a(ndx+2)
 pder(*,ndx) = (1./s2)*(1./a(ndx+2))*exp(-.5*arg^2)
 pder(*,ndx+1) = (1./s2)*(a(ndx)/a(ndx+2)^2)*arg*exp(-.5*arg^2)
 t1 = -1.*(1./s2)*(a(ndx)/a(ndx+2)^2)*exp(-.5*arg^2)
 pder(*,ndx+2) = t1 + (1./s2)*(a(ndx)/a(ndx+2)^2)*arg^2*exp(-.5*arg^2)
endfor
;**********************************************************************
; Thats all ffolks
;**********************************************************************
return
end
