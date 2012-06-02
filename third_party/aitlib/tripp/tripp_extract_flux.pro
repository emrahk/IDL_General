PRO TRIPP_EXTRACT_FLUX, logname, $
                        silent=silent, no_cntrd=no_cntrd, intup=intup,$
                        framenumbers=framenumbers, frameshift=frameshift, $
                        recycle=recycle, skyfit=skyfit
;+
; NAME:
;	TRIPP_EXTRACT_FLUX
;	
; PURPOSE:   
;
;	Automatical reduction of CCD frames to extract photometrical
;	time series. Needs aperture mask stored in file <mask_file> 
;	and a catalog of reference star positions <pos_file>, created by
;	programs TRIPP_DEFINE_MASK and TRIPP_REDUCTION.
;
; CATEGORY:
;
;	Astronomical Aperture Photometry 
;
; CALLING SEQUENCE:
;
;	TRIPP_EXTRACT_FLUX, logname [,/intup, /silent, /no_cntrd,
;                           framenumbers=framenumbers,
;                           frameshift=frameshift, /recycle, /skyfit]
;
;
; INPUTS:
;      
;       logname:          Logfile, containing information about where
;                         to find both the original and the reduced
;                         images, the mask file, and the pos file, which
;                         will all be needed here
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;        silent:          Create no plots during run
;        no_cntrd:        Do not try to re-center aperture on star
;        intup:           Add up all the (reduced) images  
;        framenumbers:    Number of exposures per frame
;        frameshift:      Pixels by which each exposure is shifted with
;                         respect to the previous one
;        recycle:         re-use old flux file and amend it
;        skyfit:          display sky levels from tripp_rad_plot as
;                         compared to tripp_flux
;
; OUTPUTS:
;
;	IDL save <flux_file> containing fluxes and areas in masks.
;
;
; OPTIONAL OUTPUTS:
;
;        If the /intup keyword is set, a fits file with the sum of all
;        images (correctly shifted onto each other) will be produced
;
;
; COMMON BLOCKS:
;        none
;
;
; SIDE EFFECTS:
;
;        If the silent keyword is not set, up to three displays
;        (window 0, 1 and 2)
;        will be created during the run and destroyed at its end
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
;
;       Version 1.0, 1996      , Ralf Geckeler -- CCD_PRED
;       Version 2.0, 1999/02/06, Jochen Deetjen
;       Version 2.1, 1999/02/06, Stefan Dreizler; keyword silent added
;       Version 2.1, 2000/11   , Sonja L. Schuh: added keyword no_cntrd   
;       Version 2.1  2001/01   , S.L. Schuh, change image to
;                                  long(image) after READFITS
;       Version 2.2  2001/02   , S.L. Schuh, defaulted silent to zero,
;                                added display of extraction areas for
;                                each image  
;                    2001/02   , SLS, added messages 
;                    2001/02   , SLS, added intup keyword and
;                    calculations
;                    2001/02   , SLS, adapted calls to tripp_tv to
;                                correct handling of different image
;                                sizes, also for /intup
;                                SLS, exptime array is new
;       Version 2.3  2001/05   , S.L. Schuh, more tests for frame
;                                transfer method from BUSCA, correct time
;                                stamps still missing but at least has
;                                differential time marks now
;                                undone: SLS, avoid error in mmm via
;                                tripp_tv if image to display has
;                                negative entries (i.e. in
;                                "reduced" overscan area)
;                    2001/05   , SLS, switched to 
;                                tripp_read_pos 
;                                added recycle capabilities 
;                    2001/05   , SLS, skyfit keyword, no action on
;                                data 
;                    2001/06   , SLS, added variable extraction radius
;                    2001/06   , SLS,  debugged recycling for auto
;                                radius
;                    2001/07   , SLS, suppress *all* windows if silent
;                                is set (a bug had been introduced here
;                                together with radauto)
;-
   
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_EXTRACT_FLUX:    No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_EXTRACT_FLUX:    The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_EXTRACT_FLUX:    Using Logfile ', logname 
    ENDIF
  ENDELSE
  
  IF NOT KEYWORD_SET(no_cntrd) THEN no_cntrd=0
  
  xmax=500
  ymax=500
  
  ;; ---------------------------------------------------------
  ;; --- READ IN LOG FILE ---
  ;;
  TRIPP_READ_IMAGE_LOG, logName, log
  
  
  ;; ---------------------------------------------------------
  ;; --- FRAME SHIFT PREPARATIONS ---
  ;;
  IF NOT exist(framenumbers) THEN framenumbers=1
  IF NOT exist(frameshift)   THEN frameshift  =0

  ;; ---------------------------------------------------------
  ;; --- DEFINITIONS ---
  ;;
  
  hside    = FIX( log.mask_bw /2.0d0 )
  
  rad      = DBLARR( log.extr_nrr )
  
  sx_shift = DBLARR( log.mask_nrs )                      ;; coordinates in current frame
  sy_shift = DBLARR( log.mask_nrs )       
  bx_shift = DBLARR( log.mask_nrs, 6 )                   ;; 6 backgrounds
  by_shift = DBLARR( log.mask_nrs, 6 )
  
  fluxs    = DBLARR( log.mask_nrs, log.nr*framenumbers, log.extr_nrr) ;; flux inclusive background
  fluxsauto= DBLARR( log.mask_nrs, log.nr*framenumbers)               ;; flux for variable aperture
  fluxb    = DBLARR( log.mask_nrs, log.nr*framenumbers)               ;; background flux
  areas    = DBLARR( log.mask_nrs, log.nr*framenumbers, log.extr_nrr) ;; area including source
  areasauto= DBLARR( log.mask_nrs, log.nr*framenumbers)                             ;; area for variable aperture
  areab    = DBLARR( log.mask_nrs, log.nr*framenumbers)               ;; area of background

  
  ;; flag=1 : Source out of frame
  ;; flag=2 : Source not found with CCD_CNTRD algorithm
  ;; flag=3 : Reference star not found
  ;; flag=4 : Flux aperture partially out of frame
  ;;
  flag     = INTARR( log.mask_nrs, log.nr*framenumbers )
  time     = DBLARR( log.nr*framenumbers )
  exptime  = DBLARR( log.nr*framenumbers )
  nxy      = INTARR( 2 )
  
  ;; ---------------------------------------------------------
  ;; --- CREATE ARRAY WITH LOG.EXTR_NRR RADII BETWEEN MIN & MAX
  ;;
  rad    = DOUBLE( log.extr_minr ) + $
    DINDGEN( log.extr_nrr ) / DOUBLE( log.extr_nrr ) * $
    (DOUBLE( log.extr_maxr ) - DOUBLE( log.extr_minr ))
  
  
  ;; ---------------------------------------------------------
  ;; --- READ POSITION REFERENCE FILE ---
  ;;
  TRIPP_READ_POS, log, files, rx, ry, start, silent=silent

  ;; ---------------------------------------------------------
  ;; --- READ APERTURE MASK ---
  ;;
  maskFile = STRTRIM( log.out_path, 2 ) + '/' + log.mask
  IF (findfile(maskFile))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT, '% TRIPP_EXTRACT_FLUX:    The specified maskfile ',maskFile,' does not exist.'
    PRINT, '                         You should first run '                         
    PRINT, ' '    
    PRINT, '                         tripp_define_mask,"',logname,'"'                 
    PRINT, ' '    
    PRINT, '                         Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF NOT KEYWORD_SET(silent) THEN print,"% TRIPP_EXTRACT_FLUX: Restoring maskfile  ",maskfile
    RESTORE, maskFile
  ENDELSE

