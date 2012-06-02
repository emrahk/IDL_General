PRO TRIPP_NEW_IMAGE_SIZE, image, pk_srch_rds, xsize, ysize, csize, $
                          xl, xr, yl, yr, xref, yref, search 
;+
; NAME:
;           TRIPP_NEW_IMAGE_SIZE
;
;
; PURPOSE:
;           redefines position of reference source
;           and area for cross-correlation
;           when sizes of previous and current image
;           do not match 
;
;
; CATEGORY: 
;           Processing of direct images in astronomy
;
;
; CALLING SEQUENCE:
;
;           TRIPP_NEW_IMAGE_SIZE, image, pk_srch_rds, $
;                          xsize, ysize, csize, $
;                          xl, xr, yl, yr, xref, yref, search 
;                            
;
; INPUTS:
;           image : Name of current file with new size
;           pk_srch_rds : Peak search radius
;           xsize : image size in x-direction               
;           ysize : image size in y-direction 
;           csize : csize of cross-correlation area
;           search : allow CCD_CENT and CCD_CNTRD to
;                      search in search pixel distance
;
;
; OUTPUTS:
;           xl, xr, yl, yr : define area of cross-correlation
;           xref, yref : position of reference source
; 
;
; COMMON BLOCKS:
;
;           none
;
;
; SIDE EFFECTS:
;
;
; PROCEDURES: 
;
;           Requires routines from the IDL astrolib, from the
;           aitlib ($CCD$ package by R.D. Geckeler) and the 
;           TRIPP package          
;   
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;   
;           Version 1.0, 2001/02, Thomas Gleissner
;   
;-
   
   
; Define the position of the reference source in the new (smaller or
; bigger) image (i.e. the same as does "tripp_define_mask.pro")
   
PRINT, ' '
PRINT, '% TRIPP_NEW_IMAGE_SIZE: Position of reference source'
TRIPP_TV, image, xmax=700, ymax=700, title="Redefinition of the reference source",/silent
   

;; ---------------------------------------------------------
;; --- GET POSITION OF REFERENCE SOURCE
;;
PRINT, ' '
PRINT, '% TRIPP_NEW_IMAGE_SIZE: Get position of reference source (#1)'
PRINT, '% TRIPP_NEW_IMAGE_SIZE: Left mouse click   : Find source'
PRINT, '% TRIPP_NEW_IMAGE_SIZE: Middle mouse click : Accept source'


;; --- ECHO SOURCE NUMBER
;;
PRINT, " "
PRINT, "% TRIPP_NEW_IMAGE_SIZE: Source #1"


;; --- GET SOURCE POSITION
;;
REPEAT BEGIN
    cursor, x, y, /DATA
    mouse = !err
    wait, 0.5
    IF (mouse EQ 1) THEN BEGIN  
        ;; --- +0.5 -> pixel center
        CCD_CNTRD, image, x, y, xref, yref, pk_srch_rds
        IF (xref EQ -1 OR yref EQ -1) THEN BEGIN
            PRINT,'% TRIPP_REDUCTION: Warning CCD_CNTRD failed'
            xref = x
            yref = y
            search=search
        ENDIF ELSE search=0
        oplot, [xref+0.5],[yref+0.5], psym=1, symsize=5, color=0
    ENDIF
ENDREP UNTIL ((xref NE -1) AND (mouse EQ 2))

;; --- PRINT maximal intensity of source #1
;;
;PRINT, "% TRIPP_NEW_IMAGE_SIZE: Maximal intensity of source #1: ", STRTRIM( STRING(image(xref,yref)),2 ) 


;; --- RESET GRID STYLE
;;
!P.ticklen = 0
charsize=1.5
wherexout=xref-csize+csize/5.
whereyout=yref-csize+csize/5.
IF NOT KEYWORD_SET(silent) THEN BEGIN
    TRIPP_TV, image, HI=8, XMAX=500, YMAX=500, $
      title="Position reference source",/silent
    OPLOT, [xref], [yref], psym=1, symsize=5
    rad = csize
    CCD_QUAD, rad, xref, yref
    XYOUTS,wherexout,whereyout,'csize = '+strtrim(string(fix(csize)),2),charsize=charsize
    wait, 2
ENDIF

;; --- define area for cross-correlation
;;
xl = xref - csize
yl = yref - csize
xr = xref + csize
yr = yref + csize

IF (xl LT 0) THEN xl = 0
IF (xr GT xsize) THEN xr = xsize
IF (yl LT 0) THEN yl = 0
IF (yr GT ysize) THEN yr = ysize

END
















