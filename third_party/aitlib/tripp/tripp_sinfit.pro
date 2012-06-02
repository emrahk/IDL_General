PRO TRIPP_SINFIT, fileName, wc, parfile, seed=seed, scargle=scargle, pfold=pfold, scsmooth=scsmooth, $
                  residual=residual, p_min=p_min, p_max=p_max, nif = nif,               $
                  fap_horne = fap_horne,  fap_sim = fap_sim, sigma = sigma, $
                  nbins = nbins,device=device, multiple=multiple,silent=silent
;+
; NAME:
;	TRIPP_SINFIT
;
; PURPOSE:   
;       
;	Fit sinus functions to the data 
;	
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_SINFIT, fileName, wc, parfile
;   
; INPUTS:
;	
;       ASCII light curves, WARNING: time in days
;
;
; OUTPUTS:
;   
;	
; RESTRICTIONS:
;       number of lines in FILENAME must be specified by wc
;
; REVISION HISTORY:
;   
;       Version 1.0, 1999/07,Stefan Dreizler, using JWCURVEFIT
;       Version 1.1, 2000/01,Stefan Dreizler, added fap simulations
;       Version 1.1, 2001/01,SLS, wc is still mandatory because of
;                                 parameterfile; think ... ? 
;       Version 1.2, 2001/02,SD,SLS, more output and plots, and do not
;                                 reconstuct the fit but use result
;                                 instead 
;-
   
  on_error,2                    ;Return to caller if an error occurs

   IF NOT EXIST(scargle)    THEN scargle  = 0 
   IF NOT EXIST(pfold)      THEN pfold    = 0 
   IF NOT EXIST(scsmooth)   THEN scsmooth = 1
   IF NOT EXIST(p_min)      THEN p_min    = 100.
   IF NOT EXIST(p_max)      THEN p_max    = 1000.
;;IF NOT EXIST(seed)       THEN seed     = !pi   better leave seed undefined
   IF NOT EXIST(residual)   THEN residual = 0
   IF NOT EXIST(fap_horne)  THEN fap_horne= 0
   IF NOT EXIST(fap_sim)    THEN fap_sim  = 0
   IF     EXIST(multiple)   THEN fap_sim  = 1
   IF NOT EXIST(multiple)   THEN multiple = 0
   IF multiple EQ 0 AND fap_sim EQ 1 THEN BEGIN
     PRINT,"% TRIPP_SINFIT: Defaulting multiple keyword to 500"
     multiple = 500
     wait,2
   ENDIF
   IF NOT EXIST(device)     THEN device   = 'x'
   IF NOT EXIST(silent)     THEN chatty   = 1
   IF NOT EXIST(silent)     THEN debug    = 1
   loadct,39

;; ---------------------------------------------------------
;; --- READ IN FILE ---
;;   
;; --- supply wc if not given: length of data file
   
   spawn,' wc '+fileName+' >length'
   get_lun,unit
   openr,unit,'length'
   readf,unit,all
   free_lun,unit
   spawn,' rm -f length'
   all=fix(all)
   IF n_elements(wc) EQ 0 THEN BEGIN
     wc = all
   ENDIF ELSE IF all LT wc THEN wc = all
   PRINT,"% TRIPP_SINFIT: Using "+strtrim(string(wc),2)+$
     " out of "+strtrim(string(all),2)+" data points."         
   
   
;; --- read in file for good
   data=dblarr(2,wc)
   get_lun,unit
   openr,unit,fileName
   READF,unit,data
   free_lun,unit
   
    time=(data[0,*]-data[0,0])*86400.
    flux=data[1,*]

    PRINT," "
    PRINT,"% TRIPP_SINFIT: READING DATA FILE     : " + fileName
    
;; READ parfile to obtain start values for sinus fitting and
;; appropriate bounds

    OPENR,unit,parfile,/get_lun
    READF,unit,itmax                  ; READ maxium number of iterations
    READF,unit,tol                    ; READ fit toleranz 
    READF,unit,dim_a                  ; READ number of fit parameters
    a = DBLARR(dim_a)                 
    READF,unit,a                      ; READ fit parameters
    READF,unit,dim_bound              ; READ number of bounds
    bound = DBLARR(2,dim_bound)
    READF,unit,bound                  ; READ bounds 
    FREE_LUN,unit


;    PRINT," "
    PRINT,"% TRIPP_SINFIT: READING PARAMETER FILE: " + parfile

