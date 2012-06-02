FUNCTION mkcte,data,ccdid,chatty=chatty
;+
; NAME:          mkcte
;
;
;
; PURPOSE:
;                Apply CTE-Correction to Event-Data
;
;
; CATEGORY:
;                XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                mkcte,data,0,/chatty
;
; 
; INPUTS:
;                data     : data structure containing line, column,
;                           energy, seconds, subseconds, time and ccd
;                           information, as defined in geteventdata
;                ccdid    : Number of the CCD to which we should apply
;                           the CTE correction
;
; OPTIONAL INPUTS:
;                none
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
;                           coorected according to CTE !
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
;                mkcte,data,2,/chatty
;
;
; MODIFICATION HISTORY:
;
; V1.0 10.08.99 M. Kuster First initial version
; V1.1 12.08.99 M. Kuster Changed data format to structured 'Data'
; V1.2 07.12.99 M. Kuster Changed the name of CTE files according to 'go'
;
;-
   ;; cte-files
   files=['CTE_00.dat',$
          'CTE_01.dat',$
          'CTE_02.dat',$
          'CTE_10.dat',$
          'CTE_11.dat',$
          'CTE_12.dat',$
          'CTE_20.dat',$
          'CTE_21.dat',$
          'CTE_22.dat',$
          'CTE_30.dat',$
          'CTE_31.dat',$
          'CTE_32.dat']
   
   ctefile=files(ccdid)
   
   scte = FLTARR(50)
   cte=1.
   
   IF (keyword_set(chatty)) THEN $
     print,'% MKCTE: Applying cte correction to CCD '+STRTRIM(ccdid,2)
   
   ;; read cte-file
   get_lun, cf
   openr, cf, files(ccdid), /XDR,ERROR=err
   IF (err NE 0) THEN BEGIN 
       print,'% MKCTE: ERROR opening CTE-File: '+files(ccdid)
       print,'% MKCTE: '+ !ERR_STRING
   ENDIF ELSE BEGIN 
       readu, cf, scte
       readu, cf, cte
       cte=1./cte
       
       ;; apply cte correction to ccd with number ccdid
       ccdind=where(data.ccd EQ ccdid)
       data(ccdind).energy=data(ccdind).energy*cte^(data(ccdind).line)
   ENDELSE 
   free_lun,cf
   return,data
END





