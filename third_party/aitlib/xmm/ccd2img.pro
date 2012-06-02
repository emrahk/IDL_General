
PRO ccd2img,path=path,ccdnum=ccdnum,img=img,nosplitcorr=nosplitcorr, $
            verbose=verbose,timemode=timemode
;+
; NAME:
;          ccd2img
;
;
; PURPOSE:
;          reads a CCD-fits file, extracts the image data and returns
;          the image
;
;
; CATEGORY:
;          IAAT XMM tools
;
;
; CALLING SEQUENCE:
;          ccd2img,path=path,ccd=ccdnum,img=img
;
; 
; INPUTS:
;          path: path to the CCD-fits file
;          ccdnum: the number of the CCD to be read (1-12)
;
;
; OPTIONAL INPUTS:
;
;
;      
; KEYWORD PARAMETERS:
;          /nosplitcorr: do not correct for split-events
;          /verbose: print a warning if the requested CCD is not found
;          /timemode: use timing mode (?!?!?)
;
;
; OUTPUTS:
;          img: array containing the image
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



img=fltarr(64,200)
pn=path+'/pn_ccd'+strtrim(ccdnum,1)+'.fits'
phaname=path+'/spec_'+strtrim(ccdnum,1)+'.pha'
exposure=0.
f=file_exist(pn)
IF (f EQ 1) THEN BEGIN 
    pnspec,spectrum,auxfile=path+'/pn_aux.fits',pnfile=pn,exposure=exposure, $
      rawx=rawx,rawy=rawy,nosplitcorr=nosplitcorr,timemode=timemode
    FOR i=0L,n_elements(rawx)-1 DO BEGIN 
        img(rawx(i),rawy(i))=img(rawx(i),rawy(i))+1
    ENDFOR 
END ELSE BEGIN
    IF (keyword_set(verbose)) THEN BEGIN 
        print,'WARNING: CCD #',strtrim(ccdnum,1),' not found, skipping'
    END 
END 

END 
