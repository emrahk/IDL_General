PRO TRIPP_CALC_RELFLUX, logName, rectify=rectify,silent=silent
;+
; NAME:
;	TRIPP_CALC_RELFLUX
;
;
; PURPOSE:   
;   
;	(Statistical) analysis of flux data from
;	photometrical time series.
;
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_CALC_RELFLUX, LOGNAME = logName, $
;                  rectify=rectify,silent=silent
;   
; INPUTS:
;	
;       IDL SAVE file *.FLX
;
;
; OPTIONAL INPUTS:   
;	
;
; OPTIONAL KEYWORDS:
;
;	rectify
;       silent
;
; OUTPUTS:
;   
;	IDL SAVE files '*.*.RMS' containing statistical data.
;       IDL SAVE file    '*.RMS' containing statistical data.
;
;	
; RESTRICTIONS:
;   
;       file type:      FLX as produced by TRIPP_EXTRACT_FLUX or CCD_PRED
;	Input directory and filename structure as specified in Log  
;
; REVISION HISTORY:
;   
;       Version 1.0, 1996/08, Ralf Geckeler -- CCD_RMS
;       Version 2.0, 1999/06, Sonja Schuh, Stefan Dreizler
;                    2001/02  SLS, added messages 
;                    2001/02  SLS, comparison for radii needs to be
;                                 done in floats
;                             SLS, added /rectify keyword 
;                    2001/03  SLS, fneu should now make sense for all 
;                                  stars including the reference stars
;                                  added calculation and saving of therr
;                    2001/05 SLS, adapted to frame transfer method
;                                 (keywords frame*) 
;                                 added /silent keyword for use with 
;                                 the quicklook option
;                    2001/12 SD,  check for existence of exptime in
;                                 save file                                 
;-


;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_CALC_RELFLUX:    No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_CALC_RELFLUX:    The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_CALC_RELFLUX:    Using Logfile ', logname 
    ENDIF
  ENDELSE


;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_IMAGE_LOG, logName, log

;; ---------------------------------------------------------
;; --- DEFINITIONS I ---
;;
IF (NOT EXIST(n_sigma)) THEN n_sigma = 5

rad      = DBLARR( log.extr_nrr )        

;; ---------------------------------------------------------
;; --- READ FLUX FILE ---
;;
fluxFile = log.out_path + '/' + log.flux 

RESTORE, fluxFile

;; fluxFile wurde hergestellt ueber 
;; SAVE, filename=fluxFile, fluxs, fluxb, areas, areab, rad, hside, flag, $
;;                          time, shift, sname, starID, files,exptime,    $
;;                          framenumbers, frameshift, fluxsauto, areasauto

if not exist(exptime) then exptime = dblarr(n_elements(time)) + 1.

;; ---------------------------------------------------------
;; --- DEFINITIONS II ---
;;
IF NOT EXIST(framenumbers) THEN framenumbers = 1
IF NOT EXIST(frameshift)   THEN frameshift   = 0
flux     = DBLARR( log.mask_nrs,log.nr*framenumbers )
fneu     = DBLARR( log.mask_nrs,log.nr*framenumbers )
fref     = DBLARR( log.nr             *framenumbers )


                         ;; ====================================================

FOR s = 0, log.extr_nrr-1 DO BEGIN      ;; Schleife ueber alle Extraktionsradien
    
    flux     = DBLARR( log.mask_nrs,log.nr*framenumbers )
    fneu     = DBLARR( log.mask_nrs,log.nr*framenumbers )
    therr    = DBLARR( log.mask_nrs,log.nr*framenumbers )
    fref     = DBLARR( log.nr             *framenumbers )
;    therrref = DBLARR( log.nr             *framenumbers )
;    err      = DBLARR( log.mask_nrs,log.nr*framenumbers )

    rmsFile  = log.out_path + '/' + log.relflx
    rmsExtended  = log.out_path + '/' + log.block + '_' + STRTRIM(string(s),2) + '.rms'
    sel_rad          = rad[s] 
            
    IF NOT KEYWORD_SET(silent) THEN BEGIN
      PRINT, " " 
      PRINT, "% TRIPP_CALC_RELFLUX: Input flux file           : " + fluxFile
      PRINT, "% TRIPP_CALC_RELFLUX: Output rms file           : " + rmsExtended
    ENDIF    

