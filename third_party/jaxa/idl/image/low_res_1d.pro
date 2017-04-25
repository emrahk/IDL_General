;+
; Project     : HESSI
;
; Name        : low_res_1d
;
; Purpose     : create a low resolution vector by removing every n'th pixels
;
; Category    : imaging, utility
;
; Explanation : 
;
; Syntax      : out=low_res_1d(in,n)
;
; Examples    :
;
; Inputs      : IN = 1d vector
;               N = # of pixels to skip
;
; Opt. Inputs : None
;
; Outputs     : OUT = reduced resolution vector
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


function low_res_1d,a,n,err=err

on_error,1

err=''
if not exist(n) then begin
 err='input error'
 pr_syntax,'out=low_res_1d(in,n)'
 if exist(a) then return,a else return,-1
endif

if data_chk(a,/ndim) ne 1 then begin
 err='input array must be 1-d'
 message,err,/cont
 if exist(a) then return,a else return,-1
endif

nx=data_chk(a,/nx)

sub=lindgen(nx)*(abs(n) > 1)

ok=where(sub lt nx,count)

if count lt 2 then begin
 err='output vector has less than 2 elements'
 message,err,/cont
 return,a
endif

return,a(sub(ok)) & end

