FUNCTION mkgain,data,ccdid,inpath=inpath,chatty=chatty
;+
; NAME:          mkcte
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
;                mkgain,data,0,/chatty
;
; 
; INPUTS:
;                data     : data structure containing line, column,
;                           energy, seconds, subseconds, time and ccd
;                           information, as defined in geteventdata
;                ccdid    : Number of the CCD to which we should apply
;                           the Gain correction
;
; OPTIONAL INPUTS:
;                inpath   : Path where the gain-files can be found
;                           (default is './')
;
;      
; KEYWORD PARAMETERS:
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
;                none
;
;
; PROCEDURE:
;                none
;
;
; EXAMPLE:
;                mkgain,data,2,/chatty
;
; MODIFICATION HISTORY:
;
; V1.0 10.08.99 M. Kuster First initial version
; V1.1 07.12.99 M. Kuster Changed name of Gain files
;- 
   ;; Gain-files
   files=['Gain_00.dat',$
          'Gain_01.dat',$
          'Gain_02.dat',$
          'Gain_10.dat',$
          'Gain_11.dat',$
          'Gain_12.dat',$
          'Gain_20.dat',$
          'Gain_21.dat',$
          'Gain_22.dat',$
          'Gain_30.dat',$
          'Gain_31.dat',$
          'Gain_32.dat']
   
   IF (NOT keyword_set(inpath)) THEN inpath='./'
   
   ;; find gain-file
   gainfile=files(ccdid)

   gain = FLTARR(64)
   
   IF (keyword_set(chatty)) THEN $
     print,'% MKGAIN: Applying gain correction to CCD '+STRTRIM(ccdid,2)
   
   ;; read gain-file
   gainfile=inpath+files(ccdid)
   gain=mkreadgain(gainfile)
   
   IF (gain EQ -1) THEN BEGIN 
       print,'% MKGAIN: ERROR ****** Can not apply Gain-Correction ******'
   ENDIF ELSE BEGIN 
       ccdind=where(data.ccd EQ ccdid)
       ;; do correction of energies
       data(ccdind).energy=data(ccdind).energy*gain(data(ccdind).column)
   ENDELSE 
   return,data
END




