@tripp_exist
PRO TRIPP_SHOW_RAW, logName,y_max=y_max,y_min=y_min,x_max=x_max,x_min=x_min
;+
; NAME:
;	TRIPP_SHOW_RAW
;
;
; PURPOSE:   
;   
;	Plot lightcurves of raw counts (stars and background) to check
;	quality.
;
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_SHOW_RAW, LOGNAME = logName
;
;   
; INPUTS:
;	
;       IDL SAVE file *.FLX
;
;
; OUTPUTS:
;   
;	PS file '*_raw.PS' showing lightcurves
;
;	
; RESTRICTIONS:
;   
;       file type:      FLX as produced by TRIPP_EXTRACT_FLUX or CCD_PRED
;	Input directory and filename structure as specified in Log  
;
; REVISION HISTORY:
;   
;       Version 1.0, 1999/12 Stefan Dreizler
;       Version 1.1  2000/11 Sonja L. Schuh, /landscape
;                    2001/02 SLS, added messages 
;                    2001/02 SLS, comparison for radii needs to be
;                                 done in floats; one more plot per star
;                    2002/05 SLS, added approximate JD start of observation
;
;-

;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SHOW_RAW:        No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SHOW_RAW:        The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_SHOW_RAW:        Using Logfile ', logname 
    ENDIF
  ENDELSE


;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_IMAGE_LOG, logName, log

;; ---------------------------------------------------------
;; --- READ FLUX FILE ---
;;
fluxFile = log.out_path + '/' + log.flux 

RESTORE, fluxFile

;; ---------------------------------------------------------
;; --- find index of extraction radius
rad_ind = -1
FOR s=0, log.extr_nrr-1 DO BEGIN
    IF float(rad[s]) EQ float(log.relflx_sr) THEN rad_ind = s
ENDFOR
IF rad_ind EQ -1 THEN BEGIN
    PRINT, "% TRIPP_SHOW_RAW: Selected radius ("+STRTRIM(string(log.relflx_sr),2)+ $
                                               ") does not match available radii"
    STOP
ENDIF

;; ----------------------------------------------------------    
;; --- POSTSCRIPT  OUTPUT OF LIGHTCURVE AND SPECTRUM---
;;    
    SET_PLOT,'ps' 
    rawFile         =  log.out_path + '/' + log.block +'_raw.ps'
    DEVICE,filename = rawFile,/landscape

    ; ---- Write Title Page
    nr      = n_elements(time) -1   
    a       =[0,0]
    PLOT,a,ystyle=4,xstyle=4,/NODATA,XMARGIN=[0.,1.],YMARGIN=[0.,1.]
   
    XYOUTS,.0,1., "--------------------"
    XYOUTS,.0,.80,log.starID,CHARSIZE=3. 
    XYOUTS,.0,.75,"--------------------"
    XYOUTS,.0,.6, "Data Block:                     "+log.block
    XYOUTS,.0,.55,"Filename:                       "+rawFile
    XYOUTS,.0,.5, "Created from File:              "+fluxFile
    XYOUTS,.0,.45,"Used Number of data points:     "+STRTRIM(STRING(nr+1),2)
    XYOUTS,.0,.35,"Timebase in seconds:           "+STRTRIM(STRING((time[nr]-time[0])*86400.d0),2)
    XYOUTS,.0,.30,"JD Start of observation:         24"+STRTRIM( STRING(time[0]),2 )
    XYOUTS,.0,.15,"The shown background fluxes are scaled to the expected number of counts"
    XYOUTS,.0,.10,"in the extraction areas for the sources."
    
    ; ---- Plot Lightcurves

    !P.MULTI = [0, 1, 3]
    FOR k = 0,log.mask_nrs -1 DO BEGIN 
        ;star counts
        IF NOT EXIST(x_min) THEN x_min=min(time-time[0])
        IF NOT EXIST(x_max) THEN x_max=max(time-time[0])
        IF NOT EXIST(y_min) THEN y1=min(fluxs[k,*,rad_ind]) ELSE y1=y_min*median(fluxs[k,*,rad_ind])
        IF NOT EXIST(y_max) THEN y2=max(fluxs[k,*,rad_ind]) ELSE y2=y_max*median(fluxs[k,*,rad_ind])
        idx = where( log.relflx_ref[0:log.relref_lth] EQ k+1,count )
        IF idx[0] NE -1 THEN ref_string = '  *used*' ELSE ref_string = ''
        plot,time-time[0],fluxs[k,*,rad_ind],xstyle=1,ystyle=1,  $
          xrange=[x_min,x_max],yrange=[y1,y2],                                   $
          xtitle='time/days',ytitle='raw counts',title='star'+STRTRIM(STRING(k+1),2)+ref_string
        ;background counts
        IF NOT EXIST(y_min) THEN y1=min(fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*]) $
                            ELSE y1=y_min*median(fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*])
        IF NOT EXIST(y_max) THEN y2=max(fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*]) $
                            ELSE y2=y_max*median(fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*])
        plot,time-time[0],fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*],xstyle=1,ystyle=1,  $
          xrange=[x_min,x_max],yrange=[y1,y2],                                   $
          xtitle='time/days',ytitle='raw counts',title='background'+STRTRIM(STRING(k+1),2)
        ;background counts
        IF NOT EXIST(y_min) THEN y1=min(fluxs[k,*,rad_ind]-fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*]) $
                            ELSE y1=y_min*median(fluxs[k,*,rad_ind]-fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*])
        IF NOT EXIST(y_max) THEN y2=max(fluxs[k,*,rad_ind]-fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*]) $
                            ELSE y2=y_max*median(fluxs[k,*,rad_ind]-fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*])
        plot,time-time[0],fluxs[k,*,rad_ind]-fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*],xstyle=1,ystyle=1,  $ 
          xrange=[x_min,x_max],yrange=[y1,y2],                                   $
          xtitle='time/days',ytitle='raw counts',title='star'+STRTRIM(STRING(k+1),2)+$
          '-background'+STRTRIM(STRING(k+1),2)
;         level=fltarr(n_elements(fluxs[0,*,rad_ind]))
;         level[*]=fluxs[k,*,rad_ind]-fluxb[k,*]*areas[k,*,rad_ind]/areab[k,*]
;         therr=sqrt(level)
;         oplot,time-time[0],level-therr,linestyle=2
;         oplot,time-time[0],level+therr,linestyle=2
    ENDFOR
    !P.MULTI = 0

    ; ----
    DEVICE,/close               
    SET_PLOT,'x'                
    
    PRINT, ' '
    PRINT, '% TRIPP_SHOW_RAW: CREATING FILE         : ' + rawFile
    PRINT, '% ==========================================================================================='
    PRINT, ' '
    
;; ---------------------------------------------------------
;; --- END ---
;;
  END

;; -------------------------------------


