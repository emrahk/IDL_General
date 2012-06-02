PRO pcadeadmerge,lcfiles,outroot
;+
; NAME: 
;          pcadeadmerge
;
;
; PURPOSE: 
;          compute new pca deadtime file from existing ones
;
;
; FEATURES:   
;          the deadtime files (ASCII) that have been created during the
;          extraction of several PCA high resolution lightcurves in the
;          same energy band that are now to be merged (see
;          lcmerge.pro), are processed; 
;          the correct deadtime information for the merged lightcurve
;          is calculated from the individual deadtime files (names
;          constructed from ``lcfiles'') and written to a merged
;          .pcadead  output ASCII file (name constructed from
;          ``outroot'')        
;   
;
; CATEGORY: 
;          timing tools
;
;
;
; CALLING SEQUENCE: 
;          pcadeadmerge,lcfiles,outroot
;
;
;
; INPUTS:
;          lcfiles: array containing the names of the LIGHTCURVES for
;                   which the deadtime information is to be computed -- it is
;                   assumed that the names of the corresponding 
;                   .pcadead-files in the same directory have the same
;                   name as the lightcurve, except for that .lc has to be
;                   exchanged for .pcadead 
;          outroot: root of the pcadead-file to be produced -- .pcadead
;                   is added to this filename
;   
;
; SIDE EFFECTS:
;          the file outroot.pcadead is written
;
;
; RESTRICTIONS:
;          at least one lightcurve must have a corresponding .pcadead file
;
;   
; PROCEDURES USED:
;          readvle.pro, writevle.pro
;   
;
; EXAMPLE:
;          see rxte_syncseg.pro   
;   
;      
;
; MODIFICATION HISTORY:
;          Version 1.1: 2000/12/22 KP/JW, initial revision
;          Version 1.2, 2001/01/12 KP,   
;                                  changed keyword 'informational'
;                                  in message command to 'information'   
;          Version 1.3, 2001/01/28 KP, IDL header completed  
;
;-
   
   avgnum=0.
   exposure=0.
   xe=0.
   prop=0.
   coinc=0.
   pcurate=0.
   vle=0.
   disc=0.
   
   ;; Read all files with PCA deadtime information
   nfil=0
   FOR i=0,n_elements(lcfiles)-1 DO BEGIN 
       pos=strpos(lcfiles[i],'.lc')
       dead=strmid(lcfiles[i],0,pos)+'.pcadead'

       IF (file_exist(dead)) THEN BEGIN 
           nfil=nfil+1
           readvle,dead,avgnum=avgnum1,exposure=exposure1,xe=xe1,prop=prop1, $
            coinc=coinc1,pcurate=pcurate1,vle=vle1, $
             discriminator=discriminator1
           
           exposure=exposure+exposure1
           
           ;; .. compute exposure-time averaged rates
           avgnum=avgnum+avgnum1*exposure1
           xe=xe+xe1*exposure1
           prop=prop+prop1*exposure1
           coinc=coinc+coinc1*exposure1
           pcurate=pcurate+pcurate1*exposure1
           vle=vle+vle1*exposure1
           disc=disc+discriminator1*exposure1
       END 
   END 
   
   IF (nfil EQ 0) THEN BEGIN 
       message,'WARNING: No PCA-deadtime information available!', $
         /information
   END ELSE BEGIN 
       writevle,outroot+'.pcadead',avgnum=avgnum/exposure,exposure=exposure, $
         xe=xe/exposure,prop=prop/exposure, $
         coinc=coinc/exposure,pcurate=pcurate/exposure,$
         vle=vle/exposure, $
         discriminator=disc/exposure
   END 
   
END 




















