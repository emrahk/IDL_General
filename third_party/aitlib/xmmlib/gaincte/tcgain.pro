FUNCTION tcgain,data,ccdid,inpath=inpath,gainfile=gainfile,hkfile=hkfile,bin=bin,chatty=chatty
;+
; NAME:          tcgain
;
;
;
; PURPOSE:
;                Apply Gain-Correction to Event-Data
;
;
; CATEGORY:
;                XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                mkgain,data,0,gainfile="Gain_30_HK000126_000.dat"
;
; 
; INPUTS:
;                data     : data structure containing line, column,
;                           energy, seconds, subseconds, time and ccd
;                           information, as defined in geteventdata
;                ccdid    : number of the CCD to which gain correction
;                           is to be applied (0..11)
;
; OPTIONAL INPUTS:
;                inpath   : Path where the gain-files can be found
;                           (default is './')
;                gainfile : name of file containing gain values
;                hkfile   : name of hk-file from which gain values
;                           have been calculated
;
;      
; KEYWORD PARAMETERS:
;                bin      : if format of gain file is binary    
;                /chatty  : Give more information on what's going
;                           on
;
; OUTPUTS:
;                data     : data structure containing line, column,
;                           energy, seconds, subseconds, time and ccd
;                           information, as defined in geteventdata;
;                           the enrgies are of the CCD 'ccdid' are
;                           coorected according to Gain !
;
;
; OPTIONAL OUTPUTS:
;                none
;
;
; COMMON BLOCKS:
;                none
;
;
; SIDE EFFECTS:
;                none
;
;
; RESTRICTIONS:    
;                If neither gainfile nor hkfile are specified, the
;                program is looking for a binary gainfile named Gain_??.dat
;
;
; PROCEDURE:
;                none
;
;
; EXAMPLE:
;                
;
; MODIFICATION HISTORY:
;
; V1.0 10.08.99 M. Kuster First initial version
; V1.1 07.12.99 M. Kuster Changed name of Gain files
; V1.2 25.01.00 T. Clauss Changed name of program, changed gain file names    
;- 
   

   IF (NOT keyword_set(inpath)) THEN inpath='./'
   
   IF (NOT keyword_set(gainfile)) THEN BEGIN
       ccdnr=['00','01','02','10','11','12','20','21','22','30','31','32']
       IF (NOT keyword_set(hkfile)) THEN BEGIN
           ; Gainfile im Format 'Gain_30.dat'
           file='Gain_'+ccdnr(ccdid)+'.dat'
           bin=1
       ENDIF ELSE BEGIN
           IF(keyword_set(bin)) THEN begin
               ; Gainfile im Format 'Gain_30_HK000120_076.bin'
               file='Gain_'+ccdnr(ccdid)+'_'+strmid(hkfile,0,strlen(hkfile)-4)+'_'+$
                                             strmid(hkfile,strlen(hkfile)-3,3)+'.bin'
           ENDIF ELSE BEGIN
               ; Gainfile im Format 'Gain_30_HK000120_076.dat'
               file='Gain_'+ccdnr(ccdid)+'_'+strmid(hkfile,0,strlen(hkfile)-4)+'_'+$
                                             strmid(hkfile,strlen(hkfile)-3,3)+'.dat'
           ENDELSE
       ENDELSE
   ENDIF ELSE file=gainfile
  
   file=inpath+file
   
   IF (keyword_set(chatty)) THEN $
     print,'% TCGAIN: Applying gain correction to CCD '+STRTRIM(ccdid,2)
   
   gain=tcreadgain(file,bin=bin)
     
   IF (gain(0) EQ -1) THEN BEGIN 
       print,'% TCGAIN: ERROR ****** Can not apply Gain-Correction ******'
   ENDIF ELSE BEGIN 
       ccdind=where(data.ccd EQ ccdid)
       ;; do correction of energies
       data(ccdind).energy=data(ccdind).energy*gain(data(ccdind).column)
   ENDELSE 
   return,data
END