;   ------ Sinus Fit  adjust phase to midpoint of time series.... much better than to the start :-)

     result = TRIPP_CURVEFIT(time-time[n_elements(time)/2],flux,[replicate(1.0,n_elements(time))], $
              a,sigmaa,FUNCTION_NAME='TRIPP_FIT_SINUS',itmax=itmax,tol=tol,iter=iter, bounds=bound)

;   ------ calculate fit curve

;     sum2 = 0.
;     FOR j=1,(N_ELEMENTS(a)-4)/3 DO BEGIN
;         jj = 3*(j - 1)+4
;         sum2=sum2+a[jj]*sin(2.*!dpi*((time-time[n_elements(time)/2])/a[jj+1]+a[jj+2]))
;     ENDFOR
     
     tt = time-time[N_ELEMENTS(time)/2]
     
;     ffit = sum2 + a[0] + tt*(a[1] + tt*(a[2] + tt*a[3]))
     
     ffit = result
     
;; ----------------------------------------------------------    
;; write fit parameters
    OPENW,unit,parfile+"_new",/get_lun
    PRINTF,unit,itmax                  ; PRINT maxium number of iterations
    PRINTF,unit,tol                    ; PRINT fit toleranz 
    PRINTF,unit,dim_a                  ; PRINT number of fit parameters
    FOR k=0,dim_a-1 DO PRINTF,unit,a[k]        ; PRINT fit parameters
    PRINTF,unit,dim_bound              ; PRINT number of bounds
    FOR k=0,dim_bound-1 DO PRINTF,unit,bound[0,k],bound[1,k] ; PRINT bounds 
    FREE_LUN,unit

    PRINT," "
    PRINT,"% TRIPP_SINFIT: # of iterations       : ",strtrim(string(iter),2)
    PRINT,"% TRIPP_SINFIT: Fit tolerance         : ", strtrim(string(tol),2)
    PRINT," "
    PRINT,"% TRIPP_SINFIT: Parameters for polynomial fit: "
    PRINT,"                f = a[0] + a[1]*t + a[2]*t^2 + a[3]*t^3"
    PRINT,"% TRIPP_SINFIT:                        a[0]              ", a[0]
    PRINT,"% TRIPP_SINFIT:                        a[1]              ", a[1]
    PRINT,"% TRIPP_SINFIT:                        a[2]              ", a[2]
    PRINT,"% TRIPP_SINFIT:                        a[3]              ", a[3]

    PRINT,"% TRIPP_SINFIT: Parameters for sinus fits: "
    FOR k=4,dim_a-1,3 DO BEGIN
      PRINT,"% TRIPP_SINFIT: Amplitude              a[",strtrim(string(k),2),"]              ", a[k]
      PRINT,"% TRIPP_SINFIT: Periode                a[",strtrim(string(k+1),2),"]              ", a[k+1]
      PRINT,"% TRIPP_SINFIT: Phase in units of time a[",strtrim(string(k+2),2),"]*period+tshift", $
        a[k+2]*a[k+1]+time(N_ELEMENTS(time)/2) MOD a[k+1]
;   time=(data[0,*]-data[0,0])*86400.
      PRINT,"% TRIPP_SINFIT: Absolute phase in JD   a[",strtrim(string(k+2),2),"]~             ", $
        (a[k+2]*a[k+1]+time[N_ELEMENTS(time)/2] MOD a[k+1])/86400.+data[0,0]
    ENDFOR
    PRINT," "
    PRINT,"% TRIPP_SINFIT: Parameters in new parameter file :"
    PRINT," "
    FOR k=0,dim_a-1 DO PRINT,strtrim(string(a[k]),2)

    PRINT," "
    PRINT,"% TRIPP_SINFIT: WRITING FILE          : " + parfile+"_new"
;; ----------------------------------------------------------    
 
   
   CASE device OF
       'ps': BEGIN 
           ;; --- ps-output file  
           psFile       =  fileName + "_fit.ps"
           SET_PLOT,'ps',/copy
           DEVICE,filename = psFile,/landscape,/color,bits=8
           ;; ----- Write Title Page    
           a       =[0,0]
           PLOT,a,ystyle=4,xstyle=4,/NODATA,XMARGIN=[0.,1.],YMARGIN=[0.,1.]
           
           XYOUTS,.0,1., "--------------------"
           XYOUTS,.0,.80,filename,CHARSIZE=3. 
           XYOUTS,.0,.75, "--------------------"
           XYOUTS,.0,.6, "Data Blocks used:"
           XYOUTS,.0,.55,"Filename:                  "+psFile
       END 
       'x' : BEGIN 
           SET_PLOT,'x',/copy
           wset,0
       END 
       ELSE: STOP 
   ENDCASE 

   
