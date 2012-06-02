PRO TRIPP_REDUCTION, logName, $
                     mouse=mouse, csize=csize, search=search, $
                     debug=debug, silent=silent, $
                     seeing=seeing, no_cut=no_cut, check=check, $
                     no_intup=no_intup, recycle=recycle, no_bad=no_bad
;+
; NAME:
;           TRIPP_REDUCTION
;
;
; PURPOSE:
;           dark- and flat field correction
;           as well as determination of shifts 
;
;
; CATEGORY: 
;           Processing of direct images in astronomy
;
;
; CALLING SEQUENCE:
;           
;           TRIPP_REDUCTION, logName [, /silent, /mouse,
;                            /debug, seeing=seeing, $
;                            csize=csize, search=search,
;                            /no_intup, /recycle]
;
;
; INPUTS:
;           logName : Name of reduction log file
;
;
; OPTIONAL INPUTS:   
;           csize    : csize of correlation area
;           search   : allow CCD_CENT and CCD_CNTRD to
;                      search in search pixel distance
;           seeing   : filename to record seeing
;
; OPTIONAL KEYWORDS:
;           silent   : create no plots during reduction
;           debug    : more output text   
;           mouse    : mark star position manually in case of trouble
;           no_intup : avoid to produce intup image
;           check    : obsolete (now: mouse)
;           no_cut   : obsolete 
;           recycle  : re-use old posfile and amend it
;           no_bad   : set bad pixels at image mean -> avoid NaN
;                      problems with ds9
;
; RESTRICTIONS:
;           file typ : FITS
;           rule for image names  : xyz0001.fits 
;                                   i.e. four digits - dot - extension 
;           name of reduced images: xyz0001_reduced.fits
;
;           even when silent is set, an image pops up as a warning
;           when the positioning process fails
;
; OUTPUTS:
;           dark- and flatfield corrected images: 
;               <imageName>_reduced.fits
;           position of one reference star in all frames: 
;               <posFile>
;
;
; OPTIONAL OUTPUTS: 
;
;           seeing file
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
;           
;
; PROCEDURES: 
;
;           Requires routines from the IDL astrolib, and from the
;           aitlib ($CCD$ package by R.D. Geckeler)
;   
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;           Version 1.0, 1999/20/04, Stefan Dreizler
;           Version 2.0, 1999/18/05, Jochen Deetjen & Thomas Rauch
;           Version 2.1  1999/12   , Stefan Dreizler no_cntrd added
;           Version 2.1  1999/12   , Stefan Dreizler no_cntrd
;                                    canceled, check and csize added
;           Version 2.2  2000/11   , seeing inherited, WDELETE and
;                                                      WINDOWSET canceled
;           Version 2.3  2000/11   , S.L. Schuh, re-normalisation of flat added
;           Version 2.3  2000/11   , S.L. Schuh, keep going even if
;                                    CCD_CNTRD fails: set
;                                    x/yref=ref_x/y and search=search
;                                    instead of 0 in that case
;           Version 2.4  2001/01   , S.L. Schuh, change image to
;                                    long(image) after READFITS
;           Version 2.5  2001/01   , S.L. Schuh, 
;                                    - changed default for csize (is now
;                                      dynamic);
;                                    - changed importance of the /no_cut
;                                      keyword: it is not necessary
;                                      any more no matter whether the
;                                      flat or bias frames are
;                                      fullframe images or have the
;                                      same size as the images, but
;                                      /no_cut can still be used as
;                                      before, i.e. it can be set when
;                                      the frame sizes are the same
;                                    - changed behavious of what
;                                      happens  when
;                                      the /check keyword is set
;                                    - added more warnings and higher
;                                      sensitivity of /check but,
;                                      unlike before, ignore a failed
;                                      correlation and re-use old
;                                      values in that case
;                                    - added /debug keyword    
;                                    - check image size for every frame
;                                      and exit if it changes
;                        2001/02   , SLS, added messages
;                        2001/02   , SLS, added bias correction from
;                                    overscan values - no rotate so far!
;                        2001/02   , SLS, added determination of
;                                    x1,x1,y1,y2 for zero and flat
;                                    from 'CCDSEC' if crval and crdelt
;                                    do not exist in the FITS file
;                                    header
;                        2001/02   , SLS, docheck changed for Thomas                                    
;           Version 2.6  2001/02   , Thomas Gleissner, Sonja L. Schuh
;                                    - double(zero) and double(flat)
;                                      instead of 
;                                      long(zero) and long(flat)
;                                    - small zero and flat are cut out
;                                      individually for each image
;                                      (this can change from one day
;                                      to the next, after all, even if
;                                      the total image size remains
;                                      the same) 
;                                    - keep big zero and flat now 
;                                    - do NOT writefits for
;                                      zero_small and flat_small
;                                    - when /debug ist set:
;                                      display the current zero_small,
;                                      flat_small and image_reduced  
;                                    - image sizes are retrieved at at
;                                      different time now
;           Version 2.7  2001/02   , Thomas Gleissner, call  
;                                    TRIPP_NEW_IMAGE_SIZE instead of
;                                    exiting in case of changed
;                                    log.xsize and log.ysizes
;                                    SLS, now still works when /debug
;                                    is set
;                                    SLS, slight change to
;                                    determination of overscan value
;                                    SLS, exchange of the order in
;                                    which reduction and define_mask
;                                    are being called (red. first then
;                                    define_mask now!); but can also
;                                    still be used in the old order
;                        2001/05   , SLS, adapted to nomenclature of
;                                    BUSCA 
;                                    SLS, define zero_small /
;                                    flat_small if correction is set
;                                    to yes but no cutting necessary
;                                    SLS, avoid error in mmm via
;                                    tripp_tv if image to display has
;                                    negative entries (i.e. in
;                                    "reduced" overscan area)
;                    2001/05   , SLS, switched to tripp_read/write_pos  
;                                    added recycle capabilities   
;                    2001/07   , SLS, destroy correlation window after
;                                    warning if /silent is set
;                    2001/07   , SLS, definition of files array should
;                                     be strarr(log.nr), not strarr(2,log.nr)
;                    2002/11   , EG , flag no_bad to deal with bad
;                                     pixels with non-finite (inf/nan) values.
;   
;-
   
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;
   
