PRO scargle_cross,ta,ca,tb,cb,tc,corr,numf=numf,nuf=nuf,$
                  ffta=ffta,fftb=fftb,psda=psda,psdb=psdb,cpd=cpd
;+
; NAME:
;         scargle_cross
;
;
; PURPOSE:
;         Compute the cross-correlation of two unevenly sampled data
;         sets, via lomb-scargle periodograms
;
;
; CATEGORY:
;         time series analysis
;
;
; CALLING SEQUENCE:
;         scargle_cross,time_a,rate_a,time_b,rate_b,time_c,corr, $
;                       numf=numf,nuf=nuf,ffta=ffta,fftb=fftb, $
;                       psda=psda,psdb=psdb,cpd=cpd
;
; 
; INPUTS:
;         time_a,_b: The times at which the time series were measured
;         rate_a,_b: the corresponding count rates
;
;
; OPTIONAL INPUTS:
;         none
;
;      
; KEYWORD PARAMETERS:
;         numf: number of independent frequencies
;
;
; OUTPUTS:
;         time_c: times used for the cross-correlation
;         corr: the correlation (if shifted to negative t, a leads b)
;
;
; OPTIONAL OUTPUTS:
;         nuf    : normal frequency  (nu=omega/(2*!DPI))
;         ffta,fftb: the (complex) fft-values corresponding to nu
;         psda,psdb: the psd-values corresponding to nu   
;         cpd: the (complex) cross power spectral density
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;         The Lomb Scargle PSD is computed according to the
;         definitions given by Scargle, 1982, ApJ, 263, 835, and 
;         Scargle, 1989, ApJ, 343, 878 (Read these papers!)
;         The regular idl FFT routines are used for the reverse
;         transform back to the time domain. 
;
;         Based upon the suggestions of Scargle, f_max is chosen to
;         avoid wrap-around effects.  f_min is chosen based upon the
;         number of independent frequencies, for even sampling.
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;          Version 1.0, 1999, Michael Nowak, JILA
;                (Based on Version 1.2, 1999.01.07, of scargle.pro, by
;                Joern Wilms, IAAT)
;-
   
   ;; make times manageable (Scargle periodogram is time-shift
   ;; invariant), but since it's a cross correlation, choose ta to be
   ;; the 0 point
   timea=ta-ta[0]
   timeb=tb-ta[0]

   ;; Subtract means from data
   cna=ca-mean(ca)
   cnb=cb-mean(cb)
   
   ;; This is the effective useful interval for cross-correlation
   tmin=min([timea[0],timeb[0]])
   tmax=max([max(timea),max(timeb)])
   tr=tmax-tmin
   IF (n_elements(numf) EQ 0) THEN BEGIN 
       numf = n_elements(timea)+n_elements(timeb)
   ENDIF 
   nav = numf/2
   tp = float(nav)/float(nav-1)*tr
   
   ;; min. freq. is 1/2Tp, to avoid windowing effects
   ;; max. freq. is defined by the number of points we have
   fmin=1./2./tp

   ;; max. freq: approx. an average Nyquist frequency
   fmax=float(numf)*fmin
   
   ffta = complexarr(numf)
   fftb = complexarr(numf)
   cpd = complexarr(numf)
   psda = fltarr(numf)
   psdb = fltarr(numf)
   
   ;;Odd or Even?? (We'll be storing in wrap-around order for the
   ;;reverse transform) 
   
   nup = findgen(numf/2+1)*fmin
   IF (numf/2 EQ numf) THEN BEGIN 
       nun = -numf/2*fmin+(findgen(numf/2-1)+1)*fmin
   ENDIF ELSE BEGIN 
       nun = -numf/2*fmin+findgen(numf/2)*fmin
   ENDELSE
   nuf=[nup,nun]
   
   om=2.*!DPI* nuf
   
   im = complex(0,1)
   
   numa=float(n_elements(timea))
   numb=float(n_elements(timeb))
   
   ;; Do 0 Frequency Separately
   ffta[0] = 0 ; total(cna)/sqrt(n_elements(timea)) ; if mean not subtracted
   fftb[0] = 0 ; total(cnb)/sqrt(n_elements(timeb)) ; if mean not subtracted
   

   FOR i=1L,numf-1L DO BEGIN 
       
       ;; Time Series A
       tau=atan(total(sin(2.*om[i]*timea[*]))/total(cos(2.*om[i]*timea[*])))
       tau=tau/(2.*om[i])

       co=cos(om[i]*(timea[*]-tau))
       si=sin(om[i]*(timea[*]-tau))

       ffta[i]= total(cna[*]*co[*]) / sqrt(total(co[*]*co[*])) + $
                im * total(cna[*]*si[*]) / sqrt(total(si[*]*si[*])) 
       ;; Note difference of 2 in normalization from Scargle, since we
       ;; are effectively zero padding to twice the length (not that
       ;; the normalization is going to make a difference in the end)
       ffta[i] = sqrt(numa) * exp(-im*om[i]*timea[0]) * ffta[i]
       
       ;; Time Series B
       tau=atan(total(sin(2.*om[i]*timeb[*]))/total(cos(2.*om[i]*timeb[*])))
       tau=tau/(2.*om[i])

       co=cos(om[i]*(timeb[*]-tau))
       si=sin(om[i]*(timeb[*]-tau))

       fftb[i]= total(cnb[*]*co[*]) / sqrt(total(co[*]*co[*])) + $
         im * total(cnb[*]*si[*]) / sqrt(total(si[*]*si[*])) 
       ;; Note: As we are doing a cross correlation, phase set to time
       ;; bin 0 of curve a.  Also note, this is more complicated than
       ;; necessary, since we set the lightcurve start to zero
       fftb[i] = sqrt(numb) * exp(-im*om[i]*timea[0]) * fftb[i]
       
       ;; Cross Correlation in Fourier Space
       cpd[i] = ffta[i]*conj(fftb[i])
       psda[i] = ffta[i]*conj(ffta[i])
       psdb[i] = fftb[i]*conj(fftb[i])
       
   ENDFOR 
;   
   ;; Do the reverse transform
   corr = fft(cpd,-1)
;   
   ;; Rather than beat ourselves over the head concerning
   ;; normalizations, realize that we want the autocorrelation to be
   ;; normalized to one, and use reverse transforms to do that for us
   auta = fft(psda,-1)
   autb = fft(psdb,-1)
   
   corr = corr/sqrt(auta[0])/sqrt(autb[0])
   auta = auta/auta[0]
   autb = autb/autb[0]
   
   ;;if even => shift to run from -Tp -> 0  -> Tp - 1/fmin
   ;;if odd => shift to run from -Tp -> 0  -> Tp
   corr = shift(corr,numf/2)
   auta = shift(auta,numf/2)
   autb = shift(autb,numf/2)
   tc = -tp+1./fmax*findgen(numf)
   
   ;; We really don't trust anything in outside the -Tp/2 -> Tp/2
   ;; range, so cut it out
   iw = where(tc GE -tp/2. AND tc LE tp/2.)
   tc = tc[iw]
   corr = float(corr[iw])
   auta = float(auta[iw]) ; not being output at the moment, but could be
   autb = float(autb[iw]) ; not being output at the moment, but could be
   
END 










