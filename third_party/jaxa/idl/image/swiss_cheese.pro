;+
; Project     : SOHO-CDS
;
; Name        : SWISS_CHEESE
;
; Purpose     : take an array and set every adjacent pixel to a 
;               specified value [def=0]
;
; Category    : imaging
;
; Explanation : useful for overlaying two images in a semi-transparent way
;
; Syntax      : sdata=swiss_cheese(data)
;
; Examples    :
;
; Inputs      : DATA = data array (1- or 2-d)
;
; Opt. Inputs : VALUE = value to set each adjacent pixel to [def=0]
;
; Outputs     : SDATA = modified DATA
;
; Opt. Outputs: None
;
; Keywords    : SHIFT_VALUE = set to offset setting value
;               NO_COPY = don't make new copy of data (i.e, destroy input data)
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 Oct 1997, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function swiss_cheese,data,value,shift_value=shift_value,no_copy=no_copy

on_error,1

if not exist(value) then value=0.
sz=size(data)
if (sz(0) ne 1) and (sz(0) ne 2) then begin
 pr_syntax,'sdata=swiss_cheese(data)'
 return,-1
endif

if keyword_set(no_copy) then sdata=temporary(data) else sdata=data

;-- 1-d case

if sz(0) eq 1 then begin
 nx=sz(1)
 index=indgen(nx)
 eindex=(index mod 2)
 even=where(eindex)
 odd=where(1-eindex)
 if keyword_set(shift_value) then sub=odd else sub=even
 sdata(sub)=value
 return,sdata
endif

;-- 2-d case

if sz(0) eq 2 then begin
 nx=sz(1) & ny=sz(2)
 nloop=nx < ny
 if nloop eq nx then nfixed=ny else nfixed=nx
 index=indgen(nfixed)
 eindex=(index mod 2)
 even=where(eindex)
 odd=where(1-eindex)
 for i=0,nloop-1 do begin
  if keyword_set(shift_value) then begin
   first=odd & second=even
  endif else begin
   first=even & second=odd
  endelse
  if i mod 2 then sub=first else sub=second
  if nloop eq nx then sdata(i,sub)=value else sdata(sub,i)=value
 endfor
endif

return,sdata & end

