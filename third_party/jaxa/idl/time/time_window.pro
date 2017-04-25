
pro time_window, index, time0, time1, $                    ; input, output
        loud=loud,                    $
        _extra=_extra,  percent=percent, $                 ; expansion params
        ecs=ecs, $
	out_style=out_style, yohkoh=yohkoh, ccsds=ccsds, $ ; output formats
        utc_stop=utc_stop
;+
;   Name: time_window
;
;   Purpose: return time range of input indices - optionally expand/pad range
;
;   Input Parameters:
;      index - structure vector including any SSW time standard
;
;   Output Parameters:
;      time0, time1   - time range of 'index' including optional expansion
;  
;   Keyword Parameters:
;      XXX=NN , where XXX = {DAYS or HOURS or MINUTES or SECONDS}
;                            type and magnitude of time window expansion
;                            (pass to timegrid.pro via keyword inherit)
;                            one elem= +/-(NN), two elem= [-n0,+n1]
;
;      PERCENT=% - alternately expand time window as a %age of deltaT
;      OUT_STYLE - output time format for time0/time1 (see anytim.pro) def=ECS
;      LOUD - if set, print time range (default if no output params
;      utc_stop - if set, and 'mjd_stop' & 'time_stop' exist, use those
;                 as implied endtimes 
;
;   Calling Examples:
;      IDL> time_window,index, time0, time1                ; return range
;      IDL> time_window,index, time0, time1, hours=12      ; expand +/- NN hours
;      IDL> time_window,index, time0, time1, seconds=20    ; expand +/- NN secs
;      IDL> time_window,index, time0, time1, percent=10.   ; expand +/- 10%(dT)
;      IDL> time_window,index, time0, time1, min=45,/ccsds ; output in CCSDS
;      IDL> time_window,index, time0, time1, hours=[-12,48]; expand -12/+48 hours
;  
;   History:
;      19-November-1998 - S.L.Freeland - simplify a common 'fmt_timer' operation
;      26-July-2000     - S.L.Freeland - allow 2 element offset arrays
;                         ie, time_window,index,t0,t1, hours=[-12,24]
;      30-aug-2005      - S.L.Freeland - add /UTC_STOP keyword & function
;
;
;   Method:
;      calls fmt_timer (H.Hudson et al) and optionally timegrid to expand
;
;   Motivation:
;      often want to plot or access dbases with time range expanded around
;      some other time entries (center plot in larger time window, $
;      get data +/- some deltaT around center time, etc.)
;-
utc_stop=keyword_set(utc_stop) and required_tags(index,'mjd_stop,time_stop')

if utc_stop then begin
   strt=anytim(index,/utc_int)
   endt=strt
   endt.mjd=index.mjd_stop
   endt.time=index.time_stop
   fmt_timer,concat_struct(strt,endt),time0,time1,/noprint
endif else   fmt_timer,index,time0,time1,/noprint  ; use fmt_timer initially

if data_chk(_extra,/struct) then begin           ; expansion keyword set?
   ttype=(tag_names(_extra))(0)                  

   if is_member(ttype, 'days,hours,minutes,seconds',/wc,/ignore_case) then begin
;     S.L.F. 26-July - permit window offsets to be one or two elements
      forward=last_nelem(_extra.(0))
      backward=(_extra.(0))(0)      
      backward=([-backward,backward]) (n_elements(_extra.(0)) eq 2)
      es=execute('time1=timegrid(time1,' + ttype + '=forward)')  ; forward
      es=execute('time0=timegrid(time0,' + ttype + '=backward)') ; backward

   endif else box_message,['Unknown keyword: ' + ttype, $
	  'IDL>time_window, index, t0,t1, [days=dd, hours=hh, min=mm, secs=secs]']
endif  else  begin
   if keyword_set(percent) then begin             ; expand as percentage of dT
      dt=ssw_deltat(time0,time1,/hour)            ; deltaTime(hours)
      dhour=dt*.01*percent(0)                     ; delta(hours) to pad
      time_window,index,time0,time1,hour=dhour    ; recurse w/explicit keyword
   endif  
endelse

; ---- convert output to requested format --------- 
case 1 of
   data_chk(out_style,/string): out_style=out_style(0)     ; user specified
   keyword_set(yohkoh): out_style='yohkoh'                 ; "
   keyword_set(ccsds):  out_style='ccsds'
   keyword_set(ecs): out_style='ecs'                       ; 
   else: out_style='vms'                                   ; default
endcase
time0=anytim(time0,out_style=out_style)
time1=anytim(time1,out_style=out_style)

if keyword_set(loud) or n_params() le 1 then fmt_timer,[time0,time1]

return
end
