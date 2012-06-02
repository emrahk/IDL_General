pro fit_0c_2lff,p,p_err,f_b,a1,a2,a3,ff,fit

window, 0
xl = 0.01
xu = 100
yl = 1.e-7
yu = 1.0

; Program for reading in and fitting an rms^2/Hz normalized power spectra

; model 2 is a zero centered lorentzian plus two lorentzians

modelname = 'model2_ff' ; the model name should also go here

a = [a1,a2,a3]

f_low = 0.01 & f_high = 100.0 ; limits for calculating the fractional rms amplitude

fix1 = p-p_err ; where
fix2 = p
g = where(fix2 gt 0)
b = where(fix1 lt 0)

!x.style = 1
!y.style = 1

read, 'Type 1 to save to ps: ', kk
if (kk eq 1) then set_plot, 'ps'
if (kk eq 1) then device, filename = 'idl.ps'
if (kk eq 1) then device, yoffset = 5.0
if (kk eq 1) then device, ysize = 17.0


cont=0
while cont eq 0 do begin

plot_oo, f_b(g), p(g), psym = 10, $
  xrange = [xl,xu], $
  yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 2.0, charthick = 2.0,/xstyle,/ystyle,$
  xtickname=['0.01','0.1','1','10','100']
oploterr, f_b(g), p(g), p_err(g), 3
fixup, b, f_b, p, p_err

w = 1.0/(p_err^2)

;bu kisim eklendi

 n = 100000
 x = 0.001+0.01*findgen(n)

 den0 = x^2 + (0.5*a(1))^2
 den1 = (x - a(4))^2 + (0.5*a(3))^2
 den2 = (x - ff)^2 + (0.5*a(6))^2

 f = (a(0)*a(1))/(2.0*!pi*den0) + (a(2)*a(3))/(2.0*!pi*den1) + (a(5)*a(6))/(2.0*!pi*den2)
 oplot, x, f, thick = 2

 ; plotting individual components
 c1 = (a(0)*a(1))/(2.0*!pi*den0)
 oplot, x, c1, linestyle = 1, thick = 2
 c2 = (a(2)*a(3))/(2.0*!pi*den1)
 oplot, x, c2, linestyle = 2, thick = 2
 c3 = (a(5)*a(6))/(2.0*!pi*den2)
 oplot, x, c3, linestyle = 2, thick = 2

 print,'which parameter you want to change, or 8 to exit'
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

  6: begin
     print,a(6)
     read,var
     a(6)=var
  end

  8: cont=1
endcase
endwhile

     


;bu kisim



yfit = curvefit_i(f_b, p, w, a, ff, chisqr, sigmaa, function_name = modelname)

array = [transpose(a), transpose(sigmaa)]
print, array

plot_oo, f_b(g), p(g), psym = 10, $
  xrange = [xl,xu], $
  yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 2.0, charthick = 2.0,/xstyle,/ystyle,$
  xtickname=['0.01','0.1','1','10','100']
oploterr, f_b(g), p(g), p_err(g), 3
fixup, b, f_b, p, p_err



; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
;g = where(yfit gt p)
;chi(g) = -chi(g)
dof = n_elements(f_b)-n_elements(a)
print,'chi2 = ',total((chi))
;print, 'chi2 = ', chisqr*dof
print, 'dof = ', dof

; plotting the fit on the data

n = 100000
x = 0.001+0.01*findgen(n)

den0 = x^2 + (0.5*a(1))^2
den1 = (x - a(4))^2 + (0.5*a(3))^2
den2 = (x - ff)^2 + (0.5*a(6))^2

f = (a(0)*a(1))/(2.0*!pi*den0) + (a(2)*a(3))/(2.0*!pi*den1) + (a(5)*a(6))/(2.0*!pi*den2)
oplot, x, f, thick = 2

; plotting individual components
c1 = (a(0)*a(1))/(2.0*!pi*den0)
oplot, x, c1, linestyle = 1, thick = 2
c2 = (a(2)*a(3))/(2.0*!pi*den1)
oplot, x, c2, linestyle = 2, thick = 2
c3 = (a(5)*a(6))/(2.0*!pi*den2)
oplot, x, c3, linestyle = 2, thick = 2

; calculating fractional rms amplitudes
print, 'zero centered:'
print, 'frac_rms = ', sqrt(a(0))
print, 'frac_rms_err = ', sigmaa(0)/(2.0*sqrt(a(0)))
print, 'f_buency = ', a(4)
print, 'frac_rms = ', sqrt(a(2))
print, 'frac_rms_err = ', sigmaa(2)/(2.0*sqrt(a(2)))
print, 'f_buency = ', ff,' fixed'
print, 'frac_rms = ', sqrt(a(5))
print, 'frac_rms_err = ', sigmaa(5)/(2.0*sqrt(a(5)))

read, 'Type 1 to show residuals: ', jj
if (jj eq 1) then window, 1
if (jj eq 1) then plot_oi, f_b, chi, psym = 10, xtitle = 'Frequency (Hz)', ytitle = 'Chi!U2!N', charsize = 2, charthick = 2, xrange = [xl,xu]
if (jj eq 1) then oplot, [1.e-5,1.e5],[0,0],linestyle = 1, thick = 2

if (kk eq 1) then device, /close
if (kk eq 1) then set_plot, 'x'
!p.multi = 0

fit=a
end





