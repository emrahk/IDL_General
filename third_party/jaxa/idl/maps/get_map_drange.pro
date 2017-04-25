;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_DRANGE
;
; Purpose     : extract min/max data of map
;
; Category    : imaging
;
; Syntax      : drange=get_map_drange(map)
;
; Inputs      : MAP = image map
;
; Outputs     : DRANGE = [dmin,dmax]
;
;
; Keywords    : ERR = error string
;               XRANGE/YRANGE = coordinate ranges within to compute DRANGE
;
; History     : Written 16 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_drange,map,err=err,xrange=xrange,yrange=yrange

drange=[0.,0.]
err=''
if ~valid_map(map,err=err) then return,drange

do_sub=(n_elements(xrange) eq 2) or (n_elements(yrange) eq 2) 
np=n_elements(map)
dmin=fltarr(np) & dmax=dmin

for i=0,np-1 do begin
 count=0
 if do_sub then begin
  sub=get_map_sub(map[i],xrange=xrange,yrange=yrange,count=count)
 endif
 if count gt 0 then tmin=min(sub,max=tmax) else $
  tmin=min(map[i].data,max=tmax)
 dmin[i]=tmin & dmax[i]=tmax
endfor

return,transpose(reform([[dmin],[dmax]]))

end