;; ---------------------------------------------------------    
;; --- REDUCE SOURCEFLUXES: REDUCEDFLUX =       ---
;; --- SOURCEFLUX - (SKALIERTER BACKGROUNDFLUX) ---
;;
    FOR k = 0,log.mask_nrs -1 DO BEGIN                      ;; ueber alle Quellen
      idx           = WHERE( areab[k,*] NE 0 )
      flux[k,idx] = fluxs[k,idx,s] - ( areas[k,idx,s]/areab[k,idx]*fluxb[k,idx] )
      
;; --------------------------------------------------------- 
;; --- THEORETICAL ERROR ESTIMATION I
;;
;      therr[k,idx] = sqrt(flux[k,idx])
;      therr[k,idx] = therr[k,idx]/flux[k,idx] ;error in per cent

;; ---------------------------------------------------------    
;; --- SCALE ALL REDUCEDFLUXES ACCORDING TO EXPOSURE TIME: 
;; --- REDUCEDFLUX = REDUCEDFLUX /(EXPTIME)
;;
      
      flux[k,idx] = flux[k,idx] / exptime[idx]
    ENDFOR
    

;; ---------------------------------------------------------    
;; --- BASTELN DES 'GEMITTELTEN' REFERENZSTERNS ---
;; --- DURCH EINFACHES AUFADDIEREN DER FLUESSE  ---

    FOR k=0,log.relref_lth-1 DO BEGIN              ;; ueber alle gewaehlten Referenzsterne
      FOR i=0,log.nr*framenumbers-1 DO BEGIN       ;; ueber alle Frames
        fref[i]=fref[i]+flux[log.relflx_ref[k]-1,i]
;          therrref[i]=therrref[i]+therr[log.relflx_ref[k]-1,i]
      ENDFOR
    ENDFOR
;    therrref     =sqrt(therrref)

;   fref = reform(fref)
    
;; ---------------------------------------------------------    
;; --- BEZIEHEN DER SOURCEFLUXES AUF (GEMITTELTEN) REFERENZSTERN --- 
;;
;; only fneu[0,*] will be used later, others do not always make sense!
   idx = WHERE (fref NE 0.0)
   FOR k=0,log.mask_nrs-1 DO BEGIN                  ;; ueber alle Quellen
     fneu[k,idx] = flux[k,idx]/(fref[idx])
   ENDFOR
;; Extrawurst fuer Referenzsterne; makes sense now!
   FOR k=0,log.relref_lth-1 DO BEGIN                
     fneu[log.relflx_ref[k]-1,idx] = $ 
       flux[log.relflx_ref[k]-1,idx]/(fref[idx]-flux[log.relflx_ref[k]-1,idx])
   ENDFOR
   IF KEYWORD_SET(rectify) THEN fneu[*,idx] = fneu[*,idx]*mean(fref[idx])

;; --------------------------------------------------------- 
;; --- THEORETICAL ERROR ESTIMATION II
;;
   ;;error in same units as fneu
;   therr[*,idx]=therr[*,idx]*fneu[*,idx] 

   ;; Fehlerfortpflanzung

;; --------------------------------------------------------- 
;; --- ERROR ESTIMATION
;;
    meanf=dblarr(log.mask_nrs)
    rms=dblarr(log.mask_nrs)
    
    
    FOR k=0,log.mask_nrs-1 DO BEGIN
        ind=where(fneu[k,*] GT 0.0,count)
        IF n_elements(ind) GT 2 THEN BEGIN
            vec=dblarr(n_elements(ind))
            vec[*]=fneu[k,ind[*]]
            CCD_BSIGMA,vec,sum,num,sigma,n_sigma=n_sigma,/silent
            IF num NE 0.0 THEN BEGIN
                meanf[k]=sum/num
                rms[k]=sigma/sqrt(num)
            ENDIF
        ENDIF
    ENDFOR
    
    
    
