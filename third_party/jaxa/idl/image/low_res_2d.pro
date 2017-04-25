;+
; Project     : HESSI
;
; Name        : low_res_2d
;
; Purpose     : create a low resolution 2d image by removing every n'th pixels
;
; Category    : imaging, utility
;
; Explanation : 
;
; Syntax      : out=low_res_2d(in,nx,ny)
;
; Examples    :
;
; Inputs      : IN = 2d array
;               NX = # of pixels in x-dim to skip
;               NY = # of pixels in y-dim to skip
;
; Opt. Inputs : None
;
; Outputs     : OUT = reduced resolution array
;
; Opt. Outputs: None
;
; Keywords    : ERR = error string
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 April 1999, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-


function low_res_2d,a,n1,n2,err=err

on_error,1

err=''
if (not exist(n1)) or (n_params() gt 3) then begin
 err='input error'
 pr_syntax,'out=low_res_2d(in,nx,ny)'
 if exist(a) then return,a else return,-1
endif

if data_chk(a,/ndim) ne 2 then begin
 err='input array must be 2-d'
 message,err,/cont
 if exist(a) then return,a else return,-1
endif


nx=data_chk(a,/nx)
subx=lindgen(nx)*(abs(n1) > 1)
okx=where(subx lt nx,count)

if count lt 2 then begin
 err='output x-dim has less than 2 elements'
 message,err,/cont
 return,a
endif

if not exist(n2) then n2=n1
ny=data_chk(a,/ny)
suby=lindgen(ny)*(abs(n2) > 1)
oky=where(suby lt ny,count)

if count lt 2 then begin
 err='output y-dim has less than 2 elements'
 message,err,/cont
 return,a
endif

temp=a(*,suby(oky))
return,temp(subx(okx),*)

end

