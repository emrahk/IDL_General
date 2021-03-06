PRO plotimg,path=path,nosplitcorr=nosplitcorr,verbose=verbose,img=img, $
            timemode=timemode

;+
; NAME:
;           plotimg
;
;
; PURPOSE:
;          read the 12 (or less) CCD-fits files generated by podf and 
;          plot them (arrengement as on EPIC)
;
; CATEGORY:
;          IAAT XMM Tools
;
;
; CALLING SEQUENCE:
;          plotimg,path=path
;
; 
; INPUTS:
;          path: the path to the CCD-fits files
;
;
; OPTIONAL INPUTS:
;
;
;      
; KEYWORD PARAMETERS:
;         /nosplitcorr: do not correct for split events
;         /verbose: say which CCD is currently being read
;         /timemode: use timing mode data (?!?!)
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;          img: array (400x384) containing the image
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          none
;
;
; RESTRICTIONS:
;          none
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
;-

img=fltarr(6*64,2*200)
ccdarray=[[2,0],[1,0],[0,0],[3,0],[4,0],[5,0], $
          [3,1],[4,1],[5,1],[2,1],[1,1],[0,1]]
FOR i=0,5 DO BEGIN
    IF (keyword_set(verbose)) THEN print,'reading ccd ',strtrim(i+1,1)
    ccd2img,path=path,ccdnum=i+1,img=imgtemp,/nosplitcorr,verbose=verbose, $
      timemode=timemode
    FOR x=0,63 DO BEGIN
        FOR y=0,199 DO BEGIN 
            img[ccdarray[0,i]*64+x,(399-y)]=imgtemp[x,y]
        ENDFOR 
    ENDFOR 
ENDFOR 
FOR i=6,11 DO BEGIN
    IF (keyword_set(verbose)) THEN print,'reading ccd ',strtrim(i+1,1)
    ccd2img,path=path,ccdnum=i+1,img=imgtemp,/nosplitcorr,verbose=verbose, $
      timemode=timemode
    FOR x=0,63 DO BEGIN
        FOR y=0,199 DO BEGIN 
            img[ccdarray[0,i]*64+63-x,y]=imgtemp[x,y]
        ENDFOR 
    ENDFOR 
ENDFOR 
loadct,39
tv,img
END 

