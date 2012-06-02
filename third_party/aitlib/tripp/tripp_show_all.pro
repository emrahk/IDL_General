@tripp_exist
PRO TRIPP_SHOW_ALL, fileName, wc, degree = degree, smoothed = smoothed, $
                    ft_max = ft_max, ft_min = ft_min, p_min = p_min, p_max = p_max,$ 
                    nr_per = nr_per, nif = nif, $                 
                    scsmooth = scsmooth, notes = notes, $
                    fap_horne = fap_horne, fap_sim = fap_sim, sigma = sigma,$
                    period=period,om=om,psd=psd,xlog=xlog,ylog=ylog,onepage=onepage
;+
; NAME:
;	TRIPP_SHOW_ALL
;
; PURPOSE:   
;       
;	Calculate Fourier Transforms of reduced photometrical data obtained with
;       TRIPP_WRITE_FINAL from  several combined blocks (or a single one). 
;       Show processed data as lightcurve, as frequency and period
;       spectrum as obtained with SCARGLE in one ps-File. 
;       The front page contains additional information about the
;       processing etc.
;	
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_SHOW_ALL, fileName, wc
;   
; INPUTS:
;	
;       ASCII LIGHTCURVE, TIME IN DAYS
;
; OPTIONAL INPUTS:
;
;       FT_MIN  : MINIMUM FREQUENCY IN MICRO-HZ
;       FT_MAX  : MAXIMUM FREQUENCY IN MICRO-HZ
;       P_MIN   : MINIMUM PERIOD    IN SECONDS
;       P_MAX   : MAXIMUM PERIOD    IN SECONDS
;       NR_PER  : min. number of periods you want to be covered   
;       NIF     : Number of frequencies used in SCARGLE   
;       SCSMOOTH: SMOOTHING OF THE LIGHTCURVE
;       FAP_HORNE : switch to plot false alarm probabilities according
;                   to Horne 
;       FAP_SIM   : switch to plot false alarm probabilities according
;                   to simulations 
;       ONEPAGE : keyword to produce ps output on one page instead of
;                 on four individual ones 
;
; OUTPUTS:
;   
;	PS file '*_all.PS' showing Fourier Transforms and Lightcurves
;       of unbinned and binned data block
;
;	
; RESTRICTIONS:
;   
;       file type:    ascii x,y table of known length wc as input 
;	No restrictions due to LogFile, not needed here.
;       You can either use p_min/max OR ft_min/max, if you give both
;       the values for p_min/max will be ignored!   
;
; REVISION HISTORY:
;   
;       Version 1.0, 1999/07, Sonja Schuh; using SCARGLE 
;       Version 1.1, 1999/10, Sonja Schuh, Stefan Dreizler smoothing
;       Version 1.2, 1999/12, Stefan Dreizler, Anpassung an TRIPP-Package
;       Version 1.2, 1999/12, Sonja Schuh, dynamische ft_min/max, p_min/max,               
;                             nr_per, degree, smooth, notes
;       Version 1.3, 2000/01, Sonja Schuh,Stefan Dreizler: reads short simulated
;                             psd-files for new faps; added fap keywords  
;                    2000/02, numf and nif added           
;       Version 1.4, 2001/01, SLS, - wc is not a necessary input any more  
;                             - switched back to new scargle from
;                               aitlib     
;                    2001/06, SLS, longer data files possible (fix to long)
;                    2002/05, SLS, added approximate JD start of observation
;                             SLS, added keyword /onepage 
;
;-
   
  on_error,2                    ;Return to caller if an error occurs
  loadct,39
  
;; ---------------------------------------------------------
;; --- READ DATA FROM INPUT FILE
;;
  PRINT," "
  PRINT,"% TRIPP_SHOW_ALL: READING FILE       : " + fileName
  
  ;; --- supply wc if not given: length of data file
  
  spawn,' \rm -f length'
  spawn,' wc '+fileName+' >length'
  get_lun,unit
  openr,unit,'length'
  readf,unit,all
  free_lun,unit
  spawn,' \rm -f length'
  all=long(all)
  IF n_elements(wc) EQ 0 THEN BEGIN
    wc = all
  ENDIF ELSE IF all LT wc THEN wc = all
  PRINT,"% TRIPP_SHOW_ALL: Using "+strtrim(string(wc),2)+$
    " out of "+strtrim(string(all),2)+" data points."         

   
   ;; --- read in file for good
   data=dblarr(2,wc)
   get_lun,unit
   openr,unit,fileName
   READF,unit,data
   free_lun,unit
   
   tclear=data[0,*]
   fclear=data[1,*]
   

