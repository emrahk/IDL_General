;+
; Project     : SOHO - CDS
;
; Name        : XVALIDATE
;
; Purpose     : validates widget time strings
;
; Category    : operations, widgets
;
; Explanation :
;
; Syntax      : IDL> good=xvalidate(info,event)
;
; Inputs      : EVENT = event id of widget program calling XVALIDATE
;               INFO = structure with tags:
;               .WOPS1 - id of start time text widget
;               .WOPS2 - id of end time text widget
;               .OPS1  - current value of start time
;               .OPS2  - current value of end time
;
;
; Opt. Inputs : None
;
; Outputs     : GOOD = 1 if input times are valid (i.e, no weird
;               characters, and START time before END time)
;
; Opt. Outputs: None
;
; Keywords    : TRIM = # of characters to trim time string by
;             : TIME_CHANGE = 1 if time changed in either widget
;             : BYTAG = look for hardwired tagnames, otherwise assume
;                WOPS1, WOPS, OPS1, and OPS2 occupy tags 0,1,2,3
;             : DIFF = check that start/stop times are different
;             : DATE = print date only
;
; History     : Version 1,  21-Feb-1995,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

 function xvalidate,info,event,trim=trim,time_change=time_change,$
          bytag=bytag,diff=diff,date=date,_extra=extra,round_times=round_times

;-- validate input times in TEXT widgets

 diff=keyword_set(diff)
 if diff then $
  terr='Please ensure that START time is less than END time' else $
   terr='Please ensure that START time is less than or equal to END time' 

 time_change=0
 do_trim=0
 if exist(trim) then if trim gt 0 then do_trim=1

 if keyword_set(bytag)  then begin
  dtags=['WOPS1','WOPS2','OPS1','OPS2']
  atags=tag_names(info)
  itags=lonarr(4)
  for i=0,3 do itags(i)=where(dtags(i) eq atags,cnt)
  if (min(itags) eq -1)  then begin
   message,'invalid input structure' & return,0
  endif
 endif else itags=[0,1,2,3]

 string_in=datatype(info.(itags(2))) eq 'STR'
 ok_start=1
 old_start=anytim2utc(info.(itags(2)),/vms,date=date)
 widget_control,info.(itags(0)),get_value=in_string
 err=''
 stime_start=anytim2utc(in_string(0),err=err,/vms,date=date) 
 if err ne '' then begin
  xack,err,group=event.top,/modal,/icon
  ok_start=0
 endif

 ok_end=1
 old_end=anytim2utc(info.(itags(3)),/vms,date=date)
 widget_control,(info.(itags(1))),get_value=in_string
 err=''
 stime_end=anytim2utc(in_string(0),err=err,/vms,date=date)
 if err ne '' then begin
  xack,err,group=event.top,/modal,/icon
  ok_end=0
 endif

 good=(ok_start and ok_end)
 if good then begin
;help,'new',stime_start,stime_end

  ops1=anytim2tai(stime_start)
  ops2=anytim2tai(stime_end)
  if diff then chk=(ops1 ge ops2) else chk=(ops1 gt ops2)
  if chk then begin
   xack,terr,group=event.top,/icon
   good=0
  endif 
 endif
  
 if good then begin
  tstart=stime_start
  tend=stime_end
;  help,'old',anytim2utc(info.(itags(2)),/vms),anytim2utc(info.(itags(3)),/vms)

  time_change=(ops1 ne info.(itags(2))) or (ops2 ne info.(itags(3)))

  if string_in then begin
   ops1=anytim2utc(ops1,/vms,date=date)
   ops2=anytim2utc(ops2,/vms,date=date)
  endif
  info.(itags(2))=ops1
  info.(itags(3))=ops2
 endif else begin
  tstart=old_start
  tend=old_end
 endelse

 if do_trim then begin
  tstart=strmid(strtrim(tstart),0,trim)
  tend=strmid(strtrim(tend),0,trim)
 endif

 if keyword_set(round_times) then begin
  tstart=round_time(tstart,_extra=extra)
  tend=round_time(tend,_extra=extra)
 endif
 widget_control,info.(itags(0)),set_value=tstart
 widget_control,info.(itags(1)),set_value=tend

 return,good & end