;; ---------------------------------------------------------
;; --- RECYCLE PREPARATIONS: READ EXISING FLUX FILE ---
;;
  IF KEYWORD_SET(recycle) THEN BEGIN
    fluxfile=STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.flux, 2 )
    result=findfile(fluxfile,count=count)
    IF count NE 0 THEN BEGIN
      TRIPP_RECYCLE_FLUX, fluxfile, fluxs, fluxsauto, fluxb, areas, areasauto, areab, $
        flag, time, files, exptime, framenumbers, start 
    ENDIF ELSE BEGIN
      PRINT,"% TRIPP_EXTRACT_FLUX: A fluxfile does not exist so far;"
      PRINT,"                  /recycle keyword will be ignored!"
      recycle = 0
      wait,1
    ENDELSE
  ENDIF

  ;; ---------------------------------------------------------
  ;; --- PROCESS FILES ---
  ;;
  FOR idx=0, log.nr-1 DO BEGIN
    
    PRINT, '% TRIPP_EXTRACT_FLUX: Processing file :   ', files[idx]
    image     = READFITS( files[idx], header, silent=silent )
    image     = long(image)
    ;; --- size of image
    ;;
    si       = SIZE( image )
    log.xsize = si[1] - 1
    log.ysize = si[2] - 1
    nxy[0:1] = si[1:2]
    new_image_size = 0
    IF idx GT 0 THEN BEGIN
      IF log.xsize NE old_xsize OR log.ysize NE old_ysize THEN new_image_size = 1   
    ENDIF 
    IF silent EQ 0 THEN BEGIN
      IF idx EQ 0 OR new_image_size EQ 1 THEN BEGIN 
        TRIPP_TV,image, title='Flux extraction',/silent, window=0,xmax=xmax,ymax=ymax ;,dynamics=2,/old 
      ENDIF ELSE  TRIPP_TV,image, /nowin,       /silent, window=0,xmax=xmax,ymax=ymax ;,dynamics=2,/old
      XYOUTS, 5., 5., files[idx], charsize=2
      IF KEYWORD_SET(skyfit) THEN begin
        window,1,title="Control of background determination",xsize=xmax,ysize=ymax/2.
        wset,0
      ENDIF
    ENDIF
    
    ;; --- get time
    ;;
    IF silent EQ 0 THEN PRINT,'% TRIPP_EXTRACT_FLUX: get julian date for '+files[idx]
    TRIPP_GET_GJD, files[idx], ti, log.instrument, log=log, etime=etime

    ;; --- LOOP OVER ALL EXPOSURES IN A FRAME
    FOR j=0,framenumbers-1 DO BEGIN
      
      time[idx*framenumbers+j]    = ti $ ; DAS IST NOCH NICHT SO DAS WAHRE !!!
        - (etime/86400.0d0)*((framenumbers-1)/2.+j)
      exptime[idx*framenumbers+j] = etime

      ;; --- get absolute position of all sources and backgrounds
      ;; --- in the current image
      ;;
      sx_shift = sx + rx[idx]                ;; expected coordinates in current frame
      sy_shift = sy + ry[idx] + frameshift*j ;; shift is expected to be in y direction
      IF j EQ framenumbers-1 then sy_shift = sy + ry[idx] + frameshift*(j+1) ;; last image 
      
      FOR b = 0, 5 DO BEGIN
        bx_shift[*,b] = bx[*,b] + sx_shift
        by_shift[*,b] = by[*,b] + sy_shift
      ENDFOR
      
      
      ;; --- determine flux of all sources and backgrounds in
      ;; --- the current image
      ;;
      FOR k = 0, log.mask_nrs-1 DO BEGIN
        
        ;; --- (1) check whether star is in frame, else next source
        ;;
        IF ((sx_shift[k] LT 0) OR (sx_shift[k] GT nxy[0]-1) OR $
            (sy_shift[k] LT 0) OR (sy_shift[k] GT nxy[1]-1)) THEN BEGIN $
          flag[k,idx*framenumbers+j]=1
          GOTO,NSOURCE
        ENDIF      
        
        ;; --- (2) find source, get exakt coordinates from CCD_CNTRD,
        ;; ---    if not available, use predicted source position and
        ;; ---    set flag=2
        ;;
        
        IF no_cntrd EQ 0 THEN BEGIN
          CCD_CNTRD, image, sx_shift[k], sy_shift[k], xcen, ycen, log.mask_sr,silent=silent
          IF ((sx_shift[k]-xcen) GT 2. OR (sy_shift[k]-ycen) GT 2.) THEN BEGIN
            PRINT,'% TRIPP_EXTRACT_FLUX: CCD_CNTRD Warning: Problems with re-centering'
          ENDIF
        ENDIF ELSE BEGIN  
          xcen=-1 
          PRINT,'% TRIPP_EXTRACT_FLUX: Setting xcen = -1 to avoid re-centering'
        ENDELSE
        
        IF (xcen EQ -1) THEN BEGIN
          flag[k,idx*framenumbers+j]=2
          
          ;; --- use predicted source coordinates instead
          xcen=sx_shift[k]
          ycen=sy_shift[k]
        ENDIF
        
        
        IF silent EQ 0 THEN XYOUTS, xcen, ycen, '    ' + sname[k], $
          charsize=2, charthick=3

        ;; --- (3) determine flux in circular aperture centered at source
        ;;
        FOR r = 0, log.extr_nrr-1 DO BEGIN
          
          ;; --- oplot aperture
          IF silent EQ 0 THEN BEGIN
            IF float(rad[r]) EQ float(log.relflx_sr) THEN BEGIN
              thick=3
              color=0
            ENDIF ELSE BEGIN
              thick=1
              color=100
            ENDELSE
            TRIPP_QUAD, rad[r], xcen, ycen, /circ, thick=thick, color=color
          ENDIF             

          ;; --- extraction
          TRIPP_FLUX, image, rad[r], xcen, ycen, flux, area, sub=5, silent=silent
          
          fluxs[k,idx*framenumbers+j,r] = flux
          areas[k,idx*framenumbers+j,r] = area
          IF (flux EQ 0.0) THEN flag[k,idx*framenumbers+j]=4
          
        ENDFOR

        ;; --- (3a) determine flux in circular aperture centered at source
        ;;          with automatically determined size of factor*fwhm

        ;; --- find aperture  (for k=0 only, then keep fixed for the
        ;;                     other sources)
        IF k EQ 0 THEN begin
          circ    = 2*log.extr_maxr
          TRIPP_RAD_PLOT, image, xcen, ycen, circ, a=a, count=count, /silent
          fwhm    = 2.  * sqrt(2.d)*a[2] * sqrt(alog(2.d))
          radauto = 2.25 * fwhm
        endif

        ;; --- oplot aperture
        IF silent EQ 0 THEN TRIPP_QUAD, radauto, xcen, ycen, /circ, thick=thick, color=1

        ;; --- extraction
        TRIPP_FLUX, image, radauto, xcen, ycen, flux, area, sub=5, silent=silent
        fluxsauto[k,idx*framenumbers+j] = flux
        areasauto[k,idx*framenumbers+j] = area

        ;; --- (4) determine flux in background apertures
        ;;
        FOR b = 0, 5 DO BEGIN
          
          ;; --- oplot aperture
          IF silent EQ 0 THEN BEGIN
            TRIPP_QUAD, hside, bx_shift[k,b], by_shift[k,b], thick=3, color=0
          ENDIF             
          
          ;; --- extraction
          TRIPP_FLUX, image, hside, bx_shift[k,b], by_shift[k,b], flux, area,$
            /quad, n_sigma=3, sub=5, silent=silent
          
          fluxb[k,idx*framenumbers+j] = fluxb[k,idx*framenumbers+j] + flux
          areab[k,idx*framenumbers+j] = areab[k,idx*framenumbers+j] + area
          
        ENDFOR
        
        IF silent EQ 0 AND KEYWORD_SET(skyfit) THEN BEGIN
          wset,1
          circ=log.mask_dist+2*hside
          bgflux=fluxb[k,idx*framenumbers+j]/areab[k,idx*framenumbers+j]
          estimate=[mean( $
                          image[xcen-fix(0.5*log.mask_sr):xcen+fix(0.5*log.mask_sr), $
                                ycen-fix(0.5*log.mask_sr):ycen+fix(0.5*log.mask_sr)] ),$
                    0.,0.5*log.mask_sr,bgflux]
          tripp_rad_plot,image,xcen,ycen,circ,a=gauss,estimate=estimate,xval=xval,yval=yval,/sky
          wo = where(xval GT log.mask_sr)
          oplot,[0,circ],[mean(yval[wo]),  mean(yval[wo])],  thick=3,color=20
          oplot,[0,circ],[median(yval[wo]),median(yval[wo])],thick=3,color=40
          oplot,[0,circ],[gauss[3],        gauss[3]],        thick=3,color=60
          oplot,[0,circ],[bgflux,          bgflux],          thick=3,color=80
          wset,0
          wait,1
          TRIPP_TV,image, /nowin,/silent, window=0,xmax=xmax,ymax=ymax ;,dynamics=2,/old
        ENDIF

      ENDFOR

      NSOURCE:
    ENDFOR 
    
    ;; ---------------------------------------------------------
    ;; ---INTUP ALL IMAGES ---
    ;;

    IF KEYWORD_SET(intup) THEN BEGIN
      IF idx EQ 0 THEN BEGIN
        IF log.zero_corr EQ 'no' OR log.flat_corr EQ 'no' THEN BEGIN 
          PRINT, ' '
          PRINT, ' '
          PRINT, '% TRIPP_EXTRACT_FLUX: Warning: Images should better be ZERO and FLATFIELD corrected for intup!'
          PRINT, ' '
          PRINT, ' '
          wait,2
        ENDIF
        int_image=image
        intupFile=STRTRIM( log.out_path, 2 )+'/'+ STRTRIM( log.block, 2 )+'_intup.fits'
        IF silent EQ 0 THEN BEGIN
          TRIPP_TV,int_image, $
            title='Current intup image', window=2,/silent,xmax=xmax,ymax=ymax 
        ENDIF
      ENDIF
      
      ;; --- add images WITHOUT shift applied
      ;;
