PRO TRIPP_TV, image, NOWIN=nowin, LO=lo, HI=hi, RAD=rad, QUAD=quad,$
              XMAX=xmax, YMAX=ymax, XCEN=xcen, YCEN=ycen, title=Title, $
              window=window, silent=silent, colortable=colortable, $
              old=old, abslo=abslo, abshi=abshi, dynamics=dynamics, $
              sqrt=sqrt
;+
; NAME:
;	TRIPP_TV
;	
; PURPOSE:   
;	Display a CCD image. A coordinate system with pixel
;	coordinates is established - coordinates (0,0) are lower
;	left corner of pixel 0,0.
;	Picture is autoscaled, maintaining relative scales of both axes.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	TRIPP_TV, image, [ NOWIN=nowin, LO=lo, HI=hi, RAD=rad, QUAD=quad, $
;               XMAX=xmax, YMAX=ymax, XCEN=xcen, YCEN=ycen ]
; 
; INPUTS:
;       IMAGE : 2D image array.
;
; OPTIONAL KEYWORDS:
;	X/YCEN:        Coordinates for overplotting circle or rectangle.
;	RAD   :        Overplot circular aperture with radius rad [pixel].
;       QUAD  :        Overplot rectangle with area [2*rad+1]^2 instead of circle.
;                      NOTE - in QUAD mode, the quadrangle includes only
;                      whole pixels (see TRIPP_FLUX), therefore the center
;                      of the mask may be shiftet by a fraction of a
;                      pixel in x/y and rad is converted to an integer.
;	NOWIN :        Reuse old window instead of deleting it.
;	LO    :        Lower cut for display data with lookup table
;	               is lo*sigma below mean, defaulted to 1.0.
;       HI    :        Upper cut for display data with lookup table
;                      is hi*sigma above mean, defaulted to 5.0.
;	XMAX  :        Maximum allowed x size of window for autoscaling.
;	YMAX  :        Maximum allowed y size of window for autoscaling.
;       WINDOW:        window device number
;       SILENT:        hand silent keyword to sky
;       COLORTABLE:    has the effect of loadct,colortable
;                      defaulted to 13 (Rainbow)
;       OLD   :        use scaling method as in ccd_tv
;       SQRT  :        show square root of image instead of image
;
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	If /NOWIN is not set, new window device is created,
;	else window device number is set to window
;	
; REVISION HISTORY:
;	Version 1.0, Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;                     --> original name: ccd_tv
;       Version 2.0, 1999/29/05, Jochen Deetjen: change color-table;
;                    added keyword title
;                    2001/02     SLS, re-introduced deleted parameter window   
;       Version 2.1, 2001/02     SLS, 
;                                - colortable can now be chosen
;                                  freely (except 0: this will be changed to 13)
;                                - several changes to "look" of the
;                                  code: headings, statements,
;                                  succession of definitions etc.
;                                - it seems sometimes wiser to stick with
;                                  the definitions of lowcut and
;                                  highcut; else the sky looks smooth
;                                  even when there are faint sources!
;                                  -> "old" keyword; also added
;                                  dynamics, abslo and abshi for experimenting
;                    2001/05     SLS, avoid error when image contains
;                                  negative values: produce warning
;                                  instead of halt by setting negative
;                                  values to zero for sky determination
;                    2001/06     SLS, sqrt keyword
;                    2001/07     SLS, check for keyword_set(nowin)
;                                  instead of existence of nowin (may
;                                  be 0)
;                    2002/08     SLS, use silent keyword for loadct
;
;-
  
  
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;
  
  ON_ERROR,2                    ;Return to caller if an error occurs
  
  IF NOT EXIST(image) THEN BEGIN
    MESSAGE,'Image file missing' 
  ENDIF ELSE BEGIN 
    si = SIZE(image)
    IF si[0] NE 2 THEN MESSAGE,'Image array must be 2 dimensional'
  ENDELSE
  
  IF (N_ELEMENTS(window) EQ 0) THEN window=0
  IF (N_ELEMENTS(title)  EQ 0) THEN title='TRIPP TV'
  
