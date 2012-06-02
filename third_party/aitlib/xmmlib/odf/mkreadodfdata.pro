PRO mkreadodfdata,path,obsid,mode,data,ccd=ccd,quad=quad,$
                  suffix=suffix,header=header,count=count,$
                  noaux=noaux,chatty=chatty
   
;+
; NAME:
;       mkreadodfdata
;
;
; PURPOSE:
;       Read XMM-ODF Data-files
;
;
; CATEGORY:
;       ODF, FITS
;
;
; CALLING SEQUENCE:
;       mkreadodfdata,path,obsid,mode,data,quad=quad,$
;                      suffix=suffix,header=header,/noaux,/chatty
; 
; INPUTS:
;       path: relativ path for the odf file to be read
;       obsid: name of odf file, without ccd and mode information
;              suffixes
;       mode: mode of observation:
;             'timing' or 'burst' or 'full' or 'small' or 'none'
;       
;
; OPTIONAL INPUTS:
;       ccd: number of CCD to be read, the valid range is 1-12. If no
;            CCD number is given, all data is read. BE CAREFUL WITH
;            THIS OPTION, BEACAUSE USUALLY THIS WILL BE A LOT OF STUFF !
;            (for timing and burst mode, ccd is set to 4)
;       quad: quadrant to be read, the valid range is 0-3.
;       suffix: additional suffix
;
;	
; KEYWORD PARAMETERS:
;       noaux: don't read auxiliary file; the time information is
;              given as a frame-counter. 
;       chatty: print more info on what's going on
;                      
;                      
; OUTPUTS:
;       data: data struct array as defined in mkreadodfccd.pro 
;             (similar to struct defined in geteventdata.pro)                     
;                      
;
; OPTIONAL OUTPUTS:
;       header: header information from odf file
;
;
; PROCEDURE: 
;       compose file name from path, obsid, ccd, mode and suffix,
;       call mkreadodfccd
;
;
; EXAMPLE:
;       mkreadodfdata,'./rev0083/','0083_0125100301_PNS001','timing',data,header=header
;                      
;                      
; MODIFICATION HISTORY:
;  V1.0 mkreadodfdata.pro: written 2000 by Markus Kuster, IAAT
;  V1.1  9.05.00 M. Kuster changed index for correlation of AUX and data
;  V1.2 16.05.00 M. Kuster added keyword header file
;  V1.3 18.05.00 M. Kuster added Small window mode support
;  V2.0 13.09.00 T. Clauss : use MRDFITS routine for reading fits files
;  V2.1 25.10.00 M. Kuster removed some bugs  
;  V2.2 23.11.00 M. Kuster works with all 12 CCDs correctly now
;-
   
   on_error,2                   ; Return to caller if an error occurs
   
   IF (n_elements(count) EQ 0) THEN BEGIN 
       readcount=0 
   ENDIF ELSE BEGIN 
       readcount=1
       count=0
   ENDELSE 
   
   ccds=['00','01','02','03','04','05','06','07','08','09','10','11','12','']
   ;;     ^
   ;;     | for aux files only
   ;; 
   ;; 00 is the aux and counter-file
   
   IF (n_elements(mode) EQ 0) THEN mode='Timing'
   
   ;; Set default values for the different read-out modes
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
      
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   
   IF (n_elements(ccd) NE 0) THEN BEGIN 
       IF (ccd NE 13) THEN BEGIN 
           auxfile=path+obsid+ccds(0)+suffaux
       ENDIF ELSE BEGIN 
           auxfile=path+obsid+suffaux
       ENDELSE 
   ENDIF 
   
   IF (n_elements(ccd) EQ 0) THEN BEGIN 
       ;; Read all 12 CCDs -> a lot of stuff !!!!
       FOR ccd=1,12 DO BEGIN
           IF keyword_set(suffix) THEN BEGIN 
               filename=path+obsid+ccds(ccd)+suff+suffix
           ENDIF ELSE BEGIN
               filename=path+obsid+ccds(ccd)+suff
           ENDELSE 
           
           mkreadodfccd,filename,dat,chatty=chatty
           
           IF (ccd EQ 1) THEN BEGIN 
               data=dat
           ENDIF ELSE BEGIN 
               data=[data,dat]
           ENDELSE 
       ENDFOR 
   ENDIF ELSE BEGIN             ; read selected CCDs
       num=n_elements(ccd)
       IF (num GT 0) THEN BEGIN 
           FOR i=0,num-1 DO BEGIN 
               IF keyword_set(suffix) THEN BEGIN 
                   filename=path+obsid+ccds(ccd(i))+suff+suffix
               ENDIF ELSE BEGIN
                   filename=path+obsid+ccds(ccd(i))+suff
               ENDELSE 
               IF (NOT keyword_set(noaux)) THEN BEGIN 
                   IF (readcount EQ 1) THEN BEGIN 
                       mkreadodfccd,filename,dat,auxfile=auxfile,header=header,$
                         count=count,chatty=chatty
                   ENDIF ELSE BEGIN 
                       mkreadodfccd,filename,dat,auxfile=auxfile,header=header,$
                         chatty=chatty
                   ENDELSE 
               ENDIF ELSE BEGIN
                   IF (readcount EQ 1) THEN BEGIN 
                       mkreadodfccd,filename,dat,header=header,count=count,chatty=chatty
                   ENDIF ELSE BEGIN 
                       mkreadodfccd,filename,dat,header=header,chatty=chatty
                   ENDELSE 
               ENDELSE
               IF (i EQ 0) THEN BEGIN 
                   data=dat
               ENDIF ELSE BEGIN 
                   data=[data,dat]
               ENDELSE                
           ENDFOR 
       ENDIF 
   ENDELSE
END 

