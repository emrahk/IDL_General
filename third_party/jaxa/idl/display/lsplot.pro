;+
; NAME:
;	lsplot
; PURPOSE:
;	plot lightcurves of selected spectral regions
; CALLING SEQUENCE:
;	lsplot,x,y,t,utbase
; INPUTS:
;	x = 	x array (bin or wavelength)
;	y = 	set of y arrays (*, n)
;       t =     time array (sec)
; KEYWORDS:
;       rate (o) = plotted lightcurve array
;       title(i) = optional plot title
;       norm (i) = signal to normalize rate by summed bins
;       over (i) = signal to overlay successive plots
;       wave (i) = signals that X is in wavelength units
;       flux (i) = signals that Y is in flux units
;       xrange (o) = wavelength range used to produce lightcurve
; HISTORY:
;       Written Mar'93 by D. Zarro (ARC)
;-

pro lsplot,x,y,t,utbase,title=title,$
  over=over,err=err,norm=norm,rate=rate,wave=wave,flux=flux,xrange=xrange

common lsplot,sindex,lindex,sp,sx,sy,lp,lx,ly,linestyle,first

on_error,1
err=0

if n_elements(first) eq 0 then first=1
if keyword_set(wave) then wave=1 else  wave=0
if keyword_set(flux) then flux=1 else  flux=0

nok1=wave and (not flux)
nok2=flux and (not wave)
if nok1 or nok2 then begin
 message,'incompatible X-Y inputs',/contin
 err=1
endif

if keyword_set(norm) then norm=1 else norm=0
if n_elements(title) eq 0 then title=''
if keyword_set(over) then over=1 else over=0
if n_elements(linestyle) eq 0 then linestyle=-1
if wave then xtitle='ANGSTROM' else xtitle='BIN'

if flux then begin
 ytitle='PHOTONS CM-2 S-1 A-1' 
 lytitle='PHOTONS CM-2 S-1'
endif else begin
 ytitle='COUNTS PER SEC PER BIN'
 lytitle='COUNTS PER SEC'
endelse

stitle='USE CURSOR TO WINDOW SPECTRAL REGION'
if n_elements(sx) ne 0 then begin
 !x=sx & !y=sy & !p=sp
endif

if n_elements(sindex) eq 0 then wdef,sindex,retain=2 else begin
 wshow,sindex & wset,sindex
endelse

tlc=total(y,1)
find=where(tlc eq max(tlc))
if (not over) or first then begin
 linestyle=0
 plot,x,y(*,find),xtitle=xtitle,ytitle=ytitle,psym=10,title=stitle,linestyle=linestyle
 sx=!x & sy=!y & sp=!p
endif else begin
 !x=sx & !y=sy & !p=sp
 linestyle=linestyle+1 
 if linestyle gt 5 then linestyle=0
endelse

message,'use cursor to window spectral region for lightcurve plot',/contin
if !d.name eq 'X' then begin
 message,'(hit right mouse button to quit)',/contin
 quit=2
endif
pcurse,xrange,npoints=2
if n_elements(xrange) lt 2 then message,'quitting '
bin=x(*,0)
cfind=where( (bin ge min(xrange)) and (bin le max(xrange)), npt)

if wave then form='(f5.3)' else form='(i4)'
brange='RANGE: '+string(xrange(0),form)+' - '+string(xrange(1),form)

if npt eq 0 then begin
 message,'no data in selected window',/contin
 err=1
 return
endif

;-- sum for light curve
 
dbin=abs(bin(1:*)-bin)
dbin=[dbin,dbin(n_elements(dbin)-1)]
bad=where(dbin le 0,count) 
if count gt 0 then dbin(bad)=1
lnorm=total(dbin(find))

rate=reform(dbin(cfind)#y(cfind,*))

if keyword_set(norm) then rate=rate/lnorm
if n_elements(lindex) eq 0 then wdef,lindex,retain=2 else begin
 wshow,lindex & wset,lindex
endelse

if (not over) or first then begin
 if keyword_set(norm) then tytitle='<'+ytitle+'>' else tytitle=lytitle
 utplot,t,rate,utbase,xtitle='****',title=title+'  '+brange,$
  ytitle=tytitle,linestyle=linestyle
 lx=!x & ly=!y & lp=!p 
 first=0
 message,'use /OVER to overplot different lightcurves',/contin
endif else begin
 !x=lx & !y=ly & !p=lp
 oplot,t,rate,linestyle=linestyle 
endelse

if keyword_set(over) then begin
 lsplot,x,y,t,utbase,title=title,$
  over=over,err=err,norm=norm,rate=rate,wave=wave,flux=flux
endif

return & end
    