on_error,2                   ;Return to caller if an error occurs
   
IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_REDUCTION:       No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
ENDIF
IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_REDUCTION:       The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
        logname=(findfile(logname))[0]
        PRINT, '% TRIPP_REDUCTION:       Using Logfile ', logname 
    ENDIF
ENDELSE

;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_IMAGE_LOG, logName, log


;; ---------------------------------------------------------
;; --- DEFAULTS ---
;;
IF     EXIST(mouse)  THEN check  = mouse
IF NOT EXIST(check)  THEN check  = 0
IF NOT EXIST(csize)  THEN csize  = 3.*log.relflx_sr
IF NOT EXIST(search) THEN search = 0
IF NOT EXIST(debug)  THEN textoff= 1 ELSE textoff =0
IF NOT EXIST(no_intup) THEN intup= 1 ELSE intup=0
IF KEYWORD_SET(recycle) AND intup EQ 1 THEN BEGIN
  IF NOT keyword_set(silent) THEN BEGIN
    print, '% TRIPP_REDUCTION: Warning: intup does not make sense'
    print, '                   when recycling, setting intup=0  .'
    wait,1
  ENDIF
  intup=0
ENDIF
IF EXIST(no_cut) THEN BEGIN
    print, '% TRIPP_REDUCTION: Warning: Keyword no_cut is obsolete'
    wait,1
ENDIF
x_max=500
y_max=500

IF KEYWORD_SET(seeing) THEN openw,units,seeing,/get_lun


;; ---------------------------------------------------------
;; --- DEFINITIONS ---
;;
IF NOT KEYWORD_SET(silent) THEN loadct, 39

files     = STRARR(    log.nr )
center    = FLTARR( 2, log.nr )
start     = log.nr

;; ---------------------------------------------------------
;; --- RECYCLE PREPARATIONS: READ EXISING POS FILE ---
;;
IF KEYWORD_SET(recycle) THEN BEGIN
  posfile=STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.pos, 2 )
  result=findfile(posfile,count=count)
  IF count NE 0 THEN BEGIN
    TRIPP_READ_POS, log, files, rx, ry, start, silent=silent
    center[0,*]=rx
    center[1,*]=ry
  ENDIF ELSE BEGIN
    PRINT,"% TRIPP_REDUCTION: A posfile does not exist so far;"
    PRINT,"                  /recycle keyword will be ignored!"
    recycle = 0
    wait,1
  ENDELSE
ENDIF

;; ---------------------------------------------------------
;; --- READ APERTURE MASK ---
;;
maskFile = STRTRIM( log.out_path, 2 ) + '/' + log.mask
result=findfile(maskFile,count=count)
IF count NE 0 THEN BEGIN
  RESTORE, maskFile
  new_image_size = 0
ENDIF ELSE new_image_size = 1

;; --- deallocate maskFile arrays
;;
sx    = 0
sy    = 0
bx    = 0
by    = 0
sname = 0

