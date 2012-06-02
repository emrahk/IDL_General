PRO TRIPP_SHOW_FINAL, logName, tstep=tstep, onepage=onepage
;+
; NAME:
;	TRIPP_SHOW_FINAL
;
; PURPOSE:   
;       
;	Calculate Fourier Transforms of reduced photometrical data obtained with
;       TRIPP_WRITE_FINAL. 
;       Write processed data as lightcurve, as frequency and period
;       spectrum as obtained with SCARGLE, as rebinned lightcurve and
;       its fast fourier transform to one ps-File. 
;	
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_SHOW_FINAL, LOGNAME = logName
;   
; INPUTS:
;	
;       IDL SAVE files *_idl.FIN
;
;
; OUTPUTS:
;   
;	PS file '*_fin.PS' showing Fourier Transforms and Lightcurves
;       of unbinned and binned data block
;
; OPTIONAL KEYWORDS:	
;
;       tstep   : for rebinning for FFT; not active, so keyword is
;                 currently obsolete
;       onepage : produce ps output on one page instead of
;                 four individual ones
;       
;
; RESTRICTIONS:
;   
;       file type:     IDL SAVE File *_idl.FIN
;	Input directory and filename structure as specified in Log  
;
; REVISION HISTORY:
;   
;       Version 1.0, 1999/07, Sonja Schuh; using SCARGLE 
;       Version 1.1, 1999/10, Sonja Schuh, Stefan Dreizler smoothing
;       Version 1.2, 2001/02, SLS, switched back to new scargle from aitlib
;                    2001/02, SLS, added messages 
;                    2001/05, SLS, xstyle=1 for plot ranges
;                    2002/05, SLS, added approximate JD start of observation
;                             SLS, added keyword /onepage 
;-
   
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SHOW_FINAL:      No logfile or name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_SHOW_FINAL:      The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0] 
      PRINT, '% TRIPP_SHOW_FINAL:      Using logfile ', logname 
    ENDIF
  ENDELSE
  
  IF NOT EXIST(tstep)    THEN tstep    = 60.

;; downward compatibility for non-smoothed data
   smoothed = 0   
   
;; ---------------------------------------------------------
;; --- SET ARRAY of FALSE ALARM PROBABILITIES for SCARGLE
   fap = dblarr(18)
   fap(0) = .9  ; confidence level of 10%
   fap(1) = .8  
   fap(2) = .7  
   fap(3) = .6  
   fap(4) = .5  ; confidence level of 50%
   fap(5) = .4  
   fap(6) = .3  
   fap(7) = .2  
   fap(8) = .1  ; confidence level of 90%
   fap(9) = .09  
   fap(10) = .08  
   fap(11) = .07  
   fap(12) = .06  
   fap(13) = .05  
   fap(14)= .04  
   fap(15) = .03  
   fap(16) = .02 
   fap(17) = .01 
   
;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;   
   TRIPP_READ_IMAGE_LOG, logname, log
   
   
;; ---------------------------------------------------------
;; --- RESTORE FINFILE ---
;;    
    finFile      =  log.out_path + '/' + log.block + "_idl.fin"
    psFile       =  log.out_path + '/' + log.block + "_fin.ps"
    
    RESTORE, finFile
    
    PRINT," "
    PRINT,"% TRIPP_SHOW_FINAL: READING FILE      : " + finFile
    
    
;; ----------------------------------------------------------    
;; --- POSTSCRIPT  OUTPUT OF FOURIER TRANSFORMS ---
;; --- (USING SCARGLE) AND LIGHTCURVE ---
;;    
 
    SET_PLOT,'ps' 
    DEVICE,filename = psFile,/landscape
    
    IF KEYWORD_SET(onepage) THEN !p.multi=[0,2,2]   

