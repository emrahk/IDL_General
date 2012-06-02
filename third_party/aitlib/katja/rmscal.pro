FUNCTION rmscal,freq,psd,fmin=inpfmin,fmax=inpfmax,chatty=chatty
;+
; NAME:
;         rmscal
;
;
; PURPOSE:
;         compute rms in a frequency range for a Miyamoto normalized PSD
;
; 
; CATEGORY:
;         timing tools
;
;
; CALLING SEQUENCE:
;      rms=rmscal(freq,psd,fmin=fmin,fmax=fmax,chatty=chatty)
;
;
;
; INPUTS:
;      freq, psd: frequency and PSD value of the MIYAMOTO normalized PSD
;
;
; OPTIONAL INPUTS:
;      -
;
;
; KEYWORD PARAMETERS:
;     fmin, fmax: frequency range over which rms is to be computed;
;                 default: min. and max. frequency of the PSD
;     chatty: be happy, be chatty
;
; OUTPUTS:
;     the function returns the rms values
;
;
; RESTRICTIONS:
;     did we say, the function is for MIYAMOTO normalized psds only?
;
;
;
; PROCEDURE:
;     trivial
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;     CVS Version 1.1, 2002.01.16, JW-TG-KP: added header; corrected
;         fmin and fmax keywords such that they really work...
;-

  ;; rms-keywords (fmin, fmax), default:
  ;; fmin=min(freq) & fmax=max(freq)  
  IF (n_elements(inpfmin) EQ 0) THEN BEGIN 
      fmin=min(freq)
  ENDIF ELSE BEGIN 
      fmin=double(inpfmin)
  ENDELSE 

  IF (n_elements(inpfmax) EQ 0) THEN BEGIN 
      fmax=max(freq)
  ENDIF ELSE BEGIN  
      fmax=double(inpfmax)
  ENDELSE 

  ;; chatty-keyword
  IF (keyword_set(chatty)) THEN BEGIN 
      print,'rmscal: The rms value is calculated...'
      print,'      starting with the frequency: ',fmin
      print,'    and ending with the frequency: ',fmax
  ENDIF 


  ;; calculate and return rms of psd between fmin and fmax
  ndx=where((freq GE fmin) AND (freq LE fmax))
  IF (ndx(0) EQ -1) THEN return,0

  imin=min(ndx)
  imax=max(ndx)
  df=freq(imin+1:imax)-freq(imin:imax-1)
  ppsd=psd(imin:imax-1)    
  rms2=total(ppsd*df)

  return,sqrt(rms2)

END 





