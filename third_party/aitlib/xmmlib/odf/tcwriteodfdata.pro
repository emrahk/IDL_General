PRO tcwriteodfdata,path,obsid,mode,data,header,ccd=ccd,chatty=chatty
;+
; NAME:
;       TCWRITEODFDATA
;
;
; PURPOSE:
;       Write XMM-ODF Data-files
;
;
; CATEGORY:
;       ODF, FITS
;
;
; CALLING SEQUENCE:
;       tcwriteodfdata,path,obsid,mode,data,header,ccd=,/chatty
; 
; INPUTS:
;       FILENAME: Name of ODF File to be written
;       
;
; OPTIONAL INPUTS:
;
;	
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; OPTIONAL OUTPUTS:
;
;
; PROCEDURE: 
;
;
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;  V1.0 ; 13.09.00 T. Clauss 
;   
;-
   
   ccds=['00','01','02','03','04','05','06','07','08','09','10','11','12','']
   ;;     ^
   ;;     | for aux files only
   ;; 
   ;; 00 is the aux and counter-file
   
   IF NOT keyword_set(ccd) THEN ccd=data(0).ccd
   
   IF (n_elements(mode) EQ 0) THEN mode='Timing'
   CASE mode OF
       'timing': BEGIN 
           suff='TIE.FIT'
           suffaux='AUX.FIT'
           ccd=4
       END 
       'burst': BEGIN
           suff='BUE.FIT'
           suffaux='AUX.FIT'
           ccd=4
       END 
       'full': BEGIN
           suff='IME.FIT'
           suffaux='AUX.FIT'
       END
       'small': BEGIN
           suff='IME.FIT'
           suffaux='AUX.FIT'
       END
       'none': BEGIN 
           suff='.FIT'
           suffaux='AUX.FIT'
           ccd=13
       END 
   ENDCASE 
      
;   IF (ccd NE 13) THEN BEGIN 
;       auxfile=path+obsid+ccds(0)+suffaux
;   ENDIF ELSE BEGIN 
;       auxfile=path+obsid+suffaux
;   ENDELSE 
   
   
   filename=path+obsid+ccds(ccd)+suff  
   tcwriteodfccd,filename,data,header,chatty=chatty
   
END 

