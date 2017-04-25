;+
; Project     : SOHO-CDS
;
; Name        : MERGE_MAP
;
; Purpose     : merge to image maps
;
; Category    : imaging
;
; Syntax      : imap=merge_map(map1,map2)
;
; Inputs      : MAP1, MAP2 = two image maps to merge
;               (MAP2 is rebinned to scale of MAP1)
;
; Outputs     : IMAP = merged map
;
; Keywords    : ERR = error strings
;               SPACE = [dx,dy] = grid spacing
;               DROTATE = set to differentially rotate MAP2 to
;                         time of MAP1
;				ADD = actually adds the maps together in the arithmetic sense.
;
; History     : Written, 13 January 1998, D. Zarro, SAC/GSFC
;               Modified, 26 June 2006, Zarro (L-3Com/GSFC)
;				6-oct-2010, richard.schwartz@nasa.gov, added ADD keyword
;
; Contact     : dzarro@solar.stanford.edu
;-

function merge_map,map1,map2,err=err,_extra=extra,space=space,drotate=drotate, add=add

err=''

if (not valid_map(map1)) or (not valid_map(map2))  then begin
 pr_syntax,'map=merge_map(map1,map2)'
 return,-1
endif

if keyword_set(drotate) then rmap=drot_map(map2,time=map1) else rmap=map2

;-- pull out data and (x,y) coordinates
;-- use pixel scale of first image as reference [unless user specifies SPACE]

unpack_map,map1,data1,xp1,yp1,dx=dx,dy=dy
unpack_map,rmap,data2,xp2,yp2

if n_elements(space) ne 2 then gspace=[dx,dy] else gspace=space

grid_xy,[xp1(*),xp2(*)],[yp1(*),yp2(*)],gx,gy,space=gspace,/preserve_area

;-- create output map

sz=size(gx)
dprint,'%MERGE_MAP: new output image dimensions: ',sz(1),sz(2)
dprint,'%MERGE_MAP: output image spacings: ',gspace(0),gspace(1)

temp=make_array(sz[1],sz[2],/byte)
temp= keyword_set(add)? temp+map1.data[0]*0b : temp
imap=rep_tag_value(map1,temp,'data')
imap=repack_map(imap,gx,gy,/no_copy)

;-- now interpolate input maps onto new output map

imap1=inter_map(map1,imap,_extra=extra,/use_min)
imap2=inter_map(rmap,imap,_extra=extra,/use_min)

imap.data=((~keyword_set(add) ? swiss_cheese(imap1.data): imap1.data) + imap2.data)

return,imap & end