;   ------ Plot Lightcurve
    !P.MULTI=[0,2,3,0,0]

    ymin=min(flux)*0.98   
    ymax=max(flux)*1.02

    PLOT,time,flux,psym=1,ystyle=1,title ="Lightcurve and fit" , $
         xtitle= 'time / s',ytitle='amplitude',yrange=[ymin,ymax]
    
;   ------ Plot Fit curve

    OPLOT, time,ffit;,color=150   

;   ------ Plot Residuals
    
    PLOT,time,flux-ffit,psym=1,ystyle=1,title ="Residuals" ,xtitle= 'time / s',ytitle='amplitude',yrange=[ymin,ymax]
    PLOT,time,flux-ffit,psym=1,ystyle=1,title ="Residuals" ,xtitle= 'time / s',ytitle='amplitude'
    
; --- Make noise for the fit and display ffit as well as residual

    !P.MULTI=[1,0,3,0,0]
    noise = sqrt((moment(flux-ffit))[1])
    noiseamp=randomn(seed,n_elements(time))*noise 
    ffit_noise = ffit + noiseamp
    PLOT, time,flux,psym=1,ystyle=1,title ="Lightcurve and noisy fit" ,    $
          xtitle= 'time / s',ytitle='amplitude',yrange=[ymin,ymax]
    OPLOT,time,ffit_noise;,color=150   

    !P.MULTI=[0,0,0,0,0]

;; ---------------------------------------------------------
;; --- WRITE SIMULATION TO FILE
    OPENW,unit,fileName+"_simulation",/get_lun
    FOR i=0,n_elements(time)-1 DO PRINTF,unit,data[0,i],ffit[i],format='(2e25.10)'
    FREE_LUN,unit

;    PRINT," "
    PRINT,"% TRIPP_SINFIT: WRITING FILE          : " + fileName+"_simulation"

;; ---------------------------------------------------------
;; --- WRITE SIMULATION TO FILE
    OPENW,unit,fileName+"_simulation_noise",/get_lun
    FOR i=0,n_elements(time)-1 DO PRINTF,unit,data[0,i],ffit_noise[i],format='(2e25.10)'
    FREE_LUN,unit

;    PRINT," "
    PRINT,"% TRIPP_SINFIT: WRITING FILE          : " + fileName+"_simulation_noise"

;; ---------------------------------------------------------
;; --- WRITE RESIDUAL TO FILE
    OPENW,unit,fileName+"_residual",/get_lun
    FOR i=0,n_elements(time)-1 DO PRINTF,unit,data[0,i],flux[i]-ffit[i],format='(2e25.10)'
    FREE_LUN,unit

;    PRINT," "
    PRINT,"% TRIPP_SINFIT: WRITING FILE          : " + fileName+"_residual"

;; ---------------------------------------------------------
;; --- scargle or pfold preparations
    IF scargle NE 0 OR pfold NE 0 THEN BEGIN
      
      PRINT," "
      
;; --- smooth  scsmooth=1 (default) means no smoothing
      tripp_smooth,time,flux,scsmooth,time_s,flux_s
      tripp_smooth,time,ffit,scsmooth,time_s,ffit_s
      tripp_smooth,time,ffit_noise,scsmooth,time_s,ffit_noise_s
      tripp_smooth,time,flux-ffit,scsmooth,time_s,diff_s
    ENDIF
    
;; ---------------------------------------------------------
;; --- SET ARRAY of FALSE ALARM PROBABILITIES for SCARGLE
    IF scargle NE 0 THEN BEGIN
      IF NOT EXIST(sigma) THEN BEGIN
;       fap = dblarr(18)
       fap = dblarr(14)
       fap(0)  =  .90           ; confidence level of 10%
       fap(1)  =  .80  
       fap(2)  =  .70  
       fap(3)  =  .60  
       fap(4)  =  .50           ; confidence level of 50%
       fap(5)  =  .40  
       fap(6)  =  .30  
       fap(7)  =  .20  
       fap(8)  =  .10           ; confidence level of 90%
       fap(9)  =  .09  
       fap(10) =  .08  
       fap(11) =  .07  
       fap(12) =  .06  
       fap(13) =  .05  
