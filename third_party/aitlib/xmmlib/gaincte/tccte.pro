FUNCTION tccte,data,ccdid,minline=minline,maxline=maxline,$
               inpath=inpath,ctefile=ctefile,hkfile=hkfile,bin=bin,chatty=chatty
;+
; NAME:          tccte
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
;                
;
; 
; INPUTS:
;                data     : data structure containing line, column,
;                           energy, seconds, subseconds, time and ccd
;                           information, as defined in geteventdata
;                ccdid    : Number of the CCD to which CTE correction
;                           is to be applied.
;
; OPTIONAL INPUTS:
;                minline, maxline : region of CCD in which
;                           CTE-correction is to be applied.
;                           CTE-correction is starting from minline.
;                inpath   : Path where the cte-files can be found
;                           (default is './')
;                ctefile  : Name of file with 64 CTE values
;                hkfile   : Name of HK-file, CTE-file is of the form
;                           CTE_??_HK??????_???.[dat,bin]
;
;      
; KEYWORD PARAMETERS:
;                bin      : CTE-file is in binary format
;                /chatty  : Give more information on what's going
;                           on
;
; OUTPUTS:
;                data     : data structure containing line, column,
;                           energy, seconds, subseconds, time and ccd
;                           information, as defined in geteventdata;
;                           the energies of the CCD 'ccdid' are
;                           corrected are corrected with the cte-values.
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
;                If neither ctefile nor hkfile are specified, the
;                program is looking for a binary ctefile named CTE_??.dat
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
; V1.2 01.02.00 T. Clauss First version derived from tcgain.pro  
;- 

   IF (NOT keyword_set(inpath)) THEN inpath='./'
   
   IF (NOT keyword_set(ctefile)) THEN BEGIN
       ccdnr=['00','01','02','10','11','12','20','21','22','30','31','32']
       IF (NOT keyword_set(hkfile)) THEN BEGIN
           ; CTEfile im Format 'CTE_30.dat'
           file='CTE_'+ccdnr(ccdid)+'.dat'
       ENDIF ELSE BEGIN
           IF(keyword_set(bin)) THEN begin
               ; CTEfile im Format 'CTE_30_HK000120_076.bin'
               file='CTE_'+ccdnr(ccdid)+'_'+strmid(hkfile,0,strlen(hkfile)-4)+'_'+$
                                             strmid(hkfile,strlen(hkfile)-3,3)+'.bin'
           ENDIF ELSE BEGIN
               ; CTEfile im Format 'CTE_30_HK000120_076.dat'
               file='CTE_'+ccdnr(ccdid)+'_'+strmid(hkfile,0,strlen(hkfile)-4)+'_'+$
                                             strmid(hkfile,strlen(hkfile)-3,3)+'.dat'
           ENDELSE
       ENDELSE
   ENDIF ELSE file=ctefile
  
   file=inpath+file
   
   IF (keyword_set(chatty)) THEN $
     print,'% TCCTE: Applying CTE correction to CCD '+STRTRIM(ccdid,2)
   
   cte=tcreadcte(file,bin=bin)
   
   IF (NOT keyword_set(minline)) THEN minline=0
   IF (NOT keyword_set(maxline)) THEN maxline=199
   
   IF (cte(0) EQ -1) THEN BEGIN 
       print,'% TCCTE: ERROR ****** Can not apply CTE-Correction ******'
   ENDIF ELSE BEGIN 
       ;; do correction of energies
       
       ccdind=where(data.ccd EQ ccdid)       
       FOR line=minline,maxline DO BEGIN
           lind=line-minline
           ind=where(data(ccdind).line EQ line)
           IF (ind(0) NE -1) THEN $
             data(ind).energy=data(ind).energy/(cte(data(ind).column)^lind)
       ENDFOR
       
   ENDELSE 
   
   return,data
   
END













