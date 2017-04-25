;+
; Project     : RHESSI
;
; Name        : GET_SUB_DATA
;
; Purpose     : Extract subarray from data
;
; Category    : imaging
;
; Syntax      : IDL> sub=get_sub_data(data,irange)
;
; Inputs      : DATA = TrueColor interleaved data array
;               IRANGE = pixel ranges to extract [xstart,xend,ystart,yend]
;
; Outputs     : SUB = subarray
;
; Keywords    : ERR = error string
;
; History     : Written 7 May 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_sub_data,data,irange,err=err

err=''
if (n_elements(irange) ne 4) then return,data
sz=get_true_size(data,true_index=true_index,err=err)
if is_string(err) then return,data

nx=sz[0]
ny=sz[1]
xstart=irange[0] > 0l
xend=irange[1] < (nx-1)
ystart=irange[2] > 0l
yend=irange[3] < (ny-1)

n1=xend-xstart+1
n2=yend-ystart+1

if (nx eq n1) && (ny eq n2) then return,data
case true_index of
 1: sdata=data[*,xstart:xend,ystart:yend]
 2: sdata=data[xstart:xend,*,ystart:yend]
 3: sdata=data[xstart:xend,ystart:yend,*]
 else: sdata=data[xstart:xend,ystart:yend]
endcase

return,sdata

end
