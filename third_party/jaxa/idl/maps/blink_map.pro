;+
; Project     : SOHO-CDS
;
; Name        : BLINK_MAP
;
; Purpose     : blink two maps using XINTERANIMATE
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : blink_map,map1,map2,_extra=extra
;
; Examples    :
;
; Inputs      : MAP1,MAP2 = image map structures
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : same as PLOT_MAP
;
; Common      : None
;
; Restrictions: First map is used to set plotting scale
;               Have to be careful setting keywords.
;               For example, to plot the first map on a linear scale
;               and the second on a log use:
;                IDL> blink_map,m1,m2,log=0,log=1
;               Also, pair similar keywords when using different ones:
;                IDL> blink_map,m1,m2,log=0,log=1,limb=0,limb=1
;
; Side effects: None
;
; History     : Written 4 Jan 1999, D. Zarro, SMA/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-


pro blink_map,map1,map2,_extra=extra

@plot_map_com

if (not valid_map(map1)) or (not valid_map(map2)) then begin
 pr_syntax,'blink_map,map1,map2'
 return
endif

;-- first kill old processes

if xregistered('xinteranimate',/noshow) ne 0 then xinteranimate,/close
xkill,'xinteranimate'

;-- split off duplicate keyword options and pass duplicates into second
;   plot_map call

split_tags,extra,s1,s2

;-- plot first map

plot_map,map1,_extra=s1

;-- load into pixmap and plot second map

xinteranimate,set=[!d.x_size,!d.y_size,2]

xinteranimate,window=last_window,frame=0

plot_map,map2,_extra=s2,fov=map1

xinteranimate,window=last_window,frame=1

xinteranimate

return & end


