;+
; NAME:
;	set_hard
; PURPOSE:
;	set hard copy page parameters
; CALLING SEQUENCE:
;	set_hard,orig,/port,/land,/send
; INPUTS:
;       plabels = optional additional plot labels 
; OUTPUTS:
;       none
; KEYWORDS:
;       /port = portrait mode
;       /land = landscape mode
;       /send = close existing file and send to printer
; PROCEDURE:
;       set
; MODIFICATION HISTORY:
;	May'94, written by DMZ (ARC)
;-


pro set_hard,plabels,land=land,port=port,send=send,_extra=extra,close=close

common set_hard_com,orig_dev,orig_font,sfile

on_error,1

if keyword_set(close) then device,/close

;-- print latest hard copy file

if keyword_set(send) and (n_elements(orig_dev) ne 0) and (!d.name eq 'PS') then begin
 message,'making hardcopy',/info
 nlab=n_elements(plabels) & maxy=.9 & miny=.1
 if (nlab gt 0) then begin
  if nlab eq 1 then b=0 else b=(miny-maxy)/(nlab-1) 
  for i=0,nlab-1 do xyouts,1.,maxy+b*i,plabels(i),/normal
 endif
 lzplot,sfile
 set_plot,orig_dev 
 !p.font=orig_font
 return
endif

;-- open idl.ps file

if !d.name ne 'PS' then begin

;-- first check if we can write plot file on disk
 
 sfile=mk_temp_file('idl.ps')

;-- default to landscape

 if n_elements(land) eq 0 then land=0 else land=1
 if n_elements(port) eq 0 then port=0 else port=1
 if (land eq 0) and (port eq 0) then land=1
 if land*port eq 1 then message,'cannot combine /land and /port'

;-- save original device name

 orig_font=!p.font & !p.font=0
 orig_dev=!d.name & set_plot,'PS',/copy

 if keyword_set(land) then $
  device,/land,xsize=18,ysize=18,yoff=26.,bits_per_pixel=8,_extra=extra,file=sfile
 
 if keyword_set(port) then device,ysiz=22.7,yoff=2.7,/port,bits_per_pixel=8,$
                                  _extra=extra,file=sfile

endif

return & end