;; ---------------------------------------------------------
;; --- DEFAULTS
;;   
;; --- estimate cycletime:
   nr     = n_elements(tclear)-1
   tdiff  = fltarr(nr)
   FOR i=1l,nr DO BEGIN
      tdiff[i-1]=(tclear[i]-tclear[i-1])*86400.d0
   ENDFOR
   cycletime = median(tdiff) 
;; ---  want to have sampled the shortest period at least twice and 
;; want to have sampled at least two full cycles of the longest period
   IF NOT EXIST(nr_per)   THEN nr_per = 2.
   IF NOT EXIST(p_max)    THEN  p_max = (tclear[nr]-tclear[0])*86400.d0/nr_per
   IF NOT EXIST(p_min)    THEN  p_min = 2.d0*cycletime
   IF NOT EXIST(ft_min)   THEN ft_min = 1.e6/p_max
   IF NOT EXIST(ft_max)   THEN ft_max = 1.e6/p_min
   IF NOT EXIST(degree)   THEN degree = -1
   IF NOT EXIST(smoothed) THEN smoothed = 0
   IF NOT EXIST(scsmooth) THEN scsmooth = 1
   IF NOT EXIST(notes)    THEN notes   = " "
   IF NOT EXIST(fap_horne)THEN fap_horne=0
   IF NOT EXIST(fap_sim)  THEN fap_sim  =1
   IF NOT EXIST(nif)      THEN BEGIN
       nif = 10.*(tclear[nr]-tclear[0])*86400.d0/cycletime
       PRINT,'% TRIPP_SHOW_ALL: Of all '+STRTRIM(STRING(nif),2)+' frequency points,'
       ;; dann noch mit p_min,p_max bzw. ft_min, ft_max passend ausschneiden 
       nif = nr_per / (86400.d0*(tclear[nr]-tclear[0])) + $
         findgen(nif)/(nif-1)  * $
           (.5/cycletime - nr_per/(86400.d0*(tclear[nr]-tclear[0]))  ) 
;       freq= ft_min*1.e-6*nr_per + findgen(nif)/(nif-1) * 1.e-6 * (ft_max - ft_min*nr_per) 
       nif  = n_elements(    where(nif GE ft_min*1.e-6 AND nif LE ft_max*1.e-6)     )
   ENDIF
   IF string(nif) NE 'horne' THEN numf=nif
   PRINT,'% TRIPP_SHOW_ALL: using  '+STRTRIM(STRING(numf),2)+' frequency points'
   
;; ---------------------------------------------------------
;; --- FIT POLYNOMIAL AND/OR SMOOTH
;;
   f_median = fclear
   IF degree GT 0 THEN BEGIN
       y  = dblarr(nr+1)
       ff = poly_fit (tclear-tclear[0],fclear,degree) 
       FOR  k = 0,degree DO y = y + ff[k]*(tclear-tclear[0])^k
       fclear = fclear / y
   ENDIF
   IF smoothed GT 1 THEN BEGIN
       fclear = fclear / SMOOTH(fclear,smoothed,/edge_truncate)
   ENDIF

;; ---------------------------------------------------------
;; ------ PLOT LIGHTCURVE AND POLYNOMIAL: SCREEN OUTPUT
;;
   !P.MULTI=[0,2,2,0,0]
   PLOT,tclear-tclear[0],f_median, ystyle=1,title ="Lightcurve",xtitle= 'time / JD'
   IF degree   GT 0 THEN oplot,tclear-tclear[0],y,color=80 ;;;,y(idx)
   IF smoothed GT 1 THEN oplot,tclear-tclear[0],SMOOTH(f_median,smoothed,/edge_truncate),color=80

