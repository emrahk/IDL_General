pro fit_2lfffw,p,p_err,f_b,al,a,cf,wi,fit,sig

save,al,cf,wi,filename='/home/emrahk/fit_par.dat'

modelname = 'lor_2lfffw' ; the model name should also go here

; This is just so the error bars on the plot look right
fix1 = p-p_err ; where
fix2 = p
g = where(fix2 gt 0)
b = where(fix1 lt 0)

;den = (x - cf)^2 + (0.5*wi)^2
;f=fltarr(n_elements(x))
;f= (a*wi)/(2.0*!pi*den)


w = 1.0/(p_err^2)
yfit = curvefit(f_b, p, w, a, sigmaa, function_name = modelname)

;array = [transpose(a), transpose(sigmaa)]

; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
dof = n_elements(f_b)-n_elements(a)
;print, 'chi2 = ', total(chi)
;print, 'dof = ', dof

;print, 'f_buency = ', a(2), sigmaa(2)
;print, 'frac_rms = ', sqrt(a(0))
;print, 'frac_rms_err = ', sigmaa(0)/(2.0*sqrt(a(0)))
;print, 'fwhm =', a(1), sigmaa(1)
;print, 'reduced chi^2 = ', total(chi), dof, total(chi)/dof

sig=sigmaa
fit=a

n = 10000
x = 0.001+0.01*findgen(n)

den_1 = (x - al(2))^2 + (0.5*al(1))^2
den_2 = (x - cf)^2 + (0.5*wi)^2

f=fltarr(n_elements(x))
f = (al(0)*al(1))/(2.0*!pi*den_1) + $
    (a*wi)/(2.0*!pi*den_2)

xl = 0.01 
xu = 512.

yl = 1.e-5 
yu = 0.5

ploterror, f_b, p, p_err,psym = 10, $
      xrange = [xl,xu],$
      yrange = [yl,yu], /ylog,$
      xtitle = 'Frequency (Hz)', /nohat, $
      ytitle = '(rms/mean)!E2!N Hz!E-1!N', /xlog,$
      charsize = 1.5, charthick = 1.5,/xstyle,/ystyle

oplot,x,f,thick=2

end
