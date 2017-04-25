pro ssw_apkpbar,time0, time1, _extra=_extra,label=label, $
   tickpos=tickpos, ticklen=ticklen, debug=debug, thick=thick, $
   nofirst=nofirst, estimated=estimated, labcolor=labcolor, labpos=labpos, $
   labove=labove, lbelow=lbelow, blank=blank

;
;+
;   Name: ssw_apkpbar
; 
;   Purpose: annotate utplot with ap/kp index colorbar
;
;   Input Paramters:
;      time0, time1 - optional time range - default is current UTPLOT
;
;   Keyword Paramters:
;      tickpos,ticklen,thick,labcolor,labpos - per evt_grid.pro definitions
;      label - if set, annotate color bars with level
;      labove/lbelow (implies /LABEL) - relative label positions (def=/labove)
;      blank - if set, blank area around annotation
;
;   History:
;     9-mar-2005 - S.L.Freeland - annotate some space weather/latest events
;    14-mar-2005 - S.L.Freeland - auto-scale label positions w/respect to bars 
;   
;   Side Effects:
;     clobbers 1st 15 r,g,b indices
;-
case 1 of 
   n_elements(blank) eq 0: noblank=1
   blank eq 1: background=!p.background
   else: background=blank
endcase
debug=keyword_set(debug)
label=keyword_set(label) or keyword_set(labove) or keyword_set(lbelow)
lbelow=keyword_set(lbelow)
labove=1-lbelow

if n_params() lt 2 then begin 
   get_utevent,t0,t1,/ut
   if n_elements(t0) eq 0 then begin
      box_message,'No existing utplot - make one or supply time range...'
      return
   endif
endif else begin 
   t0=time0
   t1=time1
endelse

last7=ssw_deltat(t0,reltime(/now),/days) le 7 
apkpind=ssw_getapkp(t0,t1,last7=last7)
if keyword_set(nofirst) then apkpind=apkpind(1:*)

if not data_chk(apkpind,/struct) then begin 
   box_message,'Cannot retrieve indices, returning..'
   return
endif

ssw_lclimit_colors
if keyword_set(estimated) then $  
   kp=gt_tagval(apkpind,/estap,missing=0.) else $
   kp=gt_tagval(apkpind,/kp,missing=gt_tagval(apkpind,/k,missing=0.))

if total(kp) eq 0 then begin
   box_message,'cannot derive index..., returning...
   return
endif 

; map index->temperature
ssw_lclimit_colors,kp,kpout
 
if n_params() eq 2 then begin  ; no utplot assumed
   utplot,apkpind,kp,psym=10,color=5,background=11,/ystyle,/xstyle
endif
 
if keyword_set(label) then labels=strtrim(kp,2)
dtdays=ssw_deltat(t0,t1,/days)
if not keyword_set(thick) then thick=20./(dtdays/6)
if not keyword_set(tickpos) then tickpos=.9
if not keyword_set(ticklen) then ticklen=.05
if not keyword_set(labpos) then $
   labpos=tickpos + (([-1,1])(labove)*(.5*ticklen + .0175) )
labsize=.7

evt_grid,apkpind,color=kpout,thick=thick, $
   tickpos=tickpos, ticklen=ticklen, labcolor=labcolor, $
   labsize=labsize, labpos=labpos, label=labels ,$
   no_blank =noblank,background=background
if debug then stop
return
end
