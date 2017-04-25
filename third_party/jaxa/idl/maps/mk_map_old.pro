;+
; Project     : SOHO-CDS
;
; Name        : MK_OLD_MAP
;
; Purpose     : convert new format map to old format
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : new=mk_map_old(map)
;
; Examples    :
;
; Inputs      : MAP = map structure with new format
;
; Opt. Inputs : None
;
; Outputs     : OMAP = map structure with old format
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
; History     : Written 16 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_map_old,map,err=err

on_error,1
err=''

if not valid_map(map,old=old,err=err) then begin
 pr_syntax,'omap=mk_map_old(map)'
 return,-1
endif

if old then begin
 message,'already using old format',/cont
 return,map
endif

for i=0,n_elements(map)-1 do begin
 xp=get_map_prop(map(i),/xp)
 yp=get_map_prop(map(i),/yp)
 tmp=rem_tag(map(i),['xc','yc','dx','dy'])
 tmp=add_tag(tmp,xp,'xp',index='data')
 tmp=add_tag(tmp,yp,'yp',index='xp')
 omap=merge_struct(omap,tmp)
endfor

return,omap & end


