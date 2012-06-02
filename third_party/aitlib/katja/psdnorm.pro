PRO psdnorm,avgrate,length,nt,psd, $
            schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
            avgback=avgback, $
            chatty=chatty
   
   
;+
; NAME:
;             psdnorm
;
;
; PURPOSE:
;             normalize the power spectral density array; return the
;             Fourier frequency array and the power spectral density
;             array in Schlittgen (default), Leahy or Miyamoto normalization
;
;
; CATEGORY:
;             timing tools
;
;
; CALLING SEQUENCE:
;             psdnorm,avgrate,length,nt,psd, $
;                       schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
;                       avgback=avgback, chatty=chatty
;   
;
; 
; INPUTS:
;             avgrate    : average count rate of the LC used for
;                          computing the PSD
;             length     : length of the time-interval used to compute
;                          the individual PSD
;             nt        :  number of points in each of the indiv. LCs
;                          (i.e. length/nt is the bin-time)
;             psd       :  corresponding power spectral density
;                          (normalization factor 1) 
;             avgback   : Average background to correct the Miyamoto 
;	                  normalization
;         
; OPTIONAL INPUTS:
;             none
;
;	
; KEYWORD PARAMETERS:
;             schlittgen : if set, return power in Schlittgen normalization
;                          (Schlittgen, H.J., Streitberg, B., 1995,
;                          Zeitreihenanalyse, R. Oldenbourg)
;             leahy      : if set, return power in Leahy normalization
;                          (Leahy, D.A., et al. 1983, Ap.J., 266, 160)
;             miyamoto   : if set, return power in Miyamoto normalization
;                          (Miyamoto, S., et al. 1991, Ap.J., 383,784)
;             chatty     : controls screen output
;
; OUTPUTS:
;             psd        : normalized power spectral density
;
;
; OPTIONAL OUTPUTS:
;             none
;
;
; COMMON BLOCKS:
;             none
;
;
; SIDE EFFECTS:
;             none
;
;
; RESTRICTIONS:
;
; PROCEDURE:
;             none
;
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;             Version 1.0, 1998/03/16, KP
;             Version 2.0, 1998/05/12, KP/JW
;             Version 3.0, 2000/11/22, KP/EK 
;				       new keyword for background corrected
;                                      normalization 
;                                      
;                           2000/12/20 Emrah Kalemci IDL Header Updated
;-
   
    
;; normalization-keywords (schlittgen, leahy, miyamoto), default:
;; miyamoto=1: Miyamoto normalization
nsch = n_elements(schlittgen)
nlea = n_elements(leahy)
nmiy = n_elements(miyamoto)
IF ((nsch+nlea+nmiy) GT 1) THEN BEGIN  
    message,'Only one normalization-keyword can be set' 
ENDIF
IF ((nsch+nlea+nmiy) EQ 0) THEN BEGIN
    miyamoto=1
ENDIF 
IF (keyword_set(schlittgen)) AND (keyword_set(chatty)) THEN BEGIN 
    print,'psdnorm: The Fourier quantities are Schlittgen-normalized'
ENDIF 
IF (keyword_set(leahy)) AND (keyword_set(chatty)) THEN BEGIN 
    print,'psdnorm: The Fourier quantities are Leahy-normalized'
ENDIF 
IF (keyword_set(miyamoto)) AND (keyword_set(chatty)) THEN BEGIN 
    print,'psdnorm: The Fourier quantities are Miyamoto-normalized'
ENDIF 


;; normalization of the power spectral density
IF (keyword_set(schlittgen)) THEN BEGIN 
    npsd=psd/nt
ENDIF 
IF (keyword_set(leahy)) THEN BEGIN
    npsd=psd*2.*length/(avgrate*nt*nt)
ENDIF 
IF (keyword_set(miyamoto)) THEN BEGIN
    IF (n_elements(avgback) NE 0) THEN BEGIN
        npsd=psd*2.*length/(nt*(avgrate-avgback))^2
    ENDIF ELSE BEGIN
        npsd=psd*2.*length/(nt*avgrate)^2
    ENDELSE
ENDIF 
psd=npsd & npsd=0.
   
   
END 









