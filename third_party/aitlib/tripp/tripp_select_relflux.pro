PRO TRIPP_SELECT_RELFLUX, logName, radii, rectify=rectify,silent=silent
;+
; NAME:
;	TRIPP_SELECT_RELFLUX
;
;
; PURPOSE:   
;       Select for all sources the apperture radius. 
;       This is an experimental tool to allow one to use different
;       apperture radii for each  source. 
;
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_SELECT_RELFLUX, LOGNAME = logName,
;                  [aprad1,aprad2,...,apradn] $
;                  rectify=rectify,silent=silent
;   
; INPUTS:
;	
;       IDL SAVE file *.FLX - the fluxes calculated by
;       tripp_extract_flux.
;       radii - vector containing the number of apperture radius for
;               each source. The appropriate radius number has to be
;               chosen manually either by checking the mask or by
;               repeated processing tripp_show_relflux (which takes
;               the apperture radius from the log file).
;
;
;
; OPTIONAL INPUTS:   
;	
;
; OPTIONAL KEYWORDS:
;
;	rectify -?
;       silent  - non verbose. 
;
; OUTPUTS:
;   
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
;       Version 1.0, 2002/11, E.G., (T.N.) :  Experimental initial version.
;-


;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SELECT_RELFLUX:    No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SELECT_RELFLUX:    The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_SELECT_RELFLUX:    Using Logfile ', logname 
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

rad_ind      = INTARR( log.extr_nrr )        

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


    
flux     = DBLARR( log.mask_nrs,log.nr*framenumbers )
fneu     = DBLARR( log.mask_nrs,log.nr*framenumbers )
therr    = DBLARR( log.mask_nrs,log.nr*framenumbers )
fref     = DBLARR( log.nr             *framenumbers )
;    therrref = DBLARR( log.nr             *framenumbers )
;    err      = DBLARR( log.mask_nrs,log.nr*framenumbers )

rmsFile  = log.out_path + '/' + log.relflx
            
IF NOT KEYWORD_SET(silent) THEN BEGIN
   PRINT, " " 
   PRINT, "% TRIPP_SELECT_RELFLUX: Input flux file           : " + fluxFile
   PRINT, "% TRIPP_SELECT_RELFLUX: Output rms file           : " + rmsFile
ENDIF    


;; ---------------------------------------------------------    
;; --- SELECT RADII INDIZES FOR INPUT RADII              ---
;;


FOR s = 0,log.mask_nrs -1 DO BEGIN                      ;; for all sources

      ;; --- calculate nearest extraction radius number
      ;;
      rad    = (radii[s] - DOUBLE( log.extr_minr )) * DOUBLE( log.extr_nrr )    $
               /(DOUBLE( log.extr_maxr ) - DOUBLE( log.extr_minr ))
             
      ;; restrict to available index:
      rad = round(rad)
      if rad lt 0 then rad = 0
      if rad ge log.extr_nrr then rad= log.extr_nrr-1


      PRINT, "% TRIPP_SELECT_RELFLUX: Selected for source "+strtrim(string(s)) $
          + " with radius " + strtrim(string(radii[s]))  $
          + " radius no: "  + strtrim(string(rad))  

      rad_ind[s] = rad

ENDFOR



FOR s = 0,log.mask_nrs -1 DO BEGIN                      ;; for all sources

;; ---------------------------------------------------------    
;; --- REDUCE SOURCEFLUXES: REDUCEDFLUX =       ---
;; --- SOURCEFLUX - (SKALIERTER BACKGROUNDFLUX) ---
;;

      ;; radius index for given source:
      rad = rad_ind[s]

      ;; --- calculate flux for given radius:
      idx           = WHERE( areab[s,*] NE 0 )
      flux[s,idx] = fluxs[s,idx,rad] - ( areas[s,idx,rad]/areab[s,idx]*fluxb[s,idx] )
      
;; --------------------------------------------------------- 
;; --- THEORETICAL ERROR ESTIMATION I
;;
;      therr[s,idx] = sqrt(flux[s,idx])
;      therr[s,idx] = therr[s,idx]/flux[s,idx] ;error in per cent

;; ---------------------------------------------------------    
;; --- SCALE ALL REDUCEDFLUXES ACCORDING TO EXPOSURE TIME: 
;; --- REDUCEDFLUX = REDUCEDFLUX /(EXPTIME)
;;
      
      flux[s,idx] = flux[s,idx] / exptime[idx]
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
     
     IF NOT KEYWORD_SET(silent) THEN BEGIN
       PRINT, "% TRIPP_SELECT_RELFLUX: RESULT FOR SELECTED RADII SAVED "
     ENDIF
     

    SAVE, filename=rmsFile, rad,  fneu, meanf, rms, sname, $
         time, flag, files, shift, fref, framenumbers, frameshift                    

     
    


PRINT, " "                  
PRINT, "% TRIPP_SELECT_RELFLUX: Output rms file: " + rmsFile



PRINT, '% ==========================================================================================='
PRINT, " "                  

;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------








