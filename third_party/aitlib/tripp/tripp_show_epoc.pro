@tripp_exist
PRO TRIPP_SHOW_EPOC, fileName, wc, degree = degree, smoothed = smoothed, $
                    ft_max = ft_max, ft_min = ft_min, p_min = p_min, p_max = p_max,$ 
                    nr_per = nr_per, nif = nif, $                 
                    scsmooth = scsmooth, notes = notes, nbins = nbins, sampling=sampling,$
                    period=period,om=om,psd=psd,xlog=xlog,ylog=ylog
;+
; NAME:
;	TRIPP_SHOW_EPOC
;
; PURPOSE:   
;       
;	Calculate epoc folding of reduced photometrical data obtained with
;       TRIPP_WRITE_FINAL from  several combined blocks (or a single one). 
;       Show processed data as lightcurve, and result of epoc folding
;       as obtained with epfold in one ps-File. 
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
;       TRIPP_SHOW_EPOC, fileName, wc
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
;       NBINS   : Number of Phase bins, default set by epfold
;
; OUTPUTS:
;   
;	PS file '*_all.PS' showing Fourier Transforms and Lightcurves
;       of unbinned and binned data block
;       file '*_PulsProfile' containing the normalized puls profile
;       over one phase   
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
;       Version 1.0, 2000/03, Stefan Dreizler
;       Version 1.1, 2001/02, SLS: - wc is not a necessary input any more  
;                                  - adapted to new epfold (period has
;                                    been replaced by maxchierg)
;                    2002/05, SLS, added approximate JD start of observation
;                             SLS, added print-out of period at which
;                                  pulse profile is calculated
;
;-
   
  on_error,2                    ;Return to caller if an error occurs
  loadct,39
   
;; ---------------------------------------------------------
;; --- READ DATA FROM INPUT FILE
;;
   PRINT," "
   PRINT,"% TRIPP_SHOW_EPOC: READING FILE       : " + fileName
   
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
   PRINT,"% TRIPP_SHOW_EPOCH: Using "+strtrim(string(wc),2)+$
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
   FOR i=1L,nr DO BEGIN
      tdiff[i-1]=(tclear[i]-tclear[i-1])*86400.d0
   ENDFOR
   cycletime = median(tdiff) 
;; ---  want to have sampled the shortest period at least twice and 
;; want to have sampled at least two full cycles of the longest period
   IF NOT EXIST(nr_per)   THEN nr_per = 2.
   IF NOT EXIST(p_max)    THEN  p_max = (tclear[nr]-tclear[0])*86400.d0/nr_per
   IF NOT EXIST(p_min)    THEN  p_min = 2*cycletime
   IF NOT EXIST(ft_min)   THEN ft_min = 1.e6/p_max
   IF NOT EXIST(ft_max)   THEN ft_max = 1.e6/p_min
   IF NOT EXIST(degree)   THEN degree = -1
   IF NOT EXIST(smoothed) THEN smoothed = 0
   IF NOT EXIST(scsmooth) THEN scsmooth = 1
   IF NOT EXIST(notes)    THEN notes   = " "
   IF NOT EXIST(nif)      THEN nif = 1.5*(tclear[nr]-tclear[0])*86400.d0/cycletime
   IF string(nif) NE 'horne' THEN numf=nif
      
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

;; ----------------------------------------------------------    
;; ------ SEARCH FOR PERIODS USING EPFOLD
;;   
;; --- smooth --- scsmooth=1 (default) means no smoothing
   tripp_smooth,(tclear-tclear[0])*86400.d0,fclear,scsmooth,time_s,flux_s
;; --- epfold
;;
;; changes to epfold by SB (2001/01): period is now maxchierg[0]
;    EPFOLD,time_s,flux_s,pstart=p_min,pstop=p_max,chierg=chierg1,   $
;      nbins=nbins,sampling=sampling,period=max_per,/chatty
;; new
   EPFOLD,time_s,flux_s,pstart=p_min,pstop=p_max,chierg=chierg1,   $
     nbins=nbins,sampling=sampling,/chatty,maxchierg=maxchierg
   max_per=maxchierg[0]
 
   period=chierg1[0,*]
   psd=chierg1[1,*]

;; ----------------------------------------------------------    
;; ------ GET PULS PROFILE
;;   
   pfold,time_s,flux_s,profile,period=max_per,nbins=nbins,/nogap
;; ----------------------------------------------------------    
;; --- SCREEN OUTPUT
;;
   plot,findgen(nbins)/float(nbins),profile,/ynozero,xtitle='phase',$
     title='puls profile at '+strtrim(string(max_per),2)+'s'
   
   !P.MULTI=[1,0,2,0,0]
   PLOT,chierg1[0,*],chierg1[1,*], xstyle=1, ystyle=1, $
     title = "Epoc Folding" ,xtitle= 'period / s',xlog=xlog,ylog=ylog 
   
   print,"% TRIPP_SHOW_EPOC: Number of frequencies used: "+strtrim(string(numf),2)
   
   !P.MULTI=0
;; ----------------------------------------------------------    
;; --- WRITE PULS PROFILE
   PRINT,"% TRIPP_SHOW_EPOC: CREATING FILE      : " +fileName+'_PulsProfile' 
   openw,unit,fileName+'_PulsProfile',/get_lun
   printf,unit,nbins
   FOR kk = 0,nbins-1 DO printf,unit,(findgen(nbins))[kk]/float(nbins),profile[kk]/max(profile)
   free_lun,unit
;; ----------------------------------------------------------    
;; --- POSTSCRIPT  OUTPUT OF FOURIER TRANSFORMS ---
;; --- (USING TRIPP_SCARGLE) AND LIGHTCURVE ---
;;    
;; --- ps-output file  
   psFile       =  fileName + "_epoc.ps"
   
   SET_PLOT,'ps',/copy
   DEVICE,filename = psFile,/landscape
   
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
   XYOUTS,.0,.35,"JD Start of observation:   24"+STRTRIM( STRING(tclear[0]),2)
   XYOUTS,.0,.30,"Degree:                     "+STRTRIM(STRING(degree),2)
   XYOUTS,.0,.25, "Smoothing parameter:      "+STRTRIM(STRING(scsmooth),2)
   XYOUTS,.0,.0 ,"Notes: "+notes
   
   
;; ------ Plot Lightcurve
   !p.multi=[0,1,2]
   PLOT,tclear[*]-tclear[0],fclear,title ="Lightcurve" ,ystyle=1,xtitle= 'time / JD'
   PLOT,findgen(nbins)/float(nbins),profile,/ynozero,xtitle='phase',$
     title='puls profile at period='+strtrim(string(max_per),2)+'s'
;   !p.multi=[0,1,2]
   !p.multi=0
   PLOT,chierg1[0,*],chierg1[1,*], xstyle=1, ystyle=1, $
     title = "Epoc Folding" ,xtitle= 'period / s',xlog=xlog,ylog=ylog    
   PLOT,1.D0/chierg1[0,*],chierg1[1,*], xstyle=1, ystyle=1, $
     title = "Epoc Folding" ,xtitle= 'frequency / Hz',xlog=xlog,ylog=ylog    

;   ------
    DEVICE,/close               
    SET_PLOT,'x',/copy
    
    
    PRINT,"% TRIPP_SHOW_EPOC: CREATING FILE      : " + psFile
    

;; ---------------------------------------------------------
;; --- END ---
;;
    
END

;; -------------------------------------

