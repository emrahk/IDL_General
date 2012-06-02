pro fit_brpl,p,p_err,f_b,a,fit,guess,sig,rmsi,xwin=xwin,ywin=ywin,plty=plty


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

modelname = 'brk_pow' ; the model name should also go here

; This is just so the error bars on the plot look right
fix1 = p-p_err ; where
fix2 = p
g = where(fix2 gt 0)
b = where(fix1 lt 0)

!x.style = 1
!y.style = 1

cont=0
while cont eq 0 do begin

ploterror, f_b(g), p(g), p_err(g),psym = 10, $
  xrange = [xl,xu],$
  yrange = [yl,yu], /ylog,$
  xtitle = 'Frequency (Hz)', /nohat, $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', /xlog,$
  charsize = 2.0, charthick = 2.0,/xstyle,/ystyle
  ;xtickname=['0.01','0.1','1','10','100']


;fixup, b, f_b, p, p_err

;determine dynamical range



if keyword_set(plty) then begin
  n=1000000L
  rat=max(f_b)/double(n)
  x=f_b(0)+rat*findgen(n)
endif else begin
  n = 100000L
  rat=max(f_b)/double(n)
  x = f_b(0)+rat*findgen(n)
endelse

g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 

f=fltarr(n_elements(x))
f(g1) = a(0) 
f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) 

oplot, x, f, thick = 2

; plotting individual components
c1_1 = a(0) 
oplot, [f_b(0),max(x(g1))], [c1_1,c1_1],linestyle = 2, thick = 1
c1_2 = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))
oplot, x(g2), c1_2, linestyle = 2, thick = 1

 print,'which parameter you want to change, or 3 to exit'
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
  
  3: cont=1
endcase

endwhile

guess=a
read, 'Type 1 to save to ps: ', kk
if (kk eq 1) then set_plot, 'ps'
if (kk eq 1) then device, filename = 'idl.ps'
if (kk eq 1) then device, yoffset = 6.0
if (kk eq 1) then device, ysize = 14.5

ploterror, f_b(g), p(g), p_err(g),psym = 10, $
  xrange = [xl,xu],$
  yrange = [yl,yu], /ylog,$
  xtitle = 'Frequency (Hz)', /nohat, $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', /xlog,$
  charsize = 2.0, charthick = 2.0,/xstyle,/ystyle
  ;xtickname=['0.01','0.1','1','10','100']

;fixup, b, f_b, p, p_err

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

g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 

f=fltarr(n_elements(x))
f(g1) = a(0) 
f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) 

oplot, x, f, thick = 2

; plotting individual components
c1_1 = a(0) 
oplot, [f_b(0),max(x(g1))], [c1_1,c1_1],linestyle = 2, thick = 1
c1_2 = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))
oplot, x(g2), c1_2, linestyle = 2, thick = 1

; calculating fractional rms amplitudes
rms_brpl_er,a(0),a(1),a(2),sigmaa(0),sigmaa(1),sigmaa(2),rm,rme
print, 'broken pow law'
print, 'frac_rms = ', rm, rme
print, 'break f = ', a(1), sigmaa(1)
print, 'level = ', a(0), sigmaa(0)
print, 'index = ', a(2), sigmaa(2)
print, 'chi^2 =', total(chi),dof,total(chi)/dof

rmsi=[rm,rme]

read, 'Type 1 to show residuals: ', jj
if (jj eq 1) then window, 1
if (jj eq 1) then plot_oi, f_b, chi, psym = 10, xtitle = 'Frequency (Hz)', ytitle = 'Chi!U2!N', charsize = 2, charthick = 2, xrange = [xl,xu]
if (jj eq 1) then oplot, [1.e-5,1.e5],[0,0],linestyle = 1, thick = 2

if (kk eq 1) then device, /close
if (kk eq 1) then set_plot, 'x'
!p.multi = 0
sig=sigmaa
fit=a

end