;; ---------------------------------------------------------
;: --- READ ZERO AND FLAT IMAGE ---
;;
IF (log.zero_corr EQ 'yes') THEN BEGIN
    
    zeroFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.zero, 2 )
    PRINT, ' '
    PRINT, '% TRIPP_REDUCTION: Reading zero image ',zeroFile
    zero     = READFITS( zeroFile, h, silent=textoff )
    zero     = DOUBLE(zero)
    zero_d   = 0
ENDIF ELSE BEGIN
    zero_d     = -1
ENDELSE

IF (log.flat_corr EQ 'yes') THEN BEGIN
    
    flatFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.flat, 2 )
    PRINT, ' '
    PRINT, '% TRIPP_REDUCTION: Reading flat image ',flatFile
    flat     = READFITS( flatFile, h, silent=textoff)
    flat     = DOUBLE(flat)
    flat_d   = 0
ENDIF ELSE BEGIN
    flat_d   = -1
ENDELSE


;; ---------------------------------------------------------
;; --- BIG LOOP: REDUCTION OF ALL IMAGES ---
;;
PRINT, ' '
PRINT, "% TRIPP_REDUCTION: Reduction of ", STRTRIM(log.nr,2), " images"
IF KEYWORD_SET(recycle) THEN BEGIN
  PRINT, "                   /recycle skips the first ",STRTRIM(start,2)
ENDIF
PRINT, ' '

imageName = log.first

FOR idx = 0, log.nr-1 DO BEGIN
    
    ;; ---------------------------------------------------------
    ;; --- READ IN IMAGES AND PREPARE A FEW THINGS ---
    ;;
    
    ;; --- create names of input and output files
    ;;
    j     = idx + 1 + log.offset
    j_str = STRTRIM( j, 2 ) 
    no    = '0000'
    
    IF (j LT 10)                  THEN  pos = 3
    IF (j GE 10   AND j LT 100)   THEN  pos = 2
    IF (j GE 100  AND j LT 1000)  THEN  pos = 1
    IF (j GE 1000 AND j LT 10000) THEN  pos = 0
    
    STRPUT, no, j_str, pos
    STRPUT, imageName, no, log.nr_pos
    
    
    ;; --- Read in image 
    ;;
    inputFile  = STRTRIM( log.in_path, 2 ) + '/' + STRTRIM( imageName, 2 )
    
    PRINT, '% TRIPP_REDUCTION: Reading image         ', inputFile
    
    image      = READFITS( inputFile, header ,silent=textoff)
    image      = LONG(image)
    
    ;; --- Read fits header: size of area 
    ;;
    crval1 = fxpar(header,'crval1')
    crval2 = fxpar(header,'crval2')
    cdelt1 = fxpar(header,'cdelt1')
    cdelt2 = fxpar(header,'cdelt2')
    naxis1 = fxpar(header,'naxis1')
    naxis2 = fxpar(header,'naxis2')
    
    ;; --- size of image
    ;;
    imageSize = SIZE(image)
    log.xsize = imageSize[1] - 1
    log.ysize = imageSize[2] - 1
    
    ;; ---------------------------------------------------------
    ;; --- CALCULATE CORNER POSITIONS FOR ZERO AND FLAT IMAGES 
    ;;
    x1 = fix(crval1/cdelt1) - fix(cdelt1)-1
    x2 = x1 + fix(naxis1) - 1                       ;;- biaswidth
    y1 = fix(crval2/cdelt2) - fix(cdelt2)
    y2 = y1 + fix(naxis2) - 1

    ;; different FITS header entries: if crval or cdelt do not
    ;; exist then fxpar returns zero and x1 becomes negative;
    ;; overwrite x1,x2,y1,y2 in this case using CCDSEC and BIASSEC
    ;; RESTRICTION: overscan area has to be vertical and to the right
    IF x1 EQ -1 THEN BEGIN 
        region  = fxpar(header,'CCDSEC')
        xvaluesstart = (strsplit(region,',',/extract))[0]
        yvaluesstart = (strsplit(region,',',/extract))[1]
        xvalues      = (strsplit(xvaluesstart,'[',/extract))[0]
        yvalues      = (strsplit(yvaluesstart,']',/extract))[0]
        bregion  = fxpar(header,'BIASSEC')
        bxvaluesstart = (strsplit(bregion,',',/extract))[0]
;          byvaluesstart = (strsplit(bregion,',',/extract))[1]
        bxvalues      = (strsplit(bxvaluesstart,'[',/extract))[0]
;          byvalues      = (strsplit(byvaluesstart,']',/extract))[0]
        bx1=fix( (strsplit(bxvalues,':',/extract))[0] ) -1
        bx2=fix( (strsplit(bxvalues,':',/extract))[1] ) -1
