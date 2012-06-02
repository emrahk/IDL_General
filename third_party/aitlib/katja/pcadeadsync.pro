PRO pcadeadsync,infile,outroot
;+
; NAME:
;          pcadeadsync
;
;
; PURPOSE:
;          writes a synchronized PCA deadtime file (in fact, just
;          copies it)
;
;
; FEATURES:    
;          a) a deadtime file (ASCII, ``infile'') corresponding to one
;          of the merged PCA high resolution lightcurves (see
;          pcadeadmerge.pro and lcmerge.pro) is copied to a file
;          (ASCII, name constructed from ``outroot'') with a name
;          corresponding to the synchronized multidimensional
;          lightcurve created from the lightcurves in different energy
;          bands (see lcsync.pro)
;          OR
;          b) a deadtime file (ASCII, ``infile'') corresponding to the 
;          synchronized multidimensional lightcurve (see a) and
;          lcsync.pro) is copied to a file (ASCII, name constructed
;          from ``outroot'') with a name corresponding to the
;          segmented multidimensional lightcurve created from the
;          synchronized lightcurve (see lcsync.pro)  
;   
;   
; CATEGORY: 
;          timing tools
;
;
;
; CALLING SEQUENCE: 
;          pcadeadsync,infile,outroot
;
;
;
; INPUTS: 
;          infile: name of the .pcadead file to be copied to outroot.pcadead
;          outroot: root of the name of the pcadead-file, gets .pcadead added
;
; SIDE EFFECTS:
;          outroot.pcadead is generated
;
;
; RESTRICTIONS:
;          infile must exist
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
; MODIFICATION HISTORY:
;          Version 1.1, 2000/12/22 JW/KP, initial revision
;          Version 1.2, 2001/01/12 KP,    
;                               changed keyword 'informative'
;                               in message command to 'information'    
;          Version 1.4, 2001/01/12 KP,    
;                               corrected idl version number   
;          Version 1.5, 2001/01/28 KP, IDL header completed    
;   
;
;-
   IF (file_exist(infile)) THEN BEGIN 
       readvle,infile,avgnum=avgnum,exposure=exposure,xe=xe,prop=prop, $
         coinc=coinc,pcurate=pcurate,vle=vle, $
         discriminator=discriminator
       writevle,outroot+'.pcadead',avgnum=avgnum,exposure=exposure,xe=xe,$
         prop=prop,coinc=coinc,pcurate=pcurate,vle=vle, $
         discriminator=discriminator
   END ELSE BEGIN 
       message,'Not performing pcadeadsync',/information
   END 
END 
   
  
