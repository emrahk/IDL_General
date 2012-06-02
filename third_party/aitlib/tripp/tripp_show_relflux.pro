PRO TRIPP_SHOW_RELFLUX, logName,mouse=mouse
;+
; NAME:
;	TRIPP_SHOW_RELFLUX
;
; PURPOSE:   
;   
;	Plot lightcurve and period spectrum as found with SCARGLE  
;       of reduced photometrical data obtained with
;       TRIPP_CALC_RELFLUX using different extraction radii and save results
;       to ps-File for inspection
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_SHOW_RELFLUX, LOGNAME = logName
;   
; INPUTS:
;	
;       IDL SAVE files *_*.RMS
;
;
; OUTPUTS:
;   
;	PS file '*_relflux.PS' showing lightcurve  of data block
;       and its period spectrum
;	
;   
; RESTRICTIONS:
;   
;       file type:      RMSExtended as produced by TRIPP_CALC_RELFLUX 
;	Input directory and filename structure as specified in Log  
;
;   
; REVISION HISTORY:
;   
;       Version 1.0, 1999/07, Sonja Schuh    (combined TRIPP_SHOW_RELFLUX
;                                             and TRIPP_SHOW_FT) 
;       Version 1.1, 2000/11, Sonja L. Schuh, added panels with cut
;                                             flux, switched to /landscape
;       Version 1.2, 2001/02, Sonja L. Schuh, - added keyword /mouse,
;                     which triggers the usage of, mainly, the CCD_MEAN routine for
;                     a display of the quality of the lightcurves at different
;                     extraction radii; new extraction radius can then
;                     be chosen and will change the log- and rmsfile for consistency. 
;                                             - use new scargle from aitlib
;                    2001/02   , SLS, added messages 
;                    2001/02 SLS, comparison for radii needs to be
;                                 done in floats
;                    2001/05 SLS, adapted to frame transfer method
;                                 (keywords frame*) 
;                    2002/05 SLS, added approximate JD start of observation
;                                 
;-

;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SHOW_RELFLUX:    No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SHOW_RELFLUX:    The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_SHOW_RELFLUX:    Using Logfile ', logname 
    ENDIF
  ENDELSE


;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;   
   TRIPP_READ_IMAGE_LOG, logname, log
   
   
;; ---------------------------------------------------------
;; --- LOOP: LIGHTCURVE & SPECTRUM FOR ALL EXTRACTION RADII ---
;;     
                                      ;; =======================================
                                      ;; Loop erfasst jeden 2. Extraktionsradius
   
FOR s=1,log.extr_nrr-1,2 DO BEGIN   
    
    rmsExtended  =  log.out_path + '/' + log.block + '_' + STRTRIM(string(s),2) + '.rms'
    relfluxFile  =  log.out_path + '/' + log.block + '_' + STRTRIM(string(s),2) +'_relflux.ps'
    
    RESTORE, rmsExtended
    
    PRINT," "
    PRINT,"% TRIPP_SHOW_RELFLUX: READING FILE         : " + rmsExtended
    
;; --- DEFINITIONS
    IF NOT EXIST(framenumbers) THEN framenumbers = 1
    IF NOT EXIST(frameshift)   THEN frameshift   = 0
    

;; ----------------------------------------------------------    
;; --- PRECLEANING OF DATA ---
;;
    idx    = where (fneu[0,*] NE 0.)
    fclean = fneu[0,idx]
    tclean = time[idx]
    
;; ----------------------------------------------------------    
;; --- POSTSCRIPT  OUTPUT OF LIGHTCURVE AND SPECTRUM---
;;    
    SET_PLOT,'ps' 
    DEVICE,filename = relfluxFile,/landscape
