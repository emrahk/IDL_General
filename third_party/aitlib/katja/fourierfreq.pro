PRO fourierfreq,time,freq
 ;+
; NAME:
;	   fourierfreq
;
;
; PURPOSE:
;         To calculate the Fourier frequencies of a given time array
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          fourierfreq,time,freq
;           
; INPUTS:
;          time : time array
;
; OPTIONAL INPUTS:
;          none 
;	
; KEYWORD PARAMETERS: 
;
; OUTPUTS:
;          freq : Fourier frequencies corresponding to the given time array
;
; OPTIONAL OUTPUTS:
;          none
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
;          fourierfreq,time,freq
;
;
; MODIFICATION HISTORY:
;          2001/12/20, Emrah KALEMCI  CASS : Header added
;-
  
   
nt=n_elements(time)             ; dimension of input time array
bt=time(1)-time(0)              ; bintime of input time array (equally binned)
freq=(findgen(nt/2)+1.)/(bt*nt) ; Fourier frequencies       
   

END 






