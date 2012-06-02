PRO PLOT_PERIOD,TIME,RATE,PERIOD,$
                CYCLELIST=CYCLELIST,PSFILE=PSFILE,BINNED=BINNED, $
                _EXTRA=EX

;+
; NAME:
;	PLOT_PERIOD
;
; PURPOSE:   
;	Plots a periodic data set stacked each period above the
;       other. Gaps are ommited. Period is aligned acording first
;       element of time array modulo period (i.e. first shown plot
;       always contains first time tag). 
;
; CATEGORY:
;	Timing
;
; CALLING SEQUENCE:
;	PLOT_PERIOD, TIME, RATE, PERIOD,                                $
;                    CYCLELIST=CYCLELIST, PSFILE=PSFILE, BINNED=BINNED, $
;                    _EXTRA=EX
;
; INPUTS:
;       TIME     : Float array containg time of each data point.
;       RATE     : Float array containing each data point. 
;                  The number of elements must equal to TIME. 
;
; OPTIONAL INPUT:
;       CYCLELIST: Integer array containing the index of desired 
;                  periods starting from zero. May be used to select 
;                  certain periods. 
;       PSFILE   : String. File name of postscript file to plot data
;                  into instead of displaying at the current window. 
;       _EXTRA   : All keywords are bypassed to the PLOT - procedure 
;                  internally used. 
;
; OPTIONAL KEYWORDS:
;       BINNED   : Assume data to be binned with a (almost) fix period and 
;                  try to acknowledge gaps which are not supported by 
;                  binnings.
;
; OUTPUTS:
;	Plot on window. 
;
; REVISION HISTORY:
;       Version 1.0, 2001/07/23, Eckart Goehler, Initial version.
;       Version 1.1, 2001/07/26, SLS, fine-tune postscript output
;       Version 1.2, 2002/01/06, Eckart Goehler, Also possible for
;       non-integer time intervals and time sequences which start not
;       at zero (time will be aligned at first time entry in time arry
;       modulo period). 
;
;-



  ; estimate maximal number of periods in data set:
  cycles=DOUBLE(CEIL((TIME[N_ELEMENTS(TIME)-1] - TIME[0])/PERIOD))

  ; border around plot (in respect to unit 1): 
  xborder=0.22
  yborder=0.1


  IF KEYWORD_SET(BINNED ) THEN BEGIN

    
;     binning   = floor(time[1]-time[0]) ; time binning 
     binning   = (time[1]-time[0]) ; time binning 
     tolerance = binning/100.      ; how much the binning may vary
     start_time = floor(time[0] / PERIOD) * PERIOD

     ; define time gaps:
     ; -> where time is not sequence of binning of time distance:
     gap_index   = where((time-[0,time]) GE binning+tolerance)-1
     gap_index   = gap_index[1:*]   ; remove first element
     time_gap    =TIME[gap_index]   ; subset of time, where gaps starts
     time_gap_end=time[gap_index+1]-binning ; subset of time, where gaps ends


     ; set for displaying rate/error at gap start/end = 0:
     disp_time=[time,time_gap,time_gap_end] - start_time
     disp_rate=[rate,replicate(0,n_elements(time_gap)*2)]

     ; and sort it: 
     sort_index=sort(disp_time)
     disp_time=disp_time[sort_index]
     disp_rate=disp_rate[sort_index]

  ENDIF ELSE BEGIN ; no binning -> use time/rate as is:

     disp_time=TIME - TIME[0]
     disp_rate=RATE

  ENDELSE


  ; only one period -> define degenerated cycle list:
  IF cycles LT 2 THEN cyclelist=0


  ; if no period numbers given -> look for non-empty one
  IF N_ELEMENTS(CYCLELIST) EQ 0 THEN BEGIN 

    cyclelist=0.    ; dummy element

    ; look for each cycle whether is empty (no time inside) or not:
    FOR i=0.D,cycles-1. DO BEGIN 
      IF N_ELEMENTS( $
        WHERE((i*PERIOD LE disp_time) $
               AND (disp_time LE (i+1.D)*PERIOD))) GT 1 $
        THEN cyclelist = [cyclelist,i]      ; not empty -> add index
    ENDFOR 

    ; remove first dummy element:
    cyclelist=cyclelist[1:n_elements(cyclelist)-1]

  ENDIF 

  

  num = DOUBLE(N_ELEMENTS(CYCLELIST)) ; number of actual to display periods

  ; print if filename given
  IF N_ELEMENTS(PSFILE) NE 0 THEN BEGIN
     SET_PLOT,"ps" 
     DEVICE, FILENAME=PSFILE, /portrait, $
        xsize=20,ysize=28,xoffset=0.5,yoffset=0 

  ENDIF ELSE ERASE  ; clear window:



  ; plot frame:
PLOT,DISP_TIME,DISP_RATE, XRANGE=[0.,PERIOD],                 $
    POSITION=[xborder/2,   1/(NUM+1) * (1-yborder) + yborder/2,  $
             (1-xborder/4),            (1-yborder) + yborder/2], $
    XSTYLE=1,                                                 $
    YSTYLE=4,                                                 $
    /NOERASE ,/NODATA,                                        $
      _EXTRA=ex

  ; plot sub-plots:
  FOR i=0.D,num-1. DO BEGIN 
;    print,[0,i/num,1,(i+1)/num]

    ind=dOUBLE(CYCLELIST[i]) ; index of period to be displayed
;    print,i, [I*PERIOD,(I+1)*PERIOD]
    PLOT, DISP_TIME-ind*PERIOD, DISP_RATE, XRANGE=[0,PERIOD],       $
      _EXTRA=ex,                                                    $
      POSITION=[xborder/2,     (i+1)/(NUM+1)*(1-yborder) + yborder/2,  $
                (1-xborder/4), (i+2)/(NUM+1)*(1-yborder) + yborder/2],$
      XSTYLE=5,                                         $
      YSTYLE=1,                                         $
      YTITLE="#"+strtrim(STRING(long(ind)),2),          $
      YTICKS=1,                                         $
      /NOERASE ,YRANGE=[MIN(RATE),MAX(RATE)]
  

  ENDFOR 




   ; close postscript file if used
   IF N_ELEMENTS(PSFILE) NE 0 THEN BEGIN
      DEVICE, /CLOSE 
      SET_PLOT,"x"
   ENDIF
 
  RETURN

END
