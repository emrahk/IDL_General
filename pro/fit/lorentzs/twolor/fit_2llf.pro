pro fit_2llf,p,p_err,f_b,a1,a2,fit,guess,sig,rmsi,rmst,xwin=xwin,ywin=ywin,plty=plty,fvf=fvf


window, 0
if (keyword_set(xwin)) then begin
   xl = xwin(0)
   xu = xwin(1)
endif else begin
   xl = 0.01 
   xu = 512.
endelse

if keyword_set(ywin) then begin
   yl = ywin(0)
   yu = ywin(1)
endif else begin
   yl = 1.e-5 
   yu = 0.5
endelse


; Program for reading in and fitting an rms^2/Hz normalized power spectra

modelname = 'lor_2l' ; the model name should also go here

; This is just so the error bars on the plot look right
fix1 = p-p_err ; where
fix2 = p
g = where(fix2 gt 0)
b = where(fix1 lt 0)

!x.style = 1
!y.style = 1

a=[a1,a2]

cont=0
while cont eq 0 do begin

ploterror, f_b(g), p(g), p_err(g),psym = 10, $
  ;xrange = [xl,xu], /xlog,$
  yrange = [yl,yu], /ylog,$
  xtitle = 'Frequency (Hz)', /nohat, $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', /xlog,$
  charsize = 2.0, charthick = 2.0,/xstyle,/ystyle
  ;xtickname=['0.01','0.1','1','10','100']


if (b[0] ne -1) then fixup, b, f_b, p, p_err

if keyword_set(plty) then begin
  n=1000000L
  x=0.0001+0.0001*findgen(n)
endif else begin
  n = 100000
  x = 0.001+0.01*findgen(n)
endelse


den_1 = (x - a(2))^2 + (0.5*a(1))^2
den_2 = (x - a(5))^2 + (0.5*a(4))^2

f=fltarr(n_elements(x))

f= (a(0)*a(1))/(2.0*!pi*den_1) + $
   (a(3)*a(4))/(2.0*!pi*den_2)


oplot, x, f, thick = 2

; plotting individual components

c_1 = (a(0)*a(1))/(2.0*!pi*den_1)
oplot, x, c_1, linestyle = 2, thick = 1

c_2 = (a(3)*a(4))/(2.0*!pi*den_2)
oplot, x, c_2, linestyle = 2, thick = 1

 print,'which parameter you want to change, or 6 to exit'
 read,ind
 case ind of
  0: begin
     print,a(0)
     read,var
     a(0)=var
  end
  
  1: begin
     print,a(1)
     read,var
     a(1)=var
  end
  
  2: begin 
     print,a(2)
     read,var
     a(2)=var
  end 
  
  3: begin
     print,a(3)
     read,var
     a(3)=var
  end
  
  4: begin
     print,a(4)
     read,var
     a(4)=var
  end
  
  5: begin 
     print,a(5)
     read,var
     a(5)=var
  end 

  6: cont=1
endcase

endwhile

read, 'Type 1 to save to ps: ', kk
if (kk eq 1) then begin
   set_plot, 'ps'
   device, filename = 'idl.ps'
   device, yoffset = 6.0
   device, ysize = 14.5
   !p.font=0
   device,/times
endif

if keyword_set(fvf) then begin
;  ploterror, f_b(g), p(g)*f_b(g), p_err(g)*f_b(g),psym = 10, $
   ploterror, f_b, p*f_b, p_err*f_b,psym = 10, $
      xrange = [xl,xu], $
      yrange = [yl*10.,yu/10.],$
      xtitle = 'Frequency (Hz)', /nohat, $
      ytitle = 'Freq.*(rms/mean)!E2!N', /xlog,/ylog,$
      charsize = 1.5, charthick = 1.5,/xstyle,/ystyle
      ;xtickname=['0.01','0.1','1','10','100']
endif else begin
    ploterror, f_b, p, p_err,psym = 10, $
      xrange = [xl,xu],$
      yrange = [yl,yu], /ylog,$
      xtitle = 'Frequency (Hz)', /nohat, $
      ytitle = '(rms/mean)!E2!N Hz!E-1!N', /xlog,$
      charsize = 1.5, charthick = 1.5,/xstyle,/ystyle
      ;xtickname=['0.01','0.1','1','10','100']
endelse

if (b[0] ne -1) then fixup, b, f_b, p, p_err

guess=a
w = 1.0/(p_err^2)
yfit = curvefit(f_b, p, w, a, sigmaa, function_name = modelname)

array = [transpose(a), transpose(sigmaa)]
print, array

; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
dof = n_elements(f_b)-n_elements(a)
print, 'chi2 = ', total(chi)
print, 'dof = ', dof

; plotting the fit on the data
;n = 100000
;x = 0.001+0.01*findgen(n)

den_1 = (x - a(2))^2 + (0.5*a(1))^2
den_2 = (x - a(5))^2 + (0.5*a(4))^2

f=fltarr(n_elements(x))
f = (a(0)*a(1))/(2.0*!pi*den_1) + $
    (a(3)*a(4))/(2.0*!pi*den_2)

if keyword_set(fvf) then oplot,x,x*f,thick=2 else oplot,x,f,thick=2


; plotting individual components

c_1 = (a(0)*a(1))/(2.0*!pi*den_1)

if keyword_set(fvf) then begin
      oplot, x, x*c_1, linestyle = 2, thick = 1
endif else oplot, x, c_1, linestyle = 2, thick = 1

c_2 = (a(3)*a(4))/(2.0*!pi*den_2)

if keyword_set(fvf) then begin
      oplot, x, x*c_2, linestyle = 2, thick = 1
endif else oplot, x, c_2, linestyle = 2, thick = 1

; calculating fractional rms amplitudes

print, 'f_buency (1) = ', a(2), sigmaa(2)
print, 'frac_rms (1, -inf to inf) = ', sqrt(a(0)), sigmaa(0)/(2.0*sqrt(a(0)))
print, 'fwhm (1) =', a(1), sigmaa(1)

rx=a(0:2)
sx=sigmaa(0:2)

calrms,rx,sx,rms0tw,rms0inf
print, 'frac_rms (1, 0 to inf)=',rms0inf(0),rms0inf(1)
print, 'frac_rms (1, 0 to 20)=',rms0tw(0),rms0tw(1)

rmsi=rms0inf
rmst=rms0tw

print, 'f_buency (2) = ', a(5), sigmaa(5)
print, 'frac_rms (2, -inf to inf) = ', sqrt(a(3)), sigmaa(3)/(2.0*sqrt(a(3)))
print, 'fwhm (2) =', a(4), sigmaa(4)

rx=a(3:5)
sx=sigmaa(3:5)

calrms,rx,sx,rms0tw,rms0inf
print, 'frac_rms (1, 0 to inf)=',rms0inf(0),rms0inf(1)
print, 'frac_rms (1, 0 to 20)=',rms0tw(0),rms0tw(1)

rmsi=[rmsi,rms0inf]
rmst=[rmst,rms0tw]

print, 'reduced chi^2 = ', total(chi), dof, total(chi)/dof

read, 'Type 1 to show residuals: ', jj
if (jj eq 1) then window, 1
if (jj eq 1) then plot_oi, f_b, chi, psym = 10, xtitle = 'Frequency (Hz)', ytitle = 'Chi!U2!N', charsize = 2, charthick = 2
if (jj eq 1) then oplot, [1.e-5,1.e5],[0,0],linestyle = 1, thick = 2

if (kk eq 1) then device, /close
if (kk eq 1) then set_plot, 'x'
!p.multi = 0

sig=sigmaa
fit=a

end