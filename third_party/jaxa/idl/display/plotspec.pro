;+
; NAME:
;       PLOT_SPEC
; PURPOSE:
;      plot spectra
; CALLING SEQUENCE:
;      plotspec,x,y
; INPUTS:
;      x = wavelength array
;      y = data array
; KEYWORDS:
;      /bin  : value by which to bin spectrum (e.g. bin=2 will double bin data)
;      /over : to overplot successive spectra
;      /avg  : to average successive spectra
;       gang : value by which to gang plots (e.g. 2 gives 2x2; [2,3] gives 2x3)
;      /draw : alerts PLOT_SPEC that window may be a DRAW widget
;      /logx : Log x-axis
;      /logy : Log y-axis
; MODIFICATION HISTORY:     
;      DMZ (ARC) Jan'92
;      May'94, DMZ, added keyword inheritance
;-

pro plotspec,x,y,bin=bin,over=over,avg=avg,gang=gang,draw=draw,logx=logx,$
                  logy=logy,ebar=ebar,_extra=extra
common wind,wval
common last_spec,last_x,last_y,last_extra

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

;-- defaults

if keyword_set(over) then over=1 else over=0
if keyword_set(logx) then xtype=1 else xtype=0
if keyword_set(logy) then ytype=1 else ytype=0

;-- open an X-Window?

if (!d.name eq 'X') and (not keyword_set(draw)) and (not over) then begin
 if n_elements(wval) eq 0 then wval=!d.window                
 if (!d.window gt 31) or (!d.window lt 0) then begin
  window,retain=2,xsize=640,ysize=640,xpos=1024-640,ypos=864-640,/free
  wval=!d.window
 endif
endif

if over then begin 
 last_x=x & last_y=y 
 if n_elements(extra) ne 0 then last_extra=extra
endif else begin
 if !d.name ne 'PS' then delvarx,last_extra
endelse

;-- if overlay then replot latest spectrum saved in memory

if !d.name eq 'PS' and (n_elements(last_extra) ne 0) then hardon=1 else hardon=0

over:

xb=x & yb=y
if keyword_set(ebar) then eb=ebar

;-- rebin data?

if (n_elements(bin) ne 0) and (not over) then begin
 if bin gt 1 then begin
  bin=fix(bin) & xb=binup(x,-bin) & yb=binup(y,-bin) 
  if keyword_set(ebar) then eb=sqrt(binup(ebar^2,-bin)/bin)
 endif
endif

if n_elements(gang) eq 0 then gover=0 else gover=1
if not gover then !p.multi=0

;-- gang plots?

case n_elements(gang) of
  0 : do_nothing=1
  1 : begin
       if gang eq 0 then !p.multi=0 else !p.multi([1,2])=gang
      end
 else:!p.multi([1,2])=gang(0:1) 
endcase

;-- plot spectra

if (!d.name eq 'X') and (not keyword_set(draw)) then wshow,wval,1

if (not over) then begin
 plot,xb,yb,xtype=xtype,ytype=ytype,_extra=extra
endif else begin
 oplot,xb,yb,_extra=extra
endelse

;-- errors

if keyword_set(ebar) and (not over) then eplot,xb,yb,ey=eb  

;-- loop back for overlay

if hardon then begin 
 message,'hardcopying previous spectrum',/info
 x=last_x & y=last_y &
 if n_elements(last_extra) ne 0 then extra=last_extra
 hardon=0 & over=1 & goto,over 
endif            

return & end

