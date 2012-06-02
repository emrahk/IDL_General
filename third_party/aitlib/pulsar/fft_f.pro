pro fft_f,time,cnts,freq,pwr,pwr_lvls,plt,stle,tres,frange=frange
;****************************************************************
; Program does an fft on evenly spaced data.
; Variables are:
;        time...............time coordinate of bin center
;        cnts...............counts array
;        freq...............output frequency array
;         pwr...............normalized power array
;   lvls_lvls...............power levels corresponding
;                           to positive detection probabilities
;                           of [.5,.9,.99,.999]
;         plt...............if set plot the data
;        stle...............optional subtitle
;        tres...............times resolution
;      frange...............frequency range
; Notes: 1) Zero frequency component set to zero
; requires n_eff.pro
; display parameters:       
;****************************************************************
if (n_params() eq 0)then begin
   print,'USE : FFT_F,TIMES,COUNTS,FREQ,PWR,PWR_LVLS,PLT,' + $
         'STLE,TRES,[FRANGE=]'
   return
endif
;****************************************************************
; Rescale the arrays to the nearest power of two:
;****************************************************************
len = float(n_elements(cnts))
num = len
num_freq = .5*(len) - 1. 
del = max(time) - min(time)
;****************************************************************
; Do fft and get positive frequency piece.
; Set zero frequency power equal to 0.
;****************************************************************
fft_arr = float(2./total(cnts))*(abs(fft(cnts,1)))^2
pos_freq_fft = fft_arr(0:len/2)
pos_freq_fft(0) = 0.0
if (ks(tres) eq 0)then tres = time(1) - time(0)
freq = findgen(long(1) + len/long(2))/(len*tres)
pwr = pos_freq_fft
;****************************************************************
; Calculate the power levels corresponding to the 
; probability levels .5,.1,.05,.01 for a pure noise
; signal. The probability distribution for a pure 
; noise signal is exponential in the normalized power.
;****************************************************************
lvls = double(1.) - double([.50,.10,.01,.001])
if (ks(frange) ne 0)then begin
   in = where(freq ge min(frange) and freq le max(frange))
   if (in(0) eq -1)then begin
      print,'NO FREQUENCIES IN FRANGE'
      return
   endif
   freq = freq(in) & pwr = pwr(in)
endif
num_freq = float(n_elements(freq))
get_pwr2,lvls,num_freq,1.,pwr_lvls
if (ks(plt))then begin
;****************************************************************
; Plot the power versus frequency and overplot the
; probability levels
;****************************************************************
   !x.style = 1 & !y.style = 1
   xtle = 'FREQUENCY (S!E-1!N)'
   ytle = 'NORMALIZED POWER'
   dfreq = freq(1) - freq(0)
   low = abs(freq - .5*dfreq)
   high = freq + .5*dfreq
   x = [min(low),max(high)]
   xrnge = [min(low),1.1*max(high)-.1*min(low)]
   yrnge = [0.,max([pwr,1.1*max(pwr_lvls)])]
   if (ks(stle) eq 0)then stle = '' 
   hstplot,low,high,pwr,xtle,ytle,yr=yrnge,st=stle,xr=xrnge
   if (ks(nrm) eq 0)then begin
      for i = 0,3 do begin
       l_str = strcompress(' ' + string(lvls(i)))
       l_str = strmid(l_str,0,strpos(l_str,'.')+4)
       if (!d.name eq 'ps')then begin
          xyouts,max(high),pwr_lvls(i),l_str
          oplot,x,[pwr_lvls(i),pwr_lvls(i)],line=2
       endif else begin
          xyouts,max(high),pwr_lvls(i),l_str,color=!p.background
          oplot,x,[pwr_lvls(i),pwr_lvls(i)],line=2,$
          color=!p.background
       endelse
      endfor
   endif
endif
;**************************************************************
; Thats all ffolks
;**************************************************************
return
end
