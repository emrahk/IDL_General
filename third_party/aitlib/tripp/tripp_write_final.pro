PRO TRIPP_WRITE_FINAL, logName, no_norm=no_norm, degree=degree, $
                       clearmax=clearmax, clearmin=clearmin, $
                       preclear_min=preclear_min, preclear_max=preclear_max, $
                       smoothed=smoothed, mouse=mouse, norm=norm,silent=silent, $
                       auto=auto
;+
; NAME:
;	TRIPP_WRITE_FINAL
;
; PURPOSE:   
;   
;	Clean IDL-saved flux data (*.rms-file) from
;	photometrical time series and write to ASCII 
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_WRITE_FINAL, LOGNAME = logName,  [ DEGREE=degree,
;       CLEARMAX=clearmax, CLEARMIN=clearmin, PRECLEAR=preclear, 
;       SMOOTHED=smoothed, NO_NORM=no_norm, MOUSE=mouse,silent=silent ]
;   
; INPUTS:
;	
;       logname (for construction of IDL SAVE file *.RMS name)
;
;
; OPTIONAL INPUTS:   
;	
;       degree
;       clearmax
;       clearmin
;       preclear
;       smoothed
;
; OPTIONAL KEYWORDS:
;	
;       no_norm
;       mouse
;       silent
;       auto   - use automatic apperture radii.
;
; OUTPUTS:
;   
;	ASCII file '*.FIN' containing reduced data as x,y- table:
;       x corresponds to time, y corresponds to relative flux
;       IDL SAVE File '*_idl.FIN' containing same data
;
;	
; RESTRICTIONS:
;   
;       file type:      RMS as produced by TRIPP_CALC_RELFLUX (or ccd_rms
;                       or ccd_rms_multi, in principle) 
;	Input directory and filename structure as specified in Log  
;
; REVISION HISTORY:
;   
;       Version 1.0, 1999/06, Sonja Schuh, Stefan Dreizler
;       Version 1.1, 1999/10, Sonja Schuh, Stefan Dreizler
;       Version 1.1, 2000/11, Sonja L. Schuh: copy preclear_values to
;                             clearvalues if the latter are less tight
;                             (for IDL save file, which is used by
;                             tripp_show_final) 
;       Version 2.0, 2001/02, Sonja L. Schuh: 
;                             - no_norm keyword added       
;                             - mouse keyword added
;                    2001/02, SLS, added messages 
;       Version 1.0, 2001/02, SLS, new handling for no_norm / norm:
;                             new keyword norm
;                             default is now NO normalisation
;                             no_norm will have no further effect
;                             norm will force the normalisation to be done
;                    2001/05, SLS, xyouts only if necessary, titles
;                             for final lightcurve plot, loadct
;                             changes and silent keyword
;                    2001/07, SLS, data points AND line in plots
;                    2001/07, SLS, sort time marks
;                    2002/08, SLS, allow for longer input files by
;                                  using long(all) instead of fix(all)
;                                  and equally for longer output files
;                                  by using k=0L instead of k=0
;                    ????     Somebody, introduced auto
;                                       keyword. (e.g.)
;                    2002/11  EG, fixes of problems for selecting
;                                 single datapoints with mouse which
;                                 uses invalid indices.
;                                 Also fixed: wrong field length for y
;                                 when performing polynominal
;                                 correction.
;                                 Changed: Display will not change
;                                 when removing data points.


;
;-
  
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;
  
  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_FINAL:     No logfile or datafile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_FINAL:     The specified logfile or datafile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0] 
      PRINT, '% TRIPP_WRITE_FINAL:     Using logfile/datafile ', logname 
    ENDIF
  ENDELSE
  
  
  IF  NOT EXIST(degree)   THEN degree = -1
  IF  NOT EXIST(preclear_min) THEN preclear_min = 0.
  IF  NOT EXIST(preclear_max) THEN preclear_max = 100.
  IF  NOT EXIST(clearmin) THEN clearmin = 0.
  IF  NOT EXIST(clearmax) THEN clearmax = 100.
  IF  NOT EXIST(smoothed) THEN smoothed = 0
  IF  NOT EXIST(no_norm) THEN no_norm = 1
  IF  NOT EXIST(   norm) THEN    norm = 0
  IF  norm EQ 0 THEN no_norm = 1
  
  