;    open_PRINT,relfluxFile,/a4,/postscript
;    device,/times
    
    ;; ---- Write Title Page
    nr      = n_elements(tclean) -1   
    a       = [0,0]
    PLOT,a,ystyle=4,xstyle=4,/NODATA,XMARGIN=[0.,1.],YMARGIN=[0.,1.]
   
    XYOUTS,.0,1., "--------------------"
    XYOUTS,.0,.80,log.starID,CHARSIZE=3. 
    XYOUTS,.0,.75,"--------------------"
    XYOUTS,.0,.6, "Data Block:                     "+log.block
    XYOUTS,.0,.55,"Filename:                       "+relfluxFile
    XYOUTS,.0,.5, "Created from File:              "+rmsExtended
    XYOUTS,.0,.45,"Original Number of data points: "+STRTRIM(STRING(log.nr),2)+ $
      "*"+STRTRIM(STRING(framenumbers),2)+"="+STRTRIM(STRING(log.nr*framenumbers),2)
    XYOUTS,.0,.4, "Number of data points used:    "+STRTRIM(STRING(nr+1),2)
    XYOUTS,.0,.35,"Timebase in seconds:           "+STRTRIM(STRING((tclean[nr]-tclean[0])*86400.d0),2) 
    XYOUTS,.0,.30,"JD Start of observation:        24"+STRTRIM( STRING(tclean[0]),2 )    

    ;; ---- Plot Lightcurve
    !P.MULTI = [0, 1, 4]
    PLOT,tclean[*]-tclean[0],fclean,title = "Lightcurve",ystyle=1,psym=1,xtitle= 'time / days',$
      xrange=[0,max(tclean[*]-tclean[0])],xstyle=1
    PLOT,tclean[*]-tclean[0],fclean,title = "Lightcurve",ystyle=1,psym=0,xtitle= 'time / days',$
      xrange=[0,max(tclean[*]-tclean[0])],xstyle=1
    PLOT,tclean[*]-tclean[0],fclean,title = "Lightcurve",ystyle=1,psym=1,xtitle= 'time / days',$
      yrange=[median(fclean)*.75,median(fclean)*1.25],xrange=[0,max(tclean[*]-tclean[0])],xstyle=1
    PLOT,tclean[*]-tclean[0],fclean,title = "Lightcurve",ystyle=1,psym=0,xtitle= 'time / days',$
      yrange=[median(fclean)*.75,median(fclean)*1.25],xrange=[0,max(tclean[*]-tclean[0])],xstyle=1
    !P.MULTI = 0

; oplot,time-time[0],fltarr(n_elements(time))+mean(fneu[0,*]+therr[0,*]),linestyle=1
; oplot,time-time[0],fltarr(n_elements(time))+mean(fneu[0,*]-therr[0,*]),linestyle=1
; oplot,time-time[0],fltarr(n_elements(time))+mean(fneu[0,*])+rms[0],linestyle=2
; oplot,time-time[0],fltarr(n_elements(time))+mean(fneu[0,*])-rms[0],linestyle=2
    
    ;; ---- Search for Periods    
;     TRIPP_SCARGLE,(tclean[*]-tclean[0])*86400.d0,fclean(0,*),om,psd, $
;       period=period,fap=0.9,numf=1.5*nr
    SCARGLE,(tclean[*]-tclean[0])*86400.d0,fclean[0,*],om,psd, $
      period=period,fap=0.9,numf=1.5*nr
    
    index=where(fclean[0,*] GE median(fclean)*.75 AND fclean[0,*] LE median(fclean)*1.25)
    fanschauen=fclean[0,index]
    
;     TRIPP_SCARGLE,(tclean[*]-tclean[0])*86400.d0,fanschauen(0,*),om,psd_anschauen, $
;       period=period,fap=0.9,numf=1.5*nr
    SCARGLE,(tclean[*]-tclean[0])*86400.d0,fanschauen[0,*],om,psd_anschauen, $
      period=period,fap=0.9,numf=1.5*nr
    
    ;; ---- Plot Frequency Spectrum 
    !P.MULTI = [0, 1, 2]
    PLOT,1.e6/period,psd, xrange = [log.ft_min,log.ft_max], xstyle=1, $
      title = "Frequency Spectrum",xtitle= 'frequency / !7l!XHz'
    PLOT,1.e6/period,psd_anschauen, xrange = [log.ft_min,log.ft_max],xstyle=1, $
      title = "Frequency Spectrum",xtitle= 'frequency / !7l!XHz'
    !P.MULTI = 0
    
    ;; ---- Plot Period Spectrum 
    !P.MULTI = [0, 1, 2]
    PLOT,period,psd, xrange = [1.e6/log.ft_max,1.e6/log.ft_min], xstyle=1, $
      title = "Period Spectrum",xtitle= 'period / s'
    PLOT,period,psd_anschauen, xrange = [1.e6/log.ft_max,1.e6/log.ft_min], xstyle=1, $
      title = "Period Spectrum",xtitle= 'period / s'
    !P.MULTI = 0
    
;     FOR k=1,log.mask_nrs-1 DO BEGIN 
;       ;; ---- Plot other Lightcurves
;       !P.MULTI = [0, 1, 4]
;       PLOT,time[*]-time[0],fneu[k,*],title = "Lightcurve",ystyle=1,psym=1,xtitle= 'time / days',$
;         xrange=[0,max(time[*]-time[0])],xstyle=1
;       PLOT,time[*]-time[0],fneu[k,*],title = "Lightcurve",ystyle=1,psym=0,xtitle= 'time / days',$
;         xrange=[0,max(time[*]-time[0])],xstyle=1
;       PLOT,time[*]-time[0],fneu[k,*],title = "Lightcurve",ystyle=1,psym=1,xtitle= 'time / days',$
;         yrange=[median(fneu[k,*])*.75,median(fneu[k,*])*1.25],xrange=[0,max(time[*]-time[0])],xstyle=1
;       PLOT,time[*]-time[0],fneu[k,*],title = "Lightcurve",ystyle=1,psym=0,xtitle= 'time / days',$
;         yrange=[median(fneu[k,*])*.75,median(fneu[k,*])*1.25],xrange=[0,max(time[*]-time[0])],xstyle=1
;       !P.MULTI = 0
;     ENDFOR

    ;; ----
    DEVICE,/close               
    SET_PLOT,'x'                
