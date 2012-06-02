PRO TRIPP_FAKE_FLUX, logName
;+
; NAME:
;	TRIPP_FAKE_FLUX
;
; PURPOSE:   
;   
;	Create faked lightcurves with an error to be set on data.
;	Used to test tripp process chain (especially the error computation)
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_FAKE_FLUX, LOGNAME = logName
;   
; INPUTS:
;	- Existing Logfile 
;
;
; OUTPUTS:
;       - IDL SAVE file *.flx
;   
;
;
; OPTIONAL KEYWORDS:

;	               
;
;	
; RESTRICTIONS:
;   
;	Input directory and filename structure as specified in Log  
;       !!! WARNING !!! DO NOT TRY ON EXISTING LOG FILES; WILL OVERWRITE *.flx !!!!
;
; REVISION HISTORY:
;       $Log: tripp_fake_flux.pro,v $
;       Revision 1.1  2003/02/20 16:48:57  goehler
;       initial version with hard coded parameters+sinus signal :0
;
;-



;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

; on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_FAKE_FLUX:   No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                    Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_FAKE_FLUX:   The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                    Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_FAKE_FLUX:   Using Logfile ', logname 
    ENDIF
  ENDELSE


;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_IMAGE_LOG, logName, log

;; ---------------------------------------------------------
;; --- DEFINE FLUX FILE ---
;;
fluxFile = log.out_path + '/' + log.flux 



;; ---------------------------------------------------------
;; create faked data
;; ---------------------------------------------------------


  ;; ---------------------------------------------------------
  ;; --- SETUP ---
  ;;

;; time distance:
delta_t = 60

;; exposure time:
exposure= 30


;; source signal expression:
expression='50.D0*(sin(0.005*!DPI*dindgen(log.nr)+1.D0))'

;; width of the point spread function (pixel)
psf_width=5.D0


;; mean source flux:
sourceflux = 5.D0

;; mean background noise:
noise=0.05D

;; mean reference flux (for each:)
refflux = (dindgen(log.mask_nrs-1)+1.D0)*sourceflux/2.d0


  ;; ---------------------------------------------------------
  ;; --- VARIABLES TO FAKE ---
  ;;

  ;; -----------------------------------------------------
  ;; create dummy variables:
  framenumbers=1
  frameshift=0
  shift  = 0
  sname     = STRARR(log.mask_nrs)
  starID = log.starId
  files = ""
  ;; -----------------------------------------------------


  ;;  background mask size:
  hside    = FIX( log.mask_bw /2.0d0 )

  ;; extractions radii
  rad      = DBLARR( log.extr_nrr )

  ;; define radii according log/min/max values:
  rad    = DOUBLE( log.extr_minr ) + $
    DINDGEN( log.extr_nrr ) / DOUBLE( log.extr_nrr ) * $
    (DOUBLE( log.extr_maxr ) - DOUBLE( log.extr_minr ))
  
  ;; create source/background flux for all sources/datapoints/radii:
  fluxs    = DBLARR( log.mask_nrs, log.nr*framenumbers, log.extr_nrr) ;; flux inclusive background
  fluxb    = DBLARR( log.mask_nrs, log.nr*framenumbers)               ;; background flux

  ;; ------------------------------------------------------------
  ;; primary source flux:

  ;; create signal expression:
  dummy=EXECUTE("signal="+expression)

  fluxs[0,*,*] = randomu(seed,log.nr*framenumbers, log.extr_nrr,poisson=sourceflux,/double) $
    + noise*randomu(seed,log.nr*framenumbers, log.extr_nrr,/normal,/double)                 

      
  ;; add signal:
  FOR i = 1, log.extr_nrr-1 DO BEGIN 
      fluxs[0,*,i] =   fluxs[0,*,i] + signal
  ENDFOR  


  ;; ------------------------------------------------------------
  ;; reference fluxes:
  FOR i = 1, log.mask_nrs-1 DO BEGIN 
      fluxs[i,*,*] = randomu(seed,log.nr*framenumbers, log.extr_nrr,poisson=refflux[i-1],/double) $
        + noise*randomu(seed,log.nr*framenumbers, log.extr_nrr,/normal,/double)
  ENDFOR 

  ;; ------------------------------------------------------------
  ;; create constant background flux:
  fluxb[*,*] = noise*randomu(seed,log.mask_nrs, log.nr*framenumbers,/normal,/double)


  ;; scale flux according radii:
  FOR radnr = 0,log.extr_nrr-1 DO BEGIN 
      ;; applying gaussian PSF:
      fluxs[*,*,radnr] = fluxs[*,*,radnr] * (2.D0*gauss_pdf(rad[radnr]/psf_width)-1.D0)
  ENDFOR 


  ;; create source area depending on the radius:
  areas    = DBLARR( log.mask_nrs, log.nr*framenumbers, log.extr_nrr) ;; area including source
  FOR i =0,log.extr_nrr-1 DO BEGIN 
      areas[*,*,i] = !DPI*rad[i]^2                                    ;; pi r^2
  ENDFOR 
  
  areab    = DBLARR( log.mask_nrs, log.nr*framenumbers)               ;; area of background
  areab[*] = 6.D0*hside*hside                                         ;; is constant sqare area

  
  ;; flag=1 : Source out of frame
  ;; flag=2 : Source not found with CCD_CNTRD algorithm
  ;; flag=3 : Reference star not found
  ;; flag=4 : Flux aperture partially out of frame
  ;;
  flag     = make_array( log.mask_nrs, log.nr*framenumbers ,value=0)
  time     = dindgen( log.nr*framenumbers )*delta_t
  exptime  = make_array( log.nr*framenumbers ,/double,value=exposure)


  
  




;; --- CREATE  FLUX FILE ---
SAVE, filename=fluxFile, fluxs, fluxb, areas, areab, rad, hside, flag, $
                          time, shift, sname, starID, files,exptime,    $
                          framenumbers, frameshift


END 