;; ---------------------------------------------------------
;; --- SET ARRAY of FALSE ALARM PROBABILITIES for SCARGLE
;;
   fap     = dblarr(18)
   IF NOT EXIST(sigma) THEN BEGIN
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
       fap(14) =  .04  
       fap(15) =  .03  
       fap(16) =  .02 
       fap(17) =  .01           ; confidence level of 99%
   ENDIF ELSE BEGIN
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
       fap(14) =  .003
       fap(15) =  .003
       fap(16) =  .003
       fap(17) =  .003
   ENDELSE
   
;; ----------------------------------------------------------    
;; --- RESTORE SAVEFILE WITH PSD INFORMATION   
;;   
;; --- construct saveFile name
   saveFile = fileName+"_smooth"+strtrim(string(scsmooth),2) + "_many_idl.psd_short"
   dummy = findfile(saveFile,count=count)
;; --- restore saveFile
   IF count EQ 1 THEN BEGIN
       PRINT,"% TRIPP_SHOW_ALL: RESTORING            "+saveFile
       restore, saveFile
       
       IF NOT exist(psdpeaksort) THEN psdpeaksort = maxpsd2dsort
       
;; --- calculate signisim's       
       clv  = 1. - fap    
       dim1 = size(psdpeaksort)
       dim2 = size(clv)
       IF dim2[0] EQ 0 THEN dim2[1] = n_elements(clv) ; dim2(1) # of clv values
       
       signisim      = dblarr(dim2[1])
       FOR i=0,dim2[1]-1 DO BEGIN    
           signisim[i] = psdpeaksort(long(clv[i]*(dim1[1]-1)))
       ENDFOR
       
       IF NOT EXIST(silent) THEN BEGIN
           PLOT,psdpeaksort
           IF NOT KEYWORD_SET(sigma) THEN oplot,[0,dim1[1]-1],[signisim[8],signisim[8]]
           IF     KEYWORD_SET(sigma) THEN oplot,[0,dim1[1]-1],[signisim[3],signisim[3]]
           IF NOT KEYWORD_SET(sigma) THEN print, $
             "% TRIPP_SHOW_ALL: FAP(90%): ",+strtrim(string(signisim[8]),2)
           IF     KEYWORD_SET(sigma) THEN print, $
             "% TRIPP_SHOW_ALL: FAP(2 sigma): ",+strtrim(string(signisim[3]),2)
       ENDIF
   ENDIF ELSE BEGIN
       PRINT,"% TRIPP_SHOW_ALL: NO FILE   : " + saveFile
       signisim = dblarr(18)
   ENDELSE
   
;; ----------------------------------------------------------    
;; ------ SEARCH FOR PERIODS USING SCARGLE   
;;   
;; --- smooth --- scsmooth=1 (default) means no smoothing
   tripp_smooth,(tclear-tclear[0])*86400.d0,fclear,scsmooth,time_s,flux_s
;; --- Scargle
;   TRIPP_SCARGLE,time_s,flux_s,om,psd,numf=numf,                     $
;    period=period,fap=fap,signi=signi,fmin=ft_min*1.e-6,fmax=ft_max*1.e-6    
;    TRIPP_2IN1SCARGLE,time_s,flux_s,om,psd,numf=numf,                     $
;      period=period,fap=fap,signi=signi,fmin=ft_min*1.e-6,fmax=ft_max*1.e-6    
   SCARGLE,time_s,flux_s,om,psd,numf=numf,                     $
     period=period,fap=fap,signi=signi,fmin=ft_min*1.e-6,fmax=ft_max*1.e-6    
   
   low = where(1.e6/period GE ft_min)
   high= where(1.e6/period LE ft_max)
   il  = max([low[0],0])
   ih  = high(n_elements(high)-1)
   
