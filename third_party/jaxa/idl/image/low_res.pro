;+
; Project     : HESSI
;
; Name        : low_res
;
; Purpose     : create a low resolution image/vector by removing every n'th pixels
;
; Category    : imaging, utility
;
; Explanation : 
;
; Syntax      : out=low_res(in,n1,n2)
;
; Examples    :
;
; Inputs      : IN = 1- or 2-d 
;               N1 = # of pixels to skip in first dimension
;               N2 = # of pixels to skip in second dimension
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


function low_res,a,n1,n2,err=err

err=''
ndim=data_chk(a,/ndim)

if ndim eq 1 then return,low_res_1d(a,n1) else $
 if ndim eq 2 then return,low_res_2d(a,n1,n2) else begin
  err='input array must be 1- or 2-d'
  message,err,/cont
 endelse
  
if exist(a) then return,a else return,-1
end