;           by1=fix( (strsplit(byvalues,':',/extract))[0] ) -1
;           by2=fix( (strsplit(byvalues,':',/extract))[1] ) -1
        x1 = fix( (strsplit(xvalues,':',/extract))[0] ) -1
        x2 = fix( (strsplit(xvalues,':',/extract))[1] ) -1 + (bx2-bx1+1)
        y1 = fix( (strsplit(yvalues,':',/extract))[0] ) -1
        y2 = fix( (strsplit(yvalues,':',/extract))[1] ) -1
    ENDIF
    
    ;; --- create dummy zero and/or flat
    IF zero_d EQ -1 THEN BEGIN
        zero_small = dblarr(log.xsize+1,log.ysize+1) ; create a dummy zero    
        zero       = zero_small
    ENDIF
    IF flat_d EQ -1 THEN BEGIN
        flat_small = make_array(log.xsize+1,log.ysize+1, /double, value=1.0d0) ; create a dummy flat
        flat       = flat_small
    ENDIF

    ;; --- check sizes and cut (or no_cut) zero and flat accordingly
    IF log.instrument EQ "BUSCA" THEN BEGIN
      x_off = -1
      y_off = -2
    ENDIF ELSE BEGIN
      x_off = 0
      y_off = 0
    ENDELSE
    IF ( (size(image))[1] NE (size(zero))[1] ) OR $
      (  (size(image))[2] NE (size(zero))[2] ) THEN BEGIN
      IF NOT KEYWORD_SET(no_cut) THEN zero_small = zero[x1+x_off:x2+x_off,y1+y_off:y2+y_off]
    ENDIF ELSE IF zero_d NE -1 THEN zero_small = zero 
    IF ( (size(image))[1] NE (size(flat))[1] ) OR $
      (  (size(image))[2] NE (size(flat))[2]) THEN BEGIN
      IF NOT KEYWORD_SET(no_cut) THEN flat_small = flat[x1+x_off:x2+x_off,y1+y_off:y2+y_off]
    ENDIF ELSE IF flat_d NE -1 THEN flat_small = flat

    ;; --- re-norm flat_small
    ;;
    flat_small = flat_small / median(flat_small)
    
    
    ;; --- one last check
    checksizei=size(image)
    checksizez=size(zero_small)
    checksizef=size(flat_small)
    IF (checksizei[1] NE checksizez[1]) OR $
      (checksizei[2] NE checksizez[2]) THEN BEGIN
      PRINT, ' '    
      PRINT, '% TRIPP_REDUCTION: Sizes of Zero and Image  do not match:'    
      IF KEYWORD_SET(no_cut) THEN PRINT, $
        '% TRIPP_REDUCTION: You probably should not use /no_cut'    
      PRINT, ' '    
      PRINT, '%                  Exiting program now.'    
      wrongsize=1 ;return
    ENDIF
    IF (checksizei[1] NE checksizef[1]) OR $
      (checksizei[2] NE checksizef[2]) THEN BEGIN
      PRINT, ' '    
      PRINT, '% TRIPP_REDUCTION: Sizes of Flat and Image do not match:'    
      IF KEYWORD_SET(no_cut) THEN PRINT, $
        '% TRIPP_REDUCTION: You probably should not use /no_cut'    
      PRINT, ' '    
      PRINT, '%                  Exiting program now.'    
      wrongsize=1 ;return
    ENDIF
    IF EXIST(wrongsize) THEN return

    ;; ---------------------------------------------------------
    ;; --- PREPARATIONS FOR THE POSITIONING PROCESS
    ;; 
    ;; --- definition of the reference star and correlation area
    ;; --- 
    
    IF (idx EQ 0) THEN BEGIN
      
      IF new_image_size EQ 0 THEN BEGIN
        
        ;; --- define position reference star
        ;;    
        CCD_CNTRD, image, ref_x, ref_y, xref, yref, log.mask_sr, /silent
        IF (xref EQ -1 OR yref EQ -1) THEN BEGIN
          PRINT,'% TRIPP_REDUCTION: Warning CCD_CNTRD failed'
          xref = ref_x
          yref = ref_y
          search=search
        ENDIF ELSE search=0
        
        ;; --- reset grid style
        !P.ticklen = 0
        charsize=1.5
        wherexout=xref-csize+csize/5.
        whereyout=yref-csize+csize/5.
        IF NOT KEYWORD_SET(silent) THEN BEGIN
          TRIPP_TV, image, HI=8, XMAX=x_max, YMAX=y_max, $
            title="Position reference source"
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
        
        IF (xl LT 0)     then xl = 0
        IF (xr GT log.xsize) then xr = log.xsize
        IF (yl LT 0)     then yl = 0
        IF (yr GT log.ysize) then yr = log.ysize
        
      ENDIF ELSE BEGIN
        
        ;; --- reset grid style
        !P.ticklen = 0
        ;; --- define position reference source
        PRINT, ' '
        PRINT, "% TRIPP_REDUCTION: No mask file has been found: "
        PRINT, "% TRIPP_REDUCTION: Definition of the reference source will be required."
        TRIPP_NEW_IMAGE_SIZE, image, log.mask_sr, log.xsize, log.ysize, $
          csize, xl, xr, yl, yr, xref, yref, search
        
      ENDELSE
      
    ENDIF
    ;; ___ END OF PREPARATIONS
    
    ;; ---------------------------------------------------------
    ;; ---  CHECK IMAGE SIZES
    ;;
    
    new_image_size = 0
    
    ;; --- HANDLING OF DIFFERENT IMAGE SIZES
    IF idx GT 0 THEN BEGIN
        IF log.xsize NE old_xsize OR log.ysize NE old_ysize THEN BEGIN
            PRINT, ' '
            PRINT, "% TRIPP_REDUCTION: Current image size is different from previous one !"
            TRIPP_NEW_IMAGE_SIZE, image, log.mask_sr, log.xsize, log.ysize, $
              csize, xl, xr, yl, yr, xref, yref, search
            new_image_size = 1    
        ENDIF
    ENDIF

    
    ;; ---------------------------------------------------------
    ;; ---  CORRELATION AREA, CORREL_OPTIMIZE, CCD_CENT [, CHECK]
    ;;
    
    docheck=0
    
    ;; --- define current correlation areas
    corrArea = image[xl:xr,yl:yr]
    
    
    ;; --- switch grid style on
    ;;
    !P.ticklen = 0.5
    !X.ticks   = 4
    !Y.ticks   = 4
    
    ;; --- plots switched off?
    ;;
    IF NOT KEYWORD_SET(silent) THEN BEGIN
        ;; --- display correlation area
        ;;
        IF ( idx eq 0 ) OR (new_image_size EQ 1) THEN BEGIN
            TRIPP_TV, corrArea, XMAX=x_max, YMAX=y_max, $
              title="Correlation Area"
        ENDIF ELSE BEGIN
            TRIPP_TV, corrArea, XMAX=x_max, YMAX=y_max, $
              title="Correlation Area", NOWIN=1, silent=textoff
        ENDELSE
        
        XYOUTS, csize/5., csize/5., imageName, charsize=charsize
        
    ENDIF
    
    ;; --- smooth correlation area --> remove cosmics
    ;;
    imageS    = FILTER_IMAGE( corrArea, /MEDIAN, /ALL )
    IF (idx EQ 0 ) OR (new_image_size EQ 1) THEN BEGIN
        refImageS = imageS
        xoff_init = 0.
        yoff_init = 0.
    ENDIF ELSE BEGIN
        xoff_init = xshift
        yoff_init = yshift
    ENDELSE
    
    ;; --- calculate off-set by cross correlation of frame with respect to 
    ;; --- reference frame (1st frame) 
    ;;
    
    CORREL_OPTIMIZE, refImageS, imageS, xshift, yshift, $
      XOFF_INIT=xoff_init, YOFF_INIT=yoff_init, /NUMPIX 
    
    IF abs(xoff_init-xshift) GT log.relflx_sr OR abs(yoff_init-yshift) GT log.relflx_sr THEN BEGIN
        IF KEYWORD_SET(check) OR KEYWORD_SET(debug) THEN BEGIN
            print,''
            print,''
            print,'                  CORRELATION FAILED'
            print,'                  CORRELATION FAILED'
            print,''
            print,''
            wait,0.5
        ENDIF
        docheck=1
        xshift=xoff_init
        yshift=yoff_init
    ENDIF
    
    ;; --- peak search in current correlation area
    ;; --- using best guess as starting position
    ;;
    xguess = xref-xshift
    yguess = yref-yshift 
    
    
    CCD_CENT, image, x=xguess, y=yguess, xcen, ycen, FWHM=log.mask_sr, /silent, search=search
    
    IF abs(xguess-xcen) GT log.relflx_sr OR abs(yguess-ycen) GT log.relflx_sr THEN BEGIN
        IF KEYWORD_SET(check) OR KEYWORD_SET(debug) THEN BEGIN
            print,''
            print,''
            print,'                  CCD_CENT FAILED'
            print,'                  CCD_CENT FAILED'
            print,''
            print,''
            wait,0.5
        ENDIF
        docheck=1
        xcen=xguess
        ycen=yguess
    ENDIF                       ;ELSE docheck=0 ;; comment introduced for Thomas ...
    
    
    ;; --- coordinate transformation: complete image -> corr area
    ;;
    xsl = xcen-xl+1.            ; seems to be the best transformation rule
    ysl = ycen-yl+1.
    
    
    ;; --- plots switched off?
    ;;
    IF NOT KEYWORD_SET(silent) THEN BEGIN
        
        ;; --- display center position in 2D plot
        ;;
        OPLOT, [xsl,xsl], [-1.0d4,+1.0d4],color=1,thick=4
        OPLOT, [-1.0d4,+1.0d4], [ysl,ysl],color=1,thick=4
        lev1 = findgen(10)/10.*max(corrarea)
        lev2 = (.91+findgen(4)/50.)*max(corrarea)
        CONTOUR, corrArea, /OVERPLOT,color=1,levels=[lev1,lev2]
        
    ENDIF
    
    ;; --- print result of both (automatic) methods
    ;;
    IF KEYWORD_SET(debug) THEN BEGIN
        PRINT, " "
        PRINT, "% TRIPP_REDUCTION: Difference between two centering methods:"
        PRINT, "% TRIPP_REDUCTION: xdiff : ", (xguess-xcen)      , " ydiff: ", (yguess-ycen)
        PRINT, "% TRIPP_REDUCTION: Shift of the center position, compared with the last image:"
        PRINT, "% TRIPP_REDUCTION: xshift: ", xshift, " yshift: ", yshift
        PRINT, "% TRIPP_REDUCTION: Center position in the correlation area:"
        PRINT, "% TRIPP_REDUCTION: xsl   : ", xsl   , " ysl   : ", ysl
    ENDIF
    
    IF abs(xguess-xcen) GT log.relflx_sr OR abs(yguess-ycen) GT log.relflx_sr OR $
      docheck EQ 1 THEN BEGIN 
        
        ;; --- display center position in 2D plot
        ;;
        TRIPP_TV, corrArea, XMAX=x_max, YMAX=y_max, $
          title="Correlation Area",silent=textoff,nowin=nowin
        nowin=1
        OPLOT, [xsl,xsl], [-1.0d4,+1.0d4],color=100,thick=4
        OPLOT, [-1.0d4,+1.0d4], [ysl,ysl],color=100,thick=4
        lev1 = findgen(10)/10.*max(corrarea)
        lev2 = (.91+findgen(4)/50.)*max(corrarea)
        CONTOUR, corrArea, /OVERPLOT,color=1,levels=[lev1,lev2]
        XYOUTS, csize/5., csize/5., imageName, charsize=charsize
        IF KEYWORD_SET(check) THEN BEGIN
            
            ;; --- prompt user for cursor input
            ;;
            newtry:
            PRINT, " "
            PRINT, "% TRIPP_REDUCTION: problems finding target position, please choose:"
            PRINT, "% TRIPP_REDUCTION: left  mouse:   mark target"
            PRINT, "% TRIPP_REDUCTION: right mouse:   accept suggestion"
            cursor,xx,yy,/data
            mouse=!mouse.button
            
            CASE mouse OF
                1: BEGIN
                    CCD_CNTRD, corrArea, xx, yy, xsl, ysl, 3*log.relflx_sr, /silent
                    IF xsl EQ -1. OR ysl EQ -1. OR $
                      abs(xsl-xx) GT log.relflx_sr OR abs(ysl-yy) GT log.relflx_sr THEN BEGIN
                        PRINT,'% TRIPP_REDUCTION: Warning CCD_CNTRD failed, using cursor position directly'
                        xsl=xx
                        ysl=yy
                    ENDIF
                    xcen=xsl+xl-1
                    ycen=ysl+yl-1
                END
                4: PRINT,'% TRIPP_REDUCTION: manual check for this frame skipped'
                ELSE: BEGIN 
                    PRINT,'% TRIPP_REDUCTION: only left or right'
                    GOTO, newtry
                END 
            ENDCASE
            
            ;; --- plots switched off?
            ;;
            IF NOT KEYWORD_SET(silent) THEN BEGIN
                
                ;; --- display center position in 2D plot
                ;;
                TRIPP_TV, corrArea, XMAX=x_max, YMAX=y_max, $
                  title="Correlation Area",/nowin
                OPLOT, [xsl,xsl], [-1.0d4,+1.0d4],color=1,thick=4
                OPLOT, [-1.0d4,+1.0d4], [ysl,ysl],color=1,thick=4
                lev1 = findgen(10)/10.*max(corrarea)
                lev2 = (.91+findgen(4)/50.)*max(corrarea)
                CONTOUR, corrArea, /OVERPLOT,color=1,levels=[lev1,lev2]
                XYOUTS, csize/5., csize/5., imageName, charsize=charsize
                wait,1
                
            ENDIF
            
        ENDIF 
        
    ENDIF 
    
    ;; --- update shifts
    ;;
    xshift=xref-xcen
    yshift=yref-ycen
    
    ;; --- switch grid style off
    ;;
    !P.ticklen = 0.02
    
    
    ;; --- print final result
    ;;
    PRINT, ' '       
    PRINT, '% TRIPP_REDUCTION: Reference coordinates : '+ $
      STRTRIM(STRING(xcen),2)+' '+STRTRIM(STRING(ycen),2)
    
    
    
    ;; ---------------------------------------------------------
    ;; --- FIT 2D-GAUSS TO DETERMINE SEEING
    ;;
    IF KEYWORD_SET(seeing) THEN BEGIN
        x1=max([xcen-20.,0.])
        x2=min([xcen+20.,log.xsize])
        y1=max([ycen-20.,0.])
        y2=min([ycen+20.,log.ysize])
        yfit = GAUSS2DFIT(image[x1:x2,y1:y2],param)
        PRINT, ' '       
        PRINT, '% TRIPP_REDUCTION: Seeing fit parameters are'
        print,param[2],param[3],format='(2f10.4)'
        printf,units,param[2],param[3],format='(2f10.4)'
    ENDIF 
    
    
    
    ;; ---------------------------------------------------------
    ;; --- BIAS FROM OVERSCAN AREA
    ;;
    IF log.zero_corr EQ 'overscan' OR log.zero_corr EQ 'OVERSCAN' OR log.zero_corr EQ 'Overscan' THEN BEGIN 
        PRINT, " "
        PRINT, "% TRIPP_REDUCTION: Bias measurement from the overscan area is in effect"
        PRINT, " "
        rotate=0
        IF rotate EQ 0 THEN begin
            FOR line=0,log.ysize-1 DO begin 
                row   = image[*,line]
                limit = (median(row)+min(row))*0.5
                overscan_area  = WHERE(row LT limit)  
                overscan_value = MEDIAN(row[overscan_area]) 
                zero_small[*,line] = zero_small[*,line] + overscan_value
            ENDFOR
        ENDIF ELSE BEGIN
            FOR line=0,log.xsize-1 DO begin 
                row   = image[line,*]
                limit = (median(row)+min(row))*0.5
                overscan_area  = WHERE(row LT limit)  
                overscan_value = MEDIAN(row[overscan_area]) 
                zero_small[line,*] = zero_small[line,*] + overscan_value
            ENDFOR
        ENDELSE
    ENDIF
    
    ;; ---------------------------------------------------------
    ;; --- DARK SUBTRACTION, FLATFIELDING
    ;;
    
    image_reduced = ( image - zero_small ) / flat_small

    ;; set bad pixels at mean: (eg, 21.11.2002)
    IF keyword_set(no_bad) THEN BEGIN 

        ;; bad/good pixel determination
        index_bad = where(finite(image_reduced) EQ 0)
        index_good = where(finite(image_reduced))

        IF index_good[0] NE -1 AND index_bad[0] NE -1 THEN BEGIN 
            image_reduced[index_bad] = mean(image_reduced[index_good])
        ENDIF 
    ENDIF
    
    ;; --- display calibration images and reduced image
    medi=median(image_reduced)
    medz=median(zero_small)
    IF medz EQ 0. THEN medz=1.e-10
    display=fltarr(3*log.xsize+3,log.ysize+1)
    FOR pix=0,log.ysize-1 DO display[*,pix]=[image_reduced[*,pix]/medi,zero_small[*,pix]/medz,flat_small[*,pix]]
    IF KEYWORD_SET(debug) THEN BEGIN  
      IF idx EQ 0 OR (new_image_size EQ 1) THEN begin
        tripp_tv,display,xmax=700,window=1,/silent,  $
          title="Reduced Image, zero (both normalised for display only) and flat"
        CCD_QUAD, (xr-xl)/2., (xr+xl)/2., (yr+yl)/2.
        XYOUTS, csize/5., csize/5., imageName, charsize=charsize
      ENDIF ELSE BEGIN
        tripp_tv,display,xmax=700,window=1,/nowin,/silent
        CCD_QUAD, (xr-xl)/2., (xr+xl)/2., (yr+yl)/2.
        XYOUTS, csize/5., csize/5., imageName, charsize=charsize
      ENDELSE
    ENDIF
    
    
    ;; --- store result
    ;;
    off=4
    IF log.instrument EQ "BUSCA" THEN off=5 
    outputName = STRMID(  imageName, 0, log.nr_pos +off ) + '_reduced.fits'
    outputFile = STRTRIM( log.out_path, 2 ) + '/' + outputName
    
    files[idx]    = outputName
    center[0,idx] = xcen
    center[1,idx] = ycen
    
    ;; --- save reduced data as fits files
    ;;
    PRINT, ' '
    PRINT, '% TRIPP_REDUCTION: writing image ', outputFile
    
    WRITEFITS, outputFile, image_reduced, header
    

    ;; ---------------------------------------------------------
    ;; ---INTUP ALL IMAGES ---
    ;;
    
    IF KEYWORD_SET(intup) THEN BEGIN
      IF idx EQ 0 THEN BEGIN
