PRO writevle,file,avgnum=avgnum,exposure=exposure,xe=xe,prop=prop, $
             coinc=coinc,pcurate=pcurate,vle=vle, $
             discriminator=discriminator
;+
; NAME: 
;          writevle
;
;
;
; PURPOSE:
;          write the ASCII file containing the PCA deadtime information
;
;
; FEATURES:
;          write the ASCII file ``file'' containing the PCA deadtime
;          information averaged over the corresponding observation
;          segment; the optional inputs are: the number of
;          PCUs ``avgnum'', the exposure ``exposure'', the
;          Xenon/Propane/coincident/total/vle count rates PER PCU
;          (``xe'',``prop'',``coinc'',``pcurate'',``vle''), and the
;          PCA deadime setting (``discriminator'')    
;          ... all are set to 0 if not given --> better give reasonable values!
;   
;   
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          writevle,file,avgnum=avgnum,exposure=exposure,xe=xe,prop=prop, $
;                   coinc=coinc,pcurate=pcurate,vle=vle, $
;                   discriminator=discriminator   
;
;
; INPUTS:
;          file: name of the ``*pcadead'' file to be written
;
;
; OPTIONAL INPUTS:
;          avgnum        : average number of PCU switched on during the
;                          determination of the housekeeping information
;          exposure      : total exposure time on which rates are based
;          xe            : average Xenon count rate PER PCU
;          prop          : average Propane count rate PER PCU
;          coinc         : average count rate of coincident events PER PCU
;          pcurate       : total counting rate PER PCU (for 10mus deadtime)
;          vle           : total VLE rate PER PCU
;          discriminator : average VLE counter setting of the PCA, should
;                          be an integer... 
;          ... all are set to 0 if not given --> better give reasonable values!
;
;   
; PROCEDURES USED:
;          none
;
;
; EXAMPLE:
;          see pcadeadmerge.pro and pcadeadsync.pro   
;   
;   
; MODIFICATION HISTORY:
;          Version 1.1, 2001/12/22 KP, initial revision
;          Version 1.2, 2001/01/12 KP,    
;                                  changed keyword 'informational'
;                                  in message command to 'information'
;          Version 1.3, 2001/01/28 KP, IDL header completed   
;   
;   
;-
   
   IF (n_elements(avgnum) EQ 0) THEN avgnum=0
   IF (n_elements(exposure) EQ 0) THEN exposure=0.
   IF (n_elements(xe) EQ 0) THEN xe=0.
   IF (n_elements(prop) EQ 0) THEN prop=0.
   IF (n_elements(coinc) EQ 0) THEN coinc=0.
   IF (n_elements(pcurate) EQ 0) THEN pcurate=0.
   IF (n_elements(vle) EQ 0) THEN vle=0.
   IF (n_elements(discriminator) EQ 0) THEN discriminator=0
   
   IF (abs(xe+prop+coinc-pcurate) GE 1E-2) THEN BEGIN 
       message,'Xe, Prop, and coincident rates do not add up!', $
         /information
   ENDIF 
   
   openw,unit,file,/get_lun
   
   printf,unit,'AVG NUM PCU: ',strtrim(string(avgnum),2)
   printf,unit,'Exposure: ',strtrim(string(exposure),2)
   printf,unit,'Good Xe rate per PCU: ',strtrim(string(xe),2)
   printf,unit,'Good Propane rate per PCU: ',strtrim(string(prop),2)
   printf,unit,'Coincident Events rate per PCU: ',strtrim(string(coinc),2)
   printf,unit,'TOTAL deadtime causing rate per PCU: ', $
     strtrim(string(pcurate),2)
   printf,unit,'VLE-Rate per PCU: ',strtrim(string(vle),2)
   printf,unit,'AVG VLE Discriminator: ',strtrim(string(discriminator),2)
   
   free_lun,unit

END 





