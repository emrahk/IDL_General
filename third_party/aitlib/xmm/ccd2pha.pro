PRO ccd2pha,path=path,ccdnum=ccdnum,exposure=exposure, $
            nosplitcorr=nosplitcorr,timemode=timemode
;+
; NAME:
;          ccd2pha
;
;
; PURPOSE:
;          read a CCD-fits file and create a spectrum. The spectrum is
;          written to disk as ccd_spec_[ccdnum].pha
;
;
; CATEGORY:
;          IAAT XMM tools
;
;
; CALLING SEQUENCE:
;          ccd2pha,path=path,ccd=ccdnum,exposure=exposure
;
; 
; INPUTS:
;          path: the path to the CCD-fits file
;          ccdnum: the number of the CCD to be read
;          exposure: the exposure time of the observation
;
;
; OPTIONAL INPUTS:
;
;
;      
; KEYWORD PARAMETERS:
;          /nosplitcorr: do not correct for split events
;          /timemode: use timing mode data. Default is imaging data
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
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;          Version 0.1 1999/03/25 Ingo Kreykenbohm
;                                 (kreyken@astro.uni-tuebingen.de)
;
;-

IF (n_elements(ccdnum) EQ 0) THEN ccdnum=1

pn=pfad+'/pn_ccd'+strtrim(num,1)+'.fits'
phaname=pfad+'/ccd_spec_'+strtrim(num,1)+'.pha'
f=file_exist(pn)
IF ( f EQ 1) THEN BEGIN 
    pnspec,spectrum,auxfile=pfad+'/pn_aux.fits',pnfile=pn,exposure=exposure
    writepha,spectrum,sqrt(spectrum),phaname,response='epn_new_rmf.fits', $
      telescope='SciSim2.0',instrument='EPN',exposure=exposure,/poisson, $
      arf='epn_thin_arf.fits'
ENDIF 
END 