;; ---------------------------------------------------------
;; --- READ IN LOG FILE (OR DATA FILE) ---
;;
  datafile=''
  IF strpos(strtrim(logName,2),'.dat') NE -1 THEN dataFile='yes'
  IF strpos(strtrim(logName,2),'.fin') NE -1 THEN dataFile='yes'
  IF strpos(strtrim(logName,2),'.all') NE -1 THEN dataFile='yes'
  
  IF datafile NE 'yes' THEN BEGIN
    
    TRIPP_READ_IMAGE_LOG, logName, LOG
    ;; ---------------------------------------------------------
    ;; --- READ RMS FILE ---
    ;;
    if keyword_set(auto) then                                                $
         rmsfile         = log.out_path + '/' + log.block + '_auto' + '.rms' $
    else rmsfile         = log.out_path + '/' + log.relflx 
    datfile         = log.out_path + '/' + log.block + ".fin"
    finfile         = log.out_path + '/' + log.block + "_idl.fin"
    ;; --- restore
    restore, rmsfile
    ;; --- time shift
    extr_tshft = log.extr_tshft
    ;; --- verbose
    IF NOT KEYWORD_SET(silent) THEN BEGIN
      PRINT, " "
      PRINT, "% TRIPP_WRITE_FINAL: INPUT RMS  FILE      : " + rmsfile
      PRINT, "% TRIPP_WRITE_FINAL: OUTPUT DATA FILES    : " + datfile
      PRINT, "% TRIPP_WRITE_FINAL:                      : " + finfile
      PRINT, " "
    ENDIF
    
  ENDIF ELSE BEGIN
    
    ;; ---------------------------------------------------------
    ;; --- READ DATA FROM INPUT FILE
    ;;
    PRINT," "
    PRINT, "% TRIPP_WRITE_FINAL: READING DATA FILE    : " + logname
    ;; --- supply wc: length of data file
    SPAWN,' wc '+logname+' >length'
    GET_LUN,unit
    OPENR,unit,'length'
    READF,unit,all
    FREE_LUN,unit
    SPAWN,' rm -f length'
    all=long(all)
    wc = all
    PRINT,"% TRIPP_WRITE_FINAL: "+STRTRIM(STRING(wc),2)+$
      " DATA POINTS."         
    ;; --- read in file for good
    data=DBLARR(2,wc)
    GET_LUN,unit
    OPENR,unit,logname
    READF,unit,data
    FREE_LUN,unit
    ;; --- names
    time = data[0,*]
    fneu = data[1,*]
    ;; --- time shift
    extr_tshft = 0.d
    ;; --- 
    datfile         = logname + ".fin"
    finfile         = logname+ "_idl.fin"
    ;; --- verbose
    PRINT, " "
    PRINT, "% TRIPP_WRITE_FINAL: INPUT  DATA FILE     : " + logname
    PRINT, "% TRIPP_WRITE_FINAL: OUTPUT DATA FILES    : " + datfile
    PRINT, "% TRIPP_WRITE_FINAL:                      : " + finfile
    PRINT, " "
    
  ENDELSE
  
;; ---------------------------------------------------------
;; --- SORTING OF TIME MARKS
;;    
    increasing=sort(time)
    time=time(increasing)
    fneu[0,*]=fneu[0,increasing]
  
  
;; ---------------------------------------------------------
;; --- CLEAN DATA FROM ZERO VALUES
;;    
  idx     = WHERE (fneu[0,*] NE 0.)
  fclean  = fneu [0,idx]
  tclean  = time [idx]  
  
  dim     = SIZE (tclean)
  
  
;; ---------------------------------------------------------
;; --- CORRECT FOR TIME SHIFT 
;;
  tshift  = extr_tshft/86400.d
  tclean  = tclean + tshift
  
  
  ttt=tclean
  fff=fclean
;  window,0

;; ---------------------------------------------------------
;; --- NORMALIZE FLUX 
;;
  m      = MEDIAN( fclean )
  fclean = fclean / m
  mremember=m
  
;; ---------------------------------------------------------
;; --- PRECLEAN DATA 
;;
  preclear=-1
  ind    = WHERE(fclean LT preclear_max AND fclean GT preclear_min)
  IF N_ELEMENTS(ind) LT N_ELEMENTS(fclean) THEN preclear=1
  m      = MEDIAN( fclean [ind] )
  fclean = fclean / m
  tclear     = tclean[ind]
  fclear     = fclean[ind]
  
