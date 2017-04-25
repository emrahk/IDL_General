;+
; Project     : RHESSI
;
; Name        : GET_TRUE_SIZE
;
; Purpose     : Return dimensions of TrueColor data array
;
; Category    : imaging
;
; Syntax      : msize=get_true_size(data)
;
; Inputs      : DATA = TrueColor interleaved data array [3,nx,ny]
;
; Outputs     : MSIZE = [nx,ny]
;
; Keywords    : ERR = error string
;               TRUE_INDEX = 0 if not TrueColor
;                          = 1,2,3 depending on which dimension is interleaved
;
; History     : Written 20 April 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_true_size,data,err=err,true_index=true_index

true_index=0
err=''
sz=size(data)

if sz[0] eq 2 then return,[sz[1],sz[2]]
if sz[0] eq 3 then begin
 case 1 of 
  sz[1] eq 3: begin true_index=1 & return,[sz[2],sz[3]] & end
  sz[2] eq 3: begin true_index=2 & return,[sz[1],sz[3]] & end
  sz[3] eq 3: begin true_index=3 & return,[sz[1],sz[2]] & end
  else: continue=1
 endcase
endif

err='Invalid input data.'
mprint,err

return,-1
end