;        fap(14) =  .04  
;        fap(15) =  .03  
;        fap(16) =  .02 
;        fap(17) =  .01           ; confidence level of 99%
   ENDIF ELSE BEGIN
       fap = dblarr(14)
       fap(0)  =  .617          ; confidence level of 0.5  si: 38.3%
       fap(1)  =  .317          ; confidence level of 1.0  si: 68.3%
       fap(2)  =  .134          ; confidence level of 1.5  si: 86.6%
       fap(3)  =  .046          ; confidence level of 2.0  si: 95.4%
       fap(4)  =  .012          ; confidence level of 2.5  si: 98.8%
       fap(5)  =  .003          ; confidence level of 3.0  si: 99.7%
       fap(6)  =  .00005        ; confidence level of 3.5  si: 99.995%
       fap(7)  =  .0000006      ; confidence level of 4.0  si: 99.99994%
       fap(8)  =  .00000007     ; confidence level of 4.5  si: 99.999993%
       fap(9)  =  .000000006    ; confidence level of 5.0  si: 99.9999994%
       fap(10) =  .003
       fap(11) =  .003
       fap(12) =  .003
       fap(13) =  .003
;        fap(14) =  .003
;        fap(15) =  .003
;        fap(16) =  .003
;        fap(17) =  .003
   ENDELSE
   
;; *** NOW CALCULATED DIRECTLY BY SCARGLE
;; --- construct saveFile name for fap simulations 
;    saveFile = fileName+"_smooth"+strtrim(string(scsmooth),2) + "_many_idl.psd_short"
;    dummy = findfile(saveFile,count=count)
; ;; --- restore saveFile
;    IF count EQ 1 THEN BEGIN
;        PRINT,"% TRIPP_SINFIT: RESTORING              "+saveFile
;        restore, saveFile
       
;        IF NOT exist(psdpeaksort) THEN psdpeaksort = maxpsd2dsort
       
; ;; --- calculate signisim's       
;        clv  = 1. - fap    
;        dim1 = size(psdpeaksort)
;        dim2 = size(clv)
;        IF dim2[0] EQ 0 THEN dim2[1] = n_elements(clv) ; dim2[1] # of clv values
       
;        signisim      = dblarr(dim2[1])
;        FOR i=0,dim2[1]-1 DO BEGIN    
;            signisim[i] = psdpeaksort(long(clv[i]*(dim1[1]-1)))
;        ENDFOR
       
;    ENDIF ELSE BEGIN
;        PRINT,"% TRIPP_SINFIT: NO FILE     : " + saveFile
;        signisim = dblarr(14)
;    ENDELSE
   
;; ---------------------------------------------------------
;; plot periodogram

   IF device EQ 'x' THEN BEGIN
     window,1
     wset,1
   ENDIF

    ;; --- set numf
    nr = n_elements(time_s)-1
    tdiff = dblarr(nr)
    FOR i=1,nr DO tdiff[i-1]=time_s[i]-time_s[i-1]
    cycletime = median(tdiff) 
    IF NOT EXIST(nif)         THEN nif = 1.5*(time_s[nr]-time_s[0])/cycletime
    IF string(nif) NE 'horne' THEN numf=nif

    IF residual NE 0 THEN GOTO,JUMP
;; --- observation

    TRIPP_PLOT_PERIODOGRAM,time_s,flux_s,device,0,4,'observation',numf=numf,      $
      faps=fap,signisim=signisim,fap_horne=fap_horne,fap_sim=fap_sim,    $
      pmin=p_min,pmax=p_max, multiple=multiple, debug=debug

;; --- noise free simulation ps file first

    TRIPP_PLOT_PERIODOGRAM,time_s,ffit_s,device,3,4,'noise free simulation',numf=numf,      $
      faps=fap,signisim=signisim,fap_horne=fap_horne,fap_sim=fap_sim,    $
      pmin=p_min,pmax=p_max, multiple=multiple, debug=debug

;; --- noisy simulation screen first


    TRIPP_PLOT_PERIODOGRAM,time_s,ffit_noise_s,device,2,4,'noisy simulation',numf=numf,      $
      faps=fap,signisim=signisim,fap_horne=fap_horne,fap_sim=fap_sim,     $
      pmin=p_min,pmax=p_max, multiple=multiple, debug=debug