;    close_PRINT   
    
;    PRINT, ' '
    PRINT,'% TRIPP_SHOW_RELFLUX: CREATING FILE        : ' + relfluxFile
;    PRINT, '% ==========================================================================================='
;    PRINT, ' '
    
    
ENDFOR

;; ---------------------------------------------------------
;; --- $CCD$ DISPLAY TO FACILITATE THE
;; --  CHOICE OF AN EXTRACTION RADIUS
;;

IF KEYWORD_SET(mouse) THEN BEGIN
  
  ;; --- CCD part
  ;;
  PRINT,''
  fluxFile = log.out_path + '/' + log.flux 
  
  ccd_rms, in=fluxFile, out=fluxFile+'_rms_tmp'
  window,3
  ccd_mean,in=fluxFile+'_rms_tmp'
                                ;
  spawn,'rm -f '+fluxFile+'_rms_tmp'
  
  ;; --- Prompt for new value of extraction radius in pixel
  ;;
  cdummy=''
  PRINT,''
  PRINT,'% TRIPP_SHOW_RELFLUX: Current extraction radius is '+string(log.relflx_sr)
  old_sel_rad=log.relflx_sr     ;remember!
  PRINT,''
  PRINT,'% TRIPP_SHOW_RELFLUX: New extraction radius?  Enter radius in pixel'
  PRINT,'% TRIPP_SHOW_RELFLUX: or  Ready to continue?  Press return'
  read,cdummy
  wdelete,3
  
  IF cdummy NE '' THEN BEGIN
    
    log.relflx_sr=float(cdummy)
    
    ;; --- calculate nearest extraction radius
    ;;
    rad    = DOUBLE( log.extr_minr ) + $
      DINDGEN( log.extr_nrr ) / DOUBLE( log.extr_nrr ) * $
      (DOUBLE( log.extr_maxr ) - DOUBLE( log.extr_minr ))
    ind=where(abs(rad-log.relflx_sr) EQ min(abs(rad-log.relflx_sr)))
    log.relflx_sr=DOUBLE(log.relflx_sr)
    sel_rad=log.relflx_sr
    compare=min(abs(rad-log.relflx_sr))

    IF compare NE 0.d OR old_sel_rad NE sel_rad THEN BEGIN
      
      log.relflx_sr=rad(ind)
      PRINT,'% TRIPP_SHOW_RELFLUX: Selection radius has been changed to ',log.relflx_sr
      
      IF old_sel_rad NE log.relflx_sr THEN BEGIN
        ;; --- re-write logFile    
        ;;
        GET_LUN, unit
        OPENW, unit, logname
        FOR I = 0, N_TAGS(log) - 1 DO BEGIN
          PRINTF, unit, log.(I)
        ENDFOR
        FREE_LUN, unit
        
        ;; --- overwrite selected *.rms file
        ;;  
        s = WHERE(float(rad) EQ float(log.relflx_sr))
        rmsFile  = log.out_path + '/' + log.relflx
        rmsExtended  = log.out_path + '/' + log.block + '_' + STRTRIM(string(s),2) + '.rms'
        spawn,'cp '+rmsExtended+' '+rmsFile
        PRINT,''
        PRINT,'% TRIPP_SHOW_RELFLUX: Copying '+rmsExtended
        PRINT,'                           to '+rmsFile
        ;; --- information about changes
        ;;
        PRINT,''
        PRINT,'% TRIPP_SHOW_RELFLUX: '+logName+' and '+rmsFile
        PRINT,'                      have been re-written to ensure consistency.'
      ENDIF ELSE BEGIN
        PRINT,''
        PRINT,"% TRIPP_SHOW_RELFLUX: No changes to extraction radius."
      ENDELSE
    ENDIF ELSE BEGIN
      PRINT,''
      PRINT,"% TRIPP_SHOW_RELFLUX: No changes to extraction radius."
    ENDELSE
    
  ENDIF ELSE BEGIN
    
    PRINT,''
    PRINT,"% TRIPP_SHOW_RELFLUX: No changes to extraction radius."
    
  ENDELSE  
  
ENDIF

PRINT, '% ==========================================================================================='
PRINT,''

;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------