;PRINT,WHERE(fclean GE preclear_max OR fclean LE preclear_MIN)
  
;; ---------------------------------------------------------
;; --- FIT POLYNOMIAL 
;;
  f_median = fclear
  IF degree GT 0 THEN BEGIN
    y  = DBLARR (n_elements(ind))
    ff = POLY_FIT (tclear-tclear[0],fclear,degree) 
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
;; --- VISUAL CHECK OF NORMALIZATION WITH DEGREE
;;
  IF NOT KEYWORD_SET(silent) THEN LOADCT,13
  IF n_elements(tclear) LT 2 THEN BEGIN
    PRINT,"% TRIPP_WRITE_FINAL: Warning: Data range for axis has zero length, returning."
    return
  ENDIF
  PLOT,tclear-tclear[0],f_median, ystyle=1,color=100000,psym=-7
  IF degree   GT 0 THEN OPLOT,tclear-tclear[0],y[idx],color=80
  IF smoothed GT 1 THEN OPLOT,tclear-tclear[0],SMOOTH(f_median,smoothed,/edge_truncate),color=80
;;IF smoothed GT 1 THEN OPLOT,tclear-tclear[0],TS_SMOOTH(f_median,smoothed),color=80
  
  
  
;; ---------------------------------------------------------
;; --- INTERACTIVE CHANGES TO DEGREE, POINTS OR AREAS 
;;
  ind=idx
  
  IF (KEYWORD_SET(mouse)) THEN BEGIN                    
    LOADCT,39
    IF degree LT 0 THEN degree=0
    wtime=0.2
    cdummy=''
    toffset=tclear[0]
    tclear=tclear-toffset
    ;; --- DISPLAY CURRENT RUN OF FCLEAR VERSUS TCLEAR 
    newplot:
    ;; --- POLYNOMIAL FIT
    fitcoeff = POLY_FIT(tclear[ind],fclear[ind],degree,/double) 
    fclearfit = fitcoeff[0]
    FOR k = 1,degree DO fclearfit = fclearfit + fitcoeff[k]*tclear^k
    
    PLOT,tclear[ind],fclear[ind],ystyle=1,                                     $
      xtitle='tclear',ytitle='fclear',$
      title ='Lightcurve',psym=-7
    IF degree GT 0 THEN BEGIN
      OPLOT,tclear,fclearfit,color=20
    ENDIF ELSE BEGIN
      plotfclearfit=DBLARR(N_ELEMENTS(tclear))
      plotfclearfit=plotfclearfit+fclearfit
      OPLOT,tclear,plotfclearfit,color=20 
    ENDELSE
    XYOUTS,tclear[1],MIN(fclearfit)+.5*(MAX(fclearfit)-MIN(fclearfit)),  $
      'Polynom fit of degree '+STRTRIM(STRING(degree),2),color=20
    PRINT,' '
    PRINT,'% TRIPP_WRITE_FINAL: Ready to continue?      Press return'
    PRINT,'% TRIPP_WRITE_FINAL: Reject points from fit? Press r'
    PRINT,'% TRIPP_WRITE_FINAL: New polynomial fit?     Enter degree'
    
    READ,cdummy                                 ;; WAIT FOR ORDERS
    CASE cdummy OF
      
      '' : PRINT,'% TRIPP_WRITE_FINAL: Continuing '            
      'r': BEGIN             
        ;; --- in case points are to be rejected from fit
        PRINT,' '
        MESSAGE,'Left   mouse click   : reject points',/INF
        MESSAGE,'Middle mouse click   : end ',/INF
        MESSAGE,'Right  mouse click   : reject area ',/INF
        
        REPEAT BEGIN
          
          PLOT,tclear[ind],fclear[ind],ystyle=1,   $
            xtitle='tclear',                       $
            ytitle='fclear',                       $
            title ='Lightcurve',psym=-7

          CURSOR,xx,yy,/data
          mouse=!mouse.button
          
          CASE mouse OF
            
            1: BEGIN 
              ; use actual range of plotted data to normalize distance:
	      range = convert_coord([0,1],[0,1],/normal,/to_data)

              diff = ((tclear[ind]-xx)/(range[0,1]-range[0,0]))^2 +$
		     ((fclear[ind]-yy)/(range[1,1]-range[1,0]))^2

              x_REJECT = WHERE (diff EQ MIN(diff))

              ;; use indgen to generate increasing numbers for the index.
              ind_n = WHERE(indgen(n_elements(ind)) NE x_reject[0])
              ind = ind[ind_n]

              WAIT,0.3
            END
          
            2: PRINT,'% TRIPP_WRITE_FINAL: Finished rejection'
            4: BEGIN
              PRINT,' '
              MESSAGE,'Next point to mark area ...',/INF
              WAIT,0.3
              CURSOR,xx2,yy,/data
              WAIT,0.3
              MESSAGE,'Area marked ...',/INF
              xx3 = [xx,xx2]
              ind3 = SORT(xx3)
              ind2 = WHERE(                    $
                            tclear[ind] LT xx3(ind3[0]) OR $
                            tclear[ind] GT xx3(ind3[1])    )
              ind = ind[ind2]
              WAIT,0.3
             END
             
          ENDCASE 
           
        ENDREP UNTIL (mouse eq 2)
        
        GOTO,newplot                        ;; re-display 
      END                                   ;; end rejection
      ELSE: BEGIN
        degree = fix(cdummy)
        GOTO,newplot
      ENDELSE    
      
    ENDCASE
    
    tclear=tclear+toffset        

    ;; apply selection
    tclear=tclear[ind]
    fclear=fclear[ind]


    
    ;; ---------------------------------------------------------
    ;; --- FIT POLYNOMIAL 
    ;;
    f_median = fclear
    IF degree GT 0 THEN BEGIN
      y  = DBLARR (n_elements(tclear)) ; fix: should use numbers of tclear instead of ind (eg)
      ff = POLY_FIT (tclear-tclear[0],fclear,degree) 
      FOR  k = 0,degree DO y = y + ff[k]*(tclear-tclear[0])^k
      fclear = fclear / y
    ENDIF ELSE degree=-1
    
  ENDIF                                     ;; end display/fit    
  

  
