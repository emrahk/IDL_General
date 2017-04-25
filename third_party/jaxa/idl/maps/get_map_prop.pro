;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_PROP
;
; Purpose     : extract map properties
;
; Category    : imaging
;
; Syntax      : prop=get_map_prop(map,/prop_name)
;
; Inputs      : MAP = image map
;
; Opt. Inputs : PROP = prop name can optionally be entered as argument
;
; Outputs     : PROP = extracted property
;               (e.g. xc=get_map_prop(map,/xc) to extract map center
;
; Keywords    : ERR = error string
;               FOUND = 1/0 if found/not found
;               INDEX = index location of property
;               DEF = def property value to return
;
; History     : Written 16 April 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_prop,map,prop,_extra=extra,err=err,found=found,quiet=quiet,$
                  index=index,def=def

;dprint,'% GET_MAP_PROP: ',get_caller()

err=''
found=0 & index=-1
ok1=valid_map(map,err=err,old=old_format)
sz=size(extra)
etype=sz[n_elements(sz)-2]
ok2=ok1 and ((etype eq 8) and (n_params() eq 1))
sz=size(prop)
stype=sz[n_elements(sz)-2]
ok3=ok1 and ((n_params() eq 2) and (stype eq 7))

if ~ok2 and ~ok3 then begin
 pr_syntax,'prop=get_map_prop(map,prop,[/xc,/yc,/id,/time,/xp,/yp])'
 return,-1
endif

if ok3 then tags=strupcase(trim(prop)) else if ok2 then tags=tag_names(extra)
if n_elements(tags) gt 1 then begin
 err='cannot handle more than one keyword'   

 message,err,/cont
 return,-1
endif
 
;-- data properties

found=1
index=where(strpos(tags,'NX') gt -1,count)
if count gt 0 then return,data_chk(map[0].data,/nx)

index=where(strpos(tags,'NY') gt -1,count)
if count gt 0 then return,data_chk(map[0].data,/ny)

index=where(strpos(tags,'DR') gt -1,count)
if count then return,[min(map.data),max(map.data)]

index=where(strpos(tags,'XP') gt -1,count)
if count then return,get_map_xp(map)

index=where(strpos(tags,'YP') gt -1,count)
if count then return,get_map_yp(map)

index=where(strpos(tags,'XR') gt -1,count)
if count then return,get_map_xrange(map)

index=where(strpos(tags,'YR') gt -1,count)
if count then return,get_map_yrange(map)
       
;-- spacings

mspace=get_map_space(map)
index=where(strpos(tags,'SPA') gt -1,count)
if count gt 0 then return,mspace

index=where(strpos(tags,'DX') gt -1,count)
if count then return,mspace[0]

index=where(strpos(tags,'DY') gt -1,count)
if count then return,mspace[1]

;-- center

mcenter=get_map_center(map)
index=where(strpos(tags,'CEN') gt -1,count)
if (count gt 0) and (strlen(tags[0]) le 6) then return,mcenter

index=where(strpos(tags,'XC') gt -1,count1)
if count1 then return,mcenter[0]

index=where(strpos(tags,'YC') gt -1,count1)
if count1 then return,mcenter[1]

;-- check for roll parameters

index=where(strpos(tags,'ROLL_C') gt -1,count1)
if count1 and tag_exist(map,'ROLL_CENTER') then return,map.roll_center 

index=where(strpos(tags,'ROLL') gt -1,count1)
if count1 and tag_exist(map,'ROLL_ANGLE') then return,map.roll_angle
       
prop=tags[0]
present=grep(prop,tag_names(map),index=index,/exact)
if index[0] gt -1 then return,map.(index[0]) else begin
 found=0
 if ~keyword_set(quiet) and ~exist(def) then message,prop+' property undefined',/cont
endelse
if exist(def) then return,def else return,-1
end



