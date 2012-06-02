PRO TRIPP_SIMULATE, amp01=amp01, period01=period01, toffset=toffset,          $
                    exptime=exptime,cycletime=cycletime,nr_datapts=nr_datapts, $
                    noise=noise, tnoise=tnoise, seed=seed, stdev=stdev,        $
                    degree=degree, clearmax=clearmax, clearmin=clearmin,       $
                    preclear=preclear,smoothed=smoothed,                       $
                    vorlage=vorlage, $   ;;file aus dem Zeitmarken kommen koennen
                    period02=period02,period03=period03,period04=period04,period05=period05,  $
                    period06=period06,period07=period07,period08=period08,period09=period09,  $
                    period10=period10, $
                    amp02=amp02,amp03=amp03,amp04=amp04,amp05=amp05,                          $
                    amp06=amp06,amp07=amp07,amp08=amp08,amp09=amp09,amp10=amp10,              $
                    silent=silent,pfile=pfile
  
;+
; NAME:               
;                     TRIPP_SIMULATE
;
;
;
; PURPOSE: 
;                     Erzeuge Daten aus SINUS-Lichtkurve(n) 
;                     der Periode(n) period(i) und Amplituden(n) amp(i) 
;                     die integrierend gesampelt wird;
;                     alternativ: aneinandergesetzte Pulsprofile aus pfile
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:     vorlage
;                      pfile
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:              *.sim     : ASCII file      
;                       *_idl.sim : IDL SAVE file
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;                    If using vorlage, nr_datapts MUST be 
;                    equal to wc (i. e. #elements) in vorlage ! 
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
;                    Version 1.0, SLS and SD
;                                 SLS, 16.12.1999:
;                                 added stdev for compatibility with 
;                                 tripp_simmany 
;                    Version 1.1, 2001/01, SLS, nr_datapts is not 
;                                 a necessary input any more  
;                    Version 1.2, 2001/02, SLS, 
;                                 - included the "profile"
;                                   functionality from the former 
;                                   tripp_simulate_profile.pro by SD:
;                                   corresponds to pfile=...  input
;                                 - added IDL SAVE file output *_idl.sim
;                                 2002/09, SLS,
;                                 - allow for longer input files
;-
   
;; ---------------------------------------------------------
;; --- SET DEFAULT PARAMETERS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  
  IF EXIST(period01) AND NOT EXIST(amp01) THEN amp01 = 1.
  IF NOT EXIST(period01)   THEN amp01      = 0.
  IF NOT EXIST(period01)   THEN period01   = 200. 
  IF NOT EXIST(exptime)    THEN exptime    = double(10.)
  IF NOT EXIST(cycletime)  THEN cycletime  = double(exptime*1.5)
  IF NOT EXIST(toffset)    THEN toffset    = double(0.)
  IF NOT EXIST(vorlage)  AND NOT EXIST(nr_datapts) THEN nr_datapts = 500 ELSE BEGIN
    IF EXIST(vorlage) THEN BEGIN
      ;; --- supply wc if not given: length of data file
      spawn,' wc '+vorlage+' >length'
      get_lun,unit
      openr,unit,'length'
      readf,unit,all
      free_lun,unit
      spawn,' rm -f length'
      all=long(all)
      IF n_elements(nr_datapts) EQ 0 THEN BEGIN
        nr_datapts = all
      ENDIF ELSE IF all LT nr_datapts THEN nr_datapts = all
      PRINT,"% TRIPP_SIMULATE: Using "+strtrim(string(nr_datapts),2)+$
        " out of "+strtrim(string(all),2)+" data points."         
    ENDIF
  ENDELSE
  IF NOT EXIST(noise)      THEN noise      = double(0.)
  IF NOT EXIST(tnoise)     THEN tnoise     = double(0.)
  IF NOT EXIST(degree)     THEN degree     = -1
  IF NOT EXIST(clearmin)   THEN clearmin   = double(-1000000.0)
  IF NOT EXIST(clearmax)   THEN clearmax   = double( 1000000.)
  IF NOT EXIST(preclear)   THEN preclear   = -1
  IF NOT EXIST(smoothed)   THEN smoothed   = 0
  IF NOT EXIST(vorlage)    THEN vorlage    = "nein"
  IF NOT EXIST(pfile)      THEN pfile      = "nein"
  IF NOT EXIST(amp02)      THEN amp02      = double(amp01)
  IF NOT EXIST(amp03)      THEN amp03      = double(amp02)
  IF NOT EXIST(amp04)      THEN amp04      = double(amp03)
  IF NOT EXIST(amp05)      THEN amp05      = double(amp04)
  IF NOT EXIST(amp06)      THEN amp06      = double(amp05)
  IF NOT EXIST(amp07)      THEN amp07      = double(amp06)
  IF NOT EXIST(amp08)      THEN amp08      = double(amp07)
  IF NOT EXIST(amp09)      THEN amp09      = double(amp08)
  IF NOT EXIST(amp10)      THEN amp10      = double(amp09)
  IF NOT EXIST(period02)   THEN amp02      = double(0.)
  IF NOT EXIST(period03)   THEN amp03      = double(0.)
  IF NOT EXIST(period04)   THEN amp04      = double(0.)
  IF NOT EXIST(period05)   THEN amp05      = double(0.)
  IF NOT EXIST(period06)   THEN amp06      = double(0.)
  IF NOT EXIST(period07)   THEN amp07      = double(0.)
  IF NOT EXIST(period08)   THEN amp08      = double(0.)
  IF NOT EXIST(period09)   THEN amp09      = double(0.)
  IF NOT EXIST(period10)   THEN amp10      = double(0.)
  IF NOT EXIST(period02)   THEN period02   = double(period01)
  IF NOT EXIST(period03)   THEN period03   = double(period01)
  IF NOT EXIST(period04)   THEN period04   = double(period01)
  IF NOT EXIST(period05)   THEN period05   = double(period01)
  IF NOT EXIST(period06)   THEN period06   = double(period01)
  IF NOT EXIST(period07)   THEN period07   = double(period01)
  IF NOT EXIST(period08)   THEN period08   = double(period01)
  IF NOT EXIST(period09)   THEN period09   = double(period01)
  IF NOT EXIST(period10)   THEN period10   = double(period01)
  
  
;; ---------------------------------------------------------
;; --- OUTPUT FILENAMES
;;

  idlfilename = "p" +strtrim(string(period01),2)+ $
    "te"+strtrim(string(exptime),2)+ $
    "tc"+strtrim(string(cycletime),2)+ $
    "nr"+strtrim(string(nr_datapts),2)+ $
    "_idl.sim"
  filename = "p" +strtrim(string(period01),2)+ $
    "te"+strtrim(string(exptime),2)+ $
    "tc"+strtrim(string(cycletime),2)+ $
    "nr"+strtrim(string(nr_datapts),2)+ $
    ".sim"
  
;; ---------------------------------------------------------
;; --- LOOP OVER ALL PERIODS
;;
  data_save = dblarr(nr_datapts)
  
  IF pfile NE "nein" THEN BEGIN
    Print, "% TRIPP_SIMULATE: reading puls profile from file " +pfile
    openr,unit,pfile,/get_lun
    readf,unit,dim
    profile = dblarr(2,dim)
    readf,unit,profile
    free_lun,unit
  ENDIF     
  
  FOR i=0,9 DO BEGIN
;; ---------------------------------------------------------
;; --- THEORETICAL AND SAMPLED LIGHTCURVES: PERIOD i
;;
    ;; --- Dimensions
    dat       = dblarr(2, 10* long(nr_datapts))
    data      = dblarr(2 , long(nr_datapts))
    helparray = dblarr(2 , long(nr_datapts))
    period    = double([period01,period02,period03,period04,period05,period06,period07,period08,period09,period10])
    amp       = double([amp01,amp02,amp03,amp04,amp05,amp06,amp07,amp08,amp09,amp10])
    
    ;; --- No input file (default)
    IF (vorlage EQ "nein") THEN BEGIN
      ;; --- Make noise
      noiseamp=double(randomn(seed,nr_datapts)*noise)
      tnoiseamp=double(randomn(seed,nr_datapts)*tnoise)
      ;; --- Sampled
      IF pfile EQ "nein" THEN BEGIN 
        FOR n = 0l, nr_datapts-1 DO BEGIN
          data[0,n] = (n*cycletime + exptime/2. +tnoiseamp[n])/86400.
          data[1,n] = amp[i]*period[i]/(2.*!DPI)/exptime*          $
            (  cos(   2.*!DPI/period[i]* (n*cycletime+tnoiseamp[n] )    )  -   $
               cos(   2.*!DPI/period[i]* (n*cycletime+exptime+tnoiseamp[n] )  ) )
        ENDFOR
      ENDIF ELSE BEGIN 
        FOR n = 0l, nr_datapts-1 DO BEGIN
          data[0,n] = (n*cycletime + exptime/2. +tnoiseamp[n])/86400.
          phase  = (data[0,n]*86400. MOD period[i])/period[i]
          data[1,n] = amp[i]*interpol(profile[1,*],profile[0,*],phase)    
        ENDFOR        
      ENDELSE 
    ENDIF
    ;; --- Input File (optional)
    IF (vorlage NE "nein") THEN BEGIN
      get_lun,unit
      openr,unit,vorlage	
      READF,unit,helparray
      free_lun,unit
      ;; --- determine standard deviation
      IF EXIST(stdev) THEN BEGIN
        result = moment(helparray[1,*])
        noise = sqrt(result[1]) 
        IF i EQ 0 THEN                    $
          Print, "% TRIPP_SIMULATE: Standard Deviation of the light curve: " + strtrim(string(noise),2)
      ENDIF
      ;; --- Sampled
      IF pfile EQ "nein" THEN BEGIN 
        FOR n=0l,nr_datapts-1 DO BEGIN
          data[0,n] = helparray[0,n]
          data[1,n] = amp[i]*period[i]/(2.*!DPI)/exptime*           $
            (  cos(2.*!DPI/period[i]*(data[0,n]*86400.-exptime/2.)) -  $
               cos(2.*!DPI/period[i]*(data[0,n]*86400.+exptime/2.))  )
        ENDFOR
      ENDIF ELSE BEGIN 
        FOR n = 0l, nr_datapts-1 DO BEGIN
          data[0,n] = helparray[0,n]
          phase  = (data[0,n]*86400. MOD period[i])/ period[i]
          data[1,n] = amp[i]*interpol(profile[1,*],profile[0,*],phase)    
        ENDFOR        
      ENDELSE         
    ENDIF
;; ---------------------------------------------------------
    data_save = data_save+data[1,*]
  ENDFOR
  data[1,*]=data_save+1.
;return
;; ---------------------------------------------------------
;; --- RENAME IMPORTANT VARIABLES: FLUX AND TIME
;;
  fclean = data[1,*]  
  tclean = data[0,*]+double(toffset)/86400.
  
;; ---------------------------------------------------------
;; --- NORMALIZE FLUX 
;;
  m      = median( fclean )
  fclean = fclean / m
;; ---------------------------------------------------------
;, --- MAKE NOISE
  noiseamp=double(randomn(seed,nr_datapts)*noise )
  fclean = fclean + noiseamp
  
;; ---------------------------------------------------------
;; --- PLOT LIGHTCURVES
;;
  IF NOT KEYWORD_SET(silent) THEN BEGIN
    loadct,39
    plot,tclean-tclean[0],fclean, ystyle=1
  ENDIF 
;; ---------------------------------------------------------
;; --- PRECLEAN DATA 
;;
  IF preclear EQ 1 THEN BEGIN
    ind    = where(fclean lt 1.5 and fclean gt 0.5)
    m      = median( fclean [ind] )
    fclean = fclean / m
  ENDIF ELSE BEGIN
    ind    = dindgen(n_elements(fclean))
  ENDELSE
  tclear     = tclean[ind]
  fclear     = fclean[ind]
;; ---------------------------------------------------------
;; --- FIT POLYNOMIAL 
;;
  IF degree GT 0 THEN BEGIN
    y  = dblarr (n_elements(ind))
    ff = poly_fit (tclear-tclear[0],fclear,degree) 
    FOR  k = 0,degree DO y = y + ff[k]*(tclear-tclear[0])^k
    fclear = fclear / y
  ENDIF
  
;; ---------------------------------------------------------
;; --- SMOOTH
;;
  IF smoothed GT 1 THEN BEGIN
    fclear = fclear / smooth(fclear,smoothed,/edge_truncate)
  ENDIF
  
;; ---------------------------------------------------------
;; --- CLEAN DATA FROM SUSPICIOUS POINTS
;;
  idx    = where(fclear lt clearmax and fclear gt clearmin)
  
  data=dblarr(2,n_elements(idx))
  data[0,*] = tclear[idx]
  data[1,*] = fclear[idx]
  
  Print, "% TRIPP_SIMULATE: wc =       " + string(n_elements(idx))
  
;; ---------------------------------------------------------
;; --- SAVE RESULT TO IDL SAVE FILE
;;
  SAVE, filename = idlfilename , data

;; ---------------------------------------------------------
;; --- WRITE SIMULATED DATA TO ASCII SIM FILE
;;
  get_lun,unit
  openw,unit,filename
  PRINTF,unit,data,format='(2e25.10)'
  free_lun,unit
  
  PRINT, " "
  PRINT, "% TRIPP_SIMULATE: DATA WRITTEN TO FILE " +idlfilename 
  PRINT, "% TRIPP_SIMULATE: DATA WRITTEN TO FILE " +filename
  PRINT, "% ==========================================================================================="
  PRINT, " "

  IF NOT KEYWORD_SET(silent) THEN BEGIN
    PRINT, "% TRIPP_SIMULATE: You can now run "
    PRINT, "% TRIPP_SIMULATE: tripp_show_all,'"+filename+"',"+strtrim(string(n_elements(idx)),2)
  ENDIF
;;PRINT, "measured noise"+string(sqrt((moment(data(1,*)))(1)))
;; ---------------------------------------------------------
;; --- END
;;
END








