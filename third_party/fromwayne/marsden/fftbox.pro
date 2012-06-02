pro fftbox,counts,freq,base,periods,prob,pwr,phz_bns
;***************************************************************************
; Program makes a box to display the highest fft results and 
; give 'fold' option. Variables are:
;         counts.................counts array to do fft on
;           base.................widget base
;            pwr.................normalized fft power array
;           freq.................frequency array
;        periods.................three most significant periods
;         ntbins.................number of time bins
;           prob.................probability
;       num_freq.................number of frequencies
;        avg_pwr.................power due to noise
;        phz_bns.................number of phase bins
; Program picks three strongest frequencies by  
;'knocking out' the 3 adjacent bins. Much effort expended on making 
; sure the picked frequencies are distinct.
; 6/10/94 Current version
; 1/27/95 Changed all 'fix' to 'long' for large data sets
;    "    Proper normalization for fft
; 7/17//95 New Normalization for chi-squared probability distribution
; First compute needed quantities:
;******************************************************************************
len = float(n_elements(counts))
num =len  
num_freq = .5*(len) - 1. 
;******************************************************************************
; Calculate the positive frequency FFT power spectrum. The normalization
; is such that the probability of getting a power p<p' in a single 
; frequency bin is given by:
;        P(p<p') = chi_squared(p',2)
; Then the probability of getting this power or less for examination of 
; of a number of requency bins num_freq is
;        P(p<p';num_freq) = 1. - (1. - P(p<p'))**num_freq
; This is what the variable prob is. For a reference see the M. Van der Klis 
; article in 'Timing Neutron Stars'.
;******************************************************************************
fft_arr = float(2./total(counts))*(abs(fft(counts,1)))^2
pwr = double(fft_arr(0:len/2))
pwr(0) = 0d
chi_pwr = pwr & chi_pwr(*) = 0d
for i = long(0),n_elements(pwr)-long(1) do chi_pwr(i) = chi_sqr1(pwr(i),1d)
ln_p = double(num_freq)*alog(1d - chi_pwr)
prob = 1d - exp(ln_p)
;******************************************************************************
; Construct Widget and do other groovy stuff
;******************************************************************************
rcol = widget_base(base,/column)
rcol1 = widget_base(rcol,/column,/frame)
period = fltarr(num_freq)
period(1:num_freq - 1) = 1./freq(1:num_freq - 1)
zer = fltarr(7)
periods = dblarr(3)
;***************************************************************************
; Now find the frequencies with the greatest probability
;***************************************************************************
for i = 0,2 do begin
   mx = where(pwr eq max(pwr))
   p = pwr(mx(0))
   pr = prob(mx(0))
   max_per = period(mx(0))
   periods(i) = double(max_per)
   if (mx(0) ge num_freq -3)then begin
      pwr(mx(0)-3:num_freq - 1) =  zer(0:2 - mx(0) + num_freq)
   endif else begin
      if (mx(0) le 2)then begin
         pwr(0:mx(0) + 3) = zer(0:3 + mx(0))
      endif else begin
         pwr(mx(0) - 3:mx(0) + 3) = zer
      endelse
   endelse
   w1 = widget_button(rcol1,value=strcompress('FREQ '+string(i+1)))
   max_freq = long((1./max_per)*1000. + .5)/1000.
   max_freq = strmid(max_freq,0,strlen(max_per) - 3)
   prr = strmid(pr,0,strlen(pr) - 1)
   a = strcompress('FREQ = ' + max_freq + ' HZ')
   a2 = strcompress('PROB = ' + prr) 
   w1 = widget_label(rcol1,value = a)
   w1 = widget_label(rcol1,value = a2)
endfor
rcol2 = widget_base(rcol1,/column,/frame)
rcol3 = widget_base(rcol2,/row)
w1 = widget_label(rcol3,value='# BINS:')
w1 = widget_text(rcol3,value=string(phz_bns),uvalue=21,xsize=5,$
     ysize=1,/editable)
;***************************************************************************
; Thats all ffolks
;***************************************************************************
return
end
