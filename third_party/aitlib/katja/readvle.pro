PRO readvle,file,avgnum=avgnum,exposure=exposure,xe=xe,prop=prop, $
            coinc=coinc,pcurate=pcurate,vle=vle, $
            discriminator=discriminator,level=level
;+
; NAME: 
;          readvle
;
;
;
; PURPOSE:
;          read the ASCII file containing the PCA deadtime information
;
;
; FEATURES: 
;          read the ASCII file ``file'' containing the PCA deadtime
;          information averaged over the corresponding observation
;          segment; see writevle.pro for the definition of the
;          file structure; the optional outputs are: the number of
;          PCUs ``avgnum'', the exposure ``exposure'', the
;          Xenon/Propane/coincident/total/vle count rates PER PCU
;          (``xe'',``prop'',``coinc'',``pcurate'',``vle''), and the
;          PCA deadime setting (``discriminator'',``level'')  
;   
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          readvle,file,avgnum=avgnum,exposure=exposure,xe=xe,prop=prop, $
;                  coinc=coinc,pcurate=pcurate,vle=vle, $
;                  discriminator=discriminator,level=level   
;
;
; INPUTS:
;          file: name of the ``*.pcadead'' file to be read (see
;                writevle.pro for the definition of the file structure)
;
;
; OPTIONAL OUTPUTS:
;          avgnum        : average number of PCUs switched on during the
;                          determination of the housekeeping information
;          exposure      : total exposure time on which rates are based
;          xe            : average Xenon count rate PER PCU
;          prop          : average Propane count rate PER PCU
;          coinc         : average count rate of coincident events PER PCU
;          pcurate       : total counting rate PER PCU (for 10mus deadtime)
;          vle           : total VLE rate PER PCU
;          discriminator : average VLE counter setting of the PCA, should
;                          be an integer (test for deviation from the
;                          next integer value is performed, if
;                          this deviation is larger than 0.01, the
;                          program stops)  
;          level         : defined as fix(discriminator+0.5)
;
; RESTRICTIONS:
;          no checks are performed whether the file really IS a
;          .pcadead file.
;
;
; PROCEDURES USED:
;          none     
;
;
; EXAMPLE:
;          readvle,'FS3b_98bc7e0-98bcdb0__excl_8_20-30.pcadead', $
;                  pcurate=pcurate,vle=vle
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 2000/12/10 KP, initial revision   
;          Version 1.2, 2001/12/22 KP, changed or new routine to allow
;                                  the performance of the PCA VLE
;                                  deadtime correction (added header,
;                                  all arguments read) 
;          Version 1.3, 2001/01/28 KP, IDL header completed
;
;   
;-
   
   openr,unit,file,/get_lun   

   zeile=''

   readf,unit,zeile & doppel=strpos(zeile,':')
   avgnum=float(strmid(zeile,doppel+1))
   readf,unit,zeile & doppel=strpos(zeile,':')
   exposure=float(strmid(zeile,doppel+1))
   readf,unit,zeile & doppel=strpos(zeile,':')
   xe=float(strmid(zeile,doppel+1))
   readf,unit,zeile & doppel=strpos(zeile,':')
   prop=float(strmid(zeile,doppel+1))
   readf,unit,zeile & doppel=strpos(zeile,':')
   coinc=float(strmid(zeile,doppel+1))
   readf,unit,zeile & doppel=strpos(zeile,':')
   pcurate=float(strmid(zeile,doppel+1))
   readf,unit,zeile & doppel=strpos(zeile,':')
   vle=float(strmid(zeile,doppel+1))
   readf,unit,zeile & doppel=strpos(zeile,':')
   discriminator=float(strmid(zeile,doppel+1))
   
   free_lun,unit

   level=fix(discriminator+0.5)
   IF (abs(discriminator-level) GT 1E-2) THEN BEGIN 
       message,'redvle: error in determination of the deadtime setting'
   ENDIF 


END 
















