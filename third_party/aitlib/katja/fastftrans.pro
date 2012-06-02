PRO fastftrans,rate,dft
;+
; NAME:
;	   fastftrans
;
;
; PURPOSE:
;         To calculate the Fast Fourier Transform of the given array
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          fastftrans,rate,dft
;           
; INPUTS:
;          rate : Evenly binned count rate
;
; OPTIONAL INPUTS:
;          none 
;	
; KEYWORD PARAMETERS: 
;
; OUTPUTS:
;          dft : Fourier transform of the given array
;
; OPTIONAL OUTPUTS:
;
;
; COMMON BLOCKS:
;          none 
;
;
; SIDE EFFECTS:
;          none
;
;
; RESTRICTIONS:
;          none
;
; PROCEDURE:
;          none 
;
; EXAMPLE:
;          fastftrans,rate,dft
;
;
; MODIFICATION HISTORY:
;          2001/12/20, Emrah KALEMCI  CASS : Header added
;-

   
   
nf=n_elements(rate)/2           ; dimension of the output dft array
ratezm=rate-mean(rate)          ; zero mean count rate 
dft=fft(ratezm,1)               ; fft of ratezm, normalization factor: 1
dft=temporary(dft(1:nf))        ; dft array corresponding to the 
                                ; physically meaningful Fourier frequencies  
      
END 



