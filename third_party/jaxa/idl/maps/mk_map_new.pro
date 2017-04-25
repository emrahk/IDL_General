;+
; Project     : SOHO-CDS
;
; Name        : MK_NEW_MAP
;
; Purpose     : convert old format map to new format
;
; Category    : imaging
;
; Syntax      : new=mk_map_new(map)
;
; Inputs      : MAP = map structure with old format
;
; Outputs     : NEW = map structure with new format
;
; Keywords    : ERR = error string
;
; History     : Written 16 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_map_new,map,err=err

err=''

if not valid_map(map,old=old,err=err) then begin
 pr_syntax,'nmap=mk_map_new(map)'
 return,-1
endif

if not old then begin
 message,'already using new format',/cont
 return,map
endif

for i=0,n_elements(map)-1 do begin
 xp=map(i).xp
 yp=map(i).yp
 xc=get_arr_center(xp,dx=dx)
 yc=get_arr_center(yp,dy=dy)
 tmp=rem_tag(map(i),'xp')
 tmp=rem_tag(tmp,'yp')
 tmp=add_tag(tmp,xc,'xc',index='time')
 tmp=add_tag(tmp,yc,'yc',index='time')
 tmp=add_tag(tmp,dx,'dx',index='time')
 tmp=add_tag(tmp,dy,'dy',index='time')
 nmap=merge_struct(nmap,tmp)
endfor

return,nmap & end


