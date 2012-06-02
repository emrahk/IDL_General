PRO TRIPP_WRITE_LIST, logName, degree=degree, clearmax=clearmax, clearmin=clearmin,preclear_min=preclear_min,preclear_max=preclear_max,smoothed=smoothed,no_clean=no_clean
;+
; NAME:
;	TRIPP_WRITE_LIST
;
; PURPOSE:   
;   
;	Write all relative fluxes to ASCII files
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_WRITE_LIST, LOGNAME = logName,  [ DEGREE=degree,
;       CLEARMAX=clearmax, CLEARMIN=clearmin, PRECLEAR=preclear, 
;       SMOOTHED=smoothed, NO_CLEAN=no_clean ]
;   
; INPUTS:
;	
;       IDL SAVE file *.RMS
;       IDL SAVE file *.APS
;
;
; OUTPUTS:
;   
;	ASCII file '*.list' containing reduced data as x,y- table:
;       x corresponds to time, y corresponds to relative flux
;       first two lines contain x and y position on the chip for identification
;	
; RESTRICTIONS:
;   
;       file type:      RMS as produced by TRIPP_CALC_RELFLUX (or ccd_rms
;                       or ccd_rms_multi, in principle) 
;	Input directory and filename structure as specified in Log  
;
; REVISION HISTORY:
;   
;       Version 1.0, 2000/02, Stefan Dreizler
;       
;-
   
  on_error,2                    ;Return to caller if an error occurs

   IF  NOT EXIST(degree)   THEN degree = -1
   IF  NOT EXIST(preclear_min) THEN preclear_min = 0.
   IF  NOT EXIST(preclear_max) THEN preclear_max = 1000000.
   IF  NOT EXIST(clearmin) THEN clearmin = 0.
   IF  NOT EXIST(clearmax) THEN clearmax = 1000000.
   IF  NOT EXIST(smoothed) THEN smoothed = 0
   IF  NOT EXIST(no_clear) THEN no_clear = 1

   
;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_IMAGE_LOG, logName, log

;; ---------------------------------------------------------
;; --- READ RMS FILE ---
;;
maskFile        = log.out_path + '/' + log.mask
rmsFile         = log.out_path + '/' + log.relflx

RESTORE, rmsFile
RESTORE, maskFile

;; ---------------------------------------------------------
;; --- determine index of extraction radius
diff = rad - log.relflx_sr
ind_rad = where(diff EQ min(diff))

PRINT, " "
PRINT, "% TRIPP_WRITE_FINAL: Input rms  file      : " + rmsFile
PRINT, "% TRIPP_WRITE_FINAL: Input rms  file      : " + maskFile


FOR kk = 0, log.mask_nrs-1 DO BEGIN 
    datFile         = log.out_path + '/' + log.block + 'star_' +  $
      strtrim(string[kk],2) + '.list'
    PRINT, " "
    PRINT, "% TRIPP_WRITE_FINAL: Output data files    : " + datFile
    PRINT, " "
    
    IF no_clear EQ 0 THEN BEGIN 
;; ---------------------------------------------------------
;; --- CLEAN DATA FROM ZERO VALUES
;;    
        idx     = WHERE (fneu[kk,*] NE 0.)
        fclean  = fneu [kk,idx]
        tclean  = time [idx] 
        
        dim     = SIZE (tclean)
        
        
;; ---------------------------------------------------------
;; --- CORRECT FOR TIME SHIFT 
;;
        tshift  = log.extr_tshft/86400.
        tclean  = tclean + tshift
        
;; ---------------------------------------------------------
;; --- NORMALIZE FLUX 
;;
        m      = MEDIAN( fclean )
        fclean = fclean / m
        
        
;; ---------------------------------------------------------
;; --- PRECLEAN DATA 
;;
        preclear=-1
        ind    = WHERE(fclean LT preclear_max AND fclean GT preclear_min)
        IF n_elements(ind) LT n_elements(fclean) THEN preclear=1
        m      = MEDIAN( fclean [ind] )
        fclean = fclean / m
        tclear     = tclean[ind]
        fclear     = fclean[ind]
        
;; ---------------------------------------------------------
;; --- FIT POLYNOMIAL 
;;
        f_median = fclear
        IF degree GT 0 THEN BEGIN
            y  = dblarr (N_ELEMENTS(ind))
            ff = poly_fit (tclear-tclear[0],fclear,degree) 
            FOR  k = 0,degree DO y = y + ff[k]*(tclear-tclear[0])^k
            fclear = fclear / y
        ENDIF
        
;; ---------------------------------------------------------
;; --- SMOOTH
;;
        IF smoothed GT 1 THEN BEGIN
            fclear = fclear / SMOOTH(fclear,smoothed,/edge_truncate)
        ENDIF
        
        
;; ---------------------------------------------------------
;; --- CLEAN DATA FROM SUSPICIOUS POINTS
;;
        idx    = WHERE(fclear LT clearmax AND fclear GT clearmin)
        
        tclear = tclear[idx]
        fclear = fclear[idx]
        f_median = f_median[idx]
        
;; ---------------------------------------------------------
;; --- VISUAL CHECK OF NORMALIZATION
;;
        LOADCT,3
        PLOT,tclear-tclear[0],f_median, ystyle=1
        IF degree   GT 0 THEN oplot,tclear-tclear[0],y[idx],color=80
        IF smoothed GT 1 THEN oplot,tclear-tclear[0],SMOOTH(f_median,smoothed,/edge_truncate),color=80
        
    ENDIF ELSE BEGIN 
        
        idx = indgen(n_elements(time))
        fclear = fneu[kk,idx]
        tclear = time[idx]
        
    ENDELSE 
    
;; ---------------------------------------------------------
;; --- WRITE RESULT TO ASCII DAT FILE
;;
    
    GET_LUN, unit
    OPENW, unit, datFile
    
    PRINTF, unit, '# of reference stars:'
    FOR jj = 0,log.relref_lth-1 DO PRINTF, unit,  log.relflx_ref[jj]
    PRINTF, unit,  '  size of aperture', rad(ind_rad)
    PRINTF, unit, ref_x+sx(kk), '  x position'
    PRINTF, unit, ref_y+sy(kk), '  y position'
        

    FOR  k = 0, n_elements(idx) -1  DO BEGIN
        PRINTF, unit, tclear[k], fclear[k],format='(f12.6,f14.6)'
    ENDFOR
    
    FREE_LUN, unit
    
    PRINT, " "
    PRINT, "% TRIPP_WRITE_FINAL: DATA WRITTEN TO FILE " + datFile
    PRINT, " "
    
ENDFOR 

;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------










