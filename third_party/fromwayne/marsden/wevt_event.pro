pro wevt_event,ev
;********************************************************************
; Program handles the events for the event list widget. 
; For an explanation of event list variables see evt.pro
; First the common blocks:
;********************************************************************
common wcontrol,whist,wphapsa,wcalhist,wmsclr,warchist,wam,wevt,$
                wfit,wold
common basecom,base,idfold,beep,chc
common evt_parms,prms,prms_save,burst
common nai,arr,nai_only
common bary,ra,dec
;********************************************************************
; Now print some values and get the event type
;********************************************************************
wold = wevt.base
type = tag_names(ev,/structure)
widget_control,ev.id,get_value=value
if (ks(nai_only) eq 0)then nai_only = 0
if (type eq 'WIDGET_BUTTON') then begin
;********************************************************************
; If choosing data type set control variable
;********************************************************************
   if (value eq 'HISTOGRAM')then begin
      chc = 'h'
      widget_control,/destroy,wold
      wevt
   endif
   if (value eq 'PHA PSA')then begin
      chc = 'p'
      widget_control,/destroy,wold
      wevt
   endif
   if (value eq 'MULTISCALAR')then begin
      chc = 'm'
      widget_control,/destroy,wold
      wevt
   endif
   if (value eq 'P.R.S.')then begin
      chc = 'prs'
      widget_control,/destroy,wold
      wevt
   endif
;********************************************************************
; Control buttons.
;********************************************************************
   if (value eq 'DONE')then begin
      widget_control,/destroy,wold
      chc = 'done'
   endif
   if (value eq 'RESET')then begin
      prms = prms_save
      widget_control,/destroy,wold
      wevt
   endif
   z = chc eq 'p' 
   zz = chc eq 'h'
   zzz = chc eq 'prs'
   zzzz = chc eq 'pp'
   z4 = z or zz or zzz or zzzz
   if (value eq 'GO' and z4)then widget_control,/destroy,wold
   if (value eq 'GO' and chc eq 'm')then begin
      widget_control,/destroy,wold
      chc = 'm'
   endif 
   if (value eq 'GO' and chc eq 'mm')then begin
      widget_control,/destroy,wold 
      chc = 'm'
   endif 
   if (value eq 'GO' and chc eq 'mmm')then begin
      widget_control,/destroy,wold 
      chc = 'm'
   endif 
   if (value eq 'GO' and chc eq 'bary')then begin
      if (ks(ra) ne 0)then begin
         if (n_elements(prms) eq 5)then chc = 'prs' else chc = 'm'
      endif
      widget_control,/destroy,wold
   endif     
;********************************************************************
; Psuld Flag control variables.
;********************************************************************
   if (value eq 'PSULD ON ONLY' and chc eq 'h')then prms(3) = 1d
   if (value eq 'PSULD OFF ONLY' and chc eq 'h')then prms(3) = 0d
;********************************************************************
; Sodium Iodide event filter selected
;********************************************************************
   if (value eq 'NAI EVENTS ONLY')then begin
      if (ks(arr) eq 0)then get_nai
      nai_only = 1
   endif
;********************************************************************
; Barycenter correcting choice
;********************************************************************
   if (value eq 'BARYCENTER CORRECT?')then chc = 'bary'
   if (value eq 'CRAB IOC')then begin
       prms(0) = 29.8928716027569d
       prms(1) = -3.75857d-10
       prms(2) = 1.03d-20
       prms(3) = 120d
       prms(4) = 50103.000000065d
       print,'ENTERING IOC CRAB EPHEMERIS'
       chc = 'bary'
       ra = 83.6332d
       dec = 22.0145d
   endif
   if (value eq '1509 IOC')then begin
       prms(0) = 6.6284166684779d
       prms(1) = -6.74303d-11
       prms(2) = 1.99d-21
       prms(3) = 30d
       prms(4) = 49923.000000072d
       print,'ENTERING IOC PSR 1509-58 EPHEMERIS'
       chc = 'bary'
       ra = 228.48178d
       dec = -59.135983d
   endif
;********************************************************************
; Multiscalar detector choice
;********************************************************************
   if (value eq '4 DETECTORS')then prms(1) = 2
   if (value eq 'SUMMED DETECTORS')then prms(1) = 0
   if (value eq '64 PHA BINS')then begin
      prms(2) = 1
      chc = 'mm'
   endif
   if (value eq '8 PHA BINS')then begin
      prms(2) = 0
      chc = 'mm'
      widget_control,/destroy,wold
      wevt
   endif
   if (value eq '1 PHA BIN')then begin
      prms(2) = 0
      chc = 'mmm'
      widget_control,/destroy,wold
      prms = prms(0:4)
      wevt
   endif
endif
;********************************************************************
; Entering the parameters.
;********************************************************************
if (type eq 'WIDGET_SLIDER')then begin
   widget_control,ev.id,get_uvalue = index
   print,'Parameter ',index-1,' entered: ',double(value(0))
   prms(index-1) = double(value(0))
endif
if (type eq 'WIDGET_TEXT' or type eq 'WIDGET_TEXT_CH')then begin
   widget_control,ev.id,get_uvalue = index
   if (chc ne 'bary')then begin
      prms(index-1) = double(value(0))
      print,'Parameter ',index-1,' entered: ',double(value(0))
   endif else begin
      if (index eq 1)then begin
         ra = double(value(0)) 
         print,'R.A. ',ra,' DEGREES ENTERED'
      endif else begin
         dec = double(value(0))
         print,'DEC ',dec,' DEGREES ENTERED'
      endelse
   endelse
endif
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end
