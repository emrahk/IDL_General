pro fit_dead,p,p_err,f,a,ro,xf,fit

window, 0
xl = 0.01
xu = 1000
yl = 1.9
yu = 2.5

modelname = 'dead_mod' 
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

plot_oi, f(g), p(g), psym = 10, $
  xrange = [xl,xu], $
  yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 2.0, charthick = 2.0,/xstyle,/ystyle,$
  xtickname=['0.01','0.1','1','10','100','1000']

oploterr, f(g), p(g), p_err(g), 3
if total(b) gt 0 then fixup, b, f, p, p_err

w = 1.0/(p_err^2)
;bu kisim eklendi

n = 100000
x = 0.001+0.01*findgen(n)

ta_fit=[2.5,4.5,7.,10.,14.,25.,35.]
rv_fit=a*xf
foo=fltarr(n_elements(x))
for i=0,6 do foo=foo+2.*rv_fit(i)*ro*sin(!PI*ta_fit(i)*1e-3*x)^2/(!PI*!PI*x*x)
oplot,x,2.+foo,line=0,thick=2

 print,'which parameter you want to change, or 7 to exit'
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

  7: cont=1
endcase

endwhile

a=a*ro*xf
yfit = curvefit(f, p, w, a, sigmaa, function_name = modelname)

array = [transpose(a), transpose(sigmaa)]
print, array
plot_oi, f(g), p(g), psym = 10, $
  xrange = [xl,xu], $
  yrange = [yl,yu], $
  xtitle = 'Frequency (Hz)', $
  ytitle = '(rms/mean)!E2!N Hz!E-1!N', $
  charsize = 2.0, charthick = 2.0,/xstyle,/ystyle,$
  xtickname=['0.01','0.1','1','10','100','1000']
oploterr, f(g), p(g), p_err(g), 3
if total(b) gt 0 then fixup, b, f, p, p_err



; calculating the chi^2 for the fit
chi = (p-yfit)^2/(p_err^2)
dof = n_elements(f)-n_elements(a)
print, 'chi2 = ', total(chi)
print, 'dof = ', dof

rv_fit=a
foo=fltarr(n_elements(x))
for i=0,6 do foo=foo+2.*rv_fit(i)*sin(!PI*ta_fit(i)*1e-3*x)^2/(!PI*!PI*x*x)
oplot,x,2.+foo,line=0,thick=2

read, 'Type 1 to show residuals: ', jj
if (jj eq 1) then window, 1
if (jj eq 1) then plot_oi, f, chi, psym = 10, xtitle = 'Frequency (Hz)', ytitle = 'Chi!U2!N', charsize = 2, charthick = 2, xrange = [xl,xu]
if (jj eq 1) then oplot, [1.e-5,1.e5],[0,0],linestyle = 1, thick = 2

if (kk eq 1) then device, /close
if (kk eq 1) then set_plot, 'x'
!p.multi = 0

fit=a

end
