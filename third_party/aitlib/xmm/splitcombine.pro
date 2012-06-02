
PRO splitcombine,pp,phaname=phaname,rawname=rawname,exposure=exposure, $
                 timemode=timemode,chatty=chatty
;+
; NAME:
;            splitcombine
;
;
; PURPOSE:
;            Read all pn-fits files produced by podf, perform split
;            event analysis, and write raw and split-corrected
;            pha-file for further analysis with XSPEC
;
;
;
; CATEGORY:
;            XMM
;
;
; CALLING SEQUENCE:
;           splitcombine,path,phaname=phaname,rawname=rawname,exposure=exposure
;
; 
; INPUTS:
;           path: path to the directory where the podf generated files reside
;           exposure: exposure time of the SciSim simulation (due to a
;                 bug the times in the podf-FITS-files are WRONG and cannot
;                 be used for the determination of the exposure time)
;
; OPTIONAL INPUTS:
;
;      
; KEYWORD PARAMETERS:
;           phaname: name of the split-corrected pha file
;           rawname: name of the pha file containing the "raw" spectrum
;           /timemode: the data is Timingmode format
;           /chatty: give some information
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;             files containing NAXIS2=0 get changed to reflect the
;             correct number of rows in the FITS file.
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;               use pnspec to perform the analysis for all files.
;
;
; EXAMPLE:
;        use SciSim to generate a SciSim file, say, ngc4258_70ksec;
;        do a 
;             podf < ngc4258_70ksec
;        and then in IDL do
;        splitcombine,'/scratch/weekly/wilms/ngc4258/', $
;            phaname='ngc70ksec.pha',rawname='ngc70ksec_raw.pha',$
;            exposure=70000.
;
;
; MODIFICATION HISTORY:
;              Version 1.0, Joern Wilms (wilms@astro.uni-tuebingen.de)
;                   1999/03/18
;              Veriosn 1.1, Ingo Kreykenbohm
;                           (kreyken@astro.uni-tuebingen.de)
;-
                 
   IF (n_elements(pp) EQ 0) THEN pp=''
   path=pp+'/'
   
   IF (n_elements(exposure) EQ 0) THEN BEGIN 
       message,'Must use exposure keyword'
   END 

   IF (n_elements(phaname) EQ 0) THEN phaname='pn_nosplit.pha'
   IF (n_elements(rawname) EQ 0) THEN rawname='pn_split.pha'


   aux='pn_aux.fits'

   auxfile=path+aux

   spectrum=fltarr(4096)
   rawspectrum=spectrum

   FOR i=1,12 DO BEGIN 
       pnfile=path+'pn_ccd'+strtrim(i,2)+'.fits'
       IF (keyword_set(chatty)) THEN print,pnfile
       pnspec,sp,rawspectrum=rsp,auxfile=auxfile,pnfile=pnfile, $
         chatty=chatty,timemode=timemode
       spectrum=spectrum+sp
       rawspectrum=rawspectrum+rsp
   END 

   IF (keyword_set(chatty)) THEN BEGIN 
       print,'Writing corrected spectrum (can take some time)'
   ENDIF 

   writepha,spectrum,sqrt(spectrum),phaname,response='epn_new_rmf.fits', $
     telescope='SciSim2.0',instrument='EPN',exposure=exposure,/poisson, $
     arf='epn_thin_arf.fits'

   IF (keyword_set(chatty)) THEN BEGIN 
       print,'Writing raw spectrum (can take some time)'
   ENDIF 
   
   writepha,rawspectrum,sqrt(rawspectrum),rawname, $
     response='epn_new_rmf.fits',telescope='SciSim2.0',instrument='EPN', $
     exposure=exposure,/poisson,arf='epn_thin_arf.fits'

END 
