pro print_netoff,rate,sig
;*****************************************************
; Program calculates some parameters that characterize
; the HEXTE background regions and prints them to the 
; screen. The variables are:
;     rate.........net off rate (counts/s)
;      sig.........sigma for each channel
;   silent.........no output to screen
; The parameters are mean, sigma, chi-squared(mean), 
; chi-squared(0), dof. The chi_squared are per dof.
; First do usage:
;*****************************************************
if (n_elements(rate) eq 0)then begin
   print,'USAGE: print_netoff,rate,sig' 
   return
endif
;*****************************************************
; Define some variables.
;*****************************************************
rate = reform(rate)
sig = reform(sig)
edgs = intarr(2,7)
edgs(0,*) = [10,20,45,60,100,170,10]
edgs(1,*) = [19,44,59,99,169,250,250]
sig2 = sig*sig 
nbns = n_elements(edgs) - 1 
;******************************************************************
; Loop through the channel ranges, calculating the parameters 
; mentioned above.
;******************************************************************
print,' '
print,' | Chans |  Avg. | Sigma | Chi2(Avg.) | Chi2(0) | Dof |'
print,' ' 
for i = 0,6 do begin
 ledg = edgs(0,i)
 uedg = edgs(1,i)
 rt = rate(ledg:uedg)
 sg2 = sig2(ledg:uedg)
 in = where(sg2 ne 0.,n)
 dof = float(n) - 1.
 if (in(0) ne -1)then begin
    s = total(1./sg2(in))
    mean = total(rt(in)/sg2(in))/s
    sigmean = sqrt(1./s)
    chi2_avg = total((rt(in)-mean)^2/sg2(in))/dof
    chi2_0 = total(rt(in)^2/sg2(in))/dof
;******************************************************************
; Round 'em off
;******************************************************************
    mean_sign = -1.*(mean lt 0.) + 1.*(mean ge 0.)
    mean = mean_sign*float(long(1.e5*abs(mean)+.5))/1.e5
    mean = strcompress(mean,/remove_all)
    sigmean = strcompress(long(1.e5*sigmean+.5)/1.e5,/remove_all)
    chi2_avg = strcompress(long(1.e5*chi2_avg+.5)/1.e5,/remove_all)
    chi2_0 = strcompress(long(chi2_0*1.e5+.5)/1.e5,/remove_all)
    mean = strmid(mean,0,strpos(mean,'.')+5)
    sigmean = strmid(sigmean,0,strpos(sigmean,'.')+5)
    chi2_avg = strmid(chi2_avg,0,strpos(chi2_avg,'.')+5) 
    chi2_0 = strmid(chi2_0,0,strpos(chi2_0,'.')+5)
 endif else begin
    print,'in(0) = -1, chans=',ledg,uedg
    mean = '0.0000'
    sigmean = '0.0000'
    chi2_avg = '0.0000'
    chi2_0 = '0.0000'
 endelse
 chns = strcompress(ledg,/remove_all) + '-' + $
        strcompress(uedg,/remove_all)
 dof = strcompress(dof,/remove_all) 
;******************************************************************
; Now print out the parameters
;******************************************************************
 print,'   ',chns,'   ',mean,'   ',sigmean,'   ',chi2_avg,'   ',$
       chi2_0,'   ',dof

endfor   
;******************************************************************
; That's all ffolks
;******************************************************************
return
end    
      
            
