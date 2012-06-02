PRO PLOT_LC, time, rate, error,gaps=gaps, $
    title=title, ytitle=ytitle, xtitle=xtitle, psfile=psfile, $
    tolerance=tolerance, $
    _EXTRA=plot_extra

;+
; NAME: PLOT_LC
;
;
;
; PURPOSE: Plot of light curves read for XTE
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;          PLOT_LC, time, rate, [error],gaps=gaps,title=title,
;                   ytitle=ytitle, xtitle=xtitle, psfile=psfile,
;                   tolerance=tolerance
;
;
; INPUTS:
;          time - time sequence
;          rate - rate sequence
;
; OPTIONAL INPUTS:
;          error - error of rate
;          title, xtitle, ytitle - as in PLOT
;          psfile - postscript file to print result at
;          plot_extra - plot keywords for all segments to plot
;          tolerance  - defines how much data time difference may
;                       jitter to be recognized as continuous data
;                       stream without gaps. 
;                       Defined in time difference between two 
;                       data points.
;                       Default 10%.
;
; KEYWORD PARAMETERS:
;          gaps  - check time distance to get gaps between
;                  observations. These gaps will be ommited when
;                  plotting the lightcurve.
;                  This works only if the lightcurve is (mostly) even
;                  sampled. 
;
; OUTPUTS:
;         (postscript file)
;
;
;
; OPTIONAL OUTPUTS:
;       
;
; SIDE EFFECTS:
;        plot in current window result
;
;
;
; RESTRICTIONS:
;
; EXAMPLE:
;      plot_lc,time,rate,error,/gaps
;      -> plots rate vs. time with error, ommit gaps
;
; MODIFICATION HISTORY:
;      $Log: plot_lc.pro,v $
;      Revision 1.3  2002/05/16 14:29:21  goehler
;      - changes of dips/plot_lc.pro
;      - new gticut.pro for selecting gti ranges in lightcurves etc.
;
;      Revision 1.2  2002/03/08 13:52:09  goehler
;      added tolerance keyword to define gap recognition time distance
;
;
;-


; default description:
IF N_ELEMENTS(title) EQ 0 THEN title='Lightcurve'
IF N_ELEMENTS(xtitle) EQ 0 THEN xtitle='Time'
IF N_ELEMENTS(ytitle) EQ 0 THEN ytitle='counts'

; open postscript file if given:
IF N_ELEMENTS(psfile) NE 0 THEN open_print,/postscript,psfile


; default: no gaps -> start from index 0
; gap_index stores the indices where a gap starts(!)
; for convenience a gap start is added immediate after the last data
; point 
gap_index=[0]


; check gaps -> compute difference, take binning into account
IF KEYWORD_SET(gaps ) THEN BEGIN
    
;     binning   = floor(time[1]-time[0]) ; time binning 
    binning   = (time[1]-time[0]) ; time binning 
    if n_elements(tolerance) eq 0 then $
    tolerance = binning/10.    ; how much the binning may vary
                               ; default: 10% 

    ;; define time gaps:
    ;; -> where time is not sequence of binning of time distance:
    gap_index   = where((time-[0,time]) GE binning+tolerance)

 ENDIF 

; add gap at last element (plus 1)
gap_index=[gap_index,n_elements(time)]


;; plot frame:
plot,time,rate,  $
  title=title, $
  psym=10,    $
  xtitle=xtitle,ytitle=ytitle, /nodata, $
  yrange=[min(rate),max(rate)], _EXTRA=plot_extra

;; for each subset separated by gaps:
for i=0,n_elements(gap_index)-2 do begin
    disp_time=time[gap_index[i]:gap_index[i+1]-1]
    disp_rate=rate[gap_index[i]:gap_index[i+1]-1]
    oplot,disp_time,disp_rate,$
          _EXTRA=plot_extra

    ;; plot error if given:
    if n_elements(error) ne 0 then  begin        
        disp_error=error[gap_index[i]:gap_index[i+1]-1]
        jwoploterr,disp_time,disp_rate,disp_error
  endif

           
endfor


; close postscript file if opened:
IF N_ELEMENTS(psfile) NE 0 THEN close_print


END









