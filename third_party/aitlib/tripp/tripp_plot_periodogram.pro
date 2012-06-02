PRO tripp_plot_periodogram,time,flux,device,i1,i2,dataset,numf=numf,faps=faps,signisim=signisim, $
                           fap_horne=fap_horne,fap_sim=fap_sim,pmin=p_min,pmax=p_max,$
                           multiple=multiple,debug=debug
;+
; NAME:                   
;                          TRIPP_PLOT_PERIODOGRAM
;
;
;
; PURPOSE:                 
;                          help TRIPP_SINFIT make its plots
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
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
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
;       Version 1.0, 1999/07, Stefan Dreizler
;       Version 1.1, 2001/02, SLS, switched back to scargle from
;                             aitlib; keyword simfap not allowed any
;                             more
;                             debug handed down to scargle
;
;
;-

IF NOT EXIST(multiple)   THEN multiple = 0

IF device EQ 'x' THEN color1=40 ELSE color1=0
IF device EQ 'x' THEN color2=80 ELSE color2=0

    SET_PLOT,device,/copy
    !P.MULTI=[i1,0,i2,0,0]

    PRINT,"% TRIPP_PLOT_PERIODOGRAM: scargle of "+dataset+ "; device: "+device
;     TRIPP_2IN1SCARGLE,time,flux,om,psd,period=period,numf=numf,      $
;                fap=faps,signi=signi,simfap=faps,simsigni=signisim,pmin=p_min,pmax=p_max,multiple=multiple
    SCARGLE,time,flux,om,psd,period=period,numf=numf,      $
      fap=faps,signi=signi,$    ;simfap=faps,
      simsigni=signisim,pmin=p_min,pmax=p_max,multiple=multiple,debug=debug


    ; set limits FOR yrange    
    low = where(period GE p_min)
    high= where(period LE p_max)
    il  = max([low(0),0])
    ih  = high(n_elements(high)-1)

    IF n_elements(signisim) EQ 0 THEN signisim_max=0 ELSE $
      signisim_max=signisim

    PLOT,period,psd, xrange = [p_min,p_max], xstyle=1, xticklen=0.05, $
      title = "Period Spectrum "+dataset ,xtitle= 'period / s',ytitle='power',   $
      charsize=1.5,yrange=[0,max([max(signisim_max),max(signi),max(psd[il:ih])])]
    FOR ll = 0,n_elements(faps)-1 DO BEGIN
      lstyle = 2
      IF (ll GT 8) THEN lstyle = 1 
      IF (ll EQ 0 OR ll EQ 4 OR ll EQ 8) THEN BEGIN
        lstyle = 5
        confi = str_sep(string(1-faps[ll]),'00')
        xyouts,p_max,signi[ll],confi[0]
      ENDIF
      IF fap_horne EQ 1 THEN BEGIN
        PLOTS,p_max,signi[ll]   ,linestyle=lstyle,color=color1
        PLOTS,p_min,signi[ll]   ,/continue,linestyle=lstyle,color=color1
      ENDIF
      IF fap_sim   EQ 1 THEN BEGIN
        PLOTS,p_max,signisim[ll],linestyle=lstyle,color=color2
        PLOTS,p_min,signisim[ll],/continue,linestyle=lstyle,color=color2
      ENDIF
    ENDFOR
    
END
