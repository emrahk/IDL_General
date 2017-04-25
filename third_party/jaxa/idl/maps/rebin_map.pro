;+
; Project     : SOHO-CDS
;
; Name        : REBIN_MAP
;
; Purpose     : Rebin an image map to new dimensions
;
; Category    : imaging
;
; Explanation : Rebin a map to user-specified dimensions and
;               compute new output pixel spacings
;
; Syntax      : gmap=rebin_map(map,gx,gy)
;
; Inputs      : MAP = image map structure
;               GX,GY = new dimensions
;
; Outputs     : GMAP = rebinned map
;
; Keyword     : CONGRID = set to use CONGRID instead of FREBIN 
;
; History     : Written 22 August 1997, D. Zarro, ARC/GSFC
;               29 September 2008, Zarro (ADNET) 
;                - improved memory management
;               31 March 2012, Zarro (ADNET)
;                - made /interp default
;               20 August 2013, Zarro (ADNET)
;                - switched from using CONGRID to FREBIN which
;                  conserves flux
;                - fixed computation error in dx and dy 
;               17 September 2013, Zarro (ADNET)
;                - preserved MAP data type.
;               3 November 2014, Zarro (ADNET)
;                - used double-precision 
;
; Contact     : dzarro@solar.stanford.edu
;-

function rebin_map,map,gx,gy,err=err,_extra=extra,congrid=congrid

;-- check inputs (valid map & dimensions)

if ~valid_map(map) or ~is_number(gx) then begin
 pr_syntax,'gmap=rebin_map(map,gx,gy)'
 if exist(map) then return,map else return,-1
endif
if not exist(gy) then gy=gx
ngx=nint(gx) & ngy=nint(gy)

if (ngx lt 2) or (ngy lt 2) then begin
 message,'Both binning dimensions must be greater than 1',/cont
 return,map
endif

if keyword_set(congrid) then funct='congrid' else funct='frebin'

sz=size(map[0].data)
nx=sz[1] & ny=sz[2]
if (ngx eq nx) and (ngy eq ny) then begin
 message,'No rebinning necessary',/cont
 return,map
endif

dtype=size(map[0].data,/type)
tdata=make_array(ngx,ngy,type=dtype)
gmap=rep_tag_value(map,tdata,'data',/no_copy)
gmap.dx=(map.dx)*(1.d0-nx)/(1.d0-ngx)
gmap.dy=(map.dy)*(1.d0-ny)/(1.d0-ngy)

for i=0,n_elements(map)-1 do begin
 gmap[i].data=call_function(funct,map[i].data,ngx,ngy,_extra=extra) 
endfor

return,gmap & end