;        IF log.zero_corr EQ 'no' OR log.flat_corr EQ 'no' THEN BEGIN 
;          PRINT, ' '
;          PRINT, ' '
;           IF log.zero_corr EQ 'no' THEN $
;             PRINT, '% TRIPP_EXTRACT_FLUX: Warning: Images should better be ZERO      corrected for intup!'
;           IF log.flat_corr EQ 'no' THEN $
;             PRINT, '% TRIPP_EXTRACT_FLUX: Warning: Images should better be FLATFIELD corrected for intup!'
;           PRINT, ' '
;           PRINT, ' '
;           wait,2
;        ENDIF
        
        intupFile=STRTRIM( log.out_path, 2 )+'/'+ STRTRIM( log.block, 2 )+'_intup.fits'
        int_image=image_reduced
        IF NOT KEYWORD_SET(silent) THEN BEGIN
          TRIPP_TV,int_image, $
            title='Current intup image', window=2,/silent,xmax=x_max,ymax=y_max 
        ENDIF
      ENDIF
      
      ;; --- add images WITH correct shift applied
      ;;
      x_fshift=FIX(center[0,0]-center[0,idx])
      y_fshift=FIX(center[1,0]-center[1,idx])
      
      IF idx EQ 0 THEN BEGIN
        l=indgen(imagesize[1])
        m=indgen(imagesize[2])
      ENDIF
      ind_l=where(  (  (l-x_fshift) GE 0) AND (  (l-x_fshift) LT imagesize[1])  )
      ind_m=where(  (  (m-y_fshift) GE 0) AND (  (m-y_fshift) LT imagesize[2])  )
      FOR len=ind_l[0],ind_l[n_elements(ind_l)-1] DO BEGIN
        int_image[len,ind_m] = int_image[len,ind_m] + image_reduced[len-x_fshift,ind_m-y_fshift]
      ENDFOR
      
      IF NOT KEYWORD_SET(silent) THEN BEGIN
        TRIPP_TV,int_image, /nowin, window=2,/silent,xmax=x_max,ymax=y_max
      ENDIF