;; ---------------------------------------------------------
;; --- SAVE RESULT
;;
     SAVE, filename=rmsExtended, rad, sel_rad, fneu, meanf, rms, sname, $
       time, flag, files, shift, fref, framenumbers, frameshift 
     
     IF NOT KEYWORD_SET(silent) THEN BEGIN
       PRINT, "% TRIPP_CALC_RELFLUX: RESULT FOR EXTRACTION RADIUS " + $
         STRTRIM(string(sel_rad),2) + " SAVED"
     ENDIF
     
     IF float(sel_rad) EQ float(log.relflx_sr) THEN BEGIN
       SAVE, filename=rmsFile, rad, sel_rad, fneu, meanf, rms, sname, $
         time, flag, files, shift, fref, framenumbers, frameshift                    
       text="% TRIPP_CALC_RELFLUX: SELECTED EXTRACTION RADIUS   " + $
         STRTRIM(string(sel_rad),2)
     ENDIF
     
    
ENDFOR 

PRINT, " "                  
PRINT, "% TRIPP_CALC_RELFLUX: Additional output rms file: " + rmsFile
PRINT, text

                         ;; ====================================================

;; Repeat calculations for varibale extraction radius
;;
IF EXIST(fluxsauto) AND EXIST(areasauto) THEN BEGIN

  ;; definitions
  autormsFile = log.out_path + '/' + log.block + '_auto' + '.rms'
  flux = DBLARR( log.mask_nrs,log.nr*framenumbers )
  fneu = DBLARR( log.mask_nrs,log.nr*framenumbers )
  fref = DBLARR( log.nr             *framenumbers )
  ;;  background correction
  FOR k = 0,log.mask_nrs -1 DO BEGIN             ;;for all sources        
    idx           = WHERE( areab[k,*] NE 0 )
    flux[k,idx]   = fluxsauto[k,idx] - ( areasauto[k,idx]/areab[k,idx]*fluxb[k,idx] )
    flux[k,idx] = flux[k,idx] / exptime[idx]
  ENDFOR
  ;; build super reference star
  FOR k=0,log.relref_lth-1 DO BEGIN              ;; ueber alle gewaehlten Referenzsterne
    FOR i=0,log.nr*framenumbers-1 DO BEGIN       ;; ueber alle Frames
      fref[i]=fref[i]+flux[log.relflx_ref[k]-1,i]
    ENDFOR
  ENDFOR
  ;; relative flux
  idx = WHERE (fref NE 0.0)
  FOR k=0,log.mask_nrs-1 DO BEGIN                  ;; ueber alle Quellen
    fneu[k,idx] = flux[k,idx]/(fref[idx])
  ENDFOR
  ;; Extrawurst fuer Referenzsterne; makes sense now!
  FOR k=0,log.relref_lth-1 DO BEGIN                
    fneu[log.relflx_ref[k]-1,idx] = $ 
      flux[log.relflx_ref[k]-1,idx]/(fref[idx]-flux[log.relflx_ref[k]-1,idx])
  ENDFOR
  IF KEYWORD_SET(rectify) THEN fneu[*,idx] = fneu[*,idx]*mean(fref[idx])
  ;; error estimation  
  meanf=dblarr(log.mask_nrs)
  rms=dblarr(log.mask_nrs)
  FOR k=0,log.mask_nrs-1 DO BEGIN
    ind=where(fneu[k,*] GT 0.0,count)
    IF n_elements(ind) GT 2 THEN BEGIN
      vec=dblarr(n_elements(ind))
      vec[*]=fneu[k,ind[*]]
      CCD_BSIGMA,vec,sum,num,sigma,n_sigma=n_sigma,/silent
      IF num NE 0.0 THEN BEGIN
        meanf[k]=sum/num
        rms[k]=sigma/sqrt(num)
      ENDIF
    ENDIF
  ENDFOR
  ;; save result
  sel_rad = mean(sqrt(areasauto/!pi))
  SAVE, filename=autormsFile, rad, sel_rad, fneu, meanf, rms, sname, $
    time, flag, files, shift, fref, framenumbers, frameshift 
  PRINT, "% TRIPP_CALC_RELFLUX: Additional output rms file: " + autormsFile
  
ENDIF

PRINT, '% ==========================================================================================='
PRINT, " "                  

;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------








