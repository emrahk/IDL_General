pro fit_brpl_1lfifffl,p,p_err,f_b,a1,a2,fi,ff,fw,fl,fit


window, 0
xl = 0.01
xu = 10.
yl = 1.e-5
yu = 1.

;set_plot,'ps'
;!p.font=0
;device,/times

; Program for reading in and fitting an rms^2/Hz normalized power spectra

modelname = 'brk_pow_1lfifffl' ; the model name should also go here

a=[a1,a2]

; This is just so the error bars on the plot look right
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
yfit = curvefit_i(f_b, p, w, a, fi, chisqr, sigmaa, function_name = modelname)

array = [transpose(a), transpose(sigmaa)]
print, array

; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
g = where(yfit gt p)
chi(g) = -chi(g)
dof = n_elements(f_b)-n_elements(a)
print, 'chi2 = ', chisqr*dof
print, 'dof = ', dof

; plotting the fit on the data
n = 100000
x = 0.001+0.01*findgen(n)

g1 = where(x le a(0)) 
g2 = where(x gt a(0)) 

den = (x - ff)^2 + (0.5*fw)^2
f=fltarr(n_elements(x))
f(g1) = fl +  (a(1)*fw)/(2.0*!pi*den(g1))
f(g2) = fl*(a(0)^(-fi))*(x(g2)^fi) + (a(1)*fw)/(2.0*!pi*den(g2))

oplot, x, f, thick = 2

; plotting individual components
c1_1 = fl 
oplot, [0.01,max(x(g1))], [c1_1,c1_1],linestyle = 2, thick = 1
c1_2 = fl*(a(0)^(-fi))*(x(g2)^fi)
oplot, x(g2), c1_2, linestyle = 2, thick = 1

c2_1 = (a(1)*fw)/(2.0*!pi*den(g1))
oplot, x(g1), c2_1, linestyle = 2, thick = 1
c2_2 = (a(1)*fw)/(2.0*!pi*den(g2))
oplot, x(g2), c2_2, linestyle = 2, thick = 1

; calculating fractional rms amplitudes
print, 'broken pow law'
print, 'frac_rms = ', sqrt(fl*a(0)+(fl*a(0)^(-fi)*(100^(fi+1)-a(0)^(fi+1))/(fi+1)))
print, 'break f = ', a(0), sigmaa(0)
print, 'level = ', fl,' fixed'
print, 'index = ', fi, '  fixed'
print, 'f_buency = ', ff, 'fixed'
print, 'frac_rms = ', sqrt(a(1)), sigmaa(1)/(2.0*sqrt(a(1)))
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