;       window,2
;       loadct,3
;       tripp_shade3,int_image,zrange=[0000,idx*40.]
      
    ENDIF

    ;; --- delete window if silent is set but centering failed
    IF KEYWORD_SET(silent) AND docheck EQ 1 THEN BEGIN
      wdelete
      nowin=0
    ENDIF

    ;; --- conserve old image size
    old_xsize=log.xsize
    old_ysize=log.ysize
    
    
    ;; --- time to contemplate the printed output
;    IF KEYWORD_SET(debug) THEN wait,2

    ;; --- Set loop counter according to recycle 
    IF KEYWORD_SET(recycle) THEN BEGIN
      idx     = start-1
      recycle = 0                 ;only do this once!
    ENDIF
ENDFOR


;; ---------------------------------------------------------
;; --- WRITE OFF-SETS TO POSFILE, SEEING TO SEEING FILE, INTUP IMAGE
;; -   TO _INTUP.FITS FILE 
;;
TRIPP_WRITE_POS, log, files, center[0,*], center[1,*], posfile, silent=silent

IF KEYWORD_SET(intup) THEN BEGIN 
    WRITEFITS, intupFile, int_image
    PRINT, ' '
    PRINT, '% TRIPP_REDUCTION: Intup image saved in              ', intupFile
ENDIF  

IF KEYWORD_SET(seeing) THEN BEGIN 
    free_lun,units
    PRINT, ' '
    PRINT, '% TRIPP_REDUCTION: Seeing recorded in                ',seeing
ENDIF  


PRINT, ' '
PRINT,   '% TRIPP_REDUCTION: Reference star positions saved in ', posFile
PRINT, '% ==========================================================================================='
PRINT, ' '


;; --- reset grid style
!P.ticklen = 0

IF NOT KEYWORD_SET(silent) THEN BEGIN
  wdelete
  IF   KEYWORD_SET(intup)  THEN wdelete
ENDIF
IF     KEYWORD_SET(debug)  THEN wdelete

;; ---------------------------------------------------------
;; --- END ---

END

;; ---------------------------------------------------------