;; ----------------------------------------------------------    
;; --- SCARGLE SCREEN OUTPUT
;;
   !P.MULTI=[1,0,2,0,0]
   PLOT,period,psd, xrange = [1.e6/ft_max,1.e6/ft_min], xstyle=1, ticklen=0.01,   $
     title = "Period Spectrum" ,xtitle= 'period / s'  ,                           $
     yrange=[0,max([max(signisim),max(signi),max(psd[il:ih])])],xlog=xlog,ylog=ylog
   
   print,"% TRIPP_SHOW_ALL: Number of frequencies used: "+strtrim(string(numf),2)
   
   IF  NOT KEYWORD_SET(sigma) THEN helper=1 ELSE helper=2  
   FOR ll  = 0,17 DO BEGIN
       lstyle = 2
       IF helper EQ 1 THEN BEGIN
           IF (ll GT 8) THEN lstyle = 1 
           IF (ll EQ 0 OR ll EQ 4 OR ll EQ 8) THEN BEGIN
               lstyle = 5
               confi = str_sep(string(1-fap[ll]),'00')
               IF fap_horne EQ 1 THEN xyouts,1.e6/ft_max,signi   [ll],confi[0]
               IF fap_sim   EQ 1 THEN xyouts,1.e6/ft_max,signisim[ll],confi[0],color=150
           ENDIF
;        IF count EQ 1 THEN BEGIN
           IF fap_sim EQ 1 THEN BEGIN
               PLOTS,1.e6/ft_min,signisim[ll],linestyle=lstyle,color=150
               PLOTS,1.e6/ft_max,signisim[ll],/continue,linestyle=lstyle,color=150
           ENDIF           
;        ENDIF ELSE BEGIN
           IF fap_horne EQ 1 THEN BEGIN
               PLOTS,1.e6/ft_min,signi[ll],linestyle=lstyle
               PLOTS,1.e6/ft_max,signi[ll],/continue,linestyle=lstyle
           ENDIF
;        ENDELSE
       ENDIF
       IF helper EQ 2 THEN BEGIN 
           IF (ll GT 8) THEN lstyle = 1 
           IF (ll EQ 1 OR ll EQ 3 OR ll EQ 5) THEN BEGIN
               lstyle = 5
               confi = STRING(fix(.5+ll/2.))+" sigma"
               IF fap_horne EQ 1 THEN xyouts,1.e6/ft_max,signi   [ll],confi
               IF fap_sim   EQ 1 THEN xyouts,1.e6/ft_max,signisim[ll],confi,color=150
           ENDIF
;        IF count EQ 1 THEN BEGIN
           IF fap_sim EQ 1 THEN BEGIN
               PLOTS,1.e6/ft_min,signisim[ll],linestyle=lstyle,color=150
               PLOTS,1.e6/ft_max,signisim[ll],/continue,linestyle=lstyle,color=150
           ENDIF
;        ENDIF ELSE BEGIN
           IF fap_horne EQ 1 THEN BEGIN
               PLOTS,1.e6/ft_min,signi[ll],linestyle=lstyle
               PLOTS,1.e6/ft_max,signi[ll],/continue,linestyle=lstyle
           ENDIF
;        ENDELSE
           IF ll EQ 10 THEN ll=18
       ENDIF
   ENDFOR
   
   !P.MULTI=0

;; ----------------------------------------------------------    
;; --- POSTSCRIPT  OUTPUT OF FOURIER TRANSFORMS ---
;; --- (USING SCARGLE) AND LIGHTCURVE ---
;;    
;; --- ps-output file  
   psFile       =  fileName + "_all.ps"
   
   SET_PLOT,'ps',/copy
   DEVICE,filename = psFile,/landscape
   
   IF KEYWORD_SET(onepage) THEN !p.multi=[0,2,2]   