;        int_image=int_image+image
;        print,'images not shifted ...'
      
      ;; --- add images WITH correct shift applied
      ;;
      x_fshift=FIX(rx[0]-rx[idx])
      y_fshift=FIX(ry[0]-ry[idx])
      
;       FOR l=0, si[1]-1 DO BEGIN
;         FOR m=0, si[2]-1 DO BEGIN
;           IF ( (l-x_fshift) GE 0) AND ( (l-x_fshift) LT si[1]) AND $
;             ( (m-y_fshift) GE 0) AND ( (m-y_fshift) LT si[2]) THEN BEGIN 
;             int_image[l,m] = int_image[l,m] + image[l-x_fshift,m-y_fshift]
;           ENDIF
;         ENDFOR
;       ENDFOR

      ;; --- add images WITH correct shift applied - alternative
      ;;
      IF idx EQ 0 THEN BEGIN
        l=indgen(si[1])
        m=indgen(si[2])
      ENDIF
      ind_l=where(  (  (l-x_fshift) GE 0) AND (  (l-x_fshift) LT si[1])  )
      ind_m=where(  (  (m-y_fshift) GE 0) AND (  (m-y_fshift) LT si[2])  )
      FOR len=ind_l[0],ind_l[n_elements(ind_l)-1] DO BEGIN
        int_image[len,ind_m] = int_image[len,ind_m] + image[len-x_fshift,ind_m-y_fshift]
      ENDFOR

      IF silent EQ 0 THEN BEGIN
        TRIPP_TV,int_image, /nowin, window=2,/silent,xmax=xmax,ymax=ymax
      ENDIF
    ENDIF
    
    ;; --- conserve old image size
    old_xsize=log.xsize
    old_ysize=log.ysize

    ;; --- Set loop counter according to recycle 
    IF KEYWORD_SET(recycle) THEN BEGIN
      idx = start-1
      recycle = 0               ;only do this once!
    ENDIF

  ENDFOR


  ;; ---------------------------------------------------------
  ;; --- SAVE RESULT ---
  ;;
  fluxFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.flux, 2 )
  
  shift  = 0
  starID = log.starID
  SAVE, filename=fluxFile, fluxs, fluxb, areas, areab, rad, hside, flag, time, shift, $
    sname, starID, files, exptime, framenumbers, frameshift, fluxsauto, areasauto
  
  
  PRINT, ' '
  
  IF KEYWORD_SET(intup) THEN BEGIN
    WRITEFITS, intupFile, int_image
    PRINT, ' '
    PRINT, '% TRIPP_EXTRACT_FLUX: Saved intup image in '+intupFile
  ENDIF
  
  PRINT, '% TRIPP_EXTRACT_FLUX: Saved raw fluxes in  '+fluxFile
  PRINT, '% ==========================================================================================='
  PRINT, ' '
  
  IF silent EQ 0 THEN BEGIN
    IF KEYWORD_SET(intup) THEN WDELETE,2
    IF KEYWORD_SET(skyfit) THEN WDELETE,1
    WDELETE,0
  ENDIF
  
;; ---------------------------------------------------------
;; --- END ---
   
 END
;; ----------------------------------------
  