JUMP:
;; --- residual ps file first

    TRIPP_PLOT_PERIODOGRAM,time_s,diff_s,device,1,4,'residual',numf=numf,      $
      faps=fap,signisim=signisim,fap_horne=fap_horne,fap_sim=fap_sim,  $
      pmin=p_min,pmax=p_max, multiple=multiple, debug=debug

    !P.MULTI=[0,0,0,0,0]
;    SET_PLOT,'x',/copy
    

    ENDIF

;;; ---------------------------------------------------------
;; --- period folding
    
    IF pfold NE 0 THEN BEGIN
      IF device EQ 'x' THEN BEGIN
        window,2    
        wset,2
      ENDIF
      IF residual NE 0 THEN GOTO,JUMP2
      !P.MULTI=[0,0,4,0,0]
      epfold,time_s,flux_s,pstart=p_min,pstop=p_max,chierg=chierg1,nbins=nbins,$
        maxchierg=maxchierg,chatty=chatty
      max_per=maxchierg[0]
      plot,chierg1[0,*],chierg1[1,*],charsize=1.5,                    $
        title = "Period Folding observation" ,xtitle= 'period / s', $
        ytitle='chi square'
      
;    pfold,time_s,ffit_s,profile,period=max_per,nbins=nbins
;    
;    !P.MULTI=[0,0,0,0,0]
;    plot,findgen(nbins)/float(nbins),profile,/ynozero
;    stop
      
      
      !P.MULTI=[3,0,4,0,0]
      epfold,time_s,ffit_s,pstart=p_min,pstop=p_max,chierg=chierg2,nbins=nbins,$
        maxchierg=maxchierg,chatty=chatty
      max_per=maxchierg[0]
      plot,chierg2[0,*],chierg2[1,*],charsize=1.5,                    $
        title = "Period Folding fit" ,xtitle= 'period / s', $
        ytitle='chi square'
      
      !P.MULTI=[2,0,4,0,0]
      epfold,time_s,ffit_noise_s,pstart=p_min,pstop=p_max,chierg=chierg3,nbins=nbins,$
        maxchierg=maxchierg,chatty=chatty
      max_per=maxchierg[0]
      plot,chierg3[0,*],chierg3[1,*],charsize=1.5,                    $
        title = "Period Folding noisy fit" ,xtitle= 'period / s', $
        ytitle='chi square'
      
      JUMP2:
      !P.MULTI=[1,0,4,0,0]
      epfold,time_s,diff_s,pstart=p_min,pstop=p_max,chierg=chierg4,nbins=nbins,$
        maxchierg=maxchierg,chatty=chatty
      max_per=maxchierg[0]
      plot,chierg4[0,*],chierg4[1,*],charsize=1.5,                    $
        title = "Period Folding residual" ,xtitle= 'period / s', $
        ytitle='chi square'
      
;    ; ps file now
;    SET_PLOT,'ps',/copy
;    IF residual NE 0 THEN GOTO,JUMP3
;    !P.MULTI=[0,0,4,0,0]
;    plot,chierg1[0,*],chierg1[1,*],charsize=1.5,                    $
;      title = "Period Folding observation" ,xtitle= 'period / s', $
;      ytitle='chi square'
;    
;    !P.MULTI=[3,0,4,0,0]
;    plot,chierg2[0,*],chierg2[1,*],charsize=1.5,                    $
;      title = "Period Folding fit" ,xtitle= 'period / s', $
;      ytitle='chi square'
;    
;    !P.MULTI=[2,0,4,0,0]
;    plot,chierg3[0,*],chierg3[1,*],charsize=1.5,                    $
;      title = "Period Folding noisy fit" ,xtitle= 'period / s', $
;      ytitle='chi square'
;    
;    JUMP3:
;    !P.MULTI=[1,0,4,0,0]
;    plot,chierg4[0,*],chierg4[1,*],charsize=1.5,                    $
;      title = "Period Folding residual" ,xtitle= 'period / s', $
;      ytitle='chi square'
    
    ENDIF 
    IF device EQ 'ps' THEN BEGIN 
      DEVICE,/close             ; all ps plots finished              
      set_plot,'x',/copy
    ENDIF 

PRINT, "% ==========================================================================================="
PRINT, " "

        
; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------