;; ----- Write Title Page    
   a       =[0,0]
   PLOT,a,ystyle=4,xstyle=4,/NODATA,XMARGIN=[0.,1.],YMARGIN=[0.,1.]
   
   XYOUTS,.0,1., "--------------------"
   XYOUTS,.0,.80,filename,CHARSIZE=3. 
   XYOUTS,.0,.75, "--------------------"
   XYOUTS,.0,.6, "Data Blocks used:"
   XYOUTS,.0,.55,"Filename:                  "+psFile
   XYOUTS,.0,.5, "Number of data points:    "+STRTRIM(STRING(nr+1),2)
   XYOUTS,.0,.45,"Timebase in seconds:      "+STRTRIM(STRING((tclear[nr]-tclear[0])*86400.d0),2)
   XYOUTS,.0,.4, "Est. cycletime in seconds:  "+STRTRIM(STRING(FIX(cycletime)),2)
   XYOUTS,.0,.35,"JD Start of observation:   24"+STRTRIM( STRING(tclear[0]),2 )
   XYOUTS,.0,.30,"Degree:                     "+STRTRIM(STRING(degree),2)
   XYOUTS,.0,.25, "Smoothing parameter:      "+STRTRIM(STRING(scsmooth),2)
   XYOUTS,.0,.0 ,"Notes: "+notes
   
   
;; ------ Plot Lightcurve
   PLOT,tclear[*]-tclear[0],fclear,title ="Lightcurve" ,ystyle=1,xtitle= 'time / JD'
   
;; ------ Plot Frequency Amplitude Spectrum
   
   PLOT,1.e6/period,psd, xrange = [ft_min,ft_max],xstyle=1, ticklen=0.01,                  $
     title = "Frequency Spectrum" ,xtitle= 'frequency / !7l!XHz',                          $
     yrange=[0,max([max(signisim),max(signi),max(psd[il:ih])])],xlog=xlog,ylog=ylog
   
   ;*
   IF  NOT KEYWORD_SET(sigma) THEN helper=1 ELSE helper=2  
   FOR ll  = 0,17 DO BEGIN
       lstyle = 2
       IF helper EQ 1 THEN BEGIN
           IF (ll GT 8) THEN lstyle = 1 
           IF (ll EQ 0 OR ll EQ 4 OR ll EQ 8) THEN BEGIN
               lstyle = 5
               confi = str_sep(string(1-fap[ll]),'00')
               IF fap_horne EQ 1 THEN xyouts,ft_min,signi   [ll],confi[0]
               IF fap_sim   EQ 1 THEN xyouts,ft_min,signisim[ll],confi[0],color=150
           ENDIF
;        IF count EQ 1 THEN BEGIN
           IF fap_sim EQ 1 THEN BEGIN
               PLOTS,ft_min,signisim[ll],linestyle=lstyle,color=150
               PLOTS,ft_max,signisim[ll],/continue,linestyle=lstyle,color=150
           ENDIF
;        ENDIF ELSE BEGIN
           IF fap_horne EQ 1 THEN BEGIN
               PLOTS,ft_min,signi[ll],linestyle=lstyle
               PLOTS,ft_max,signi[ll],/continue,linestyle=lstyle
           ENDIF
;        ENDELSE
       ENDIF
       IF helper EQ 2 THEN BEGIN 
           IF (ll GT 8) THEN lstyle = 1 
           IF (ll EQ 1 OR ll EQ 3 OR ll EQ 5) THEN BEGIN
               lstyle = 5
               confi = STRING(fix(.5+ll/2.))+" sigma"
               IF fap_horne EQ 1 THEN xyouts,ft_min,signi   [ll],confi
               IF fap_sim   EQ 1 THEN xyouts,ft_min,signisim[ll],confi,color=150
           ENDIF
;        IF count EQ 1 THEN BEGIN
           IF fap_sim EQ 1 THEN BEGIN
               PLOTS,ft_min,signisim[ll],linestyle=lstyle,color=150
               PLOTS,ft_max,signisim[ll],/continue,linestyle=lstyle,color=150
           ENDIF
;        ENDIF ELSE BEGIN
           IF fap_horne EQ 1 THEN BEGIN
               PLOTS,ft_min,signi[ll],linestyle=lstyle
               PLOTS,ft_max,signi[ll],/continue,linestyle=lstyle
           ENDIF
;        ENDELSE
           IF ll EQ 10 THEN ll=18
       ENDIF
   ENDFOR

    ;*