;; ---------------------------------------------------------
;; --- REVERSE MEDIAN NORMALISATION IF NORM IS NOT SET
;;
  IF NOT KEYWORD_SET(norm) THEN fclear = fclear*mremember
  
  PLOT,ttt-ttt[0],fff,ystyle=1,$
    xtitle="Time in days since start",ytitle="relative intensity",psym=-7
  IF n_elements(fclear) NE n_elements(fff) OR fclear[0] NE fff[0] THEN silent=0
  IF NOT keyword_set(silent) THEN BEGIN
    OPLOT,tclear-ttt[0],fclear,color=20
    xyouts,'     original data points    '
    xyouts,'     saved data points       ',color=20
  ENDIF

;; ---------------------------------------------------------
;; --- WRITE RESULT TO ASCII DAT FILE
;;
  
  GET_LUN, unit
  OPENW, unit, datFile
  FOR  k = 0L, n_elements(ind) -1  DO BEGIN
    PRINTF, unit, tclear[k], fclear[k],format='(f14.6,f14.6)'
  ENDFOR
  
  FREE_LUN, unit
  
;; ---------------------------------------------------------
;; --- SAVE RESULT TO IDL SAVE FILE
;;
  
  IF preclear_min GT clearmin THEN clearmin = preclear_min
  IF preclear_max LT clearmax THEN clearmax = preclear_max
  
  SAVE, filename = finFile, tclear, fclear, degree, clearmin, clearmax, preclear, smoothed
  
  
  PRINT, " "
  PRINT, "% TRIPP_WRITE_FINAL: DATA WRITTEN TO FILE " + datFile
  PRINT, "% TRIPP_WRITE_FINAL: DATA WRITTEN TO FILE " + finFile
  PRINT, "% ==========================================================================================="
  PRINT, " "
  IF NOT KEYWORD_SET(silent) THEN BEGIN
    PRINT, "% TRIPP_WRITE_FINAL: TO CONTINUE, YOU MAY USE "
    PRINT, " "
    PRINT, "                       restore, '"+finFile+"'"
    PRINT, " "
  ENDIF 
  
;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------