;   ----- Write Title Page    
    nr      = n_elements(tclear) -1    
    a       =[0,0]
    PLOT,a,ystyle=4,xstyle=4,/NODATA,XMARGIN=[0.,1.],YMARGIN=[0.,1.]
   
    XYOUTS,.0,1., "--------------------"
    XYOUTS,.0,.80,log.starID,CHARSIZE=3. 
    XYOUTS,.0,.75, "--------------------"
    XYOUTS,.0,.6, "Data Block:                "+log.block
    XYOUTS,.0,.55,"Filename:                  "+psFile
    XYOUTS,.0,.5, "Number of data points:    "+STRTRIM(STRING(nr),2)
    XYOUTS,.0,.45,"Timebase in seconds:      "+STRTRIM(STRING((tclear[nr]-tclear[0])*86400.d0),2)
    XYOUTS,.0,.40,"JD Start of observation:   24"+STRTRIM( STRING(tclear[0]),2 )
    IF preclear EQ 1 THEN BEGIN
        XYOUTS,.0,.30,"Precleaning                 executed"
    ENDIF ELSE BEGIN
        XYOUTS,.0,.30,"Precleaning           not   executed"
    ENDELSE
    XYOUTS,.0,.25, "Degree of polynomial fit:  "+STRTRIM(STRING(degree),2)
    XYOUTS,.0,.2 , "Smoothing width:          "+STRTRIM(STRING(smoothed),2)
    XYOUTS,.0,.15, "Minimum cutoff value:     "+STRTRIM(STRING(clearmin),2)
    XYOUTS,.0,.1 , "Maximum cutoff value:    "+STRTRIM(STRING(clearmax),2)
    XYOUTS,.0,.0 , "Notes:"
    
     
;   ------ Plot Lightcurve
    PLOT,tclear[*]-tclear[0],fclear,title ="Lightcurve" ,ystyle=1,$
      xtitle= 'time / days', xrange=[0,max(tclear[*]-tclear[0])],xstyle=1
    
    
;   ------ Search for Periods using SCARGLE   
;     TRIPP_SCARGLE,(tclear-tclear[0])*86400.d0,fclear,om,psd,period=period,fap=fap, $
;       signi=signi,numf=1.5*nr
    SCARGLE,(tclear-tclear[0])*86400.d0,fclear,om,psd,period=period,fap=fap, $
      signi=signi,numf=1.5*nr
    
;   ------ Plot Frequency Amplitude Spectrum
    PLOT,1.e6/period,psd, xrange = [log.ft_min,log.ft_max], title = "Frequency Spectrum" , $
      xtitle= 'frequency / !7l!XHz', ytitle= 'psd power', xstyle=1
    FOR ll = 0,17 DO BEGIN
        lstyle = 2
        IF (ll GT 8) THEN lstyle = 1 
        IF (ll EQ 0 OR ll EQ 4 OR ll EQ 8) THEN BEGIN
            lstyle = 5
            confi = str_sep(string(1-fap[ll]),'00')
            xyouts,log.ft_min,signi[ll],confi[0]
        ENDIF
        PLOTS,log.ft_min,signi[ll],linestyle=lstyle
        PLOTS,log.ft_max,signi[ll],/continue,linestyle=lstyle
    ENDFOR
    
;   ------ Plot Period Amplitude Spectrum    
    PLOT,period,psd, xrange = [1.e6/log.ft_max,1.e6/log.ft_min], title = "Period Spectrum" , $
      xtitle= 'period / s', ytitle= 'psd power', xstyle=1
    FOR ll = 0,17 DO BEGIN
         lstyle = 2
        IF (ll GT 8) THEN lstyle = 1 
        IF (ll EQ 0 OR ll EQ 4 OR ll EQ 8) THEN BEGIN
            lstyle = 5
            confi = str_sep(string(1-fap[ll]),'00')
            xyouts,1.e6/log.ft_max,signi[ll],confi[0]
        ENDIF
        PLOTS,1.e6/log.ft_max,signi[ll],linestyle=lstyle
        PLOTS,1.e6/log.ft_min,signi[ll],/continue,linestyle=lstyle
    ENDFOR
    
;   ------ Make Fourier transform ;;auskommentiert von sonja
;                                ;rebinning
;    rebinlc,(tclear-tclear[0])*86400.d0,fclear-1.,tnew,fnew,dt=tstep,/gaps
;                                ;fft
;    fastftrans, fnew,dft
;    fourierfreq,tnew,freq
;    
;   ------ Plot rebinnned Lightcurve    
;    PLOT,tnew,fnew,title = "Rebinned Lightcurve, time step = "+STRTRIM(STRING(tstep),2)+"s",ystyle=1,xtitle= 'time / s'
;    
;    
;   ------ Plot Fourier transform of rebinned lightcurve    
;    PLOT,1./freq,abs(dft), xrange = [1.e6/log.ft_max,1.e6/log.ft_min], title = "Fourier Transform of Rebinned Lightcurve" ,xtitle= 'period / s', ytitle= 'amplitude'
;    
    
;   ------
    !p.multi=0

    DEVICE,/close               
    SET_PLOT,'x'                
    
    
    PRINT, ' '
    PRINT, '% TRIPP_SHOW_FINAL: CREATING FILE      : ' + psFile
    PRINT, '% ==========================================================================================='
    PRINT, ' '
    
    

;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------