;; ------ Plot Period Amplitude Spectrum    
    PLOT,period,psd, xrange = [1.e6/ft_max,1.e6/ft_min], xstyle=1, ticklen=0.01, $
         title = "Period Spectrum" ,xtitle= 'period / s',                        $
         yrange=[0,max([max(signisim),max(signi),max(psd[il:ih])])],xlog=xlog,ylog=ylog
    ;*
   IF  NOT KEYWORD_SET(sigma) THEN helper=1 ELSE helper=2  
   FOR ll  = 0,17 DO BEGIN
       lstyle = 2
       IF helper EQ 1 THEN BEGIN
           IF (ll GT 8) THEN lstyle = 1 
           IF (ll EQ 0 OR ll EQ 4 OR ll EQ 8) THEN BEGIN
               lstyle = 5
               confi = str_sep(string(1-fap[ll]),'00')
               IF fap_horne EQ 1 THEN xyouts,1.e6/ft_max,signi   [ll],confi[0]
               IF fap_sim   EQ 1 THEN xyouts,1.e6/ft_max,signisim[ll],confi[0],color=150
           ENDIF
;        IF count EQ 1 THEN BEGIN
           IF fap_sim EQ 1 THEN BEGIN
               PLOTS,1.e6/ft_min,signisim[ll],linestyle=lstyle,color=150
               PLOTS,1.e6/ft_max,signisim[ll],/continue,linestyle=lstyle,color=150
           ENDIF
;        ENDIF ELSE BEGIN
           IF fap_horne EQ 1 THEN BEGIN
               PLOTS,1.e6/ft_min,signi[ll],linestyle=lstyle
               PLOTS,1.e6/ft_max,signi[ll],/continue,linestyle=lstyle
           ENDIF
;        ENDELSE
       ENDIF
       IF helper EQ 2 THEN BEGIN 
           IF (ll GT 8) THEN lstyle = 1 
           IF (ll EQ 1 OR ll EQ 3 OR ll EQ 5) THEN BEGIN
               lstyle = 5
               confi = STRING(fix(.5+ll/2.))+" sigma"
               IF fap_horne EQ 1 THEN xyouts,1.e6/ft_max,signi   [ll],confi
               IF fap_sim   EQ 1 THEN xyouts,1.e6/ft_max,signisim[ll],confi,color=150
           ENDIF
;        IF count EQ 1 THEN BEGIN
           IF fap_sim EQ 1 THEN BEGIN
               PLOTS,1.e6/ft_min,signisim[ll],linestyle=lstyle,color=150
               PLOTS,1.e6/ft_max,signisim[ll],/continue,linestyle=lstyle,color=150
           ENDIF
;        ENDIF ELSE BEGIN
           IF fap_horne EQ 1 THEN BEGIN
               PLOTS,1.e6/ft_min,signi[ll],linestyle=lstyle
               PLOTS,1.e6/ft_max,signi[ll],/continue,linestyle=lstyle
           ENDIF
;        ENDELSE
           IF ll EQ 10 THEN ll=18
       ENDIF
   ENDFOR

    ;*
    
;   ------ Make Fourier transform ;;auskommentiert seit 12/99
;                                 ;rebinning
;    rebinlc,(tclear-tclear(0))*86400.d0,fclear-1.,tnew,fnew,dt=tstep,/gaps
;                                ;fft
;    fastftrans, fnew,dft
;    fourierfreq,tnew,freq
;    
;   ------ Plot rebinnned Lightcurve    
;    PLOT,tnew,fnew,title = "Rebinned Lightcurve, time step = " $
;      +STRTRIM(STRING(tstep),2)+"s",ystyle=1,xtitle= 'time / s'
;    
;    
;   ------ Plot Fourier transform of rebinned lightcurve    
;    PLOT,1./freq,abs(dft), xrange = [1.e6/ft_max,1.e6/ft_min], title= $
;    "Fourier Transform of Rebinned Lightcurve" ,xtitle= 'period / s', ytitle= 'amplitude'
;    
    
;   ------
    !p.multi=0

    DEVICE,/close               
    SET_PLOT,'x',/copy
    
    
    PRINT,"% TRIPP_SHOW_ALL: CREATING FILE      : " + psFile
    

;; ---------------------------------------------------------
;; --- END ---
;;
    
END

;; -------------------------------------

