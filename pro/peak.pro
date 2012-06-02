pro peak,f1,f1_err,f1_fwhm,f1_fwhm_err,f_red,f_red_err

if f1 eq 0. then begin
 f_red=f1_fwhm/2.
 f_red_err=f1_fwhm_err/2.
endif else begin
f_red=sqrt((f1_fwhm/(2*f1))^2+1.)*f1
f_red_err=(sqrt((f1_fwhm/(2.*f1))^2+1.)-(f1_fwhm^2/(4*f1^2))/$
(sqrt((f1_fwhm/(2.*f1))^2+1.)))*f1_err+$
f1_fwhm/(f1*4.*sqrt((f1_fwhm/(2.*f1))^2+1.))*f1_fwhm_err
endelse
end
