
orbit_number = '04'
band = '00_79'
a1 = [1.e-2,0.2,0.8]
a2 = [5.e-3,0.4,1.6]
a3 = [1.e-2,2.0,0.1]
a4 = [5.e-3,2.0,5.0]

window, 0
xl = 0.01
xu = 100
yl = 1.e-7
yu = 1.0

; Program for reading in and fitting an rms^2/Hz normalized power spectra

.r model4
; model 4 is four Lorentzians
.r curvefit
.r rebin_geo

modelname = 'model4' ; the model name should also go here
fname = 'orbit'+orbit_number+'_'+band
step = 1.01 ; for rebinning
a = [a1,a2,a3,a4] ; guess for curvefit
f_low = 0.01 & f_high = 10.0 ; limits for calculating the fractional rms amplitude

restore, 'freq_'+fname+'.dat'
restore, 'p_'+fname+'.dat'
restore, 'p_err_'+fname+'.dat'

; rebinning
rebin_geo, step, freq, p, p_err

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

plot_oo, freq(g), freq(g)*p(g), psym = 10, $
  xrange = [xl,xu], $
  yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = 'Frequency*Power', $
  charsize = 2.0, charthick = 2.0
oploterr, freq(g), freq(g)*p(g), freq(g)*p_err(g), 3
fixup, b, freq, freq*p, freq*p_err

w = 1.0/(p_err^2)
yfit = curvefit(freq, p, w, a, chisqr, sigmaa, function_name = modelname)

array = [transpose(a), transpose(sigmaa)]
print, array

; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
g = where(yfit gt p)
chi(g) = -chi(g)
dof = n_elements(freq)-n_elements(a)
print, 'chi2 = ', chisqr*dof
print, 'dof = ', dof

; plotting the fit on the data
n = 100000
x = 0.001+0.01*findgen(n)
den0 = (x - a(2))^2 + (0.5*a(1))^2
den1 = (x - a(5))^2 + (0.5*a(4))^2
den2 = (x - a(8))^2 + (0.5*a(7))^2
den3 = (x - a(11))^2 + (0.5*a(10))^2
f = (a(0)*a(1))/(2.0*!pi*den0) + (a(3)*a(4))/(2.0*!pi*den1) + (a(6)*a(7))/(2.0*!pi*den2) + (a(9)*a(10))/(2.0*!pi*den3)
oplot, x, x*f, thick = 2

; plotting individual components
c1 = (a(0)*a(1))/(2.0*!pi*den0)
oplot, x, x*c1, linestyle = 1, thick = 2
c2 = (a(3)*a(4))/(2.0*!pi*den1)
oplot, x, x*c2, linestyle = 2, thick = 2
c3 = (a(6)*a(7))/(2.0*!pi*den2)
oplot, x, x*c3, linestyle = 2, thick = 2
c4 = (a(9)*a(10))/(2.0*!pi*den3)
oplot, x, x*c4, linestyle = 1, thick = 2

; calculating fractional rms amplitudes
print, 'frequency = ', a(2)
print, 'frac_rms = ', sqrt(a(0))
print, 'frac_rms_err = ', sigmaa(0)/(2.0*sqrt(a(0)))
print, 'frequency = ', a(5)
print, 'frac_rms = ', sqrt(a(3))
print, 'frac_rms_err = ', sigmaa(3)/(2.0*sqrt(a(3)))
print, 'frequency = ', a(8)
print, 'frac_rms = ', sqrt(a(6))
print, 'frac_rms_err = ', sigmaa(6)/(2.0*sqrt(a(6)))
print, 'frequency = ', a(11)
print, 'frac_rms = ', sqrt(a(9))
print, 'frac_rms_err = ', sigmaa(9)/(2.0*sqrt(a(9)))

read, 'Type 1 to show residuals: ', jj
if (jj eq 1) then window, 1
if (jj eq 1) then plot_oi, freq, chi, psym = 10, xtitle = 'Frequency (Hz)', ytitle = 'Chi!U2!N', charsize = 2, charthick = 2, xrange = [xl,xu]
if (jj eq 1) then oplot, [1.e-5,1.e5],[0,0],linestyle = 1, thick = 2

if (kk eq 1) then device, /close
if (kk eq 1) then set_plot, 'x'
!p.multi = 0
