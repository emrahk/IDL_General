;+
; Project     : RHESSI
;
; Name        : TRUEGRID
;
; Purpose     : Wrapper around CONGRID to handle TrueColor image data
;
; Category    : imaging
;
; Syntax      : IDL> truegrid,data,nx,ny
;
; Inputs      : DATA = TrueColor interleaved data array
;               NX,NY = dimensions to resample to
;
; Outputs     : CDATA = resampled data
;
; Keywords    : ERR = error string
;
; History     : Written 7 May 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function truegrid,data,nx,ny,err=err,_extra=extra

err=''
if ~is_number(nx) || ~is_number(ny) || ~exist(data) then begin
 pr_syntax,'cdata=truegrid(data,nx,ny)'
 return,-1
endif

;-- get data size

sz=get_true_size(data,err=err,true=true)
if is_string(err) || ((sz[0] eq nx) && (sz[1] eq ny)) then return,data

case true of
 1 : return,congrid(data,3,nx,ny,_extra=extra)
 2 : return,congrid(data,nx,3,ny,_extra=extra)
 3 : return,congrid(data,nx,ny,3,_extra=extra)
 else: return,congrid(data,nx,ny,_extra=extra)
endcase

return,-1
end
