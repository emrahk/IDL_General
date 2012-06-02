pro fit_pl,p,p_err,f_b,a1,fit,guess,sig


window, 0
xl = min(f_b)
xu = max(f_b)
yl = min(p)/5.
yu = max(p)*5.

; Program for reading in and fitting an rms^2/Hz normalized power spectra

modelname = 'pow' ; the model name should also go here

a=[a1]

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
  ;yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 2.0, charthick = 2.0,/xstyle,ystyle=1
 ; xtickname=['0.01','0.1','1','10','100']

oploterr, f_b(g), p(g), p_err(g)
;fixup, b, f_b, p, p_err

n = 100000
x = 0.001+0.01*findgen(n)


f=fltarr(n_elements(x))
f = a(0)*(x^a(1))


oplot, x, f, thick = 2

; plotting individual components

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
  
   3: cont=1
endcase

endwhile

read, 'Type 1 to save to ps: ', kk
if (kk eq 1) then set_plot, 'ps'
if (kk eq 1) then device, filename = 'idl.ps'
if (kk eq 1) then device, yoffset = 5.0
if (kk eq 1) then device, ysize = 17.0

plot_oo, f_b(g), p(g), psym = 10, $
  xrange = [xl,xu], $
  ;yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 2.0, charthick = 2.0,/xstyle,ystyle=1
  $xtickname=['0.01','0.1','1','10','100']

oploterr, f_b(g), p(g), p_err(g), 3
;fixup, b, f_b, p, p_err

guess=a
w = 1.0/(p_err^2)
yfit = curvefit(f_b, p, w, a, sigmaa, iter=100, function_name = modelname)

array = [transpose(a), transpose(sigmaa)]
print, array

; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
dof = n_elements(f_b)-n_elements(a)
print, 'chi2 = ', total(chi)
print, 'dof = ', dof

; plotting the fit on the data
n = 100000
x = 0.001+0.01*findgen(n)


f=fltarr(n_elements(x))
f = a(0)*(x^a(1)) 


oplot, x, f, thick = 2




; calculating fractional rms amplitudes
print, 'level = ', a(0), sigmaa(0)
print, 'index = ', a(1), sigmaa(1)
print, 'reduced chi^2 = ', total(chi), dof, total(chi)/dof
rms_100=sqrt((a(0)/(a(1)+1.))*(100.^(a(1)+1.)-0.01^(a(1)+1.)))
rms_10_up=sqrt(((a(0)+sigmaa(0))/(a(1)+sigmaa(1)+1.))*(10.^(a(1)+sigmaa(1)+1.)-0.01^(a(1)+sigmaa(1)+1.)))
rms_10=sqrt((a(0)/(a(1)+1.))*(10.^(a(1)+1.)-0.01^(a(1)+1.)))
s1=sqrt(a(0))/(2.*sqrt((100.^(a(1)+1.)-0.01^(a(1)+1.))/(a(1)+1)))
s2=(100.^a(1)-0.01^(a(1)))
s3=(100.^(a(1)+1.)-0.01^(a(1)+1.))/(a(1)+1.)^2
print,s1,s2,s3
rms_100_err=rms_100*sigmaa(0)/(2.*a(0))+(s1*(s2-s3))*sigmaa(1)
print, 'rms 0.01-10 Hz =',rms_10,rms_10_up-rms_10
print,rms_10_up

read, 'Type 1 to show residuals: ', jj
if (jj eq 1) then window, 1
if (jj eq 1) then plot_oi, f_b, chi, psym = 10, xtitle = 'Frequency (Hz)', ytitle = 'Chi!U2!N', charsize = 2, charthick = 2, xrange = [xl,xu]
if (jj eq 1) then oplot, [1.e-5,1.e5],[0,0],linestyle = 1, thick = 2

if (kk eq 1) then device, /close
if (kk eq 1) then set_plot, 'x'
!p.multi = 0

fit=a
sig=sigmaa
end