;; ---------------------------------------------------------
;; --- SQRT DISPLAY?
;;
  IF KEYWORD_SET(sqrt) THEN image=sqrt(image)


;; ---------------------------------------------------------
;; --- IMAGE SIZE SCALING
;;
  
  xsize = si[1]
  ysize = si[2]
  
  IF NOT EXIST(xmax) then xmax=700.0d0 else xmax=double(xmax)
  IF NOT EXIST(ymax) then ymax=700.0d0 else ymax=double(ymax)
  
  scale=(xmax/xsize)<(ymax/ysize)
  
;; ---------------------------------------------------------
;; --- IMAGE INTENSITY SCALING
;;
  IF NOT EXIST(dynamics) THEN dynamics=1.

  IF NOT EXIST(lo)  THEN lo=1.0d0*dynamics ;display cut determination
  IF NOT EXIST(hi)  THEN hi=5.0d0*dynamics

  index = where(image LT 0)
  IF n_elements(index) GT 1 THEN BEGIN
    PRINT,"% TRIPP_TV : WARNING: Setting negative intesity values of"
    PRINT,"%                     image to zero for sky determination."
    image_corr=image
    image_corr[index]=0
    SKY,image_corr,skymode,skysig,silent=silent
  ENDIF ELSE SKY,image,skymode,skysig,silent=silent

  lowcut  = skymode - lo*skysig
  highcut = skymode + hi*skysig
  
  IF NOT keyword_set(old) THEN BEGIN 
    mean    =  MEDIAN(image)
    lowcut  =  0.8*mean
    highcut =  1.4*mean
  ENDIF
  
  IF EXIST(abslo)   THEN lowcut   = abslo ELSE abslo=lowcut
  IF EXIST(abshi)   THEN highcut  = abshi ELSE abshi=highcut
  
  IF NOT KEYWORD_SET(silent) THEN BEGIN
    PRINT,"% TRIPP_TV : Lower cut value (compared to minimum)= ", $
      lowcut ,"  (",strtrim(string(min(image)),0),")"
    PRINT,"% TRIPP_TV : Upper cut value (compared to maximum)= ", $
      highcut,"  (",strtrim(string(max(image)),0),")"
  ENDIF

;; ---------------------------------------------------------
;; --- WINDOW
;;
  IF NOT KEYWORD_SET(nowin) THEN BEGIN
    
    WINDOW,window,xsize=long(scale*xsize),ysize=long(scale*ysize),title=Title	
    WSET,window
    ;; --- colortable (default: Rainbow)
    IF NOT keyword_set(colortable) THEN LOADCT,13,silent=silent ELSE $
      loadct,colortable,silent=silent 

  ENDIF ELSE wset,window
  
;; ---------------------------------------------------------
;; --- TV
;;
  cimage = CONGRID(image,long(scale*xsize),long(scale*ysize))
  TVSCL, BYTSCL(cimage,min=lowcut, max=highcut)
  
  PLOT,[0,1],[0,1],/noerase,/nodata,xsty=1,ysty=1,xrange=[0,xsize]             $
    ,yrange=[0,ysize],xmargin=[0,0],ymargin=[0,0] ;set axis scales
  
;; ---------------------------------------------------------
;; --- ADDITIONS: CCD_CIRC, CCD_QUAD
;;
  IF (EXIST(xcen) and EXIST(ycen)) THEN BEGIN
    IF (not EXIST(quad) and EXIST(rad)) THEN CCD_CIRC,rad,xcen,ycen
    IF     (EXIST(quad) and EXIST(rad)) THEN CCD_QUAD,rad,xcen,ycen
  ENDIF
  
;; ---------------------------------------------------------
;; --- END
;;
  RETURN
END



