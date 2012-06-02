pro hstplot,low,high,y,xtle,ytle,tle=tle,stle=stle,xrnge=xrnge,$
            yrnge=yrnge,lg=lg,ebar=ebar,charsz=charsz
;**********************************************************************
; Program makes a histogram of the data.
; Necessary because the IDL histogram sucks!!!!!!!!
; Variables are:
;        low,high...................lower,upper bin edges
;               y...................data array
;            xtle...................x plot label
;            ytle...................y plot label
;             tle...................plot title
;            stle...................plot subtitle
;           yrnge...................y plot range
;           xrnge...................x plot range
;            ebar...................array of 1 sigma errors
;              lg...................log-log plot if defined
;          charsz...................character size for labels
; First list the parameters:
;**********************************************************************
if (n_params() eq 0)then begin
   print,'USE : HSTPLOT,LOW,HIGH,Y,XTLE,YTLE,[TLE=],[STLE=],'+$
         '[XRNGE=],[YRNGE=],[LG=LG],[EBAR=],[CHARSZ=]'
   return
endif
;**********************************************************************
; Set some plotting parameters:
;**********************************************************************
!x.style=1 & !y.style=1
if (not(ks(xrnge)))then xrnge = [min(low),max(high)]
if (not(ks(yrnge)))then yrnge = [.9*min(y),1.1*max(y)]
if (ks(stle) eq 0)then stle = ''
if (ks(tle) eq 0)then tle = ''
if (ks(charsz) eq 0)then charsz=1.
len = long(n_elements(y))
;**********************************************************************
; Do machinations for postscript
;**********************************************************************
if (!d.name eq 'PS')then begin
   sz = size(image)
   xsz = !d.x_size
   ysz = !d.y_size
   xformsz = 8.5
   yformsz = 11.0
   xszmax = 6.5
   yszmax = 9.0
   xsc = xszmax/xsz
   ysc = yszmax/ysz
   sc = xsc
   if (ysc LT sc) then sc=ysc
   if (xsc LT ysc) then begin
	xff = 1.0
	yff = (yformsz-ysz*sc)/2.0
   endif else begin
	xff = (xformsz-xsz*sc)/2.0
	yff = 1.0
   endelse
   device, xs=sc*xsz, ys=sc*ysz, xoff=xff, yoff=yff, /inches
endif
;**********************************************************************
; Plot the arrays. Don't switch color and background if postscript.
;**********************************************************************
if (ks(lgy) eq 0)then begin
   if (!d.name ne 'PS')then begin
      plot,low,y,title=tle,xtitle=xtle,ytitle=ytle,subtitle=stle,$
      /nodata,yrange=yrnge,xrange=xrnge,color=!p.background,$
      background=!p.color,charsize=charsz
   endif else begin
      plot,low,y,title=tle,xtitle=xtle,ytitle=ytle,subtitle=stle,$
      /nodata,yrange=yrnge,xrange=xrnge,charsize=charsz
   endelse
endif else begin
   if (!d.name ne 'PS')then begin
      plot_oo,low,y,title=tle,xtitle=xtle,ytitle=ytle,subtitle=stle,$
      /nodata,yrange=[.1,yrnge(1)],xrange=xrnge,color=!p.background,$
      background=!p.color,charsize=charsz
   endif else begin
      plot_oo,low,y,title=tle,xtitle=xtle,ytitle=ytle,subtitle=stle,$
      /nodata,yrange=yrnge,xrange=xrnge,charsize=charsz
   endelse
endelse
;**********************************************************************
; Overplot the histogram. Don't switch color and background if
; postscript.
;**********************************************************************
a = lonarr(1)
i = a(0)
xerr = .5*(low + high)
if (!d.name ne 'PS')then begin
   for i = long(0),long(len-1) do $
   oplot,[low(i),high(i)],[y(i),y(i)],color=!p.background       
   oplot,[low(0),low(0)],[y(0),0.],color=!p.background
   oplot,[high(len-1),high(len-1)],[y(len-1),0],color=!p.background
   for i = long(1),long(len-1) do $
   oplot,[low(i),low(i)],[y(i),y(i-1)],color=!p.background
   if (ks(ebar) ne 0)then begin  
      for i = long(0),long(len)-long(1) do $
       oplot,[xerr(i),xerr(i)],[y(i)+ebar(i),y(i)-ebar(i)],$
            color=!p.background
   endif
endif else begin
   for i = long(0),long(len-1) do $
   oplot,[low(i),high(i)],[y(i),y(i)]       
   oplot,[low(0),low(0)],[y(0),0.]
   oplot,[high(len-1),high(len-1)],[y(len-1),0]
   for i = long(1),long(len-1) do $
   oplot,[low(i),low(i)],[y(i),y(i-1)]
   if (ks(ebar) ne 0)then begin
      for i = long(0),long(len)-long(1) do $
      oplot,[xerr(i),xerr(i)],[y(i)-ebar(i),y(i)+ebar(i)]
   endif
endelse      ;**********************************************************************
; Thats all ffolks
;**********************************************************************
return
end
