;+
; NAME:
;	plotltc
; PURPOSE:
;	plot light curve
; CATEGORY:
;       plotting
; CALLING SEQUENCE:
;	plotltc,t,y,utbase
; INPUTS:
;       x = time axis
;       y = data array
;       utbase = UTBASE of data (string for SMM UTPLOT, float for YOHKOH)
; KEYWORDS:
;       ebar = data uncertainties 
;       /log = plot lightcurve on logarithmic scale
;       /draw = plot window may be a DRAW widget
;       /over = overplot lightcurves
; PROCEDURE:
;	uses UTPLOT
; MODIFICATION HISTORY:
;	Written by DMZ (ARC) Jan'92
;       May'94, DMZ, added keyword inheritance
;-

pro plotltc,x,y,utbase,ebar=ebar,log=log,gang=gang,$
                draw=draw,over=over,interval=interval,_extra=extra

common wind,wval

multi=!p.multi

err=0
if (n_elements(x) lt 2) or (n_elements(y) lt 2) then err=1
if not err then begin
 if (min(x) eq max(x)) or (min(y) eq max(y)) then err=1
endif

if err then begin
 plabels='NO DATA TO PLOT'
 plot,[0,1] & oplot,[1,0]
 message,plabels,/cont
 return
endif

;--defaults

xtitle='TIME (UT)'
if (not keyword_set(over)) then over=0 else over=1
if keyword_set(log) then ytype=1 else ytype=0

;-- open an X-Window?

if (!d.name eq 'X') and (not keyword_set(draw)) and (not over) then begin
 if n_elements(wval) eq 0 then wval=!d.window                
 if (!d.window gt 31) or (!d.window lt 0) then begin
  window,retain=2,xsize=640,ysize=640,xpos=1024-640,ypos=864-640,/free
  wval=!d.window
 endif
endif

;-- gang plots?

case n_elements(gang) of
  0 : do_nothing=1
  1 : begin
       if gang eq 0 then !p.multi=0 else !p.multi([1,2])=gang
      end
 else:!p.multi([1,2])=gang(0:1) 
endcase

xb=x & yb=y & np=n_elements(x)
diff=xb(1:*)-xb
nok=where(diff lt 0,count)
if count gt 0 then xb(nok(0)+1:*)=xb(nok(0)+1:*)+24*3600.

if keyword_set(interval) then begin
 xb=(transpose(reform([xb,xb+interval],np,2)))(*)
 yb=(transpose(reform([yb,yb],np,2)))(*)
endif

if over then oplot,xb,yb,_extra=extra else begin
 utplot,xb,yb,utbase,xtitle=xtitle,ytype=ytype,_extra=extra
endelse

if (!d.name eq 'X') and (not keyword_set(draw)) then wshow,wval,1

;--errors

if keyword_set(ebar) then begin
 if keyword_set(interval) then begin
  xb=rebin(xb,np) & yb=rebin(yb,np)
 endif
 eplot,xb,yb,ey=ebar
endif

return & end
  
