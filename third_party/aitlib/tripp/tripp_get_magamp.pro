pro tripp_get_magamp
;+
; NAME:               
;                     TRIPP_GET_MAGAMP
;
;
;
; PURPOSE:            
;                     convert intensity variation to amplitude in
;                     magnitudes, milli-magnitudes
;                     OR
;                     convert magnitudes (milli-magnitude) variation
;                     to intensity amplitude
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:   
;                     tripp_get_magamp
;
;
;
; INPUTS:             
;                     none
;
;
;
; OPTIONAL INPUTS:    
;                     none
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
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
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;                     2000/12       SLS, SD 2000/12
;
;-

on_error,2                      ;Return to caller if an error occurs

;Formula: 2.5 + 2.5 log (delta m) = (delta I + I) / I
;;neu   Formula: - 2.5 log ((delta I + I) / I) = deltam
   
print, 'intensity to magnitudes: enter i'
print, 'magnitudes to intensity: enter m'
print, 'mmag       to intensity: enter mm'
was=''
read,was
was=strtrim(was,2)
print,was

case was of 
 'i' : begin
		
   ;convert intensity variation to amplitude in magnitudes

   print,'enter maximal relative intensity amplitude, i.e. 1.05'
   read, maxamp ;eq deltai+1

;   deltam = 10^(maxamp/2.5 -1)
   deltam = - 2.5*alog10(maxamp)   
   
   print,'amplitude in magnitudes is '+string(deltam)+' mag'
   print,'                        or '+string(deltam*10^(3))+' mmag'

   end

 'm' : begin

   print,'enter magnitude amplitude, i.e. 0.5'
   read, deltam

;   deltai = 2.5 + 2.5*alog10(deltam)
   maxamp = 10^(-deltam / 2.5)
   deltai = maxamp              ; !!!
   
   print,'maximal relative intensity amplitude is '+string(deltai)
   print,'                                     or '+string((deltai-1)*10^2)+' %'

   end
  
 'mm' : begin

   print,'enter mmag amplitude, i.e. 50'
   deltamm=0.d
   read, deltamm


;   deltai = 2.5 + 2.5*alog10(float(deltamm*0.001))
   maxamp = 10^(-deltam*0.001 / 2.5)
   deltai = maxamp              ; !!!
   
   print,'maximal relative intensity amplitude is '+string(deltai)
   print,'                                     or '+string((deltai-1)*10^2)+' %'

   end
  

endcase

end
