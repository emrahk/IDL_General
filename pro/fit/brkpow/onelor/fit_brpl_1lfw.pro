pro fit_brpl_1lfw,p,p_err,f_b,a1,a2,fw,fit,guess


window, 0
xl = 0.01
xu = 100
yl = 1.e-5
yu = 1.

;set_plot,'ps'
;!p.font=0
;device,/times

; Program for reading in and fitting an rms^2/Hz normalized power spectra

modelname = 'brk_pow_1lfw' ; the model name should also go here

a=[a1,a2]

; This is just so the error bars on the plot look right
fix1 = p-p_err ; where
fix2 = p
g = where(fix2 gt 0)
b = where(fix1 lt 0)

!x.style = 1
!y.style = 1

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

n = 100000
x = 0.001+0.01*findgen(n)


g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 

den = (x - a(4))^2 + (0.5*fw)^2
f=fltarr(n_elements(x))
f(g1) = a(0) +  (a(3)*fw)/(2.0*!pi*den(g1))
f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) + (a(3)*fw)/(2.0*!pi*den(g2))

;f = a(0)*x^(-a(1)) + (a(2)*a(3))/(2.0*!pi*den)
oplot, x, f, thick = 2

; plotting individual components
c1_1 = a(0) 
oplot, [0.01,max(x(g1))], [c1_1,c1_1],linestyle = 2, thick = 1
c1_2 = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))
oplot, x(g2), c1_2, linestyle = 2, thick = 1

c2_1 = (a(3)*fw)/(2.0*!pi*den(g1))
oplot, x(g1), c2_1, linestyle = 2, thick = 1
c2_2 = (a(3)*fw)/(2.0*!pi*den(g2))
oplot, x(g2), c2_2, linestyle = 2, thick = 1

 print,'which parameter you want to change, 5 to change width, or 6 to exit'
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
     print,fw,'  remember this is going to be fixed in curvefit'
     read,var
     fw=var
  end

  6: cont=1
endcase

endwhile



read, 'Type 1 to save to ps: ', kk
if (kk eq 1) then set_plot, 'ps'
if (kk eq 1) then device, filename = 'idl.ps'
if (kk eq 1) then device, yoffset = 5.0
if (kk eq 1) then device, ysize = 17.0

plot_oo, f_b(g), p(g), psym = 10, $
  xrange = [xl,xu], $
  yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 2.0, charthick = 2.0,/xstyle,/ystyle,$
  xtickname=['0.01','0.1','1','10','100']

oploterr, f_b(g), p(g), p_err(g), 3
fixup, b, f_b, p, p_err

guess=a
w = 1.0/(p_err^2)
yfit = curvefit_i(f_b, p, w, a, fw, chisqr, sigmaa, function_name = modelname)

array = [transpose(a), transpose(sigmaa)]
print, array

; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
dof = n_elements(f_b)-n_elements(a)
print, 'chi2 = ', chisqr*dof
print, 'dof = ', dof

; plotting the fit on the data
n = 100000
x = 0.001+0.01*findgen(n)


g1 = where(x le a(1)) 
g2 = where(x gt a(1)) 

den = (x - a(4))^2 + (0.5*fw)^2
f=fltarr(n_elements(x))
f(g1) = a(0) +  (a(3)*fw)/(2.0*!pi*den(g1))
f(g2) = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2)) + (a(3)*fw)/(2.0*!pi*den(g2))

;f = a(0)*x^(-a(1)) + (a(2)*a(3))/(2.0*!pi*den)
oplot, x, f, thick = 2

; plotting individual components
c1_1 = a(0) 
oplot, [0.01,max(x(g1))], [c1_1,c1_1],linestyle = 2, thick = 1
c1_2 = a(0)*(a(1)^(-a(2)))*(x(g2)^a(2))
oplot, x(g2), c1_2, linestyle = 2, thick = 1

c2_1 = (a(3)*fw)/(2.0*!pi*den(g1))
oplot, x(g1), c2_1, linestyle = 2, thick = 1
c2_2 = (a(3)*fw)/(2.0*!pi*den(g2))
oplot, x(g2), c2_2, linestyle = 2, thick = 1

; calculating fractional rms amplitudes
print, 'broken pow law'
print, 'frac_rms = ', sqrt(a(0)*a(1)+(a(0)*a(1)^(-a(2))*(100^(a(2)+1)-a(1)^(a(2)+1))/(a(2)+1))), sigmaa(0)/(2.0*sqrt(a(0)))
print, 'break f = ', a(1), sigmaa(1)
print, 'level = ', a(0), sigmaa(0)
print, 'index = ', a(2), sigmaa(2)
print, 'f_buency = ', a(4), sigmaa(4)
print, 'frac_rms = ', sqrt(a(3)), sigmaa(3)/(2.0*sqrt(a(3)))
print, 'reduced chi^2 = ', chisqr, dof

read, 'Type 1 to show residuals: ', jj
if (jj eq 1) then window, 1
if (jj eq 1) then plot_oi, f_b, chi, psym = 10, xtitle = 'Frequency (Hz)', ytitle = 'Chi!U2!N', charsize = 2, charthick = 2, xrange = [xl,xu]
if (jj eq 1) then oplot, [1.e-5,1.e5],[0,0],linestyle = 1, thick = 2

if (kk eq 1) then device, /close
if (kk eq 1) then set_plot, 'x'
!p.multi = 0

fit=a

end
